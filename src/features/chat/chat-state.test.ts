import { describe, expect, it } from 'vitest'
import { mergeSession, reconcileSessions, summarizeReplay } from './chat-state'

describe('stream replay reconciliation', () => {
  it('orders, deduplicates, and concatenates missed deltas', () => {
    const result = summarizeReplay([
      { seq: 4, type: 'text_delta', payload: { delta: 'world' } },
      { seq: 3, type: 'text_delta', payload: { delta: 'hello ' } },
      { seq: 4, type: 'text_delta', payload: { delta: 'duplicate' } },
      { seq: 5, type: 'done', payload: {} },
    ], 2)
    expect(result).toEqual({ cursor: 5, delta: 'hello world', completed: true, error: '' })
  })

  it('ignores events already acknowledged by the cursor', () => {
    expect(summarizeReplay([{ seq: 9, type: 'text_delta', payload: { delta: 'old' } }], 9).delta).toBe('')
  })
})

describe('session reconciliation', () => {
  it('updates one session without removing the others', () => {
    const sessions = [
      { id: 'a', updatedAt: '2026-08-01T00:00:00Z', title: 'A' },
      { id: 'b', updatedAt: '2026-08-02T00:00:00Z', title: 'B' },
    ]
    const merged = mergeSession(sessions, { id: 'a', updatedAt: '2026-08-03T00:00:00Z', title: 'Updated A' })
    expect(merged.map((item) => item.id)).toEqual(['a', 'b'])
    expect(merged[0]?.title).toBe('Updated A')
  })

  it('does not erase a known session when a partial refresh omits it', () => {
    const current = [
      { id: 'active', updatedAt: '2026-08-03T00:00:00Z', title: 'Active' },
      { id: 'older', updatedAt: '2026-08-01T00:00:00Z', title: 'Older' },
    ]
    const refreshed = reconcileSessions(current, [
      { id: 'older', updatedAt: '2026-08-04T00:00:00Z', title: 'Renamed' },
    ])
    expect(refreshed.map((item) => item.id)).toEqual(['older', 'active'])
    expect(refreshed.find((item) => item.id === 'older')?.title).toBe('Renamed')
  })
})
