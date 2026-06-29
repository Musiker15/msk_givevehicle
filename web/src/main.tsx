import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import './styles/index.css'

function isBrowser(): boolean {
  try {
    GetParentResourceName()
    return false
  } catch {
    return true
  }
}

if (import.meta.env.DEV && isBrowser()) {
  import('./admin/devMock')
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
