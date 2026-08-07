import { createMiddleware } from '@tanstack/react-start'
import { createNubaseUserClient } from './server-client.server'

function getBearerToken(request: Request) {
  const authorization = request.headers.get('authorization')
  const match = authorization?.match(/^Bearer\s+(.+)$/i)
  return match?.[1] ?? null
}

export const withNubaseUser = createMiddleware().server(
  async ({ request, next }) => {
    const accessToken = getBearerToken(request)

    return next({
      context: {
        nubase: accessToken ? createNubaseUserClient(accessToken) : null,
        nubaseAccessToken: accessToken,
      },
    })
  },
)

export const requireNubaseUser = createMiddleware().server(
  async ({ request, next }) => {
    const accessToken = getBearerToken(request)

    if (!accessToken) {
      throw new Response('Unauthorized', { status: 401 })
    }

    return next({
      context: {
        nubase: createNubaseUserClient(accessToken),
        nubaseAccessToken: accessToken,
      },
    })
  },
)
