import { cloudflare } from '@cloudflare/vite-plugin'
import tailwindcss from '@tailwindcss/vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import { devtools } from '@tanstack/devtools-vite'
import viteReact from '@vitejs/plugin-react'
import { defineConfig, type UserConfig } from 'vite'

export interface VibeCodingTanStackConfigOptions {
  serverEntry?: string
  cloudflareEnvironmentName?: string
  extraConfig?: UserConfig
}

export function defineVibeCodingConfig(options: VibeCodingTanStackConfigOptions = {}) {
  const extra = options.extraConfig ?? {}
  return defineConfig({
    ...extra,
    resolve: {
      tsconfigPaths: true,
      ...(extra.resolve ?? {}),
    },
    plugins: [
      devtools(),
      cloudflare({
        viteEnvironment: {
          name: options.cloudflareEnvironmentName ?? 'ssr',
        },
      }),
      tailwindcss(),
      tanstackStart({
        server: {
          entry: options.serverEntry ?? 'server',
        },
      }),
      viteReact(),
      ...(extra.plugins ?? []),
    ],
  })
}
