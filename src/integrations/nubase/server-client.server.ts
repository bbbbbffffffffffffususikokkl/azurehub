import { createClient, type SupabaseClient } from '@supabase/supabase-js'
import { getNubaseServerConfig } from './config'

export type NubaseServerClientOptions = RequestInit & {
  accessToken?: string
}

type SupabaseTableBuilder = ReturnType<SupabaseClient['from']>
export type NubaseServerTableBuilder = Pick<
  SupabaseTableBuilder,
  'select' | 'insert' | 'update' | 'upsert' | 'delete'
>

function headersWithCredentials(
  key: string,
  options?: NubaseServerClientOptions,
) {
  const headers = new Headers(options?.headers)
  headers.set('apikey', key)

  if (options?.accessToken && !headers.has('authorization')) {
    headers.set('authorization', `Bearer ${options.accessToken}`)
  }

  if (!headers.has('content-type') && options?.body) {
    headers.set('content-type', 'application/json')
  }

  return headers
}

function createSdkClient(baseUrl: string, key: string, accessToken?: string) {
  return createClient(baseUrl, key, {
    auth: {
      autoRefreshToken: false,
      detectSessionInUrl: false,
      persistSession: false,
    },
    global: {
      headers: accessToken ? { authorization: `Bearer ${accessToken}` } : {},
    },
  })
}

function createServerFetch(baseUrl: string, key: string, accessToken?: string) {
  return (path: string, options?: NubaseServerClientOptions) => {
    const url = path.startsWith('http') ? path : `${baseUrl}${path}`

    return fetch(url, {
      ...options,
      headers: headersWithCredentials(key, {
        ...options,
        accessToken: options?.accessToken ?? accessToken,
      }),
    })
  }
}

export function createNubaseUserClient(accessToken: string) {
  const config = getNubaseServerConfig()
  const client = createSdkClient(config.upstreamUrl, config.publishableKey, accessToken)
  const nubaseFetch = createServerFetch(
    config.upstreamUrl,
    config.publishableKey,
    accessToken,
  )

  return {
    config,
    auth: {
      getUser() {
        return client.auth.getUser(accessToken)
      },
    },
    from(table: string): NubaseServerTableBuilder {
      return client.from(table) as NubaseServerTableBuilder
    },
    fetch: nubaseFetch,
    rest(path: string, options?: NubaseServerClientOptions) {
      return nubaseFetch(`/rest/v1/${path.replace(/^\/+/, '')}`, options)
    },
  }
}

export function createNubaseAdminClient() {
  const config = getNubaseServerConfig()

  if (!config.serviceRoleKey) {
    throw new Error('Missing NUBASE_SERVICE_ROLE_KEY for server-only Nubase admin client.')
  }

  const client = createSdkClient(config.upstreamUrl, config.serviceRoleKey)
  const nubaseFetch = createServerFetch(config.upstreamUrl, config.serviceRoleKey)

  return {
    config,
    auth: {
      getUser(accessToken: string) {
        return client.auth.getUser(accessToken)
      },
    },
    from(table: string): NubaseServerTableBuilder {
      return client.from(table) as NubaseServerTableBuilder
    },
    fetch: nubaseFetch,
    rest(path: string, options?: NubaseServerClientOptions) {
      return nubaseFetch(`/rest/v1/${path.replace(/^\/+/, '')}`, options)
    },
  }
}

