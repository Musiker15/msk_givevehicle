/// <reference types="vite/client" />

declare global {
  // Injected by the FiveM NUI runtime. Absent in a normal browser (dev).
  function GetParentResourceName(): string
}

export {}
