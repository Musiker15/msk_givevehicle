import { useCallback, useEffect, useState } from 'react'
import { ChevronLeft, ChevronRight, MapPin, Play, RotateCw, Trash2 } from 'lucide-react'
import { fetchNui } from '../lib/nui'
import { fmt, type AdminStrings } from './i18n'
import type { AdminBootstrap, BrowseResult, BrowseRow } from './types'
import { Btn, ConfirmDialog, Field, Modal, Select, StatusText, TextInput } from './ui'
import { PlayerPicker, errText, type Call, type Notify, type Toast } from './parts'

export function VehiclesTab({
  d,
  t,
  call,
  notify,
  toast,
}: {
  d: AdminBootstrap
  t: AdminStrings
  call: Call
  notify: Notify
  toast: Toast
}) {
  const [query, setQuery] = useState('')
  const [model, setModel] = useState('')
  const [garage, setGarage] = useState('')
  const [vtype, setVtype] = useState('')
  const [page, setPage] = useState(1)
  const [result, setResult] = useState<BrowseResult | null>(null)
  const [loading, setLoading] = useState(false)

  // Row-action dialogs.
  const [spawnPlate, setSpawnPlate] = useState<string | null>(null)
  const [spawnTarget, setSpawnTarget] = useState<number | null>(null)
  const [movePlate, setMovePlate] = useState<string | null>(null)
  const [moveGarage, setMoveGarage] = useState('')
  const [deletePlate, setDeletePlate] = useState<string | null>(null)

  const p = d.perms
  const canMove = d.mskGarageRunning && p['vehicle.move']

  const load = useCallback(async () => {
    setLoading(true)
    const res = await fetchNui<BrowseResult>('admin:vehicle:browse', {
      page,
      query,
      garage,
      vtype,
      model,
    })
    setLoading(false)
    if (res?.ok) setResult(res)
  }, [page, query, garage, vtype, model])

  // Debounced reload on any filter/page change.
  useEffect(() => {
    const id = window.setTimeout(load, 250)
    return () => window.clearTimeout(id)
  }, [load])

  const resetPage = () => setPage(1)

  const doSpawn = async () => {
    if (!spawnPlate || spawnTarget == null) return
    const res = await call('admin:vehicle:spawn', { target: spawnTarget, plate: spawnPlate })
    if (res?.ok) {
      notify(t.spawned, true)
      setSpawnPlate(null)
      setSpawnTarget(null)
      load()
    } else notify(errText(t, res?.err), false)
  }

  const doMove = async () => {
    if (!movePlate || !moveGarage) return
    const res = await call('admin:vehicle:move', { plate: movePlate, garage: moveGarage })
    if (res?.ok) {
      notify(t.moved, true)
      setMovePlate(null)
      setMoveGarage('')
      load()
    } else notify(errText(t, res?.err), false)
  }

  const doDelete = async (plate: string) => {
    const res = await call('admin:vehicle:delete', { plate })
    if (res?.ok) {
      notify(t.deleted, true)
      load()
    } else notify(errText(t, res?.err), false)
  }

  const garageLabel = (id?: string) => {
    if (!id) return '—'
    const g = d.garages.find((x) => x.id === id)
    return g ? g.label : id
  }

  const typeOptions = [{ value: '', label: t.all_types }, ...d.vehicleTypes.map((v) => ({ value: v, label: v }))]
  const garageFilterOptions = [
    { value: '', label: t.all_garages },
    ...d.garages.map((g) => ({ value: g.id, label: g.label })),
  ]
  const moveOptions = [
    { value: '', label: `— ${t.garage} —` },
    ...d.garages.map((g) => ({ value: g.id, label: `${g.id} — ${g.label}` })),
  ]

  const rows: BrowseRow[] = result?.rows ?? []
  const pages = result?.pages ?? 1

  return (
    <div className="flex flex-col gap-4">
      {/* Filters */}
      <div className="grid grid-cols-12 gap-3">
        <div className={d.mskGarageRunning ? 'col-span-5' : 'col-span-7'}>
          <Field label={t.search}>
            <TextInput
              value={query}
              onChange={(v) => { setQuery(v); resetPage() }}
              placeholder={t.search_placeholder}
            />
          </Field>
        </div>
        <div className="col-span-3">
          <Field label={t.model_filter}>
            <TextInput value={model} onChange={(v) => { setModel(v); resetPage() }} placeholder="zentorno" />
          </Field>
        </div>
        {d.mskGarageRunning && (
          <div className="col-span-2">
            <Field label={t.filter_garage}>
              <Select value={garage} onChange={(v) => { setGarage(v); resetPage() }} options={garageFilterOptions} />
            </Field>
          </div>
        )}
        <div className="col-span-2">
          <Field label={t.filter_type}>
            <Select value={vtype} onChange={(v) => { setVtype(v); resetPage() }} options={typeOptions} />
          </Field>
        </div>
      </div>

      {/* Table */}
      <div className="overflow-hidden rounded-sm border border-border">
        <table className="w-full border-collapse text-left">
          <thead>
            <tr className="bg-panel-raised">
              {[t.plate, t.owner, t.filter_type, ...(d.mskGarageRunning ? [t.garage] : []), t.status, t.actions].map((h) => (
                <th key={h} className="msk-label px-3 py-2 text-[10px] font-bold">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((r) => (
              <tr key={r.plate} className="border-t border-border hover:bg-white/[0.02]">
                <td className="px-3 py-2 font-mono text-[12px] text-text-primary">{r.plate}</td>
                <td className="px-3 py-2 font-sans text-[12px] text-text-secondary">
                  {r.ownerName || r.owner || t.ownerless}
                  {r.job ? <span className="ml-1 text-text-muted">· {r.job}</span> : null}
                </td>
                <td className="px-3 py-2 font-sans text-[12px] text-text-muted">{r.type || '—'}</td>
                {d.mskGarageRunning && (
                  <td className="px-3 py-2 font-sans text-[12px] text-text-muted">{garageLabel(r.garage)}</td>
                )}
                <td className="px-3 py-2">
                  <span className={`font-mono text-[10px] uppercase ${r.stored === 1 ? 'text-accent' : 'text-text-muted'}`}>
                    {r.stored === 1 ? t.stored : t.out}
                  </span>
                </td>
                <td className="px-3 py-2">
                  <div className="flex items-center gap-1.5">
                    {p['vehicle.spawn'] && (
                      <button onClick={() => { setSpawnPlate(r.plate); setSpawnTarget(null) }} title={t.spawn}
                        className="rounded-sm border border-border p-1.5 text-text-secondary hover:text-accent">
                        <Play size={13} />
                      </button>
                    )}
                    {canMove && (
                      <button onClick={() => { setMovePlate(r.plate); setMoveGarage('') }} title={t.move}
                        className="rounded-sm border border-border p-1.5 text-text-secondary hover:text-accent">
                        <MapPin size={13} />
                      </button>
                    )}
                    {p['vehicle.delete'] && (
                      <button onClick={() => setDeletePlate(r.plate)} title={t.delete}
                        className="rounded-sm border border-border p-1.5 text-text-muted hover:text-red-400">
                        <Trash2 size={13} />
                      </button>
                    )}
                  </div>
                </td>
              </tr>
            ))}
            {!loading && rows.length === 0 && (
              <tr>
                <td colSpan={8} className="px-3 py-10 text-center">
                  <p className="font-display text-[14px] text-text-secondary">{t.no_results}</p>
                  <p className="mt-1 font-sans text-[12px] text-text-muted">{t.no_results_hint}</p>
                </td>
              </tr>
            )}
            {loading && (
              <tr>
                <td colSpan={8} className="px-3 py-10 text-center font-mono text-[11px] uppercase tracking-[0.1em] text-text-muted">
                  …
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Btn onClick={load}><RotateCw size={13} /> {t.refresh}</Btn>
          <span className="font-mono text-[11px] text-text-muted">{result ? `${result.total}` : '—'}</span>
          <StatusText toast={toast} />
        </div>
        <div className="flex items-center gap-2">
          <Btn onClick={() => setPage((x) => Math.max(1, x - 1))} disabled={page <= 1}>
            <ChevronLeft size={13} /> {t.prev}
          </Btn>
          <span className="font-mono text-[11px] text-text-secondary">{fmt(t.page_of, page, pages)}</span>
          <Btn onClick={() => setPage((x) => Math.min(pages, x + 1))} disabled={page >= pages}>
            {t.next} <ChevronRight size={13} />
          </Btn>
        </div>
      </div>

      {/* Spawn modal */}
      {spawnPlate && (
        <Modal
          title={`${t.spawn} — ${spawnPlate}`}
          onClose={() => setSpawnPlate(null)}
          footer={
            <>
              <Btn variant="ghost" onClick={() => setSpawnPlate(null)}>{t.cancel}</Btn>
              <Btn variant="accent" onClick={doSpawn} disabled={spawnTarget == null}>{t.spawn}</Btn>
            </>
          }
        >
          <PlayerPicker t={t} players={d.onlinePlayers} value={spawnTarget} onChange={setSpawnTarget} />
        </Modal>
      )}

      {/* Move modal */}
      {movePlate && (
        <Modal
          title={`${t.move_to} — ${movePlate}`}
          onClose={() => setMovePlate(null)}
          footer={
            <>
              <Btn variant="ghost" onClick={() => setMovePlate(null)}>{t.cancel}</Btn>
              <Btn variant="accent" onClick={doMove} disabled={!moveGarage}>{t.move}</Btn>
            </>
          }
        >
          <Field label={t.garage}>
            <Select value={moveGarage} onChange={setMoveGarage} options={moveOptions} />
          </Field>
        </Modal>
      )}

      {/* Delete confirm */}
      {deletePlate && (
        <ConfirmDialog
          title={t.delete}
          message={`${t.confirm_delete_vehicle}\n\n${deletePlate}`}
          confirmLabel={t.delete}
          cancelLabel={t.cancel}
          onCancel={() => setDeletePlate(null)}
          onConfirm={() => {
            const plate = deletePlate
            setDeletePlate(null)
            void doDelete(plate)
          }}
        />
      )}
    </div>
  )
}
