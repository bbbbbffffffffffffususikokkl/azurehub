import { createFileRoute } from '@tanstack/react-router'
import { ChatWorkspace } from '../features/chat/chat-workspace'

export const Route = createFileRoute('/')({
  head: () => ({
    meta: [
      { title: 'Agent Revival — Persistent AI Workspace' },
      { name: 'description', content: 'A fast, resilient AI workspace with durable background tasks and automatic message recovery.' },
    ],
  }),
  component: ChatWorkspace,
})
