import { useEffect, useRef, useState } from 'react'
import type { AdminStrings } from './i18n'
import type { AdminBootstrap, SettingsPayload } from './types'
import { Btn, ColorInput, Field, Section, Select, StatusText, TextInput, ToggleRow } from './ui'
import { DEFAULT_THEME, applyTheme, normalizeTheme, type Theme } from '../lib/theme'
import { errText, type Call, type Notify, type Toast } from './parts'

export function SettingsTab({
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
  const [s, setS] = useState<SettingsPayload>(d.settings)
  const [busy, setBusy] = useState(false)
  const set = (patch: Partial<SettingsPayload>) => setS((prev) => ({ ...prev, ...patch }))

  const theme = normalizeTheme(s.Theme)
  const savedTheme = useRef<Theme>(normalizeTheme(d.settings.Theme))
  savedTheme.current = normalizeTheme(d.settings.Theme)
  // Restore the persisted theme if the user previews colours but leaves unsaved.
  useEffect(() => () => applyTheme(savedTheme.current), [])

  const setTheme = (patch: Partial<Theme>) =>
    setS((prev) => {
      const next = { ...normalizeTheme(prev.Theme), ...patch }
      applyTheme(next)
      return { ...prev, Theme: next }
    })

  const toOptions = (list: string[]) => list.map((v) => ({ value: v, label: v }))

  const save = async () => {
    setBusy(true)
    const res = await call('admin:settings:save', { settings: s })
    setBusy(false)
    if (res?.ok) notify(t.saved, true)
    else notify(errText(t, res?.err), false)
  }

  return (
    <div className="flex flex-col gap-4">
      <Section title={t.general}>
        <div className="grid grid-cols-2 gap-3">
          <Field label={t.locale}>
            <Select
              value={s.Locale}
              onChange={(v) => set({ Locale: v })}
              options={[
                { value: 'en', label: 'English' },
                { value: 'de', label: 'Deutsch' },
              ]}
            />
          </Field>
          <Field label={t.fuel_system}>
            <Select value={s.FuelSystem} onChange={(FuelSystem) => set({ FuelSystem })} options={toOptions(d.scripts.fuel)} />
          </Field>
        </div>
        <p className="font-sans text-[12px] text-text-muted">{t.fuel_hint}</p>
        <div className="grid grid-cols-2 gap-3">
          <ToggleRow label={t.debug} checked={s.Debug} onChange={(Debug) => set({ Debug })} />
          <ToggleRow label={t.version_checker} checked={s.VersionChecker} onChange={(VersionChecker) => set({ VersionChecker })} />
        </div>
      </Section>

      <Section title={t.plate_section}>
        <div className="grid grid-cols-3 gap-3">
          <Field label={t.plate_format}>
            <Select
              value={s.Plate.format}
              onChange={(v) => set({ Plate: { ...s.Plate, format: v as SettingsPayload['Plate']['format'] } })}
              options={[
                { value: 'XXX XXX', label: 'XXX XXX' },
                { value: 'XX XXXX', label: 'XX XXXX' },
              ]}
            />
          </Field>
          <Field label={t.plate_prefix}>
            <TextInput value={s.Plate.prefix} onChange={(prefix) => set({ Plate: { ...s.Plate, prefix } })} placeholder="PX" />
          </Field>
          <div className="flex items-end">
            <div className="w-full">
              <ToggleRow label={t.plate_enable_prefix} checked={s.Plate.enablePrefix} onChange={(enablePrefix) => set({ Plate: { ...s.Plate, enablePrefix } })} />
            </div>
          </div>
        </div>
      </Section>

      <Section title={t.vehicle_keys} hint={t.vehicle_keys_hint}>
        <ToggleRow label={t.enable} checked={s.VehicleKeys.enable} onChange={(enable) => set({ VehicleKeys: { ...s.VehicleKeys, enable } })} />
        <Field label={t.key_script}>
          <Select
            value={s.VehicleKeys.script}
            onChange={(script) => set({ VehicleKeys: { ...s.VehicleKeys, script } })}
            options={toOptions(d.scripts.vehicleKeys)}
          />
        </Field>
      </Section>

      <Section title={t.admin_command}>
        <Field label={t.admin_command}>
          <TextInput value={s.adminCommand} onChange={(adminCommand) => set({ adminCommand })} />
        </Field>
        <p className="font-sans text-[12px] text-text-muted">{t.admin_command_hint}</p>
      </Section>

      <Section title={t.colors} hint={t.colors_hint}>
        <Field label={t.brand_tag}>
          <TextInput value={s.BrandTag ?? ''} onChange={(BrandTag) => set({ BrandTag })} placeholder="MSK" />
        </Field>
        <div className="grid grid-cols-3 gap-3">
          <ColorInput label={t.color_accent} value={theme.accent} onChange={(accent) => setTheme({ accent })} />
          <ColorInput label={t.color_bg} value={theme.bg} onChange={(bg) => setTheme({ bg })} />
          <ColorInput label={t.color_panel} value={theme.panel} onChange={(panel) => setTheme({ panel })} />
          <ColorInput label={t.color_text_primary} value={theme.textPrimary} onChange={(textPrimary) => setTheme({ textPrimary })} />
          <ColorInput label={t.color_text_secondary} value={theme.textSecondary} onChange={(textSecondary) => setTheme({ textSecondary })} />
        </div>
        <div className="flex justify-start">
          <Btn variant="default" onClick={() => setTheme(DEFAULT_THEME)}>{t.reset_colors}</Btn>
        </div>
      </Section>

      <div className="flex items-center justify-end gap-3">
        <StatusText toast={toast} />
        <Btn variant="accent" onClick={save} disabled={busy}>{t.save}</Btn>
      </div>
    </div>
  )
}
