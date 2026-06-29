import { useMemo, useState } from 'react'
import type { AdminStrings } from './i18n'
import type { CallResult, OnlinePlayer } from './types'
import { Field, Select, TextInput } from './ui'

export type Call = (endpoint: string, payload?: unknown) => Promise<CallResult | null>
export type Notify = (msg: string, ok: boolean) => void
export type Toast = { msg: string; ok: boolean } | null

// Searchable online-player picker (text filter + select).
export function PlayerPicker({
  t,
  players,
  value,
  onChange,
}: {
  t: AdminStrings
  players: OnlinePlayer[]
  value: number | null
  onChange: (id: number | null) => void
}) {
  const [search, setSearch] = useState('')

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase()
    if (!q) return players
    return players.filter(
      (p) =>
        p.name.toLowerCase().includes(q) ||
        String(p.id).includes(q) ||
        (p.identifier ?? '').toLowerCase().includes(q),
    )
  }, [players, search])

  const options = [
    { value: '', label: `— ${t.select_player} —` },
    ...filtered.map((p) => ({ value: String(p.id), label: `[${p.id}] ${p.name}${p.job ? ` · ${p.job}` : ''}` })),
  ]

  return (
    <div className="grid grid-cols-2 gap-3">
      <Field label={t.search}>
        <TextInput value={search} onChange={setSearch} placeholder={t.search_player} />
      </Field>
      <Field label={t.player}>
        <Select
          value={value != null ? String(value) : ''}
          onChange={(v) => onChange(v === '' ? null : Number(v))}
          options={options}
        />
      </Field>
    </div>
  )
}

// Maps a Core/admin error code to a friendly, localized message.
export function errText(t: AdminStrings, err?: string): string {
  const friendly: Record<string, string> = {
    no_permission: t.error,
    plate_exists: t.err_plate_exists,
    no_target: t.err_no_target,
    bad_model: t.err_bad_model,
    bad_job: t.err_bad_job,
    bad_id: t.err_bad_id,
    unknown_garage: t.err_unknown_garage,
    not_found: t.err_not_found,
    type_mismatch: t.err_type_mismatch,
    delete_failed: t.err_delete_failed,
    garage_unavailable: t.err_garage_unavailable,
    bad_plate: t.err_bad_plate,
  }
  return (err && friendly[err]) || `${t.error}${err ? `: ${err}` : ''}`
}
