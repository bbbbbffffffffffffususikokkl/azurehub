import type { UserConfig } from 'vite'

export interface VibeCodingTanStackConfigOptions {
  serverEntry?: string
  cloudflareEnvironmentName?: string
  extraConfig?: UserConfig
}

export declare function defineVibeCodingConfig(
  options?: VibeCodingTanStackConfigOptions,
): UserConfig
