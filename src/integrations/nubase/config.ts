export type NubasePublicConfig = {
  url: string
  publishableKey: string
}

export type NubaseServerConfig = NubasePublicConfig & {
  authUrl?: string
  upstreamUrl: string
  runtimeMode: string
  projectRef?: string
  serviceRoleKey?: string
}

const PUBLIC_URL_KEYS = ['VITE_NUBASE_URL', 'NUBASE_PUBLIC_URL'] as const
const PUBLIC_KEY_KEYS = ['NUBASE_PUBLISHABLE_KEY', 'VITE_NUBASE_PUBLISHABLE_KEY'] as const
const SERVER_AUTH_URL_KEYS = ['NUBASE_AUTH_URL'] as const
const SERVER_UPSTREAM_URL_KEYS = ['NUBASE_UPSTREAM_URL', 'NUBASE_URL', 'VITE_NUBASE_URL'] as const
const RUNTIME_PUBLIC_CONFIG_KEY = '__NUBASE_PUBLIC_CONFIG__'
const RUNTIME_SERVER_CONFIG_KEY = '__NUBASE_SERVER_CONFIG__'
const DEFAULT_RUNTIME_MODE = 'same-origin-proxy'

type RuntimeEnv = Record<string, unknown>
type RuntimePublicConfig = Partial<NubasePublicConfig>
type RuntimeServerConfig = Partial<NubaseServerConfig>

function readImportMetaEnv(key: string) {
  return import.meta.env?.[key]?.trim()
}

function readProcessEnv(key: string) {
  if (typeof process === 'undefined') return undefined
  return process.env[key]?.trim()
}

function readRuntimePublicConfig(): RuntimePublicConfig | undefined {
  const value = (globalThis as RuntimeEnv)[RUNTIME_PUBLIC_CONFIG_KEY]
  if (!value || typeof value !== 'object') return undefined

  const config = value as RuntimePublicConfig
  return {
    url: typeof config.url === 'string' ? config.url.trim() : undefined,
    publishableKey: typeof config.publishableKey === 'string'
      ? config.publishableKey.trim()
      : undefined,
  }
}

function readRuntimeServerConfig(): RuntimeServerConfig | undefined {
  const value = (globalThis as RuntimeEnv)[RUNTIME_SERVER_CONFIG_KEY]
  if (!value || typeof value !== 'object') return undefined

  const config = value as RuntimeServerConfig
  return {
    url: typeof config.url === 'string' ? config.url.trim() : undefined,
    publishableKey: typeof config.publishableKey === 'string'
      ? config.publishableKey.trim()
      : undefined,
    authUrl: typeof config.authUrl === 'string'
      ? config.authUrl.trim()
      : undefined,
    upstreamUrl: typeof config.upstreamUrl === 'string'
      ? config.upstreamUrl.trim()
      : undefined,
    runtimeMode: typeof config.runtimeMode === 'string'
      ? config.runtimeMode.trim()
      : undefined,
    projectRef: typeof config.projectRef === 'string'
      ? config.projectRef.trim()
      : undefined,
    serviceRoleKey: typeof config.serviceRoleKey === 'string'
      ? config.serviceRoleKey.trim()
      : undefined,
  }
}

function readRuntimePublicConfigValue(key: string) {
  const config = readRuntimePublicConfig()

  if (config) {
    if (PUBLIC_URL_KEYS.includes(key as (typeof PUBLIC_URL_KEYS)[number])) {
      return config.url
    }
    if (PUBLIC_KEY_KEYS.includes(key as (typeof PUBLIC_KEY_KEYS)[number])) {
      return config.publishableKey
    }
  }

  const serverConfig = readRuntimeServerConfig()
  if (!serverConfig) return undefined

  if (PUBLIC_KEY_KEYS.includes(key as (typeof PUBLIC_KEY_KEYS)[number])) {
    return serverConfig.publishableKey
  }
  return undefined
}

function firstRuntimeValue(keys: readonly string[]) {
  for (const key of keys) {
    const value = readRuntimePublicConfigValue(key)
      || readImportMetaEnv(key)
      || readProcessEnv(key)
    if (value) return value
  }
  return undefined
}

function normalizeBaseUrl(url: string) {
  return url.replace(/\/+$/, '')
}

function readBrowserOrigin() {
  const location = (
    globalThis as typeof globalThis & { location?: { origin?: string } }
  ).location
  const origin = location?.origin?.trim()
  return origin ? normalizeBaseUrl(origin) : undefined
}

function readEnvValue(env: RuntimeEnv | undefined, keys: readonly string[]) {
  if (!env) return undefined
  for (const key of keys) {
    const value = env[key]
    if (typeof value === 'string' && value.trim()) {
      return value.trim()
    }
  }
  return undefined
}

export function getNubasePublicConfigFromEnv(
  env: RuntimeEnv | undefined,
  requestOrigin?: string,
): NubasePublicConfig | undefined {
  const url = requestOrigin?.trim() || readEnvValue(env, PUBLIC_URL_KEYS)
  const publishableKey = readEnvValue(env, PUBLIC_KEY_KEYS)
  if (!url || !publishableKey) return undefined

  return {
    url: normalizeBaseUrl(url),
    publishableKey,
  }
}

export function getNubaseServerConfigFromEnv(
  env: RuntimeEnv | undefined,
  publicConfig: NubasePublicConfig | undefined,
): NubaseServerConfig | undefined {
  const upstreamUrl = readEnvValue(env, SERVER_UPSTREAM_URL_KEYS)
  const publishableKey = publicConfig?.publishableKey
    ?? readEnvValue(env, PUBLIC_KEY_KEYS)
  if (!upstreamUrl || !publishableKey) return undefined

  return {
    url: publicConfig?.url ?? normalizeBaseUrl(upstreamUrl),
    publishableKey,
    authUrl: readEnvValue(env, SERVER_AUTH_URL_KEYS),
    upstreamUrl: normalizeBaseUrl(upstreamUrl),
    runtimeMode: readEnvValue(env, ['NUBASE_RUNTIME_MODE']) ?? DEFAULT_RUNTIME_MODE,
    projectRef: readEnvValue(env, ['NUBASE_PROJECT_REF']),
    serviceRoleKey: readEnvValue(env, ['NUBASE_SERVICE_ROLE_KEY']),
  }
}

export function setNubaseRuntimePublicConfig(
  config: NubasePublicConfig | undefined,
) {
  if (!config) {
    delete (globalThis as RuntimeEnv)[RUNTIME_PUBLIC_CONFIG_KEY]
    return
  }

  ;(globalThis as RuntimeEnv)[RUNTIME_PUBLIC_CONFIG_KEY] = config
}

export function setNubaseRuntimeServerConfig(
  config: NubaseServerConfig | undefined,
) {
  if (!config) {
    delete (globalThis as RuntimeEnv)[RUNTIME_SERVER_CONFIG_KEY]
    return
  }

  ;(globalThis as RuntimeEnv)[RUNTIME_SERVER_CONFIG_KEY] = config
}

function escapeJsonForInlineScript(value: string) {
  return value
    .replace(/</g, '\\u003c')
    .replace(/\u2028/g, '\\u2028')
    .replace(/\u2029/g, '\\u2029')
}

export function renderNubaseRuntimeConfigScript(
  config: NubasePublicConfig | undefined,
) {
  if (!config) return ''

  const json = escapeJsonForInlineScript(JSON.stringify(config))
  return `<script>window.${RUNTIME_PUBLIC_CONFIG_KEY}=${json};</script>`
}

export function getNubasePublicConfig(): NubasePublicConfig {
  const url = firstRuntimeValue(PUBLIC_URL_KEYS) || readBrowserOrigin()
  const publishableKey = firstRuntimeValue(PUBLIC_KEY_KEYS)

  if (!url || !publishableKey) {
    throw new Error(
      'Nubase is unavailable because this app is missing its platform runtime configuration.',
    )
  }

  return {
    url: normalizeBaseUrl(url),
    publishableKey,
  }
}

export function getNubaseServerConfig(): NubaseServerConfig {
  const runtimeServerConfig = readRuntimeServerConfig()
  const publicConfig = getNubasePublicConfig()
  const upstreamUrl = runtimeServerConfig?.upstreamUrl
    || readProcessEnv('NUBASE_UPSTREAM_URL')
    || readProcessEnv('NUBASE_URL')
  const authUrl = runtimeServerConfig?.authUrl || readProcessEnv('NUBASE_AUTH_URL')

  if (!upstreamUrl) {
    throw new Error('Missing NUBASE_UPSTREAM_URL for server-only Nubase client.')
  }

  return {
    ...publicConfig,
    ...(authUrl ? { authUrl: normalizeBaseUrl(authUrl) } : {}),
    upstreamUrl: normalizeBaseUrl(upstreamUrl),
    runtimeMode: runtimeServerConfig?.runtimeMode
      || readProcessEnv('NUBASE_RUNTIME_MODE')
      || DEFAULT_RUNTIME_MODE,
    projectRef: runtimeServerConfig?.projectRef || readProcessEnv('NUBASE_PROJECT_REF'),
    serviceRoleKey: runtimeServerConfig?.serviceRoleKey || readProcessEnv('NUBASE_SERVICE_ROLE_KEY'),
  }
}
