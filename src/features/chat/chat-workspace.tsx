import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import {
  Activity, Archive, ArrowUp, Check, ChevronLeft, Cloud,
  LoaderCircle, LogOut, Menu, MessageSquareText, MoonStar, Plus, Radio, RefreshCw,
  Search, Sparkles, Sun, WifiOff, X,
} from 'lucide-react'
import { toast, Toaster } from 'sonner'
import { archiveSessionFn, createSessionFn, getSnapshotFn, listSessionsFn, startMessageFn } from './chat.api'
import { nubase } from '../../integrations/nubase'
import { AuthGate } from './auth-gate'
import { mergeSession, reconcileSessions, summarizeReplay } from './chat-state'

type Status = 'idle' | 'running' | 'completed' | 'failed' | 'cancelled' | 'archived'
type Session = { id: string; title: string; model: string; status: Status; lastError: string | null; createdAt: string; updatedAt: string }
type Message = { id: string; role: 'user' | 'assistant' | 'system'; content: string; createdAt: string }
type StreamEvent = { seq: number; runId: string; type: string; payload: { delta?: string; message?: string }; createdAt: string }

type Config = { baseUrl: string; apiKey: string; model: string }

function defaultConfig(): Config {
  return { baseUrl: 'https://api.openai.com/v1', apiKey: '', model: 'gpt-4o-mini' }
}

function relativeTime(value: string) {
  const seconds = Math.max(1, Math.floor((Date.now() - new Date(value).getTime()) / 1000))
  if (seconds < 60) return 'now'
  if (seconds < 3600) return `${Math.floor(seconds / 60)}m`
  if (seconds < 86400) return `${Math.floor(seconds / 3600)}h`
  return `${Math.floor(seconds / 86400)}d`
}

function statusMeta(status: Status) {
  if (status === 'running') return { label: 'Working', className: 'status-running' }
  if (status === 'failed') return { label: 'Needs attention', className: 'status-failed' }
  if (status === 'completed') return { label: 'Complete', className: 'status-complete' }
  return { label: 'Ready', className: 'status-idle' }
}

function SessionRow({ session, active, onOpen, onArchive }: { session: Session; active: boolean; onOpen: () => void; onArchive: () => void }) {
  const status = statusMeta(session.status)
  return (
    <div className={`session-row group ${active ? 'session-row-active' : ''}`}>
      <button className="session-main" onClick={onOpen} aria-current={active ? 'page' : undefined}>
        <span className={`session-signal ${status.className}`}><span /></span>
        <span className="min-w-0 flex-1">
          <span className="block truncate text-[13px] font-medium text-white/90">{session.title}</span>
          <span className="mt-1 flex items-center gap-1.5 text-[10px] text-white/38">
            <span>{status.label}</span><span>·</span><span>{relativeTime(session.updatedAt)}</span>
          </span>
        </span>
      </button>
      <button className="archive-button" onClick={onArchive} aria-label={`Archive ${session.title}`}><Archive size={13} /></button>
    </div>
  )
}

function MessageBubble({ message }: { message: Message }) {
  if (message.role === 'system') return null
  const user = message.role === 'user'
  return (
    <article className={`message ${user ? 'message-user' : 'message-assistant'}`}>
      {!user && <div className="agent-mark"><Sparkles size={14} /></div>}
      <div className="message-content">
        <div className="message-copy">{message.content}</div>
        <time>{new Date(message.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</time>
      </div>
    </article>
  )
}

function SetupModal({ open, onClose, onCreate, busy }: { open: boolean; onClose: () => void; onCreate: (config: Config) => void; busy: boolean }) {
  const [config, setConfig] = useState<Config>(defaultConfig)
  if (!open) return null
  return (
    <div className="modal-backdrop" role="presentation">
      <form className="setup-card" onSubmit={(event) => { event.preventDefault(); onCreate(config) }}>
        <div className="setup-glow" />
        <div className="relative">
          <div className="mb-8 flex items-start justify-between">
            <div>
              <div className="eyebrow">New workspace</div>
              <h2>Connect your model</h2>
              <p>Credentials stay server-side and are never returned to the browser.</p>
            </div>
            <button type="button" className="icon-button" onClick={onClose} aria-label="Close"><X size={17} /></button>
          </div>
          <label>API endpoint<input value={config.baseUrl} onChange={(e) => setConfig({ ...config, baseUrl: e.target.value })} placeholder="https://api.openai.com/v1" required /></label>
          <label>API key<input type="password" value={config.apiKey} onChange={(e) => setConfig({ ...config, apiKey: e.target.value })} placeholder="sk-…" autoComplete="off" required /></label>
          <label>Model<input value={config.model} onChange={(e) => setConfig({ ...config, model: e.target.value })} placeholder="gpt-4o-mini" required /></label>
          <button className="primary-button mt-3" disabled={busy}>{busy ? <LoaderCircle className="animate-spin" size={16} /> : <Plus size={16} />} Create session</button>
        </div>
      </form>
    </div>
  )
}

function AuthenticatedWorkspace({ onSignOut }: { onSignOut: () => void }) {
  const [sessions, setSessions] = useState<Session[]>([])
  const [activeId, setActiveId] = useState<string | null>(null)
  const [messages, setMessages] = useState<Message[]>([])
  const [streamText, setStreamText] = useState('')
  const [input, setInput] = useState('')
  const [query, setQuery] = useState('')
  const [loading, setLoading] = useState(true)
  const [creating, setCreating] = useState(false)
  const [sending, setSending] = useState(false)
  const [setupOpen, setSetupOpen] = useState(false)
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [dark, setDark] = useState(true)
  const [online, setOnline] = useState(true)
  const [backendIssue, setBackendIssue] = useState<string | null>(null)
  const [lastSeq, setLastSeq] = useState(0)
  const [returnSummary, setReturnSummary] = useState<string | null>(null)
  const activeRef = useRef<string | null>(null)
  const seqRef = useRef(0)
  const bottomRef = useRef<HTMLDivElement>(null)
  const textareaRef = useRef<HTMLTextAreaElement>(null)

  const activeSession = sessions.find((item) => item.id === activeId) ?? null
  const visibleSessions = useMemo(() => sessions.filter((item) => item.title.toLowerCase().includes(query.toLowerCase())), [sessions, query])

  const refreshSessions = useCallback(async () => {
    try {
      const next = await listSessionsFn()
      setSessions((current) => reconcileSessions(current, next))
      setOnline(true)
      setBackendIssue(null)
      setActiveId((current) => current && next.some((item) => item.id === current)
        ? current
        : next[0]?.id ?? null)
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Could not load sessions'
      setOnline(navigator.onLine)
      setBackendIssue(navigator.onLine ? message : null)
      toast.error(message, { id: 'session-refresh-error' })
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { void refreshSessions() }, [])
  useEffect(() => {
    activeRef.current = activeId
  }, [activeId])
  useEffect(() => { seqRef.current = lastSeq }, [lastSeq])

  const applyEvents = useCallback((events: StreamEvent[]) => {
    if (!events.length) return
    const replay = summarizeReplay(events, seqRef.current)
    if (replay.delta) setStreamText((current) => current + replay.delta)
    seqRef.current = replay.cursor
    setLastSeq(replay.cursor)
    if (replay.completed || replay.error) {
      setStreamText('')
      setSending(false)
      if (document.visibilityState === 'visible') setReturnSummary(replay.completed ? 'Background response synced' : 'Background task needs attention')
    }
  }, [])

  useEffect(() => {
    if (!activeId) { setMessages([]); setStreamText(''); return }
    let stopped = false
    let timer: ReturnType<typeof setTimeout>
    let initial = true
    setMessages([])
    setStreamText('')
    setLastSeq(0)
    seqRef.current = 0

    const poll = async () => {
      try {
        const snapshot = await getSnapshotFn({ data: { sessionId: activeId, after: seqRef.current } })
        if (stopped || activeRef.current !== activeId) return
        setMessages(snapshot.messages)
        if (snapshot.session.status === 'running') {
          applyEvents(snapshot.events)
        } else {
          const cursor = snapshot.events.at(-1)?.seq ?? seqRef.current
          seqRef.current = cursor
          setLastSeq(cursor)
          setStreamText('')
        }
        setOnline(true)
        setBackendIssue(null)
        setSessions((items) => mergeSession(items, snapshot.session))
        setSending(snapshot.session.status === 'running')
        if (initial && snapshot.events.length && document.visibilityState === 'visible') {
          const done = snapshot.events.some((event) => event.type === 'done')
          if (done) setReturnSummary('Caught up with work completed while you were away')
        }
        initial = false
        timer = setTimeout(poll, snapshot.session.status === 'running' ? 180 : 2200)
      } catch (error) {
        if (stopped) return
        setOnline(navigator.onLine)
        setBackendIssue(navigator.onLine ? (error instanceof Error ? error.message : 'The workspace service is temporarily unavailable.') : null)
        timer = setTimeout(poll, 2500)
      }
    }
    void poll()
    return () => { stopped = true; clearTimeout(timer) }
  }, [activeId, applyEvents])

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: streamText ? 'auto' : 'smooth' })
  }, [messages, streamText])

  useEffect(() => {
    const onVisible = () => { if (document.visibilityState === 'visible') void refreshSessions() }
    document.addEventListener('visibilitychange', onVisible)
    window.addEventListener('online', onVisible)
    return () => { document.removeEventListener('visibilitychange', onVisible); window.removeEventListener('online', onVisible) }
  }, [refreshSessions])

  const create = async (config: Config) => {
    setCreating(true)
    try {
      const created = await createSessionFn({ data: config })
      setSessions((items) => [created, ...items])
      setActiveId(created.id)
      setSetupOpen(false)
      toast.success('Session ready')
    } catch (error) {
      toast.error(error instanceof Error ? error.message : 'Could not create session')
    } finally { setCreating(false) }
  }

  const archive = async (session: Session) => {
    if (!window.confirm(`Archive “${session.title}”? Its history will no longer appear in the session rail.`)) return
    try {
      await archiveSessionFn({ data: { sessionId: session.id } })
      setSessions((items) => items.filter((item) => item.id !== session.id))
      if (activeId === session.id) {
        setActiveId(sessions.find((item) => item.id !== session.id)?.id ?? null)
      }
      toast.success('Session archived')
    } catch (error) {
      toast.error(error instanceof Error ? error.message : 'Could not archive session')
    }
  }

  const send = async () => {
    const content = input.trim()
    if (!activeId || !content || sending) return
    setInput('')
    setSending(true)
    const optimistic: Message = { id: `pending-${Date.now()}`, role: 'user', content, createdAt: new Date().toISOString() }
    setMessages((items) => [...items, optimistic])
    try {
      await startMessageFn({ data: { sessionId: activeId, content } })
      await refreshSessions()
    } catch (error) {
      setMessages((items) => items.filter((item) => item.id !== optimistic.id))
      setInput(content)
      setSending(false)
      toast.error(error instanceof Error ? error.message : 'Could not start task')
    }
  }

  return (
    <div className={dark ? 'app-shell dark' : 'app-shell'}>
      <Toaster theme={dark ? 'dark' : 'light'} position="top-center" richColors />
      <SetupModal open={setupOpen} onClose={() => setSetupOpen(false)} onCreate={create} busy={creating} />
      <aside className={`sidebar ${sidebarOpen ? 'sidebar-open' : ''}`}>
        <div className="brand-row"><div className="brand-mark"><Sparkles size={16} /></div><div><strong>Agent Revival</strong><span>Persistent AI workspace</span></div><button className="mobile-close" onClick={() => setSidebarOpen(false)}><X size={18} /></button></div>
        <button className="new-session" onClick={() => setSetupOpen(true)}><Plus size={15} /> New session <kbd>⌘ N</kbd></button>
        <div className="search-box"><Search size={14} /><input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Search sessions" /></div>
        <div className="session-heading"><span>Sessions</span><span>{sessions.length}</span></div>
        <nav className="session-list" aria-label="Sessions">
          {visibleSessions.map((session) => <SessionRow key={session.id} session={session} active={session.id === activeId} onOpen={() => { setActiveId(session.id); setSidebarOpen(false) }} onArchive={() => void archive(session)} />)}
          {!loading && !visibleSessions.length && <div className="empty-sessions"><MessageSquareText size={20} /><p>No sessions yet</p><span>Create one to begin.</span></div>}
        </nav>
        <div className="sidebar-footer">
          <div className="connection-state">{online ? <Cloud size={14} /> : <WifiOff size={14} />}<span>{online ? 'Synced' : 'Reconnecting'}</span><i className={online ? 'online' : ''} /></div>
          <button className="icon-button" onClick={() => setDark((value) => !value)} aria-label="Toggle appearance">{dark ? <Sun size={16} /> : <MoonStar size={16} />}</button>
          <button className="icon-button" onClick={() => void onSignOut()} aria-label="Sign out"><LogOut size={16} /></button>
        </div>
      </aside>

      <main className="workspace">
        <header className="workspace-header">
          <button className="menu-button" onClick={() => setSidebarOpen(true)}><Menu size={18} /></button>
          <div className="header-title">
            <div className="mobile-back"><ChevronLeft size={16} /></div>
            <div><h1>{activeSession?.title ?? 'Agent Revival'}</h1><p>{activeSession ? activeSession.model : 'Create a session to start'}</p></div>
          </div>
          <div className="header-actions">
            {activeSession && <span className={`live-pill ${activeSession.status === 'running' ? 'is-live' : ''}`}><Radio size={13} />{activeSession.status === 'running' ? 'Streaming live' : statusMeta(activeSession.status).label}</span>}
            <button className="icon-button" onClick={() => void refreshSessions()} aria-label="Refresh"><RefreshCw size={15} /></button>
          </div>
        </header>

        {returnSummary && <button className="return-summary" onClick={() => setReturnSummary(null)}><Check size={14} />{returnSummary}<X size={13} /></button>}
        {!online && <div className="offline-banner"><WifiOff size={14} /> You are offline. Your server-side task will continue; reconnecting automatically.</div>}
        {online && backendIssue && <div className="offline-banner"><Cloud size={14} /> Workspace service unavailable. <button onClick={() => void refreshSessions()}>Retry now</button></div>}

        <section className="conversation" aria-live="polite">
          <div className="conversation-inner">
            {!activeSession ? (
              <div className="empty-workspace"><div className="hero-mark"><Sparkles size={25} /></div><div className="eyebrow">Durable by design</div><h2>Your work keeps moving.</h2><p>Start a session, send a task, and leave whenever you need. Responses are stored and reconciled when you return.</p><button className="primary-button compact" onClick={() => setSetupOpen(true)}><Plus size={16} /> Create your first session</button></div>
            ) : messages.length === 0 && !sending ? (
              <div className="empty-workspace"><div className="hero-mark"><Activity size={24} /></div><div className="eyebrow">Session is ready</div><h2>What are we building?</h2><p>Ask for code, analysis, a plan, or a long-running task. You can safely close this tab after it starts.</p><div className="prompt-grid"><button onClick={() => setInput('Audit this codebase and list the highest-impact bugs.')}>Audit a codebase<span>Find risky defects and race conditions</span></button><button onClick={() => setInput('Create a practical implementation plan for this feature: ')}>Plan a feature<span>Break work into clear milestones</span></button></div></div>
            ) : (
              <>{messages.map((message) => <MessageBubble key={message.id} message={message} />)}{streamText && <MessageBubble message={{ id: 'streaming', role: 'assistant', content: streamText, createdAt: new Date().toISOString() }} />}{sending && !streamText && <div className="thinking-row"><div className="agent-mark"><Sparkles size={14} /></div><div><span /><span /><span /></div><p>Thinking and working in the background</p></div>}<div ref={bottomRef} /></>
            )}
          </div>
        </section>

        <footer className="composer-wrap">
          <div className="composer">
            <textarea ref={textareaRef} value={input} onChange={(event) => setInput(event.target.value)} onKeyDown={(event) => { if (event.key === 'Enter' && !event.shiftKey) { event.preventDefault(); void send() } }} placeholder={activeSession ? 'Message Agent Revival…' : 'Create a session to begin'} disabled={!activeSession || sending} rows={1} />
            <div className="composer-bottom"><div className="composer-hint"><span className={online ? 'pulse-dot' : 'pulse-dot offline'} />{sending ? 'Task continues if you leave' : 'Enter to send · Shift + Enter for newline'}</div><button className="send-button" onClick={() => void send()} disabled={!activeSession || !input.trim() || sending} aria-label="Send message">{sending ? <LoaderCircle className="animate-spin" size={17} /> : <ArrowUp size={18} />}</button></div>
          </div>
          <p className="fine-print">Responses are persisted as they arrive and automatically recovered across reconnects.</p>
        </footer>
      </main>
    </div>
  )
}


export function ChatWorkspace() {
  const [authState, setAuthState] = useState<'loading' | 'signed-out' | 'signed-in'>('loading')

  useEffect(() => {
    let active = true
    void nubase.auth.getSession().then(({ data }) => {
      if (active) setAuthState(data.session ? 'signed-in' : 'signed-out')
    }).catch(() => {
      if (active) setAuthState('signed-out')
    })
    return () => { active = false }
  }, [])

  if (authState === 'loading') {
    return <main className="auth-shell"><LoaderCircle className="animate-spin" size={24} aria-label="Loading workspace" /></main>
  }
  if (authState === 'signed-out') {
    return <AuthGate onAuthenticated={() => setAuthState('signed-in')} />
  }
  return <AuthenticatedWorkspace onSignOut={async () => { await nubase.auth.signOut(); setAuthState('signed-out') }} />
}
