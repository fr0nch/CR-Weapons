<h3><b>CR Weapons</b></h3>

<a href="https://github.com/fr0nch/CR-Weapons/releases/"><b>Перейти к скачиванию</b></a>


>**weapons** - Ключ в который нужно вписать оружия, которые нужно выдавать. Названия оружий нужно перечислять через знак `,` <br />
> 
>**block_weapons** - Отвечает за блокировку любого оружия не прописанного в ключе `weapons`, если нет оружий в ключе `weapons`, то блокировка не будет работать. (По умолчанию: 0)<br />
> 
>**no_weapons** - Очищает игроков от оружия. (По умолчанию: 0) Не используйте его с ключём `weapons`<br />
> 
>**no_knife** - Очищает оружие, и блокирует ножи, если есть оружия в ключе `weapons`. (По умолчанию: 0)<br />
> 
>**save_weapons** - Сохраняет оружия игрока перед началом нестандартного раунда. (По умолчанию: 1)<br />
> 
>**clear_map** - Очищает карту от оружия. (По умолчанию: 0) | 1 - очищает в начале раунда | 2 - очищает в конце раунда | 3 - очищает в начали и конце раунда<br />

**Пример:**
```
"Scout Only"
{
	"weapons"		"weapon_ssg08"
	"block_weapons"		"1"
}

"Knifes"
{
	"block_weapons"		"1"
	"no_weapons"		"1"
}
  
"Fists"
{
	"weapons"		"weapon_fists"
	"block_weapons"		"1"
	"no_knife"		"1"
}
```
