# [FREE] MSK GiveVehicle - Give & manage vehicles from an in-game Admin Dashboard

Hey everyone! 👋

A while ago `msk_givevehicle` was a small command/item script to hand vehicles to players. With **v3.0.0** I rebuilt it from the ground up: everything now runs through a clean **in-game admin dashboard** instead of typing commands. No more remembering argument order, no more typos in plates — you just point and click.

The old in-game slash commands are gone (replaced by the dashboard), but the **server console commands stay**, so your automations and external tools keep working exactly as before.

It's **completely free and open source** (LGPL-3.0).

---

## Preview

[details="📷 Click to expand screenshots"]

![MSK GiveVehicle – Give Vehicle tab|690x462](upload://8BI1z32la7KwhcYOScz7kpUKn3i.png)

![MSK GiveVehicle – Give Job Vehicle tab|690x461](upload://wcjBQUYP4q1vkSrXvchZCchCDvs.png)

![MSK GiveVehicle – Vehicle browser|689x461](upload://lKVoLIRoLP59gOfoqFx1UgL2nGd.png)

![MSK GiveVehicle – Settings|528x500](upload://pNvmAkILjXrWO2OQXyzwuEXUNTw.png)

![MSK GiveVehicle – Permissions|528x500](upload://4nGAhDvtasIOM4rjgSTnuGYaXbt.png)

![MSK GiveVehicle – Move to garage|690x206](upload://uST4qxZZsDEv0Nmj45sYnrjxKxc.png)

[/details]

---

## What it does

Open the dashboard in-game (default `/adgiveveh`, name is configurable) and you get a tabbed interface:

- **Give Vehicle** — pick an online player from a searchable list, choose a category and model, set an optional plate, and (if `msk_garage` is running) a target garage. Leave the plate empty for a random one.
- **Job Vehicle** — same as above, plus a job and whether the vehicle is owned by the player or by the job/society.
- **Vehicles** — a full browser over your `owned_vehicles` table with **server-side search & pagination**. Built for big servers (3000+ vehicles): search by plate, owner identifier, player name or model, filter by type and garage — it never loads the whole table at once. Per-row actions: **spawn** to a player, **delete**, and (with `msk_garage`) **move to another garage**.
- **Item Vehicles** — manage the usable item-vehicles right in the dashboard (no config editing).
- **Settings** — language, debug, version checker, fuel system, plate format, vehicle keys, the dashboard command name, brand tag and a live color theme.
- **Permissions** — a per-group rights matrix and a dashboard-group whitelist.

Everything is **stored in the database and live-editable** — change a setting, a permission or an item and it applies instantly, no restart needed. On the very first start the script seeds the database from your `config.lua`; after that the dashboard is the source of truth.

## Highlights

- 🔐 **Group & permission system** — 9 rights (give / job-give / spawn / delete / move / browse / items / settings / permissions). `group.admin` always has everything, `group.user` can never open the dashboard, every other group is configurable. Works with your server.cfg ACE groups **and** ESX framework groups.
- 🅿️ **Plate duplicate check** — every give checks for an existing plate before inserting and aborts with a clear error instead of creating a broken vehicle.
- 🔑 **Automatic vehicle keys** — a key is given on give/spawn and removed on delete. The active key script is auto-detected (`msk_vehiclekeys`, `VehicleKeyChain`, `vehicles_keys`) and can be toggled in Settings.
- ⛽ **Fuel system selector** — `statebag` (ox_fuel & msk_fuel), `LegacyFuel`, `qs-fuelstations`, native, or a custom hook.
- 🎨 **Live theming & language switch** — recolor the whole UI with a live preview, set your own brand tag, switch between English and German.
- 🖥️ **Console commands stay** — `_giveveh`, `_givejobveh`, `_delveh` and `spawnveh` work exactly like before.

## msk_garage integration (optional)

If `msk_garage` is running, extra features appear automatically (and stay hidden if it isn't):

- pick a **target garage** when giving a vehicle,
- a **garage column & filter** in the vehicle browser,
- **move a vehicle** from one garage to another,
- if you leave the target garage empty, the vehicle is placed in the **msk_garage default garage** for its category (land / sea / air).

---

## Performance note

The vehicle browser is designed for large servers. Owner/plate filters run in SQL with `LIMIT`/`OFFSET` pagination. For the best experience, add an index on the owner column:

```sql
ALTER TABLE `owned_vehicles` ADD INDEX `idx_owner` (`owner`);
```

## Installation

1. Make sure the dependencies are installed and started **before** the script.
2. Drop `msk_givevehicle` into your resources and `ensure msk_givevehicle`.
3. Start the server once — the three database tables are created and seeded automatically.
4. Open the dashboard in-game with `/adgiveveh` (configurable).

The built UI is included, so the server needs **no npm** — just drag & drop.

## Download & Docs

- 📦 **Download (free):** https://github.com/Musiker15/msk_givevehicle
- 🌐 **More MSK Scripts:** [www.msk-scripts.de](https://www.msk-scripts.de)

If you run into anything or have a feature request, drop a reply below or join the Discord — I read everything. ❤️

---

|                       |                                                                                    |
| --------------------- | ---------------------------------------------------------------------------------- |
| Code is accessible    | Yes                                                                                |
| Subscription-based    | No                                                                                 |
| Lines (approximately) | ~4,000                                                                             |
| Requirements          | [es_extended](https://github.com/esx-framework/esx_core), [oxmysql](https://github.com/overextended/oxmysql), [msk_core](https://github.com/MSK-Scripts/msk_core). **Optional:** [msk_garage](https://forum.cfx.re/t/release-msk-garage-impound-in-game-admin-dashboard-no-config-editing-esx-v5-0-0/5122014) + a [vehicle-key](https://forum.cfx.re/t/release-msk-vehiclekeys-unique-items-v2-0-0-esx-qbcore/5264475) script |
| Support               | Yes                                                                                |
