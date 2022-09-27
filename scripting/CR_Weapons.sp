#pragma semicolon 1

#include <sourcemod>
#include <custom_rounds>

#include <PTaH>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

int			m_iItemDefinitionIndex = -1,
			m_hMyWeapons = -1;

ArrayList	weapons_list[2],
			weapons_storage[MAXPLAYERS+1];

bool		weapons_block = false,
			weapons_save = false,
			weapons_no_knife = false;

int			weapons_clear_map = 0,
			weapons_no_equip_clear = 0;

public Plugin myinfo =
{
	name	= "[CR] Weapons Equipper",
	version	= "2.1.0",
	author	= "Fr4nch (vk.com/fr4nch)",
	url		= "vk.com/fr4nch | discord.gg/3Crc3nVDKa"
};

public void OnPluginStart() 
{
	if (GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("This plugin only for CS:GO");
	}

	m_iItemDefinitionIndex = FindSendPropInfo("CEconEntity", "m_iItemDefinitionIndex");
	m_hMyWeapons = FindSendPropInfo("CBasePlayer", "m_hMyWeapons");
	
	for (int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
}

/* * * * * * * * * * * * * 
	Clients
 * * * * * * * * * * * * */

public void OnClientPutInServer(int client)
{
	weapons_storage[client] = new ArrayList(ByteCountToCells(8));
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public void OnClientDisconnect(int client)
{
	delete weapons_storage[client];
	SDKUnhook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public void CR_OnPlayerSpawn(int client, KeyValues kv)
{
	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		if (kv)
		{
			if (weapons_save && weapons_no_equip_clear < 2)
			{
				SaveWeapons(client);
			}
			
			if (weapons_no_equip_clear < 2)
			{
				ClearWeapons(client);
			}
			
			GiveWeapons(client);

			if (weapons_list[0].Length == 0 || weapons_list[1].Length == 0)
			{
				FakeClientCommand(client, "use weapon_knife");
			}
		}
		else
		{
			if (weapons_storage[client].Length > 0)
			{
				ClearWeapons(client);
				GiveWeapons(client, true);
			}
		}
	}
}

Action OnWeaponCanUse(int client, int weapon) 
{
	if (weapons_block)
	{
		if (IsWeaponKnife(weapon) && weapons_no_knife == false)
		{
			return Plugin_Continue;
		}

		int item_def = GetWeaponDefinition(weapon, true);

		if (weapons_list[0].FindValue(item_def) == -1 && weapons_list[1].FindValue(item_def) == -1)
		{
			// LogMessage("Weapon \"%s\" is blocked.", GetWeaponName(item_def));
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

/* * * * * * * * * * * * * 
	Main
 * * * * * * * * * * * * */

public void CR_OnRoundStart(KeyValues kv)
{
	if (kv)
	{
		char buffer[256], weapons[10][24];

		for (int i = 0; i < 2; i++)
		{
			// Weapons
			weapons_list[i] = new ArrayList(); // 0 - Main weapons | 1 - Additional weapons for ignore

			kv.GetString((i == 0) ? "weapons" : "weapons_ignore", buffer, sizeof buffer);
			TrimString(buffer);

			if (buffer[0])
			{
				int count = ExplodeString(buffer, ",", weapons, sizeof weapons, sizeof weapons[]);

				// LogMessage("%s: %s", (i == 0) ? "weapons" : "weapons_ignore", buffer);
				
				for (int b; b < count; ++b)
				{
					weapons_list[i].Push(PTaH_GetItemDefinitionByName(weapons[b]).GetDefinitionIndex());
					// LogMessage("Added weapon in array: %s", weapons[b]);
				}
			}
		}

		// Additional parameters
		weapons_block			= view_as<bool>(kv.GetNum("weapons_block", 0));
		weapons_save			= view_as<bool>(kv.GetNum("weapons_save", 1));
		weapons_no_knife		= view_as<bool>(kv.GetNum("weapons_no_knife", 0));

		weapons_clear_map		= kv.GetNum("weapons_clear_map", 0);
		weapons_no_equip_clear	= kv.GetNum("weapons_no_equip_clear", 0);

		if (weapons_clear_map == 1 || weapons_clear_map == 3)
		{
			ClearMap();
		}
	}
}

public void CR_OnRoundEnd(KeyValues kv)
{
	if (kv)
	{
		weapons_list[0].Clear();
		weapons_list[1].Clear();

		for (int i = 1; i <= MaxClients; ++i)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i))
			{
				if (weapons_no_equip_clear == 0 || weapons_no_equip_clear == 2)
				{
					ClearWeapons(i);
				}

				if (weapons_no_knife)
				{
					EquipPlayerWeapon(i, GivePlayerItem(i, "weapon_knife"));
				}
				
				FakeClientCommand(i, "use weapon_knife");
			}
		}

		if (weapons_clear_map > 1)
		{
			ClearMap();
		}

		if (weapons_block)
		{
			weapons_block = false;
		}
	}
}

/* * * * * * * * * * * * * 
	Utils
 * * * * * * * * * * * * */

bool GiveWeapons(int client, bool saved = false)
{
	int count = (saved) ? weapons_storage[client].Length : weapons_list[0].Length;

	for (int i = 0; i < count; ++i)
	{
		int item = (saved) ? weapons_storage[client].Get(i) : weapons_list[0].Get(i);

		if (item == 69 || item == 75 || item == 76 || item == 78)
		{
			EquipPlayerWeapon(client, GivePlayerItem(client, GetWeaponName(item)));
			// LogMessage("Give weapon melee for %L: %s", client, GetWeaponName(item));
		}
		else
		{
			GivePlayerItem(client, GetWeaponName(item));
			// LogMessage("Give weapon for %L: %s", client, GetWeaponName(item));
		}
	}

	if (saved)
	{
		weapons_storage[client].Clear();
	}
}

void SaveWeapons(int client)
{
	if (weapons_storage[client].Length > 0)
	{
		return;
	}

	for (int i = 0; i < 64; i++)
	{
		int ent = GetEntDataEnt2(client, m_hMyWeapons + i * 4);

		if (ent != -1)
		{
			if (IsWeaponKnife(ent) && weapons_no_knife == false)
			{
				continue;
			}

			int weapon_def = GetWeaponDefinition(ent);
			weapons_storage[client].Push(weapon_def);

			// LogMessage("Weapon saved: %s", GetWeaponName(GetWeaponDefinition(ent)));
		}
	}
}

void ClearWeapons(int client)
{
	for (int i = 0; i < 64; i++)
	{
		int ent = GetEntDataEnt2(client, m_hMyWeapons + i * 4);

		if (ent != -1)
		{
			if (IsWeaponKnife(ent) && weapons_no_knife == false)
			{
				continue;
			}

			RemovePlayerItem(client, ent);

			if (IsValidEdict(ent))
			{
				RemoveEntity(ent);
			}

			// LogMessage("Weapon removed: %s", GetWeaponName(GetWeaponDefinition(ent, true)));
		}
	}
}

bool ClearMap()
{
	int ent = MaxClients+1;

	while ((ent = FindEntityByClassname(ent, "weapon_*")) != INVALID_ENT_REFERENCE)
	{
		if (GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity") == -1)
		{
			int item_def = GetWeaponDefinition(ent, true);

			if (weapons_list[0].FindValue(item_def) == -1 && weapons_list[1].FindValue(item_def) == -1)
			{
				RemoveEntity(ent);
			}
		}
	}
}

bool IsWeaponKnife(int weapon)
{
	char class[8];
	GetEntityNetClass(weapon, class, sizeof class);
	return (strncmp(class, "CKnife", 6) == 0);
}

int GetWeaponDefinition(int ent, bool prop = false)
{
	return (prop) ? GetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex") : GetEntData(ent, m_iItemDefinitionIndex, 2);
}

char GetWeaponName(int item_def)
{
	char buffer[32];
	PTaH_GetItemDefinitionByDefIndex(item_def).GetDefinitionName(buffer, sizeof buffer);
	return buffer;
}