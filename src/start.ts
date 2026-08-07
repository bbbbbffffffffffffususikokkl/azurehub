import {
  createCsrfMiddleware,
  createMiddleware,
  createStart,
} from '@tanstack/react-start'
import { platformFunctionMiddleware } from './platform/backend'

const csrfMiddleware = createCsrfMiddleware({
  filter: (ctx) => ctx.handlerType === 'serverFn',
})

const requestErrorMiddleware = createMiddleware().server(async ({ next }) => {
  try {
    return await next()
  } catch (error) {
    console.error('[request] Unhandled server error', error)
    throw error
  }
})

export const startInstance = createStart(() => ({
  requestMiddleware: [csrfMiddleware, requestErrorMiddleware],
  functionMiddleware: platformFunctionMiddleware,
}))
