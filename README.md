# MSK GiveVehicle

Give, spawn, delete & manage vehicles through an **in-game admin dashboard**
(React NUI, MSK design). Everything that used to be an in-game slash command now
happens in the dashboard. The server-console commands stay available.

`msk_garage`-specific features (target-garage selection, garage filter/column,
"move to garage") only appear when `msk_garage` is started.

## Admin Dashboard ##
Open it in-game with the configurable command (default `/givevehadmin`).

Access is gated by the permission system:
* `group.admin` always has every right.
* `group.user` can **never** open the dashboard.
* Any other group must be listed under **dashboard groups** *and* be granted at
  least one right in the **Permissions** tab.

Tabs (shown based on your rights):
* **Give Vehicle** — pick an online player, category, model, optional plate, and
  (with msk_garage) a target garage.
* **Job Vehicle** — same, plus a job and the owner (player vs. job/society).
* **Vehicles** — server-side filtered & paginated browser over `owned_vehicles`
  (search by plate / owner / name, filter by type and garage). Per-row actions:
  spawn to a player, delete, and (with msk_garage) move to another garage.
* **Item Vehicles** — manage the usable item-vehicles (DB-backed).
* **Settings** — language, debug, version checker, fuel system, plate format,
  vehicle keys (auto give/remove + key script), dashboard command, theme.
* **Permissions** — per-group rights matrix + dashboard-group whitelist.

The first start seeds the DB from `config.lua`; after that the dashboard is the
source of truth (settings, items and permissions are live-editable without a
restart). Three tables are created automatically:
`msk_givevehicle_settings`, `msk_givevehicle_permissions`, `msk_givevehicle_items`.

### Vehicle keys ###
When enabled in Settings, a key is automatically **given** on give/spawn and
**removed** on delete, using the selected key script. The active script is
auto-detected at runtime (`msk_vehiclekeys`, `VehicleKeyChain`, `vehicles_keys`).

## Console Command Usage ##
The server-console commands are unchanged:
```lua
-- PLATE is OPTIONAL
_giveveh <playerID> <categorie> <carModel> <plate>
> Example: _giveveh 1 car zentorno "LS 1234"

-- BOOL = 1 (owner = job) or 0 (owner = player identifier) ; PLATE is OPTIONAL
_givejobveh <playerID> <categorie> <carModel> <job> <bool> <plate>
> Example: _givejobveh 1 car zentorno police 1 "LS 1234"

_delveh <plate>
> Example: _delveh "LS 1234"

-- Spawns an owned vehicle at the player's coords
spawnveh <playerID> <plate>
> Example: spawnveh 1 "LS 1234"
```

## Performance ##
The vehicle browser is built for large servers (3000+ rows): owner/plate filters
run in SQL with `LIMIT`/`OFFSET` pagination and never load the whole table. For
best performance add an index on the owner column:
```sql
ALTER TABLE `owned_vehicles` ADD INDEX `idx_owner` (`owner`);
```

## Requirements ##
* [ESX Legacy](https://github.com/esx-framework/esx_core)
* [oxmysql](https://github.com/overextended/oxmysql)
* [msk_core](https://github.com/Musiker15)
* Optional: a vehicle-key script (`msk_vehiclekeys` / `VehicleKeyChain` / `vehicles_keys`)
* Optional: `msk_garage` (enables garage selection / move)

## Building the NUI ##
The built UI is committed in `html/` — the server needs no npm. To change the UI:
```bash
cd web
npm install
npm run build   # outputs to ../html
npm run dev     # browser dev (devMock makes every tab/action clickable)
```
