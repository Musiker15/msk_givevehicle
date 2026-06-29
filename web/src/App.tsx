import { useCallback, useEffect, useState } from 'react'
import { fetchNui } from './lib/nui'
import { AdminApp } from './admin/AdminApp'
import type { AdminBootstrap } from './admin/types'

interface OpenAdminMessage {
  action: 'openAdmin'
  data: AdminBootstrap
}

export default function App() {
  const [adminData, setAdminData] = useState<AdminBootstrap | null>(null)

  useEffect(() => {
    const listener = (event: MessageEvent) => {
      const msg = event.data as OpenAdminMessage
      if (msg && msg.action === 'openAdmin') setAdminData(msg.data)
    }
    window.addEventListener('message', listener)
    return () => window.removeEventListener('message', listener)
  }, [])

  const closeAdmin = useCallback(() => {
    setAdminData(null)
    fetchNui('admin:close')
  }, [])

  if (!adminData) return null
  return <AdminApp data={adminData} onClose={closeAdmin} />
}
