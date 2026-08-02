# Changelog — msk_givevehicle

All notable changes to this script are documented here.

---

## [3.1.1] — 2026-08-01 — Dashboard Access on ESX, QBCore and Qbox

### Fixed

- **Admins could not open the dashboard even though their `server.cfg` gave them
  the group.** Two things were stacked on top of each other here. First, FiveM
  keeps principals and ace objects apart: a line like `add_principal
  identifier.license:xxx group.admin` only makes that player a *member* of the
  group, it does not create the ace object of the same name that the check was
  looking for. Unless someone had also written `add_ace group.admin group.admin
  allow` by hand, the check came back empty. Second, the frameworks do not even
  agree on how a group principal is named: ESX and Qbox use `group.admin`, QBCore
  uses `qbcore.admin`, and that is not something you can configure away, it is
  what `/addpermission` and `QBCore.Functions.AddPermission` write. QBCore also
  only ever links `qbcore.god` to `group.admin`, so anyone below god level was a
  member of no `group.*` principal at all. On ESX this often stayed invisible
  because the group from the `users` table caught it, and that fallback does not
  exist on QBCore. The script now registers its own ace object per group on start
  and points both spellings at it, for `admin`, for every group in
  `Config.dashboardGroups` and for every group in the permission matrix. So a
  plain `add_principal ... group.mod` and a `/addpermission 1 mod` both get you
  in, and groups you add on the Permissions tab are covered right away without a
  restart. *(fxmanifest.lua, server/admin/permissions.lua, server/admin/boot.lua,
  server/admin/api.lua)*
- **Checking a group name on the Permissions tab reported "not found" for brand
  new groups.** The check ran before the group existed as an ace object, so it
  could never find anyone in it. The group is registered first now.
  *(server/admin/api.lua)*

- **`Access denied for command add_ace` spam on every server start.** FiveM checks
  `add_ace` against the resource that runs it, and no resource holds that right by
  default, so the ace objects were never actually created. Every attempt was refused
  and only printed an error. On ESX this went unnoticed because the framework group
  caught it. The aces are registered through msk_core now, which is the one resource
  your server.cfg already grants that right, and the script checks up front whether it
  is allowed instead of spamming the console.
  *(server/admin/permissions.lua)*

### Requires msk_core 3.3.0

This release uses `MSK.AddRawAce` and `MSK.CanAddAce`, both added in msk_core 3.3.0.
Update msk_core along with this script, and make sure your server.cfg has the msk_core
ace lines. They are the ones the msk_core documentation has always listed and they
cover every MSK script at once:

```cfg
add_ace resource.msk_core command.add_ace allow
add_ace resource.msk_core command.remove_ace allow
add_ace resource.msk_core command.add_principal allow
add_ace resource.msk_core command.remove_principal allow
```

If they are missing nothing breaks, the script says so on start and group access falls
back to your framework group.

There is nothing to rebuild and no database change. Replace the resource files and
restart it.

---

## [3.1.0] — 2026-08-01 — Society Ownership for Existing Vehicles

### Added

- **Change the owner of a vehicle that already exists.** Until now a vehicle could
  only be made society owned at the moment it was handed out, through the
  **Job Vehicle** tab. Everything that was already in the database was stuck the way
  it had been created. The **Vehicles** tab now has a new row action (the building
  icon) that opens an **Ownership** dialog: pick **Player** or **Job / Society**,
  pick the job, and save. Society owned means the `owner` column holds the job name
  instead of a player identifier, exactly like `_givejobveh <...> 1` writes it, so
  ESX and msk_garage treat the row as a faction vehicle and every member of the job
  can use it. Switching back to a player works through the online player picker, or
  through a typed identifier when the owner is offline. *(server/main.lua,
  server/admin/api.lua, client/admin/nui.lua, web/src/admin/VehiclesTab.tsx,
  web/src/admin/i18n.ts, web/src/admin/AdminApp.tsx, web/src/admin/devMock.ts,
  html/\*\*)*
- **Society vehicles are visible at a glance.** The owner column in the vehicle
  browser shows a green **JOB / SOCIETY** badge instead of a player name whenever
  the row belongs to a job, and the ownership button of those rows is highlighted
  in the accent colour. *(web/src/admin/VehiclesTab.tsx)*
- **New permission `vehicle.owner`** ("Change owner" / "Besitzer ändern"), listed in
  the Permissions tab like every other right. `group.admin` gets it automatically.
  **Your own groups do not** — open the Permissions tab once, tick the new right for
  the groups that should have it and save. Without the right the button simply is
  not rendered, and the server refuses the call as well.
  *(shared/admin_perms.lua, web/src/admin/i18n.ts)*
- **New server console command `_setvehowner`**, so the console can do everything the
  dashboard can do, same as with every other action:

  ```text
  _setvehowner job police "ABC 123"
  _setvehowner player char1:abcd1234 "ABC 123"
  ```

  The command name is configurable through `Config.ConsoleCommands.setvehowner`.
  Older config files without that key keep working, the command then falls back to
  `_setvehowner`. *(config.lua, server/commands.lua)*

### Changed

- **Vehicle keys follow the owner.** When the ownership of a vehicle changes and
  `Config.VehicleKeys.enable` is on, every key for that plate is removed and a fresh
  key is handed to the new owner (player identifier or job name), through the same
  auto-detected key adapter that give and spawn already use. *(server/main.lua)*
- The **Vehicles** tab now also opens for admins who only hold `vehicle.owner` and
  none of the other vehicle rights. *(web/src/admin/AdminApp.tsx)*

### Notes

- Switching a player vehicle to society **overwrites the `owner` column**, so the
  original player identifier is gone afterwards. That is why the dialog has the
  identifier field, it is the way back for an owner who is not online.
- Setting the owner type to **Player** with the job left on "no job" clears the `job`
  column to a real `NULL`, which turns a faction vehicle back into a plain private
  vehicle.

### Changed files

```text
CHANGELOG.md
VERSION
fxmanifest.lua
config.lua
translation.lua
shared/admin_perms.lua
server/main.lua
server/commands.lua
server/admin/api.lua
client/admin/nui.lua
html/index.html
html/assets/*
web/package.json
web/src/admin/AdminApp.tsx
web/src/admin/VehiclesTab.tsx
web/src/admin/devMock.ts
web/src/admin/i18n.ts
```

---

## [3.0.0] — Admin Dashboard Rebuild

### Added

- **In-game admin dashboard** (`/adgiveveh`, command name configurable): give, spawn,
  delete and manage vehicles visually. The old in-game slash commands were replaced
  by it, the server console commands stayed.
- **Settings, permissions and item vehicles moved into the database**, seeded once
  from `config.lua` on first start and live-editable in the dashboard without a
  restart.
- **Group and permission system** with 9 rights (give / job-give / spawn / delete /
  move / browse / items / settings / permissions). `group.admin` always has
  everything, `group.user` can never open the dashboard, other groups are managed
  through a dashboard-group whitelist.
- **Vehicle browser** with server-side search and pagination, built for large
  servers: filter by owner, player name, plate, model or type without ever loading
  the whole `owned_vehicles` table.
- **Duplicate plate check** before every insert, with an error message instead of a
  broken entry.
- **Automatic vehicle keys** on give and spawn, removed on delete. The key script is
  auto-detected (msk_vehiclekeys / VehicleKeyChain / vehicles_keys) and can be
  toggled in Settings.
- **msk_garage integration**, only shown when msk_garage is running: pick a target
  garage when giving, filter the browser by garage and move a vehicle between
  garages. An empty target garage uses the msk_garage default garage for the
  vehicle's category.
- **Fuel system dropdown** (statebag / ox_fuel / msk_fuel / LegacyFuel /
  qs-fuelstations / native / custom).
- **UI colour customization** with live preview, an editable brand tag and a
  language switch (DE / EN).

### Changed

- Switched the license to **LGPL-3.0**, same as msk_core.

---

## [2.0.4]

### Fixed

- Fixed the `delveh` command.

### Added

- Added support for msk_vehiclekeys.
