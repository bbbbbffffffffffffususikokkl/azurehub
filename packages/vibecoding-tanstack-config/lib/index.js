import { cloudflare } from '@cloudflare/vite-plugin'
import tailwindcss from '@tailwindcss/vite'
import { devtools } from '@tanstack/devtools-vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import viteReact from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

export function defineVibeCodingConfig(options = {}) {
  const extra = options.extraConfig ?? {}
  return defineConfig({
    ...extra,
    resolve: {
      tsconfigPaths: true,
      ...(extra.resolve ?? {}),
    },
    plugins: [
      devtools(),
      cloudflare({ viteEnvironment: { name: options.cloudflareEnvironmentName ?? 'ssr' } }),
      tailwindcss(),
      tanstackStart({ server: { entry: options.serverEntry ?? 'server' } }),
      viteReact(),
      ...(extra.plugins ?? []),
    ],
  })
}
