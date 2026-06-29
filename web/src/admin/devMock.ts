// Browser dev mock. Lets `npm run dev` render and click through the whole
// dashboard without FiveM. Only loaded in dev + browser (see main.tsx).
import { DEFAULT_THEME } from '../lib/theme'
import type { AdminBootstrap, BrowseResult, BrowseRow } from './types'

const ALL_PERMS = {
  'vehicle.give': true, 'vehicle.givejob': true, 'vehicle.spawn': true, 'vehicle.delete': true,
  'vehicle.move': true, 'vehicle.browse': true, 'items.manage': true, 'settings.manage': true,
  'permissions.manage': true,
}

// Mutable in-memory state for the dev session. Every reply returns a fresh
// CLONE of this (see snapshot()) so React's referential-equality check sees a
// new object and re-renders — this is what makes the Settings language switch
// actually update the UI in the browser.
const state: AdminBootstrap = {
  locale: 'en',
  perms: ALL_PERMS,
  permKeys: Object.keys(ALL_PERMS),
  settings: {
    Locale: 'en',
    Debug: true,
    VersionChecker: true,
    FuelSystem: 'statebag',
    Plate: { format: 'XXX XXX', enablePrefix: true, prefix: 'PX' },
    VehicleKeys: { enable: true, script: 'msk_vehiclekeys' },
    adminCommand: 'adgiveveh',
    Theme: { ...DEFAULT_THEME },
    BrandTag: 'MSK',
    dashboardGroups: ['mod'],
  },
  items: [
    { id: 'zentorno', label: 'Zentorno', model: 'zentorno', categorie: 'car' },
    { id: 'seashark', label: 'Seashark', model: 'seashark', categorie: 'boat' },
  ],
  groups: [
    { name: 'admin', protected: true, perms: ALL_PERMS },
    { name: 'mod', protected: false, perms: { 'vehicle.give': true, 'vehicle.browse': true } },
  ],
  suggestedGroups: ['admin', 'mod', 'dev'],
  jobsList: [
    { name: 'police', label: 'Police' },
    { name: 'ambulance', label: 'EMS' },
    { name: 'mechanic', label: 'Mechanic' },
  ],
  onlinePlayers: [
    { id: 1, name: 'John Carter', identifier: 'char1:abcd', job: 'police' },
    { id: 2, name: 'Emma Wilson', identifier: 'char1:efgh', job: 'unemployed' },
    { id: 5, name: 'Liam Brooks', identifier: 'char1:ijkl', job: 'mechanic' },
  ],
  vehicleTypes: ['car', 'truck', 'bike', 'boat', 'submarine', 'helicopter', 'aircraft', 'trailer', 'train'],
  mskGarageRunning: true,
  garages: [
    { id: 'legion', label: 'Legion Square', type: ['car', 'bike'] },
    { id: 'marina', label: 'Marina', type: ['boat'] },
    { id: 'airport', label: 'Airport', type: ['helicopter', 'aircraft'] },
  ],
  scripts: {
    fuel: ['statebag', 'LegacyFuel', 'ox_fuel', 'qs-fuelstations', 'native', 'custom'],
    vehicleKeys: ['msk_vehiclekeys', 'VehicleKeyChain', 'vehicles_keys'],
  },
}

// Deep clone so each reply is a brand-new object graph (forces a React re-render).
const snapshot = (): AdminBootstrap => JSON.parse(JSON.stringify(state))

// A fake owned_vehicles table for the browser.
const OWNER_NAMES = ['John Carter', 'Emma Wilson', 'Liam Brooks', 'Olivia Hayes']
const MOCK_ROWS: BrowseRow[] = Array.from({ length: 137 }, (_, i) => ({
  plate: `MSK ${String(100 + i)}`,
  owner: `char1:${(1000 + i).toString(16)}`,
  ownerName: OWNER_NAMES[i % OWNER_NAMES.length],
  type: ['car', 'boat', 'helicopter', 'bike'][i % 4],
  stored: i % 3 === 0 ? 0 : 1,
  garage: ['legion', 'marina', 'airport'][i % 3],
  job: i % 5 === 0 ? 'police' : undefined,
}))

function browse(data: any): BrowseResult {
  const perPage = 25
  let rows = MOCK_ROWS
  const q = String(data?.query ?? '').toLowerCase()
  if (q) rows = rows.filter((r) => r.plate.toLowerCase().includes(q) || (r.ownerName ?? '').toLowerCase().includes(q) || r.owner.includes(q))
  if (data?.garage) rows = rows.filter((r) => r.garage === data.garage)
  if (data?.vtype) rows = rows.filter((r) => r.type === data.vtype)
  const total = rows.length
  const page = Math.max(1, Number(data?.page) || 1)
  const start = (page - 1) * perPage
  return { ok: true, rows: rows.slice(start, start + perPage), total, page, perPage, pages: Math.max(1, Math.ceil(total / perPage)) }
}

function handle(endpoint: string, data: any): unknown {
  switch (endpoint) {
    case 'admin:bootstrap':
      return { ok: true, data: snapshot() }
    case 'admin:vehicle:give':
    case 'admin:vehicle:givejob':
      return { ok: true, plate: data?.plate || 'ABC 123' }
    case 'admin:vehicle:spawn':
    case 'admin:vehicle:delete':
    case 'admin:vehicle:move':
      return { ok: true }
    case 'admin:vehicle:browse':
      return browse(data)
    case 'admin:items:save': {
      const item = data?.item
      if (item) {
        const idx = state.items.findIndex((x) => x.id === item.id)
        if (idx >= 0) state.items[idx] = item
        else state.items = [...state.items, item]
      }
      return { ok: true, data: snapshot() }
    }
    case 'admin:items:delete':
      state.items = state.items.filter((x) => x.id !== data?.id)
      return { ok: true, data: snapshot() }
    case 'admin:settings:save':
      state.settings = { ...state.settings, ...(data?.settings ?? {}) }
      state.locale = state.settings.Locale
      return { ok: true, data: snapshot() }
    case 'admin:perms:saveGroup': {
      const name = data?.name
      if (name) {
        const idx = state.groups.findIndex((g) => g.name === name)
        const g = { name, protected: false, perms: data.perms ?? {} }
        if (idx >= 0) state.groups[idx] = g
        else state.groups = [...state.groups, g]
      }
      return { ok: true, data: snapshot() }
    }
    case 'admin:perms:deleteGroup':
      state.groups = state.groups.filter((g) => g.name !== data?.name)
      return { ok: true, data: snapshot() }
    case 'admin:perms:dashboardGroups':
      state.settings = { ...state.settings, dashboardGroups: data?.groups ?? [] }
      return { ok: true, data: snapshot() }
    case 'admin:perms:validateGroup':
      return { ok: true, valid: true, exists: false }
    case 'admin:close':
      return 'ok'
    default:
      return null
  }
}

window.addEventListener('nui:dev-call', (e: Event) => {
  const ce = e as CustomEvent
  const { id, endpoint, data } = ce.detail || {}
  const result = handle(endpoint, data)
  window.dispatchEvent(new CustomEvent('nui:dev-reply', { detail: { id, result } }))
})

// Auto-open the dashboard in the browser.
window.setTimeout(() => {
  window.postMessage({ action: 'openAdmin', data: snapshot() }, '*')
}, 50)
