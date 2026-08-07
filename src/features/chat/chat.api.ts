import { createMiddleware, createServerFn } from '@tanstack/react-start'

type CreateInput = { baseUrl: string; apiKey: string; model: string }
type SessionInput = { sessionId: string }
type SnapshotInput = SessionInput & { after?: number }
type MessageInput = SessionInput & { content: string }
type ExecutionContext = { waitUntil(task: Promise<unknown>): void }

const requireWorkspaceUser = createMiddleware().server(async ({ request, context, next }) => {
  const authorization = request.headers.get('authorization')
  const token = authorization?.match(/^Bearer\s+(.+)$/i)?.[1]
  if (!token) throw new Response('Unauthorized', { status: 401 })

  const { createNubaseUserClient } = await import('../../integrations/nubase/server-client.server')
  const db = createNubaseUserClient(token)
  const { data, error } = await db.auth.getUser()
  if (error || !data.user) throw new Response('Unauthorized', { status: 401 })

  return next({
    context: {
      db,
      userId: data.user.id,
      executionContext: (context.executionContext as ExecutionContext | undefined),
    },
  })
})

export const listSessionsFn = createServerFn({ method: 'GET' })
  .middleware([requireWorkspaceUser])
  .handler(async ({ context }) => {
    const { listSessions } = await import('./chat.server')
    return listSessions(context.db)
  })

export const createSessionFn = createServerFn({ method: 'POST' })
  .middleware([requireWorkspaceUser])
  .validator((data: CreateInput) => data)
  .handler(async ({ data, context }) => {
    const { createSession } = await import('./chat.server')
    return createSession(context.db, context.userId, data)
  })

export const archiveSessionFn = createServerFn({ method: 'POST' })
  .middleware([requireWorkspaceUser])
  .validator((data: SessionInput) => data)
  .handler(async ({ data, context }) => {
    const { archiveSession } = await import('./chat.server')
    return archiveSession(context.db, data.sessionId)
  })

export const getSnapshotFn = createServerFn({ method: 'GET' })
  .middleware([requireWorkspaceUser])
  .validator((data: SnapshotInput) => data)
  .handler(async ({ data, context }) => {
    const { getSnapshot } = await import('./chat.server')
    return getSnapshot(context.db, data)
  })

export const startMessageFn = createServerFn({ method: 'POST' })
  .middleware([requireWorkspaceUser])
  .validator((data: MessageInput) => data)
  .handler(async ({ data, context }) => {
    const { startMessage } = await import('./chat.server')
    return startMessage(context.db, data, context.executionContext)
  })
