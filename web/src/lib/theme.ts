// Runtime theming. The 5 brand colours drive every UI surface via CSS custom
// properties. Tailwind tokens reference these vars (tailwind.config.ts), so
// setting them on :root recolours everything live. Derived shades are computed
// here to keep the editable set small and consistent.

export interface Theme {
  accent: string
  bg: string
  panel: string
  textPrimary: string
  textSecondary: string
}

export const DEFAULT_THEME: Theme = {
  accent: '#00E676',
  bg: '#0a0b0d',
  panel: '#131317',
  textPrimary: '#f0ede8',
  textSecondary: '#b0adb8',
}

export const THEME_KEYS: (keyof Theme)[] = ['accent', 'bg', 'panel', 'textPrimary', 'textSecondary']

type RGB = [number, number, number]

function hexToRgb(hex: string): RGB | null {
  const m = /^#?([0-9a-fA-F]{6})$/.exec(String(hex).trim())
  if (!m) return null
  const n = parseInt(m[1], 16)
  return [(n >> 16) & 255, (n >> 8) & 255, n & 255]
}

const clamp = (n: number) => Math.max(0, Math.min(255, Math.round(n)))

function shade([r, g, b]: RGB, amt: number): RGB {
  if (amt >= 0) {
    return [clamp(r + (255 - r) * amt), clamp(g + (255 - g) * amt), clamp(b + (255 - b) * amt)]
  }
  return [clamp(r * (1 + amt)), clamp(g * (1 + amt)), clamp(b * (1 + amt))]
}

const triplet = (rgb: RGB) => `${rgb[0]} ${rgb[1]} ${rgb[2]}`

export function normalizeTheme(theme?: Partial<Theme> | null): Theme {
  const t = { ...DEFAULT_THEME, ...(theme || {}) }
  const out = {} as Theme
  for (const k of THEME_KEYS) {
    out[k] = hexToRgb(t[k]) ? t[k] : DEFAULT_THEME[k]
  }
  return out
}

export function applyTheme(theme?: Partial<Theme> | null) {
  const t = normalizeTheme(theme)
  const root = document.documentElement
  const set = (name: string, rgb: RGB) => root.style.setProperty(name, triplet(rgb))

  const accent = hexToRgb(t.accent)!
  const bg = hexToRgb(t.bg)!
  const panel = hexToRgb(t.panel)!
  const textPrimary = hexToRgb(t.textPrimary)!
  const textSecondary = hexToRgb(t.textSecondary)!

  set('--c-accent-rgb', accent)
  set('--c-accent-dim-rgb', shade(accent, -0.2))
  set('--c-bg-rgb', bg)
  set('--c-panel-rgb', panel)
  set('--c-panel-raised-rgb', shade(panel, 0.06))
  set('--c-text-primary-rgb', textPrimary)
  set('--c-text-secondary-rgb', textSecondary)
  set('--c-text-muted-rgb', shade(textSecondary, -0.4))
}
