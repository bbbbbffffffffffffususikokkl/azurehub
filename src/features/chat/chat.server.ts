import { createNubaseUserClient } from '../../integrations/nubase/server-client.server'

type ScopedDb = ReturnType<typeof createNubaseUserClient>

export type SessionStatus = 'idle' | 'running' | 'completed' | 'failed' | 'cancelled' | 'archived'

type SessionRow = {
  id: string
  owner_id: string
  title: string
  base_url: string
  api_key: string
  model: string
  status: SessionStatus
  last_error: string | null
  created_at: string
  updated_at: string
}

type MessageRow = {
  id: string
  session_id: string
  role: 'user' | 'assistant' | 'system'
  content: string
  created_at: string
}

type EventRow = {
  seq: number
  session_id: string
  run_id: string
  type: string
  payload: { delta?: string; message?: string } | null
  created_at: string
}


function cleanSession(row: SessionRow) {
  return {
    id: row.id,
    title: row.title,
    model: row.model,
    status: row.status,
    lastError: row.last_error,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

async function ownedSession(db: ScopedDb, sessionId: string) {
  const { data, error } = await db
    .from('agent_sessions')
    .select('*')
    .eq('id', sessionId)
    .maybeSingle()
  if (error) throw error
  if (!data) throw new Error('Session not found')
  return data as SessionRow
}

export async function listSessions(db: ScopedDb) {
  const { data, error } = await db
    .from('agent_sessions')
    .select('*')
    .neq('status', 'archived')
    .order('updated_at', { ascending: false })
    .limit(40)
  if (error) throw error
  return (data as SessionRow[]).map(cleanSession)
}

export async function createSession(db: ScopedDb, ownerId: string, input: {
  baseUrl: string
  apiKey: string
  model: string
}) {
  const baseUrl = input.baseUrl.trim().replace(/\/$/, '')
  if (!/^https:\/\//.test(baseUrl)) throw new Error('Use a secure HTTPS API URL')
  if (!input.apiKey.trim() || !input.model.trim()) throw new Error('API key and model are required')
  const { data, error } = await db
    .from('agent_sessions')
    .insert({
      owner_id: ownerId,
      title: 'New session',
      base_url: baseUrl,
      api_key: input.apiKey.trim(),
      model: input.model.trim(),
      status: 'idle',
    })
    .select('*')
    .single()
  if (error) throw error
  return cleanSession(data as SessionRow)
}

export async function archiveSession(db: ScopedDb, sessionId: string) {
  await ownedSession(db, sessionId)
  const { error } = await db
    .from('agent_sessions')
    .update({ status: 'archived', updated_at: new Date().toISOString() })
    .eq('id', sessionId)
  if (error) throw error
  return { ok: true }
}

export async function getSnapshot(db: ScopedDb, input: { sessionId: string; after?: number }) {
  const session = await ownedSession(db, input.sessionId)
  const after = Number.isFinite(input.after) ? Math.max(0, Number(input.after)) : 0
  const [{ data: messages, error: messagesError }, { data: events, error: eventsError }] = await Promise.all([
    db.from('agent_messages').select('*').eq('session_id', session.id).order('created_at', { ascending: true }).limit(500),
    db.from('agent_events').select('*').eq('session_id', session.id).gt('seq', after).order('seq', { ascending: true }).limit(800),
  ])
  if (messagesError) throw messagesError
  if (eventsError) throw eventsError
  return {
    session: cleanSession(session),
    messages: (messages as MessageRow[]).map((message) => ({
      id: message.id,
      role: message.role,
      content: message.content,
      createdAt: message.created_at,
    })),
    events: (events as EventRow[]).map((event) => ({
      seq: Number(event.seq),
      runId: event.run_id,
      type: event.type,
      payload: {
        ...(typeof event.payload?.delta === 'string' ? { delta: event.payload.delta } : {}),
        ...(typeof event.payload?.message === 'string' ? { message: event.payload.message } : {}),
      },
      createdAt: event.created_at,
    })),
  }
}

async function emit(db: ScopedDb, sessionId: string, runId: string, type: string, payload: Record<string, unknown> = {}) {
  const { error } = await db.from('agent_events').insert({ session_id: sessionId, run_id: runId, type, payload })
  if (error) throw error
}

function decodeSseFrames(buffer: string, flush = false) {
  const normalized = buffer.replace(/\r\n/g, '\n').replace(/\r/g, '\n')
  const frames = normalized.split('\n\n')
  if (flush) return { frames: frames.filter((frame) => frame.trim()), rest: '' }
  return { frames: frames.slice(0, -1), rest: frames.at(-1) ?? '' }
}

async function completeRun(db: ScopedDb, session: SessionRow, runId: string) {
  let assistantText = ''
  let pendingDelta = ''
  let lastFlush = Date.now()

  const flushDelta = async (force = false) => {
    if (!pendingDelta || (!force && Date.now() - lastFlush < 35 && pendingDelta.length < 120)) return
    const delta = pendingDelta
    pendingDelta = ''
    lastFlush = Date.now()
    await emit(db, session.id, runId, 'text_delta', { delta })
  }

  try {
    const { data: history, error: historyError } = await db
      .from('agent_messages')
      .select('role,content')
      .eq('session_id', session.id)
      .order('created_at', { ascending: true })
      .limit(60)
    if (historyError) throw historyError

    await emit(db, session.id, runId, 'started')
    const response = await fetch(`${session.base_url}/chat/completions`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${session.api_key}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: session.model,
        stream: true,
        messages: [
          { role: 'system', content: 'You are a capable AI coding assistant. Be clear, practical, and concise.' },
          ...(history as Array<{ role: string; content: string }>).map(({ role, content }) => ({ role, content })),
        ],
      }),
    })
    if (!response.ok || !response.body) {
      const detail = (await response.text()).slice(0, 500)
      throw new Error(detail || `Provider request failed (${response.status})`)
    }

    const reader = response.body.getReader()
    const decoder = new TextDecoder()
    let buffer = ''
    while (true) {
      const { done, value } = await reader.read()
      buffer += decoder.decode(value, { stream: !done })
      const parsed = decodeSseFrames(buffer, done)
      buffer = parsed.rest
      for (const frame of parsed.frames) {
        const data = frame
          .split('\n')
          .filter((line) => line.startsWith('data:'))
          .map((line) => line.slice(5).trimStart())
          .join('\n')
          .trim()
        if (!data || data === '[DONE]') continue
        try {
          const event = JSON.parse(data) as { choices?: Array<{ delta?: { content?: string } }> }
          const delta = event.choices?.[0]?.delta?.content ?? ''
          if (delta) {
            assistantText += delta
            pendingDelta += delta
            await flushDelta()
          }
        } catch {
          // Ignore malformed provider heartbeat frames without aborting the run.
        }
      }
      if (done) break
    }
    await flushDelta(true)
    if (!assistantText.trim()) throw new Error('The provider returned an empty response')

    const now = new Date().toISOString()
    const [{ error: messageError }, { error: runError }, { error: sessionError }] = await Promise.all([
      db.from('agent_messages').insert({ session_id: session.id, role: 'assistant', content: assistantText }),
      db.from('agent_runs').update({ status: 'completed', completed_at: now }).eq('id', runId),
      db.from('agent_sessions').update({ status: 'completed', last_error: null, updated_at: now }).eq('id', session.id),
    ])
    if (messageError || runError || sessionError) throw messageError ?? runError ?? sessionError
    await emit(db, session.id, runId, 'done', { message: assistantText })
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Background run failed'
    const now = new Date().toISOString()
    await Promise.all([
      db.from('agent_runs').update({ status: 'failed', error: message, completed_at: now }).eq('id', runId),
      db.from('agent_sessions').update({ status: 'failed', last_error: message, updated_at: now }).eq('id', session.id),
      emit(db, session.id, runId, 'error', { message }),
    ])
  }
}

type ExecutionContext = { waitUntil(task: Promise<unknown>): void }

export async function startMessage(
  db: ScopedDb,
  input: { sessionId: string; content: string },
  executionContext?: ExecutionContext,
) {
  const content = input.content.trim()
  if (!content) throw new Error('Write a message first')
  const session = await ownedSession(db, input.sessionId)
  if (session.status === 'running') throw new Error('This session already has a task running')

  const title = session.title === 'New session' ? content.replace(/\s+/g, ' ').slice(0, 46) : session.title
  const { data: run, error: runError } = await db
    .from('agent_runs')
    .insert({ session_id: session.id, status: 'running', prompt: content, started_at: new Date().toISOString() })
    .select('id')
    .single()
  if (runError) throw runError

  const now = new Date().toISOString()
  const runId = String((run as { id: string }).id)
  const [{ error: messageError }, { error: sessionError }] = await Promise.all([
    db.from('agent_messages').insert({ session_id: session.id, role: 'user', content }),
    db.from('agent_sessions').update({ title, status: 'running', last_error: null, updated_at: now }).eq('id', session.id),
  ])
  if (messageError || sessionError) {
    const message = (messageError ?? sessionError)?.message ?? 'Could not start background run'
    await db.from('agent_runs').update({ status: 'failed', error: message, completed_at: now }).eq('id', runId)
    throw messageError ?? sessionError
  }

  const task = completeRun(db, { ...session, title, status: 'running', updated_at: now }, runId)
  if (executionContext) {
    executionContext.waitUntil(task)
  } else {
    void task
  }
  return { runId }
}
