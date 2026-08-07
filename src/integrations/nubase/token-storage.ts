export const NUBASE_ACCESS_TOKEN_STORAGE_KEY = 'nubase.access_token'
export const NUBASE_AUTH_STORAGE_KEY = 'nubase.auth'

export function getNubaseAccessToken() {
  if (typeof window === 'undefined') return null
  return window.localStorage.getItem(NUBASE_ACCESS_TOKEN_STORAGE_KEY)
}

export function setNubaseAccessToken(accessToken: string | null) {
  if (typeof window === 'undefined') return

  if (accessToken) {
    window.localStorage.setItem(NUBASE_ACCESS_TOKEN_STORAGE_KEY, accessToken)
  } else {
    window.localStorage.removeItem(NUBASE_ACCESS_TOKEN_STORAGE_KEY)
  }
}
