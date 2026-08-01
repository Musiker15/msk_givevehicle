export type AdminLocale = 'de' | 'en'

export interface AdminStrings {
  title: string
  close: string
  save: string
  cancel: string
  delete: string
  edit: string
  error: string
  saved: string
  // tabs
  tab_give: string
  tab_givejob: string
  tab_vehicles: string
  tab_items: string
  tab_settings: string
  tab_permissions: string
  // give
  player: string
  select_player: string
  search_player: string
  category: string
  model: string
  plate: string
  plate_optional: string
  plate_random_hint: string
  garage: string
  garage_optional: string
  garage_default: string
  none: string
  give: string
  give_vehicle: string
  give_job_vehicle: string
  job: string
  select_job: string
  owner: string
  owner_player: string
  owner_job: string
  give_hint: string
  no_player_selected: string
  delivered: string
  // vehicles / browse
  search: string
  search_placeholder: string
  filter_garage: string
  filter_type: string
  all_garages: string
  all_types: string
  model_filter: string
  status: string
  stored: string
  out: string
  actions: string
  spawn: string
  spawn_to: string
  move: string
  move_to: string
  refresh: string
  page_of: string
  prev: string
  next: string
  no_results: string
  no_results_hint: string
  confirm_delete_vehicle: string
  spawned: string
  moved: string
  deleted: string
  ownerless: string
  // ownership
  change_owner: string
  change_owner_title: string
  change_owner_hint: string
  current_owner: string
  owner_type: string
  owner_identifier: string
  owner_identifier_hint: string
  owner_job_none: string
  owner_changed: string
  // items
  create_item: string
  add_item: string
  item_id: string
  item_label: string
  item_model: string
  item_category: string
  confirm_delete_item: string
  no_items: string
  items_hint: string
  // settings
  general: string
  locale: string
  debug: string
  version_checker: string
  fuel_system: string
  fuel_hint: string
  plate_section: string
  plate_format: string
  plate_enable_prefix: string
  plate_prefix: string
  vehicle_keys: string
  vehicle_keys_hint: string
  enable: string
  key_script: string
  admin_command: string
  admin_command_hint: string
  colors: string
  colors_hint: string
  brand_tag: string
  color_accent: string
  color_bg: string
  color_panel: string
  color_text_primary: string
  color_text_secondary: string
  reset_colors: string
  // permissions
  dashboard_groups: string
  dashboard_groups_hint: string
  add_group: string
  group_name: string
  group_protected: string
  validate: string
  group_exists: string
  group_unknown: string
  confirm_delete: string
  // errors
  err_generic: string
  err_plate_exists: string
  err_no_target: string
  err_bad_model: string
  err_bad_job: string
  err_bad_id: string
  err_unknown_garage: string
  err_not_found: string
  err_type_mismatch: string
  err_delete_failed: string
  err_garage_unavailable: string
  err_bad_plate: string
  // perm labels
  perm_give: string
  perm_givejob: string
  perm_spawn: string
  perm_delete: string
  perm_move: string
  perm_owner: string
  perm_browse: string
  perm_items: string
  perm_settings: string
  perm_permissions: string
}

const en: AdminStrings = {
  title: 'GIVEVEHICLE ADMIN',
  close: 'Close',
  save: 'Save',
  cancel: 'Cancel',
  delete: 'Delete',
  edit: 'Edit',
  error: 'Error',
  saved: 'Saved',
  tab_give: 'Give Vehicle',
  tab_givejob: 'Job Vehicle',
  tab_vehicles: 'Vehicles',
  tab_items: 'Item Vehicles',
  tab_settings: 'Settings',
  tab_permissions: 'Permissions',
  player: 'Player',
  select_player: 'Select player',
  search_player: 'Search player…',
  category: 'Category',
  model: 'Model',
  plate: 'Plate',
  plate_optional: 'Plate (optional)',
  plate_random_hint: 'Leave empty for a random plate',
  garage: 'Garage',
  garage_optional: 'Target garage (optional)',
  garage_default: 'Default garage',
  none: 'None',
  give: 'Give',
  give_vehicle: 'Give Vehicle',
  give_job_vehicle: 'Give Job Vehicle',
  job: 'Job',
  select_job: 'Select job',
  owner: 'Owner',
  owner_player: 'Player',
  owner_job: 'Job / Society',
  give_hint: 'Delivers the vehicle to the player (stored in a garage).',
  no_player_selected: 'Select a player first.',
  delivered: 'Vehicle is being delivered.',
  search: 'Search',
  search_placeholder: 'Plate or owner / name…',
  filter_garage: 'Garage',
  filter_type: 'Type',
  all_garages: 'All garages',
  all_types: 'All types',
  model_filter: 'Model (exact)',
  status: 'Status',
  stored: 'Stored',
  out: 'Out',
  actions: 'Actions',
  spawn: 'Spawn',
  spawn_to: 'Spawn to',
  move: 'Move',
  move_to: 'Move to garage',
  refresh: 'Refresh',
  page_of: 'Page {0} / {1}',
  prev: 'Prev',
  next: 'Next',
  no_results: 'No vehicles found',
  no_results_hint: 'Adjust the filters and try again.',
  confirm_delete_vehicle: 'Permanently delete this vehicle from the database?',
  spawned: 'Vehicle spawned.',
  moved: 'Vehicle moved.',
  deleted: 'Vehicle deleted.',
  ownerless: '(no owner)',
  change_owner: 'Change owner',
  change_owner_title: 'Ownership',
  change_owner_hint: 'Society vehicles belong to the job instead of a player. Every member of the job can use them.',
  current_owner: 'Current',
  owner_type: 'Owned by',
  owner_identifier: 'Identifier (offline)',
  owner_identifier_hint: 'Only used when no online player is selected.',
  owner_job_none: '— no job —',
  owner_changed: 'Owner changed.',
  create_item: 'Create item vehicle',
  add_item: 'Add item',
  item_id: 'Item name',
  item_label: 'Label',
  item_model: 'Vehicle model',
  item_category: 'Category',
  confirm_delete_item: 'Delete this item vehicle?',
  no_items: 'No item vehicles yet.',
  items_hint: 'Players can use the item to get the vehicle delivered to a garage.',
  general: 'General',
  locale: 'Language',
  debug: 'Debug',
  version_checker: 'Version checker',
  fuel_system: 'Fuel system',
  fuel_hint: '“statebag” covers ox_fuel & msk_fuel. Use “custom” for the config.lua hook.',
  plate_section: 'License plate',
  plate_format: 'Format',
  plate_enable_prefix: 'Use prefix',
  plate_prefix: 'Prefix',
  vehicle_keys: 'Vehicle keys',
  vehicle_keys_hint: 'Auto-give a key on give/spawn and remove it on delete (auto-detected key script).',
  enable: 'Enable',
  key_script: 'Key script',
  admin_command: 'Dashboard command',
  admin_command_hint: 'In-game command that opens this dashboard.',
  colors: 'Colors',
  colors_hint: 'Live preview — changes apply on save.',
  brand_tag: 'Brand tag',
  color_accent: 'Accent',
  color_bg: 'Background',
  color_panel: 'Panel',
  color_text_primary: 'Text primary',
  color_text_secondary: 'Text secondary',
  reset_colors: 'Reset colors',
  dashboard_groups: 'Dashboard groups',
  dashboard_groups_hint: 'Groups (besides group.admin) allowed to open the dashboard. group.user is always blocked.',
  add_group: 'Add group',
  group_name: 'group name',
  group_protected: 'group.admin always has every right and cannot be edited.',
  validate: 'Validate',
  group_exists: 'A player with this group is online.',
  group_unknown: 'No online player in this group (still allowed).',
  confirm_delete: 'Are you sure?',
  err_generic: 'Error',
  err_plate_exists: 'Plate already exists.',
  err_no_target: 'Select a player first.',
  err_bad_model: 'Invalid model.',
  err_bad_job: 'Invalid job.',
  err_bad_id: 'Invalid item name.',
  err_unknown_garage: 'Unknown garage.',
  err_not_found: 'Vehicle not found.',
  err_type_mismatch: 'Vehicle type does not fit the garage.',
  err_delete_failed: 'Delete failed.',
  err_garage_unavailable: 'msk_garage is not running.',
  err_bad_plate: 'Invalid plate.',
  perm_give: 'Give vehicle',
  perm_givejob: 'Give job vehicle',
  perm_spawn: 'Spawn vehicle',
  perm_delete: 'Delete vehicle',
  perm_move: 'Move garage',
  perm_owner: 'Change owner',
  perm_browse: 'Browse vehicles',
  perm_items: 'Manage items',
  perm_settings: 'Manage settings',
  perm_permissions: 'Manage permissions',
}

const de: AdminStrings = {
  title: 'GIVEVEHICLE ADMIN',
  close: 'Schließen',
  save: 'Speichern',
  cancel: 'Abbrechen',
  delete: 'Löschen',
  edit: 'Bearbeiten',
  error: 'Fehler',
  saved: 'Gespeichert',
  tab_give: 'Fahrzeug geben',
  tab_givejob: 'Job-Fahrzeug',
  tab_vehicles: 'Fahrzeuge',
  tab_items: 'Item-Fahrzeuge',
  tab_settings: 'Einstellungen',
  tab_permissions: 'Berechtigungen',
  player: 'Spieler',
  select_player: 'Spieler wählen',
  search_player: 'Spieler suchen…',
  category: 'Kategorie',
  model: 'Modell',
  plate: 'Kennzeichen',
  plate_optional: 'Kennzeichen (optional)',
  plate_random_hint: 'Leer lassen für ein zufälliges Kennzeichen',
  garage: 'Garage',
  garage_optional: 'Ziel-Garage (optional)',
  garage_default: 'Standard-Garage',
  none: 'Keine',
  give: 'Geben',
  give_vehicle: 'Fahrzeug geben',
  give_job_vehicle: 'Job-Fahrzeug geben',
  job: 'Job',
  select_job: 'Job wählen',
  owner: 'Besitzer',
  owner_player: 'Spieler',
  owner_job: 'Job / Gesellschaft',
  give_hint: 'Liefert das Fahrzeug an den Spieler (in einer Garage abgestellt).',
  no_player_selected: 'Bitte zuerst einen Spieler wählen.',
  delivered: 'Fahrzeug wird ausgeliefert.',
  search: 'Suche',
  search_placeholder: 'Kennzeichen oder Besitzer / Name…',
  filter_garage: 'Garage',
  filter_type: 'Typ',
  all_garages: 'Alle Garagen',
  all_types: 'Alle Typen',
  model_filter: 'Modell (exakt)',
  status: 'Status',
  stored: 'Eingelagert',
  out: 'Draußen',
  actions: 'Aktionen',
  spawn: 'Spawnen',
  spawn_to: 'Spawnen an',
  move: 'Verschieben',
  move_to: 'In Garage verschieben',
  refresh: 'Aktualisieren',
  page_of: 'Seite {0} / {1}',
  prev: 'Zurück',
  next: 'Weiter',
  no_results: 'Keine Fahrzeuge gefunden',
  no_results_hint: 'Passe die Filter an und versuche es erneut.',
  confirm_delete_vehicle: 'Dieses Fahrzeug dauerhaft aus der Datenbank löschen?',
  spawned: 'Fahrzeug gespawnt.',
  moved: 'Fahrzeug verschoben.',
  deleted: 'Fahrzeug gelöscht.',
  ownerless: '(kein Besitzer)',
  change_owner: 'Besitzer ändern',
  change_owner_title: 'Besitzverhältnis',
  change_owner_hint: 'Society-Fahrzeuge gehören dem Job statt einem Spieler. Jeder Mitarbeiter des Jobs kann sie nutzen.',
  current_owner: 'Aktuell',
  owner_type: 'Gehört',
  owner_identifier: 'Identifier (offline)',
  owner_identifier_hint: 'Wird nur genutzt, wenn kein Online-Spieler gewählt ist.',
  owner_job_none: '— kein Job —',
  owner_changed: 'Besitzer geändert.',
  create_item: 'Item-Fahrzeug erstellen',
  add_item: 'Item hinzufügen',
  item_id: 'Item-Name',
  item_label: 'Bezeichnung',
  item_model: 'Fahrzeugmodell',
  item_category: 'Kategorie',
  confirm_delete_item: 'Dieses Item-Fahrzeug löschen?',
  no_items: 'Noch keine Item-Fahrzeuge.',
  items_hint: 'Spieler können das Item nutzen, um das Fahrzeug in eine Garage geliefert zu bekommen.',
  general: 'Allgemein',
  locale: 'Sprache',
  debug: 'Debug',
  version_checker: 'Versions-Check',
  fuel_system: 'Tank-System',
  fuel_hint: '„statebag“ deckt ox_fuel & msk_fuel ab. „custom“ nutzt den config.lua-Hook.',
  plate_section: 'Kennzeichen',
  plate_format: 'Format',
  plate_enable_prefix: 'Präfix verwenden',
  plate_prefix: 'Präfix',
  vehicle_keys: 'Fahrzeugschlüssel',
  vehicle_keys_hint: 'Schlüssel beim Geben/Spawnen automatisch vergeben und beim Löschen entfernen (Key-Script wird automatisch erkannt).',
  enable: 'Aktiviert',
  key_script: 'Key-Script',
  admin_command: 'Dashboard-Command',
  admin_command_hint: 'Ingame-Command, der dieses Dashboard öffnet.',
  colors: 'Farben',
  colors_hint: 'Live-Vorschau — Änderungen werden beim Speichern übernommen.',
  brand_tag: 'Brand-Tag',
  color_accent: 'Akzent',
  color_bg: 'Hintergrund',
  color_panel: 'Panel',
  color_text_primary: 'Text primär',
  color_text_secondary: 'Text sekundär',
  reset_colors: 'Farben zurücksetzen',
  dashboard_groups: 'Dashboard-Gruppen',
  dashboard_groups_hint: 'Gruppen (neben group.admin), die das Dashboard öffnen dürfen. group.user ist immer gesperrt.',
  add_group: 'Gruppe hinzufügen',
  group_name: 'Gruppenname',
  group_protected: 'group.admin hat immer alle Rechte und kann nicht bearbeitet werden.',
  validate: 'Prüfen',
  group_exists: 'Ein Spieler mit dieser Gruppe ist online.',
  group_unknown: 'Kein Online-Spieler in dieser Gruppe (trotzdem erlaubt).',
  confirm_delete: 'Bist du sicher?',
  err_generic: 'Fehler',
  err_plate_exists: 'Kennzeichen existiert bereits.',
  err_no_target: 'Bitte zuerst einen Spieler wählen.',
  err_bad_model: 'Ungültiges Modell.',
  err_bad_job: 'Ungültiger Job.',
  err_bad_id: 'Ungültiger Item-Name.',
  err_unknown_garage: 'Unbekannte Garage.',
  err_not_found: 'Fahrzeug nicht gefunden.',
  err_type_mismatch: 'Fahrzeugtyp passt nicht zur Garage.',
  err_delete_failed: 'Löschen fehlgeschlagen.',
  err_garage_unavailable: 'msk_garage ist nicht gestartet.',
  err_bad_plate: 'Ungültiges Kennzeichen.',
  perm_give: 'Fahrzeug geben',
  perm_givejob: 'Job-Fahrzeug geben',
  perm_spawn: 'Fahrzeug spawnen',
  perm_delete: 'Fahrzeug löschen',
  perm_move: 'Garage wechseln',
  perm_owner: 'Besitzer ändern',
  perm_browse: 'Fahrzeuge durchsuchen',
  perm_items: 'Items verwalten',
  perm_settings: 'Einstellungen verwalten',
  perm_permissions: 'Berechtigungen verwalten',
}

const STRINGS: Record<AdminLocale, AdminStrings> = { en, de }

export function strings(locale: string): AdminStrings {
  return STRINGS[(locale as AdminLocale)] || STRINGS.en
}

const PERM_LABELS: Record<string, keyof AdminStrings> = {
  'vehicle.give': 'perm_give',
  'vehicle.givejob': 'perm_givejob',
  'vehicle.spawn': 'perm_spawn',
  'vehicle.delete': 'perm_delete',
  'vehicle.move': 'perm_move',
  'vehicle.owner': 'perm_owner',
  'vehicle.browse': 'perm_browse',
  'items.manage': 'perm_items',
  'settings.manage': 'perm_settings',
  'permissions.manage': 'perm_permissions',
}

export function permLabel(t: AdminStrings, key: string): string {
  const k = PERM_LABELS[key]
  return k ? t[k] : key
}

export function fmt(s: string, ...args: (string | number)[]): string {
  return s.replace(/\{(\d+)\}/g, (_, i) => String(args[Number(i)] ?? ''))
}
