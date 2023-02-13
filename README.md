# msk_givevehicle
Give Vehicles with Command or Item and Delete Vehicles with Command

## Ingame Command Usage ##
```lua
-- PLATE is OPTIONAL

/giveveh <playerID> <categorie> <carModel> <plate>

> Example: /giveveh 1 car zentorno "LS 1234"
> Example: /giveveh 1 boat dinghy "LS 1234"
> Example: /giveveh 1 aircraft cuban800 "LS 1234"
> Example: /giveveh 1 helicopter maverick "LS 1234"
```
```lua
-- PLATE is OPTIONAL
-- BOOL = '1' or '0' // 1 means identifier = job // 0 means identifier = xPlayer.identifier

/givejobveh <playerID> <categorie> <carModel> <job> <bool> <plate>

> Example: /givejobveh 1 car zentorno 'police' '1' "LS 1234"
> Example: /givejobveh 1 boat dinghy 'police' '1' "LS 1234"
> Example: /givejobveh 1 aircraft cuban800 'police' '1' "LS 1234"
> Example: /givejobveh 1 helicopter maverick 'police' '1' "LS 1234"
```
```lua
/delveh <plate>

> Example: /delveh "LS 1234"
```

## Console Command Usage ##
```lua
-- PLATE is OPTIONAL

_giveveh <playerID> <categorie> <carModel> <plate>

> Example: _giveveh 1 car zentorno LS 1234
> Example: _giveveh 1 boat dinghy LS 1234
> Example: _giveveh 1 aircraft cuban800 LS 1234
> Example: _giveveh 1 helicopter maverick LS 1234
```
```lua
-- PLATE is OPTIONAL
-- BOOL = '1' or '0' // 1 means identifier = job // 0 means identifier = xPlayer.identifier

_givejobveh <playerID> <categorie> <carModel> <job> <bool> <plate>

> Example: _givejobveh 1 car zentorno 'police' '1' LS 1234
> Example: _givejobveh 1 boat dinghy 'police' '1' LS 1234
> Example: _givejobveh 1 aircraft cuban800 'police' '1' LS 1234
> Example: _givejobveh 1 helicopter maverick 'police' '1' LS 1234
```
```lua
_delveh <plate>

> Example: _delveh LS 1234
```
## Requirements ##
* [ESX 1.2 and above](https://github.com/esx-framework/esx_core)
* [oxmysql](https://github.com/overextended/oxmysql)
