# Graph Report - .  (2026-08-01)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 242 nodes · 444 edges · 27 communities
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 19 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `52ee7a17`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- SettingsTab.tsx
- main.lua
- AdminApp.tsx
- types.ts
- compilerOptions
- api.lua
- permissions.lua
- package.json
- devDependencies
- store.lua

## God Nodes (most connected - your core abstractions)
1. `compilerOptions` - 16 edges
2. `AdminApi.BuildBootstrap()` - 11 edges
3. `errText()` - 11 edges
4. `AdminBootstrap` - 10 edges
5. `plateForms()` - 9 edges
6. `applyTheme()` - 9 edges
7. `AdminPerms.GetPlayerPerms()` - 8 edges
8. `AdminPerms.PlayerInGroup()` - 7 edges
9. `AdminStrings` - 7 edges
10. `fetchNui()` - 7 edges

## Surprising Connections (you probably didn't know these)
- `AdminApi.GroupsArray()` --calls--> `AdminPerms.AllPerms()`  [INFERRED]
  ../server/admin/api.lua → ../shared/admin_perms.lua
- `AdminApi.GaragesArray()` --calls--> `Core.GetGarages()`  [INFERRED]
  ../server/admin/api.lua → ../server/main.lua
- `AdminApi.BuildBootstrap()` --calls--> `AdminPerms.GetPlayerPerms()`  [INFERRED]
  ../server/admin/api.lua → ../server/admin/permissions.lua
- `AdminApi.BuildBootstrap()` --calls--> `Core.IsGarageRunning()`  [INFERRED]
  ../server/admin/api.lua → ../server/main.lua
- `AdminCommand.Register()` --calls--> `AdminPerms.CanOpen()`  [INFERRED]
  ../server/admin/command.lua → ../server/admin/permissions.lua

## Import Cycles
- None detected.

## Communities (27 total, 0 thin omitted)

### Community 0 - "SettingsTab.tsx"
Cohesion: 0.18
Nodes (30): GiveTab(), AdminLocale, AdminStrings, de, en, fmt(), PERM_LABELS, permLabel() (+22 more)

### Community 1 - "main.lua"
Cohesion: 0.13
Nodes (25): resolveGarage(), Items.Register(), Items.RegisterAll(), register(), current(), Keys.Active(), Keys.GiveKey(), Keys.HasKey() (+17 more)

### Community 2 - "AdminApp.tsx"
Cohesion: 0.16
Nodes (17): AdminApp(), TabId, STRINGS, SettingsTab(), App(), OpenAdminMessage, fetchNui(), isBrowser() (+9 more)

### Community 3 - "types.ts"
Cohesion: 0.12
Nodes (20): ALL_PERMS, browse(), handle(), MOCK_ROWS, OWNER_NAMES, snapshot(), state, BrowseResult (+12 more)

### Community 4 - "compilerOptions"
Cohesion: 0.09
Nodes (21): compilerOptions, allowImportingTsExtensions, isolatedModules, jsx, lib, module, moduleResolution, noEmit (+13 more)

### Community 5 - "api.lua"
Cohesion: 0.15
Nodes (13): AdminApi.Broadcast(), AdminApi.BuildBootstrap(), AdminApi.GaragesArray(), AdminApi.GroupsArray(), AdminApi.ItemsArray(), AdminApi.JobsList(), AdminApi.OnlinePlayers(), AdminApi.SanitizeItem() (+5 more)

### Community 6 - "permissions.lua"
Cohesion: 0.19
Nodes (15): AdminPerms.CanOpen(), AdminPerms.EnsureAce(), AdminPerms.EnsureAces(), AdminPerms.GetFrameworkGroup(), AdminPerms.GetPlayerPerms(), AdminPerms.GetQbPermission(), AdminPerms.GroupAce(), AdminPerms.Has() (+7 more)

### Community 7 - "package.json"
Cohesion: 0.10
Nodes (19): dependencies, @fontsource/open-sans, @fontsource/work-sans, lucide-react, react, react-dom, name, private (+11 more)

### Community 8 - "devDependencies"
Cohesion: 0.12
Nodes (17): autoprefixer, devDependencies, autoprefixer, postcss, tailwindcss, @types/react, @types/react-dom, typescript (+9 more)

### Community 9 - "store.lua"
Cohesion: 0.62
Nodes (6): AdminStore.LoadAll(), AdminStore.LoadItems(), AdminStore.LoadPermissions(), AdminStore.LoadSettings(), isEnabled(), jdecode()

## Knowledge Gaps
- **53 isolated node(s):** `name`, `private`, `version`, `type`, `dev` (+48 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AdminApi.BuildBootstrap()` connect `api.lua` to `main.lua`, `permissions.lua`?**
  _High betweenness centrality (0.035) - this node is a cross-community bridge._
- **Why does `Core.IsGarageRunning()` connect `main.lua` to `api.lua`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **Why does `AdminPerms.GetPlayerPerms()` connect `permissions.lua` to `api.lua`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **Are the 3 inferred relationships involving `AdminApi.BuildBootstrap()` (e.g. with `AdminPerms.GetPlayerPerms()` and `Core.IsGarageRunning()`) actually correct?**
  _`AdminApi.BuildBootstrap()` has 3 INFERRED edges - model-reasoned connections that need verification._
- **What connects `name`, `private`, `version` to the rest of the system?**
  _53 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `main.lua` be split into smaller, more focused modules?**
  _Cohesion score 0.12903225806451613 - nodes in this community are weakly interconnected._
- **Should `types.ts` be split into smaller, more focused modules?**
  _Cohesion score 0.11688311688311688 - nodes in this community are weakly interconnected._