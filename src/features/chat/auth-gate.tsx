import { useState } from 'react'
import { LoaderCircle, LockKeyhole, Sparkles } from 'lucide-react'
import { nubase } from '../../integrations/nubase'

type Mode = 'signin' | 'signup'

export function AuthGate({ onAuthenticated }: { onAuthenticated: () => void }) {
  const [mode, setMode] = useState<Mode>('signin')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  const submit = async (event: React.FormEvent) => {
    event.preventDefault()
    setBusy(true)
    setError(null)
    setMessage(null)
    try {
      if (mode === 'signin') {
        const result = await nubase.auth.signInWithPassword({ email: email.trim(), password })
        if (result.error) throw result.error
        if (!result.data.session) throw new Error('Sign-in did not create a session. Please try again.')
        onAuthenticated()
        return
      }

      const result = await nubase.auth.signUpWithEmailVerification({ email: email.trim(), password })
      if (result.status === 'error') throw result.error ?? new Error(result.message ?? 'Could not create account')
      if (result.status === 'verification_required' || !result.session) {
        setMessage(result.message ?? 'Check your email to verify your account before signing in.')
        return
      }
      onAuthenticated()
    } catch (cause) {
      setError(nubase.auth.describeError(cause))
    } finally {
      setBusy(false)
    }
  }

  return (
    <main className="auth-shell">
      <section className="auth-card" aria-labelledby="auth-title">
        <div className="auth-mark"><Sparkles size={22} /></div>
        <div className="eyebrow">Agent Revival v6</div>
        <h1 id="auth-title">{mode === 'signin' ? 'Resume your workspace' : 'Create your workspace'}</h1>
        <p>Sign in to keep sessions private and available across reconnects.</p>
        <form onSubmit={submit}>
          <label>Email<input type="email" value={email} onChange={(event) => setEmail(event.target.value)} autoComplete="email" required /></label>
          <label>Password<input type="password" value={password} onChange={(event) => setPassword(event.target.value)} autoComplete={mode === 'signin' ? 'current-password' : 'new-password'} minLength={8} required /></label>
          {message && <div className="auth-notice" role="status">{message}</div>}
          {error && <div className="auth-error" role="alert">{error}</div>}
          <button className="primary-button" disabled={busy}>{busy ? <LoaderCircle className="animate-spin" size={16} /> : <LockKeyhole size={16} />}{mode === 'signin' ? 'Sign in' : 'Create account'}</button>
        </form>
        <button className="auth-switch" onClick={() => { setMode(mode === 'signin' ? 'signup' : 'signin'); setError(null); setMessage(null) }}>
          {mode === 'signin' ? 'New here? Create an account' : 'Already registered? Sign in'}
        </button>
      </section>
    </main>
  )
}
