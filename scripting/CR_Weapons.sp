#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <custom_rounds>

#include PTaH

#pragma newdecls required

ArrayList	g_hWeapons[MAXPLAYERS+1];

char		g_sWeapons[256];

bool		g_bBlock,
			g_bNoWeapons,
			g_bNoKnife,
			g_bSave,
			g_bSaved[MAXPLAYERS+1];

int			m_iItemDefinitionIndex = -1,
			g_iClearMap;

public Plugin myinfo = 
{
	name = "[CR] Weapons",
	author = "Fr4nch",
	version = "1.1.3",
	url = "https://vk.com/fr4nch | https://github.com/fr0nch"
};

public void OnPluginStart() 
{ 
	if(GetEngineVersion() != Engine_CSGO) 
		SetFailState("This plugin only for CS:GO");
	
	for (int i = 1; i <= MaxClients; ++i)
		if(IsClientInGame(i))
			OnClientPutInServer(i);

	m_iItemDefinitionIndex = FindSendPropInfo("CEconEntity", "m_iItemDefinitionIndex");
}

public void OnClientPutInServer(int iClient)
{	
	g_bSaved[iClient] = false;
	g_hWeapons[iClient] = new ArrayList(ByteCountToCells(24));
	SDKHook(iClient, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public void OnClientDisconnect(int iClient)
{
	if(g_hWeapons[iClient]) delete g_hWeapons[iClient];
	g_bSaved[iClient] = false;
}

public void CR_OnRoundStart(KeyValues Kv)
{
	if (Kv)
	{
		KvGetString(Kv, "weapons", g_sWeapons, sizeof(g_sWeapons));			// Ключ `weapons` в который нужно вписать оружия, которые нужно выдавать
		g_bBlock		= view_as<bool>(Kv.GetNum("block_weapons", 0));		// Не работает, если нет оружий в ключе `weapons`
		g_bNoWeapons	= view_as<bool>(Kv.GetNum("no_weapons", 0));		// Очищает игроков от оружия
		g_bNoKnife 		= view_as<bool>(Kv.GetNum("no_knife", 0));			// Очищает оружие, и блокирует ножи, если есть оружия в ключе `weapons`
		g_bSave	 		= view_as<bool>(Kv.GetNum("save_weapons", 1));		// Сохраняет оружия игрока перед нестандартным раундом
		g_iClearMap		= Kv.GetNum("clear_map", 0);						// Очищает карту от оружия | 1 - очищает в начале раунда | 2 - очищает в конце раунда | 3 - очищает в начали и конце раунда
	
		if (g_iClearMap == 1 || g_iClearMap == 3)
		{
			CreateTimer(1.5, ClearMapTimer);
		}
	}
	else
	{
		if (g_bBlock)
		{
			g_bBlock = false;
		}
	}
}

Action ClearMapTimer(Handle timer)
{
	ClearMap();
	//PrintToConsole(0, "#######    Карта очищена от оружия!    #######"); // Дебаг
}

public void CR_OnPlayerSpawn(int iClient, KeyValues Kv)
{
	if(!CR_IsCustomRound() && g_hWeapons[iClient].Length != 0 && g_bSaved[iClient])
	{
		ClearWeapons(iClient);
		RequestFrame(GiveSavedWeapons, iClient);
	}
	if(Kv)
	{
		//PrintToChat(iClient, "g_bSaved: %b", g_bSaved[iClient]);
		//PrintToChat(iClient, "g_bSave: %b", g_bSave);
		if(g_bNoWeapons || g_sWeapons[0]) ClearWeapons(iClient);
		if(g_sWeapons[0]) RequestFrame(GiveWeapons, iClient);
	}
}

public void CR_OnRoundEnd(KeyValues Kv)
{
	if(Kv)
	{
		for (int i = 1; i <= MaxClients; ++i)
		{
			if(IsClientInGame(i) && IsPlayerAlive(i))
			{
				ClearWeapons(i);

				if(g_bNoKnife)
					GivePlayerItem(i, "weapon_knife_t");

				FakeClientCommand(i, "use weapon_knife");
			}
		}

		if(g_iClearMap == 2 || g_iClearMap == 3) ClearMap();
	}
}

void ClearWeapons(int iClient)
{
	if(IsClientInGame(iClient) && !IsFakeClient(iClient) && IsPlayerAlive(iClient))
	{
		char sWeapon[24]; 

		for(int iEnt, i; i <= 3; ++i)
		{
			if(i == 2 && !g_bNoKnife) continue;
			while ((iEnt = GetPlayerWeaponSlot(iClient, i)) != -1)
			{
				RemovePlayerItem(iClient, iEnt);
				if (IsValidEdict(iEnt))
				{
					if (g_bSave && !g_bSaved[iClient])
					{
						GetWeaponName(iEnt, sWeapon, sizeof(sWeapon));
						if (StrEqual(sWeapon, "weapon_usp_silencer"))
						{
							FormatEx(sWeapon, sizeof(sWeapon), "weapon_silencer");
						}
						if(strcmp(sWeapon, "weapon_melee") == 0)
						{
							switch(GetEntData(iEnt, m_iItemDefinitionIndex, 2))
							{
								case 75: sWeapon = "weapon_axe";
								case 76: sWeapon = "weapon_hammer";
								case 78: sWeapon = "weapon_spanner";
							}
						}

						g_hWeapons[iClient].PushString(sWeapon);
						//PrintToChat(iClient, "Сохранило оружие! %s", sWeapon);
					}

					GetEdictClassname(iEnt, sWeapon, sizeof(sWeapon)); 
					if(StrContains(sWeapon, "weapon_", false) != -1)
						RemoveEntity(iEnt);     
				}
			}
		}

		if(g_bNoWeapons && !g_sWeapons[0]) FakeClientCommand(iClient, "use weapon_knife");
		if(!g_bSaved[iClient]) g_bSaved[iClient] = true;	
	}

}

void GiveWeapons(int iClient)
{
	if(IsClientInGame(iClient) && !IsFakeClient(iClient) && IsPlayerAlive(iClient))
	{
		char sWeapons[10][24];
		int count = ExplodeString(g_sWeapons, ",", sWeapons, sizeof(sWeapons), sizeof(sWeapons[]));
		for(int i; i < count; ++i)
		{
			TrimString(sWeapons[i]);
			if(!strcmp(sWeapons[i], "weapon_fists") || !strcmp(sWeapons[i], "weapon_axe") || !strcmp(sWeapons[i], "weapon_hammer") || !strcmp(sWeapons[i], "weapon_spanner"))
			{
				EquipPlayerWeapon(iClient, GivePlayerItem(iClient, sWeapons[i]));
				//LogMessage("ID: %i | Выдалось сохранённое оружие - %s", iClient, sWeapons[i]);
			}	
			else {
				GivePlayerItem(iClient, sWeapons[i]);
				RequestFrame(GiveFists, iClient);
			}
		}
	}
}

void GiveFists(int iClient)
{
	int iEnt = -1;
	if((iEnt = GetPlayerWeaponSlot(iClient, 2)) != -1)
	{
		char sWeapon[24];
		GetWeaponName(iEnt, sWeapon, sizeof(sWeapon));
		if(!strcmp(sWeapon, "weapon_fists"))
		{
			FakeClientCommand(iClient, "use weapon_fists");
			//PrintToConsole(0,sWeapon); // Дебаг
		}
	}
}

void GiveSavedWeapons(int iClient)
{	
	if (IsClientInGame(iClient) && !IsFakeClient(iClient) && IsPlayerAlive(iClient))
	{
		char sWeapon[24];		
		int size = GetArraySize(g_hWeapons[iClient]);
		for(int i = 0; i < size; ++i)
		{
			GetArrayString(g_hWeapons[iClient], i, sWeapon, sizeof(sWeapon));			
			if(!strcmp(sWeapon, "weapon_fists") || !strcmp(sWeapon, "weapon_axe") || !strcmp(sWeapon, "weapon_hammer") || !strcmp(sWeapon, "weapon_spanner"))
				EquipPlayerWeapon(iClient, GivePlayerItem(iClient, sWeapon));
			else {
				GivePlayerItem(iClient, sWeapon);
				//LogMessage("ID: %i | Выдалось сохранённое оружие - %s", iClient, sWeapon);
			}
			//PrintToChat(iClient, "Выдал сохранённое оружие.");
		}

		ClearArray(g_hWeapons[iClient]);
		g_bSaved[iClient] = false;
		//PrintToChat(iClient, "g_bSaved: %b", g_bSaved[iClient]);
	} 
	else { ClearArray(g_hWeapons[iClient]); g_bSaved[iClient] = false; }
}

void ClearMap()
{
	int iEnt = MaxClients+1;
	while ((iEnt = FindEntityByClassname(iEnt, "weapon_*")) != INVALID_ENT_REFERENCE)
	{
		if(GetEntPropEnt(iEnt, Prop_Data, "m_hOwnerEntity") == -1)
			RemoveEntity(iEnt);
	}
}

Action OnWeaponCanUse(int iClient, int iWeapon) 
{ 
	if(/*CR_IsCustomRound() &&*/ g_bBlock)
	{
		char sWeapon[24], sKnife[24];  
		GetWeaponName(iWeapon, sWeapon, sizeof(sWeapon));
		if (IsWeaponKnife(iWeapon))
			GetWeaponName(iWeapon, sKnife, sizeof(sKnife));
		if(StrEqual(sWeapon, sKnife, false) && !g_bNoKnife)
			return Plugin_Continue;
		if(StrContains(g_sWeapons, sWeapon, false) == -1)
			return Plugin_Handled;
	}
	return Plugin_Continue;
}

void GetWeaponName(int iEnt, char[] sBuff, int iBuffSize)
{
	CEconItemDefinition pItemDefinition = PTaH_GetItemDefinitionByDefIndex(GetEntProp(iEnt, Prop_Send, "m_iItemDefinitionIndex"));
	pItemDefinition.GetDefinitionName(sBuff, iBuffSize);
	// PrintToChatAll("Оружие - %s", sBuff);
}

bool IsWeaponKnife(int iWeapon){
	char sClass[8];
	GetEntityNetClass(iWeapon, sClass, sizeof(sClass));
	return strncmp(sClass, "CKnife", 6) == 0;
}