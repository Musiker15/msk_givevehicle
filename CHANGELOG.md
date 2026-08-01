# Changelog — msk_givevehicle

All notable changes to this script are documented here.

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
