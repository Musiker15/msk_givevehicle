const resourceName = (): string => {
  try {
    return GetParentResourceName()
  } catch {
    return 'msk_givevehicle'
  }
}

export const isBrowser = (): boolean => {
  try {
    GetParentResourceName()
    return false
  } catch {
    return true
  }
}

export async function fetchNui<T = unknown>(endpoint: string, data: unknown = {}): Promise<T | null> {
  if (isBrowser()) {
    // Dev mode: route to devMock via a custom event and await its reply.
    return new Promise<T | null>((resolve) => {
      const id = Math.random().toString(36).slice(2)
      const handler = (e: Event) => {
        const ce = e as CustomEvent
        if (ce.detail?.id !== id) return
        window.removeEventListener('nui:dev-reply', handler)
        resolve((ce.detail?.result ?? null) as T | null)
      }
      window.addEventListener('nui:dev-reply', handler)
      window.dispatchEvent(new CustomEvent('nui:dev-call', { detail: { id, endpoint, data } }))
      // Safety timeout so a missing mock handler never hangs the UI.
      window.setTimeout(() => {
        window.removeEventListener('nui:dev-reply', handler)
        resolve(null)
      }, 1000)
    })
  }

  try {
    const resp = await fetch(`https://${resourceName()}/${endpoint}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data),
    })
    if (!resp.ok) return null
    const text = await resp.text()
    return text ? (JSON.parse(text) as T) : null
  } catch {
    return null
  }
}
