# Contributing to MSK GiveVehicle

Thanks for taking the time to contribute. MSK GiveVehicle gives admins a way to
give, spawn, delete and manage vehicles through an in-game dashboard, so most
changes touch either the server API, the permission system or the React NUI.
This guide explains how to report issues, suggest features and open pull
requests.

## Ways to contribute

* **Report a bug** using the bug report issue template.
* **Request a feature** using the feature request issue template.
* **Improve the docs** at [docu.msk-scripts.de](https://docu.msk-scripts.de).
* **Open a pull request** with a fix or a new feature.

If you just have a question or want to discuss an idea first, join the
[MSK Scripts Discord](https://discord.gg/5hHSBRHvJE).

## Before you start

* **Lua 5.4** is required (`lua54 'yes'` in the fxmanifest).
* The script targets **ESX Legacy** and talks to the framework through
  [msk_core](https://github.com/MSK-Scripts/msk_core). Do not call ESX directly
  where a `MSK.*` function exists.
* Database access goes through **oxmysql**. Queries over `owned_vehicles` must
  stay filtered and paginated in SQL, never load the whole table into Lua.
* Server-side validation is mandatory. Every dashboard action is gated by a
  permission check in `server/admin/api.lua`, and client input is never trusted.
* Support for `msk_garage` and for vehicle-key scripts is **optional at
  runtime**. Guard those code paths, the script has to keep working without them.

## Project layout

```
msk_givevehicle/
├── config.lua           seed values, the DB is the source of truth after first start
├── translation.lua      in-game languages
├── shared/              admin permission constants
├── client/
│   ├── main.lua
│   └── admin/           dashboard open, NUI callbacks, live sync
├── server/
│   ├── main.lua, items.lua, commands.lua
│   ├── keys/            vehicle-key adapters (init first, adapters register themselves)
│   ├── versionchecker.lua
│   └── admin/           store, permissions, seed, api, command, boot
└── web/                 React + Vite + TypeScript NUI, build committed to ../html
```

**Load order matters.** The server scripts are listed explicitly in
`fxmanifest.lua`, not by glob. `server/admin/boot.lua` has to stay last, it
depends on every admin file above it. A new file that is not listed there never
loads.

## Working on the NUI

The built UI is committed in `html/` so the server never needs npm.

```bash
cd web
npm install
npm run dev     # browser dev, devMock makes every tab and action clickable
npm run build   # outputs to ../html, commit the result
```

After any UI change, run `npm run build` and commit the updated `html/`.

## Adding a language

Languages are two-stage. The in-game menu reads `translation.lua`, the dashboard
reads `web/src/admin/i18n.ts`. A new language has to go into **both**,
otherwise the dashboard silently falls back to the default language.

## Pull request checklist

1. Fork the repo and create a branch from `main`.
2. Keep your change focused. One feature or fix per pull request.
3. Match the existing code style (naming, indentation, comment density).
4. New server files are added to `fxmanifest.lua` in the right position, with
   `server/admin/boot.lua` still last.
5. Test with ESX, and with `msk_garage` both started and stopped if your change
   touches garage handling.
6. If you changed the NUI, rebuild and commit `html/`.
7. Update `CHANGELOG.md` and the documentation if behavior, config or the DB
   schema changed.
8. Fill out the pull request template.

## Reporting security issues

Please do not open public issues for security vulnerabilities. See
[SECURITY.md](SECURITY.md) for how to report them privately.

## License

By contributing, you agree that your contributions will be licensed under the
project's **LGPL-3.0-or-later** license. See [LICENSE](../LICENSE).
