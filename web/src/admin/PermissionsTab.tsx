import { useState } from 'react'
import { Check, Plus, Shield, Trash2, X } from 'lucide-react'
import type { AdminStrings } from './i18n'
import { permLabel } from './i18n'
import type { AdminBootstrap, GroupDef } from './types'
import { Btn, ConfirmDialog, Section, StatusText, Switch } from './ui'
import { errText, type Call, type Notify, type Toast } from './parts'

function GroupRow({
  t,
  group,
  permKeys,
  onSave,
  onDelete,
}: {
  t: AdminStrings
  group: GroupDef
  permKeys: string[]
  onSave: (g: GroupDef) => void
  onDelete: (name: string) => void
}) {
  const [perms, setPerms] = useState<Record<string, boolean>>(group.perms)
  const [dirty, setDirty] = useState(false)

  const toggle = (key: string) => {
    setPerms((p) => ({ ...p, [key]: !p[key] }))
    setDirty(true)
  }

  return (
    <div className="rounded-sm border border-border bg-panel-raised p-4">
      <div className="mb-3 flex items-center justify-between">
        <div className="flex items-center gap-2">
          {group.protected && <Shield size={14} className="text-accent" />}
          <span className="font-mono text-[13px] uppercase tracking-[0.06em] text-text-primary">group.{group.name}</span>
        </div>
        {!group.protected && (
          <div className="flex gap-2">
            <Btn variant="accent" onClick={() => { onSave({ ...group, perms }); setDirty(false) }} disabled={!dirty}>
              {t.save}
            </Btn>
            <button onClick={() => onDelete(group.name)} className="rounded-sm border border-border p-2 text-text-muted hover:text-red-400">
              <Trash2 size={14} />
            </button>
          </div>
        )}
      </div>
      <div className="grid grid-cols-2 gap-x-4 gap-y-2">
        {permKeys.map((key) => (
          <div key={key} className="flex items-center justify-between">
            <span className="font-sans text-[12px] text-text-secondary">{permLabel(t, key)}</span>
            <Switch
              checked={group.protected ? true : Boolean(perms[key])}
              onChange={() => toggle(key)}
              disabled={group.protected}
            />
          </div>
        ))}
      </div>
    </div>
  )
}

export function PermissionsTab({
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
  const groups = d.groups
  const permKeys = d.permKeys
  const dashboardGroups = d.settings.dashboardGroups

  const [newGroup, setNewGroup] = useState('')
  const [validateMsg, setValidateMsg] = useState<string | null>(null)
  const [newDash, setNewDash] = useState('')
  const [pendingDelete, setPendingDelete] = useState<string | null>(null)

  const existing = new Set(groups.map((g) => g.name))

  const addGroup = async () => {
    const name = newGroup.trim().toLowerCase().replace(/^group\./, '')
    if (!name) return
    if (name === 'user') { notify('group.user', false); return }
    const res = await call('admin:perms:saveGroup', { name, perms: { 'vehicle.browse': true } })
    if (res?.ok) { notify(t.saved, true); setNewGroup('') }
    else notify(errText(t, res?.err), false)
  }

  const validate = async () => {
    const name = newGroup.trim().toLowerCase().replace(/^group\./, '')
    if (!name) return
    const res = await call('admin:perms:validateGroup', { name })
    if (res?.blacklisted) setValidateMsg('group.user')
    else if (res?.exists) setValidateMsg(t.group_exists)
    else setValidateMsg(t.group_unknown)
  }

  const saveGroup = async (g: GroupDef) => {
    const res = await call('admin:perms:saveGroup', { name: g.name, perms: g.perms })
    notify(res?.ok ? t.saved : errText(t, res?.err), Boolean(res?.ok))
  }

  const deleteGroup = async (name: string) => {
    const res = await call('admin:perms:deleteGroup', { name })
    notify(res?.ok ? t.saved : errText(t, res?.err), Boolean(res?.ok))
  }

  const saveDash = async (next: string[]) => {
    const res = await call('admin:perms:dashboardGroups', { groups: next })
    notify(res?.ok ? t.saved : errText(t, res?.err), Boolean(res?.ok))
  }

  const addDash = () => {
    const name = newDash.trim().toLowerCase().replace(/^group\./, '')
    if (!name || name === 'user' || name === 'admin' || dashboardGroups.includes(name)) { setNewDash(''); return }
    void saveDash([...dashboardGroups, name])
    setNewDash('')
  }

  const inputCls = 'rounded-sm border border-border bg-input px-3 py-2 text-[13px] text-text-primary outline-none focus:border-border-accent'

  return (
    <div className="flex flex-col gap-4">
      <div className="flex min-h-[18px] items-center justify-end">
        <StatusText toast={toast} />
      </div>

      <Section title={t.dashboard_groups} hint={t.dashboard_groups_hint}>
        <div className="flex flex-wrap items-center gap-2">
          <span className="rounded-sm border border-border-accent bg-accent/15 px-2.5 py-1 font-mono text-[11px] uppercase text-accent">group.admin</span>
          {dashboardGroups.map((name) => (
            <span key={name} className="flex items-center gap-1.5 rounded-sm border border-border bg-input px-2.5 py-1 font-mono text-[11px] uppercase text-text-secondary">
              group.{name}
              <button onClick={() => saveDash(dashboardGroups.filter((x) => x !== name))} className="text-text-muted hover:text-red-400">
                <X size={12} />
              </button>
            </span>
          ))}
        </div>
        <div className="flex gap-2">
          <input value={newDash} onChange={(e) => setNewDash(e.target.value)} placeholder={t.group_name} className={`${inputCls} flex-1`} />
          <Btn onClick={addDash}><Plus size={13} /> {t.add_group}</Btn>
        </div>
      </Section>

      <Section title={t.add_group} hint={t.group_protected}>
        <div className="flex flex-wrap gap-1.5">
          {d.suggestedGroups.filter((g) => !existing.has(g) && g !== 'admin').map((g) => (
            <button key={g} onClick={() => setNewGroup(g)} className="rounded-sm border border-border bg-input px-2.5 py-1 font-mono text-[11px] uppercase text-text-secondary hover:text-accent">
              {g}
            </button>
          ))}
        </div>
        <div className="flex gap-2">
          <input value={newGroup} onChange={(e) => { setNewGroup(e.target.value); setValidateMsg(null) }} placeholder={t.group_name} className={`${inputCls} flex-1`} />
          <Btn onClick={validate}>{t.validate}</Btn>
          <Btn variant="accent" onClick={addGroup}><Plus size={13} /> {t.add_group}</Btn>
        </div>
        {validateMsg && (
          <div className="flex items-center gap-2 font-sans text-[12px] text-text-secondary">
            <Check size={13} className="text-accent" /> {validateMsg}
          </div>
        )}
      </Section>

      <div className="flex flex-col gap-3">
        {groups.map((g) => (
          <GroupRow key={g.name} t={t} group={g} permKeys={permKeys} onSave={saveGroup} onDelete={setPendingDelete} />
        ))}
      </div>

      {pendingDelete && (
        <ConfirmDialog
          title={t.delete}
          message={`${t.confirm_delete}\n\ngroup.${pendingDelete}`}
          confirmLabel={t.delete}
          cancelLabel={t.cancel}
          onCancel={() => setPendingDelete(null)}
          onConfirm={() => {
            const name = pendingDelete
            setPendingDelete(null)
            void deleteGroup(name)
          }}
        />
      )}
    </div>
  )
}
