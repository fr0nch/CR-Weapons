[CR] Weapons Equipper 2.0.0
===========================

**[CR] Weapons Equipper** - модуль ядра **[Custom Rounds](https://github.com/SomethingFromSomewhere/Custom-Rounds)**, который позволяет выдавать оружия во время кастомного раунда. <br/>
Данный модуль был разработан для того, чтобы заменить модуль **[[CR] Weapons](https://github.com/SomethingFromSomewhere/Custom-Rounds/blob/master/scripting/CR_Weapons.sp)**, т.к. этот работает не стабильно.

Поддерживаемые игры:
--------------------
Counter-Strike: Global Offensive

Требования:
----------------
- **[SourceMod 1.10 Stable](sourcemod.net/downloads.php?branch=stable) и выше.**
- **[Custom Rounds](https://github.com/SomethingFromSomewhere/Custom-Rounds) (не ниже версии 2.1, версия с HLmod не подойдёт)**
- **[PTaH](https://ptah.zizt.ru) (не ниже версии 1.1.3 build20)**

Настройки и примеры:
----------------
> <h3>Описание ключей настроек:</h3>

**`weapons`** - Ключ отвечает за выдачу оружия. Названия оружия нужно перечислять через знак **`,`** <br/>
- **`По умолчанию: ""`**

**`weapons_ignore`** - Ключ отвечает за спиок оружия, который будет игнорироваться при блокировке его подбора и очистки карты. Названия оружия нужно перечислять через знак **`,`** <br/>
- **`По умолчанию: ""`**

**`weapons_block`** - Ключ отвечает за блокировку поднятия оружия, которого нет в списке ключей **`weapons`** и **`weapons_ignore`** <br/>
- **`По умолчанию: 0`**

**`weapons_save`** - Ключ отвечает за сохранения уже имеющегося у игрока оружия, которое было получено не вовремя кастомного раунда, для того чтобы выдаеть его после прошедшего кастомного раунда <br/>
- **`По умолчанию: 1`**

**`weapons_no_knife`** - Ключ отвечает за блокировку и удаления у игрока ножа <br/>
- **`По умолчанию: 0`**

**`weapons_clear_map`** - Ключ отвечает за очистку карты от оружия <br/>
- **`По умолчанию: 0 | 1 - очищает в начале раунда | 2 - очищает в конце раунда | 3 - очищает в начали и конце раунда`**

<br/>

> <h3>Примеры настроек:</h3>

<details><summary>Раунд на кулаках</summary> 

```h
"Fists"
{
	"weapons"			"weapon_fists"
	"weapons_block"			"1"
	"weapons_no_knife"		"1"
	"weapons_clear_map"		"2"
}
```
</details>

<details><summary>Раунд на ножах</summary> 

```h
"Knifes"
{
	"weapons_block"			"1"
	"weapons_clear_map"		"2"
}
```
</details>

<details><summary>Раунд на AK-47</summary> 

```h
"AK-47"
{
	"weapons"			"weapon_ak47"
	"weapons_block"			"1"
	"weapons_clear_map"		"2"
}
```
</details>

<details><summary>Раунд на AWP, урон только в голову</summary> 

```h
"AWP - Headshot"
{
	"weapons"			"weapon_awp"
	"weapons_block"			"1"
	"weapons_clear_map"		"2"

	"only_head"			"1"
}
```

⚠️ Обратите внимание для того, чтобы был урон только в голову, нужен модуль **[[CR] Only HeadShot 2.0](https://github.com/theelsaud/CR-Only-HeadShot)**
</details>

<details><summary>Раунд на SSG-08 без прицела</summary> 

```h
"SSG-08 - No Zoom"
{
	"weapons"			"weapon_ssg08"
	"weapons_block"			"1"
	"weapons_clear_map"		"2"

	"no_zoom"			"1"
}
```

⚠️ Обратите внимание для того, чтобы был раунд без прицела, нужен модуль **[[CR] No Zoom 2.1](https://github.com/SomethingFromSomewhere/Custom-Rounds/blob/master/scripting/CR_No_Zoom.sp)**
</details>

<h3><a href="https://github.com/fr0nch/CR-Weapons/releases/">Перейти к скачиванию</a></h3>