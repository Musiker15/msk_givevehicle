import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// NUI loads assets from the resource over a file:// style origin, so we emit
// relative paths. The build output lands directly in ../html which is what
// fxmanifest's ui_page points at.
export default defineConfig({
  plugins: [react()],
  base: './',
  build: {
    outDir: '../html',
    emptyOutDir: true,
    assetsDir: 'assets',
    chunkSizeWarningLimit: 1500,
  },
})
