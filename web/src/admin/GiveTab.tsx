import { useState } from 'react'
import { Car } from 'lucide-react'
import type { AdminStrings } from './i18n'
import type { AdminBootstrap } from './types'
import { Btn, Field, Section, Select, StatusText, TextInput } from './ui'
import { PlayerPicker, errText, type Call, type Notify, type Toast } from './parts'

export function GiveTab({
  mode,
  d,
  t,
  call,
  notify,
  toast,
}: {
  mode: 'give' | 'givejob'
  d: AdminBootstrap
  t: AdminStrings
  call: Call
  notify: Notify
  toast: Toast
}) {
  const [target, setTarget] = useState<number | null>(null)
  const [type, setType] = useState('car')
  const [model, setModel] = useState('')
  const [plate, setPlate] = useState('')
  const [garage, setGarage] = useState('')
  const [job, setJob] = useState('')
  const [owner, setOwner] = useState<'player' | 'job'>('player')
  const [busy, setBusy] = useState(false)

  const typeOptions = d.vehicleTypes.map((v) => ({ value: v, label: v }))
  const garageOptions = [
    { value: '', label: `${t.garage_default} (msk_garage)` },
    ...d.garages.map((g) => ({ value: g.id, label: `${g.id} — ${g.label}` })),
  ]
  const jobOptions = [
    { value: '', label: `— ${t.select_job} —` },
    ...d.jobsList.map((j) => ({ value: j.name, label: `${j.label} (${j.name})` })),
  ]

  const submit = async () => {
    if (target == null) {
      notify(t.no_player_selected, false)
      return
    }
    if (!model.trim()) {
      notify(errText(t, 'bad_model'), false)
      return
    }
    if (mode === 'givejob' && !job) {
      notify(errText(t, 'bad_job'), false)
      return
    }
    setBusy(true)
    const payload: Record<string, unknown> = {
      target,
      type,
      model: model.trim(),
      plate: plate.trim() || undefined,
      garage: garage || undefined,
    }
    if (mode === 'givejob') {
      payload.job = job
      payload.owner = owner
    }
    const res = await call(mode === 'give' ? 'admin:vehicle:give' : 'admin:vehicle:givejob', payload)
    setBusy(false)
    if (res?.ok) {
      notify(`${t.delivered}${res.plate ? ` (${res.plate})` : ''}`, true)
      setPlate('')
    } else {
      notify(errText(t, res?.err), false)
    }
  }

  return (
    <div className="mx-auto flex max-w-[760px] flex-col gap-4">
      <Section title={mode === 'give' ? t.give_vehicle : t.give_job_vehicle} hint={t.give_hint}>
        <PlayerPicker t={t} players={d.onlinePlayers} value={target} onChange={setTarget} />

        <div className="grid grid-cols-2 gap-3">
          <Field label={t.category}>
            <Select value={type} onChange={setType} options={typeOptions} />
          </Field>
          <Field label={t.model}>
            <TextInput value={model} onChange={setModel} placeholder="zentorno" />
          </Field>
        </div>

        {mode === 'givejob' && (
          <div className="grid grid-cols-2 gap-3">
            <Field label={t.job}>
              <Select value={job} onChange={setJob} options={jobOptions} />
            </Field>
            <Field label={t.owner}>
              <Select
                value={owner}
                onChange={(v) => setOwner(v as 'player' | 'job')}
                options={[
                  { value: 'player', label: t.owner_player },
                  { value: 'job', label: t.owner_job },
                ]}
              />
            </Field>
          </div>
        )}

        <div className="grid grid-cols-2 gap-3">
          <Field label={t.plate_optional}>
            <TextInput value={plate} onChange={setPlate} placeholder={t.plate_random_hint} />
          </Field>
          {d.mskGarageRunning && (
            <Field label={t.garage_optional}>
              <Select value={garage} onChange={setGarage} options={garageOptions} />
            </Field>
          )}
        </div>
      </Section>

      <div className="flex items-center justify-end gap-3">
        <StatusText toast={toast} />
        <Btn variant="accent" onClick={submit} disabled={busy}>
          <Car size={14} /> {t.give}
        </Btn>
      </div>
    </div>
  )
}
