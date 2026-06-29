import { useState } from 'react'
import { Pencil, Plus, Trash2 } from 'lucide-react'
import type { AdminStrings } from './i18n'
import type { AdminBootstrap, ItemDef } from './types'
import { Btn, ConfirmDialog, Field, Modal, Section, Select, StatusText, TextInput } from './ui'
import { errText, type Call, type Notify, type Toast } from './parts'

const EMPTY: ItemDef = { id: '', label: '', model: '', categorie: 'car' }

export function ItemsTab({
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
  const [editing, setEditing] = useState<ItemDef | null>(null)
  const [isNew, setIsNew] = useState(false)
  const [pendingDelete, setPendingDelete] = useState<string | null>(null)

  const typeOptions = d.vehicleTypes.map((v) => ({ value: v, label: v }))

  const openNew = () => { setEditing({ ...EMPTY }); setIsNew(true) }
  const openEdit = (item: ItemDef) => { setEditing({ ...item }); setIsNew(false) }

  const save = async () => {
    if (!editing) return
    if (!editing.id.trim() || !editing.model.trim()) {
      notify(errText(t, !editing.id.trim() ? 'bad_id' : 'bad_model'), false)
      return
    }
    const res = await call('admin:items:save', { item: editing })
    if (res?.ok) { notify(t.saved, true); setEditing(null) }
    else notify(errText(t, res?.err), false)
  }

  const remove = async (id: string) => {
    const res = await call('admin:items:delete', { id })
    notify(res?.ok ? t.saved : errText(t, res?.err), Boolean(res?.ok))
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center justify-between">
        <StatusText toast={toast} />
        <Btn variant="accent" onClick={openNew}><Plus size={14} /> {t.add_item}</Btn>
      </div>

      <Section title={t.tab_items} hint={t.items_hint}>
        {d.items.length === 0 ? (
          <p className="py-6 text-center font-sans text-[13px] text-text-muted">{t.no_items}</p>
        ) : (
          <div className="overflow-hidden rounded-sm border border-border">
            <table className="w-full border-collapse text-left">
              <thead>
                <tr className="bg-panel-raised">
                  {[t.item_id, t.item_label, t.item_model, t.item_category, t.actions].map((h) => (
                    <th key={h} className="msk-label px-3 py-2 text-[10px] font-bold">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {d.items.map((item) => (
                  <tr key={item.id} className="border-t border-border hover:bg-white/[0.02]">
                    <td className="px-3 py-2 font-mono text-[12px] text-text-primary">{item.id}</td>
                    <td className="px-3 py-2 font-sans text-[12px] text-text-secondary">{item.label}</td>
                    <td className="px-3 py-2 font-mono text-[12px] text-text-muted">{item.model}</td>
                    <td className="px-3 py-2 font-sans text-[12px] text-text-muted">{item.categorie}</td>
                    <td className="px-3 py-2">
                      <div className="flex items-center gap-1.5">
                        <button onClick={() => openEdit(item)} title={t.edit}
                          className="rounded-sm border border-border p-1.5 text-text-secondary hover:text-accent">
                          <Pencil size={13} />
                        </button>
                        <button onClick={() => setPendingDelete(item.id)} title={t.delete}
                          className="rounded-sm border border-border p-1.5 text-text-muted hover:text-red-400">
                          <Trash2 size={13} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Section>

      {editing && (
        <Modal
          title={isNew ? t.create_item : `${t.edit} — ${editing.id}`}
          onClose={() => setEditing(null)}
          footer={
            <>
              <Btn variant="ghost" onClick={() => setEditing(null)}>{t.cancel}</Btn>
              <Btn variant="accent" onClick={save}>{t.save}</Btn>
            </>
          }
        >
          <div className="flex flex-col gap-3">
            <div className="grid grid-cols-2 gap-3">
              <Field label={t.item_id}>
                <TextInput value={editing.id} onChange={(id) => setEditing({ ...editing, id })} placeholder="zentorno" disabled={!isNew} />
              </Field>
              <Field label={t.item_label}>
                <TextInput value={editing.label} onChange={(label) => setEditing({ ...editing, label })} placeholder="Zentorno" />
              </Field>
              <Field label={t.item_model}>
                <TextInput value={editing.model} onChange={(model) => setEditing({ ...editing, model })} placeholder="zentorno" />
              </Field>
              <Field label={t.item_category}>
                <Select value={editing.categorie} onChange={(categorie) => setEditing({ ...editing, categorie })} options={typeOptions} />
              </Field>
            </div>
          </div>
        </Modal>
      )}

      {pendingDelete && (
        <ConfirmDialog
          title={t.delete}
          message={`${t.confirm_delete_item}\n\n${pendingDelete}`}
          confirmLabel={t.delete}
          cancelLabel={t.cancel}
          onCancel={() => setPendingDelete(null)}
          onConfirm={() => {
            const id = pendingDelete
            setPendingDelete(null)
            void remove(id)
          }}
        />
      )}
    </div>
  )
}
