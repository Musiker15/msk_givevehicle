import type { Config } from 'tailwindcss'

export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      // Colours are driven by CSS custom properties (web/src/lib/theme.ts +
      // :root defaults in src/styles/index.css) so the dashboard can recolour
      // every surface live. The `<alpha-value>` placeholder keeps Tailwind
      // opacity modifiers (e.g. bg-accent/15) working with var() colours.
      colors: {
        bg: 'rgb(var(--c-bg-rgb) / <alpha-value>)',
        panel: 'rgb(var(--c-panel-rgb) / <alpha-value>)',
        'panel-raised': 'rgb(var(--c-panel-raised-rgb) / <alpha-value>)',
        input: 'rgb(var(--c-text-primary-rgb) / 0.05)',
        border: 'rgb(var(--c-text-primary-rgb) / 0.08)',
        'border-accent': 'rgb(var(--c-accent-rgb) / 0.35)',
        accent: 'rgb(var(--c-accent-rgb) / <alpha-value>)',
        'accent-dim': 'rgb(var(--c-accent-dim-rgb) / <alpha-value>)',
        text: {
          primary: 'rgb(var(--c-text-primary-rgb) / <alpha-value>)',
          secondary: 'rgb(var(--c-text-secondary-rgb) / <alpha-value>)',
          muted: 'rgb(var(--c-text-muted-rgb) / <alpha-value>)',
        },
      },
      fontFamily: {
        display: ['"Work Sans"', 'sans-serif'],
        sans: ['"Open Sans"', 'sans-serif'],
        mono: ['"Open Sans"', 'sans-serif'],
      },
      borderRadius: {
        lg: '12px',
        sm: '6px',
      },
      boxShadow: {
        panel: '0 8px 32px rgba(0,0,0,0.5)',
        glow: '0 0 0 1px rgb(var(--c-accent-rgb) / 0.35), 0 0 20px rgb(var(--c-accent-rgb) / 0.15)',
      },
      keyframes: {
        'fade-in': { '0%': { opacity: '0' }, '100%': { opacity: '1' } },
        'slide-up': {
          '0%': { opacity: '0', transform: 'translateY(12px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        'scale-in': {
          '0%': { opacity: '0', transform: 'scale(0.96)' },
          '100%': { opacity: '1', transform: 'scale(1)' },
        },
        spin: { '0%': { transform: 'rotate(0deg)' }, '100%': { transform: 'rotate(360deg)' } },
      },
      animation: {
        'fade-in': 'fade-in 0.2s ease-out',
        'slide-up': 'slide-up 0.25s ease-out',
        'scale-in': 'scale-in 0.18s ease-out',
        spin: 'spin 0.8s linear infinite',
      },
    },
  },
  plugins: [],
} satisfies Config
