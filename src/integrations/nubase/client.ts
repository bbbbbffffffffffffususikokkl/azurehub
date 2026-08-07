import { createClient, type Session, type SupabaseClient } from '@supabase/supabase-js'
import { getNubasePublicConfig, type NubasePublicConfig } from './config'
import {
  getNubaseAccessToken,
  NUBASE_AUTH_STORAGE_KEY,
  setNubaseAccessToken,
} from './token-storage'
import { unsupported } from './unsupported'

export type NubaseFetchOptions = RequestInit & {
  accessToken?: string | null
}

type SupabaseTableBuilder = ReturnType<SupabaseClient['from']>
export type NubaseTableBuilder = Pick<
  SupabaseTableBuilder,
  'select' | 'insert' | 'update' | 'upsert' | 'delete'
>
export type NubaseOAuthProvider = 'google'
export type NubaseEmailSignUpStatus = 'signed_in' | 'verification_required' | 'error'

export interface NubaseSignInWithOAuthOptions {
  provider: NubaseOAuthProvider
  redirectTo?: string
}

export interface NubaseEmailSignUpResult {
  status: NubaseEmailSignUpStatus
  email: string | null
  user: Session['user'] | null
  session: Session | null
  error: unknown | null
  message: string | null
}

type OAuthResponse = Awaited<ReturnType<SupabaseClient['auth']['signInWithOAuth']>>
type OAuthCallbackMessage = {
  type: typeof OAUTH_CALLBACK_MESSAGE_TYPE
  session: {
    access_token: string
    refresh_token: string
  }
  returnTo: string
}

const OAUTH_CALLBACK_MESSAGE_TYPE = 'nubase:oauth-callback'

let oauthCallbackMessageHandlerInstalled = false

function defaultOAuthRedirectTo() {
  const callbackUrl = new URL('/auth/callback', window.location.origin)
  const returnPath = `${window.location.pathname}${window.location.search}${window.location.hash}`
  callbackUrl.searchParams.set('returnTo', returnPath || '/')
  return callbackUrl.toString()
}

function isEmbeddedFrame() {
  try {
    return window.self !== window.top
  } catch {
    return true
  }
}

function openPendingOAuthWindow() {
  return window.open('about:blank', '_blank')
}

function openOAuthUrlFromEmbeddedPreview(url: string, pendingWindow: Window | null) {
  try {
    if (pendingWindow && !pendingWindow.closed) {
      pendingWindow.location.href = url
      pendingWindow.focus()
      return
    }
  } catch {
    // Fall back to opening the URL directly below.
  }
  window.open(url, '_blank', 'noopener,noreferrer')
}

function safeOAuthReturnTo(value: unknown) {
  if (typeof value !== 'string' || !value.startsWith('/')) {
    return '/'
  }
  if (value.startsWith('//')) {
    return '/'
  }
  return value
}

function isOAuthCallbackMessage(value: unknown): value is OAuthCallbackMessage {
  if (!value || typeof value !== 'object') return false
  const message = value as Partial<OAuthCallbackMessage>
  const session = message.session
  return message.type === OAUTH_CALLBACK_MESSAGE_TYPE &&
    typeof message.returnTo === 'string' &&
    typeof session?.access_token === 'string' &&
    typeof session.refresh_token === 'string'
}

function installOAuthCallbackMessageHandler(client: SupabaseClient) {
  if (typeof window === 'undefined' || oauthCallbackMessageHandlerInstalled) return
  oauthCallbackMessageHandlerInstalled = true

  window.addEventListener('message', async (event) => {
    if (event.origin !== window.location.origin || !isOAuthCallbackMessage(event.data)) {
      return
    }

    const result = await client.auth.setSession(event.data.session)
    rememberSessionAccessToken(result.data.session)
    if (!result.error) {
      window.location.replace(safeOAuthReturnTo(event.data.returnTo))
    }
  })
}

export function notifyOAuthOpener(session: Session | null | undefined, returnTo: unknown) {
  if (
    typeof window === 'undefined' ||
    !window.opener ||
    !session?.access_token ||
    !session.refresh_token
  ) {
    return false
  }

  window.opener.postMessage(
    {
      type: OAUTH_CALLBACK_MESSAGE_TYPE,
      session: {
        access_token: session.access_token,
        refresh_token: session.refresh_token,
      },
      returnTo: safeOAuthReturnTo(returnTo),
    },
    window.location.origin,
  )
  return true
}

function rememberSessionAccessToken(session: { access_token?: string } | null | undefined) {
  setNubaseAccessToken(session?.access_token ?? null)
}

function emailFromCredentials(credentials: Parameters<SupabaseClient['auth']['signUp']>[0]) {
  return 'email' in credentials && typeof credentials.email === 'string'
    ? credentials.email.trim()
    : null
}

export function describeAuthError(
  error: unknown,
  fallback = 'Authentication failed. Please try again.',
) {
  if (!error) return fallback
  if (typeof error === 'string') return error
  if (error instanceof Error && error.message.trim()) return error.message

  if (typeof error === 'object') {
    const record = error as Record<string, unknown>
    for (const key of ['message', 'error_description', 'error', 'msg']) {
      const value = record[key]
      if (typeof value === 'string' && value.trim()) {
        return value.trim()
      }
    }
  }

  try {
    const serialized = JSON.stringify(error)
    return serialized && serialized !== '{}' ? serialized : fallback
  } catch {
    return fallback
  }
}

function nubaseHeaders(config: NubasePublicConfig, options?: NubaseFetchOptions) {
  const headers = new Headers(options?.headers)
  headers.set('apikey', config.publishableKey)

  const accessToken = options?.accessToken ?? getNubaseAccessToken()
  if (accessToken && !headers.has('authorization')) {
    headers.set('authorization', `Bearer ${accessToken}`)
  }

  if (!headers.has('content-type') && options?.body) {
    headers.set('content-type', 'application/json')
  }

  return headers
}

export function createNubaseBrowserClient(config = getNubasePublicConfig()) {
  const client = createClient(config.url, config.publishableKey, {
    auth: {
      autoRefreshToken: true,
      detectSessionInUrl: true,
      persistSession: true,
      storageKey: NUBASE_AUTH_STORAGE_KEY,
    },
  })
  installOAuthCallbackMessageHandler(client)
  client.auth.onAuthStateChange((_event, session) => {
    rememberSessionAccessToken(session)
  })

  async function nubaseFetch(path: string, options?: NubaseFetchOptions) {
    const url = path.startsWith('http') ? path : `${config.url}${path}`

    return fetch(url, {
      ...options,
      headers: nubaseHeaders(config, options),
    })
  }

  return {
    config,
    unsupported,
    auth: {
      async signUp(
        credentials: Parameters<typeof client.auth.signUp>[0],
      ) {
        const result = await client.auth.signUp(credentials)
        rememberSessionAccessToken(result.data.session)
        return result
      },
      async signUpWithEmailVerification(
        credentials: Parameters<typeof client.auth.signUp>[0],
      ): Promise<NubaseEmailSignUpResult> {
        const result = await client.auth.signUp(credentials)
        rememberSessionAccessToken(result.data.session)
        const email = emailFromCredentials(credentials)

        if (result.error) {
          return {
            status: 'error',
            email,
            user: result.data.user,
            session: result.data.session,
            error: result.error,
            message: describeAuthError(result.error),
          }
        }

        if (result.data.session) {
          return {
            status: 'signed_in',
            email,
            user: result.data.user,
            session: result.data.session,
            error: null,
            message: null,
          }
        }

        return {
          status: 'verification_required',
          email,
          user: result.data.user,
          session: null,
          error: null,
          message: email
            ? `Check ${email} to verify your email before signing in.`
            : 'Check your email to verify your account before signing in.',
        }
      },
      async resendSignUpConfirmation(
        email: string,
        options?: { emailRedirectTo?: string; captchaToken?: string },
      ) {
        return client.auth.resend({
          type: 'signup',
          email,
          ...(options ? { options } : {}),
        })
      },
      async signInWithPassword(
        credentials: Parameters<typeof client.auth.signInWithPassword>[0],
      ) {
        const result = await client.auth.signInWithPassword(credentials)
        rememberSessionAccessToken(result.data.session)
        return result
      },
      describeError: describeAuthError,
      async signInWithOAuth(options: NubaseSignInWithOAuthOptions) {
        const redirectTo = options.redirectTo ?? defaultOAuthRedirectTo()
        const embedded = isEmbeddedFrame()
        const pendingWindow = embedded ? openPendingOAuthWindow() : null
        const result = await client.auth.signInWithOAuth({
          provider: options.provider,
          options: {
            redirectTo,
            skipBrowserRedirect: embedded,
          },
        })
        if (pendingWindow && result.data.url) {
          openOAuthUrlFromEmbeddedPreview(result.data.url, pendingWindow)
        } else if (pendingWindow) {
          pendingWindow.close()
        } else if (embedded && result.data.url) {
          openOAuthUrlFromEmbeddedPreview(result.data.url, null)
        }
        return result as OAuthResponse
      },
      async getSession() {
        const result = await client.auth.getSession()
        rememberSessionAccessToken(result.data.session)
        return result
      },
      async getUser(accessToken = getNubaseAccessToken() ?? undefined) {
        return client.auth.getUser(accessToken)
      },
      async refreshSession(
        currentSession?: Parameters<typeof client.auth.refreshSession>[0],
      ) {
        const result = await client.auth.refreshSession(currentSession)
        rememberSessionAccessToken(result.data.session)
        return result
      },
      async signOut() {
        const result = await client.auth.signOut()
        setNubaseAccessToken(null)
        return result
      },
      getAccessToken: getNubaseAccessToken,
      setAccessToken: setNubaseAccessToken,
    },
    from(table: string): NubaseTableBuilder {
      return client.from(table) as NubaseTableBuilder
    },
    fetch: nubaseFetch,
    rest(path: string, options?: NubaseFetchOptions) {
      return nubaseFetch(`/rest/v1/${path.replace(/^\/+/, '')}`, options)
    },
    storage(path: string, options?: NubaseFetchOptions) {
      return nubaseFetch(`/storage/v1/${path.replace(/^\/+/, '')}`, options)
    },
    realtime: {
      channel() {
        return unsupported('Realtime channels')
      },
    },
    functions: {
      invoke() {
        return unsupported('Supabase Functions SDK invoke')
      },
    },
  }
}

export type NubaseBrowserClient = ReturnType<typeof createNubaseBrowserClient>

let defaultClient: NubaseBrowserClient | null = null

function getDefaultNubaseClient() {
  defaultClient ??= createNubaseBrowserClient()
  return defaultClient
}

export const nubase = new Proxy({} as NubaseBrowserClient, {
  get(_target, property, receiver) {
    return Reflect.get(getDefaultNubaseClient(), property, receiver)
  },
})

export async function completeOAuthRedirect(client: NubaseBrowserClient = getDefaultNubaseClient()) {
  const { data, error } = await client.auth.getSession()
  return { session: data.session, error }
}
