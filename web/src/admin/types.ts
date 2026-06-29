import type { Theme } from '../lib/theme'

export interface PlateConfig {
  format: 'XXX XXX' | 'XX XXXX'
  enablePrefix: boolean
  prefix: string
}

export interface VehicleKeysConfig {
  enable: boolean
  script: string
}

export interface SettingsPayload {
  Locale: string
  Debug: boolean
  VersionChecker: boolean
  FuelSystem: string
  Plate: PlateConfig
  VehicleKeys: VehicleKeysConfig
  adminCommand: string
  Theme: Theme
  BrandTag: string
  dashboardGroups: string[]
}

export interface ItemDef {
  id: string
  label: string
  model: string
  categorie: string
}

export interface GroupDef {
  name: string
  protected: boolean
  perms: Record<string, boolean>
}

export interface JobInfo {
  name: string
  label: string
}

export interface OnlinePlayer {
  id: number
  name: string
  identifier: string
  job?: string
}

export interface GarageInfo {
  id: string
  label: string
  type: string[]
}

export interface AdminBootstrap {
  locale: string
  perms: Record<string, boolean>
  permKeys: string[]
  settings: SettingsPayload
  items: ItemDef[]
  groups: GroupDef[]
  suggestedGroups: string[]
  jobsList: JobInfo[]
  onlinePlayers: OnlinePlayer[]
  vehicleTypes: string[]
  mskGarageRunning: boolean
  garages: GarageInfo[]
  scripts: { fuel: string[]; vehicleKeys: string[] }
}

export interface BrowseRow {
  plate: string
  owner: string
  ownerName?: string
  type?: string
  stored: number
  garage?: string
  job?: string
}

export interface BrowseResult {
  ok: boolean
  err?: string
  rows: BrowseRow[]
  total: number
  page: number
  perPage: number
  pages: number
}

export interface CallResult {
  ok: boolean
  err?: string
  data?: AdminBootstrap
  plate?: string
  valid?: boolean
  exists?: boolean
  blacklisted?: boolean
}
