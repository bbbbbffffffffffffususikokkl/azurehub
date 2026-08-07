import { createFileRoute, useNavigate, useSearch } from '@tanstack/react-router'
import { useEffect, useState } from 'react'
import { completeOAuthRedirect, notifyOAuthOpener } from '../../integrations/nubase'

type CallbackSearch = {
  returnTo?: string
}

function safeReturnTo(value: unknown) {
  if (typeof value !== 'string' || !value.startsWith('/')) {
    return '/'
  }
  if (value.startsWith('//')) {
    return '/'
  }
  return value
}

export const Route = createFileRoute('/auth/callback')({
  validateSearch: (search: Record<string, unknown>): CallbackSearch => ({
    returnTo: typeof search.returnTo === 'string' ? search.returnTo : undefined,
  }),
  component: AuthCallback,
})

function AuthCallback() {
  const navigate = useNavigate()
  const search = useSearch({ from: '/auth/callback' })
  const [errorMessage, setErrorMessage] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false

    async function finishRedirect() {
      const { error, session } = await completeOAuthRedirect()
      if (cancelled) return
      if (error) {
        setErrorMessage(error.message || 'Unable to complete Google login.')
        await navigate({
          to: '/',
          search: { authError: 'oauth_callback_failed' },
          replace: true,
        })
        return
      }
      if (notifyOAuthOpener(session, search.returnTo)) {
        window.close()
        setTimeout(() => {
          window.location.replace(safeReturnTo(search.returnTo))
        }, 300)
        return
      }
      window.location.replace(safeReturnTo(search.returnTo))
    }

    finishRedirect().catch(async () => {
      if (cancelled) return
      setErrorMessage('Unable to complete Google login.')
      await navigate({
        to: '/',
        search: { authError: 'oauth_callback_failed' },
        replace: true,
      })
    })

    return () => {
      cancelled = true
    }
  }, [navigate, search.returnTo])

  return (
    <main className="flex min-h-screen items-center justify-center px-6 py-12">
      <div className="w-full max-w-sm text-center">
        <h1 className="text-xl font-semibold text-neutral-950">Completing sign in</h1>
        <p className="mt-3 text-sm text-neutral-600">
          {errorMessage ?? 'Please wait while Google returns you to the app.'}
        </p>
      </div>
    </main>
  )
}
