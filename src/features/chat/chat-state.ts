export type SessionLike = { id: string; updatedAt: string }
export type ReplayEvent = {
  seq: number
  type: string
  payload: { delta?: string; message?: string }
}

export function mergeSession<T extends SessionLike>(items: T[], incoming: T): T[] {
  const merged = items.some((item) => item.id === incoming.id)
    ? items.map((item) => item.id === incoming.id ? incoming : item)
    : [...items, incoming]
  return merged.sort((a, b) => +new Date(b.updatedAt) - +new Date(a.updatedAt))
}

export function reconcileSessions<T extends SessionLike>(current: T[], incoming: T[]): T[] {
  const next = new Map(current.map((item) => [item.id, item]))
  for (const item of incoming) next.set(item.id, item)
  return [...next.values()].sort((a, b) => +new Date(b.updatedAt) - +new Date(a.updatedAt))
}

export function summarizeReplay(events: ReplayEvent[], after: number) {
  const ordered = events
    .filter((event) => event.seq > after)
    .sort((a, b) => a.seq - b.seq)
    .filter((event, index, items) => index === 0 || event.seq !== items[index - 1]?.seq)

  return {
    cursor: ordered.at(-1)?.seq ?? after,
    delta: ordered.filter((event) => event.type === 'text_delta').map((event) => event.payload.delta ?? '').join(''),
    completed: ordered.some((event) => event.type === 'done'),
    error: [...ordered].reverse().find((event) => event.type === 'error')?.payload.message ?? '',
  }
}
