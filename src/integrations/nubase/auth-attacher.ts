import { createMiddleware } from '@tanstack/react-start'
import { getNubaseAccessToken } from './token-storage'

export const attachNubaseAuth = createMiddleware({ type: 'function' }).client(
  async ({ next }) => {
    const accessToken = getNubaseAccessToken()

    if (!accessToken) {
      return next()
    }

    return next({
      headers: {
        authorization: `Bearer ${accessToken}`,
      },
    })
  },
)
