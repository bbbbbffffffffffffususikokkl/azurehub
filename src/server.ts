import handler, { createServerEntry } from '@tanstack/react-start/server-entry'
import {
  clearPlatformRuntime,
  handlePlatformRequest,
  preparePlatformRuntime,
  transformPlatformResponse,
} from './platform/backend'

type RuntimeEnv = Record<string, unknown>

type ExecutionContext = {
  waitUntil(task: Promise<unknown>): void
}

type AssetFetcher = {
  fetch(request: Request): Response | Promise<Response>
}

const ROOT_STATIC_FILE_EXTENSIONS = new Set([
  '.css',
  '.js',
  '.mjs',
  '.json',
  '.wasm',
  '.svg',
  '.png',
  '.jpg',
  '.jpeg',
  '.gif',
  '.webp',
  '.avif',
  '.bmp',
  '.tif',
  '.tiff',
  '.ico',
  '.woff',
  '.woff2',
  '.ttf',
  '.otf',
  '.eot',
  '.txt',
  '.xml',
  '.webmanifest',
])

declare module '@tanstack/react-router' {
  interface Register {
    server: {
      requestContext: {
        env?: RuntimeEnv
        executionContext?: ExecutionContext
      }
    }
  }
}

function renderServerError() {
  return new Response(
    '<!doctype html><html><head><title>Application error</title></head><body><h1>Application error</h1><p>The server failed to render this request.</p></body></html>',
    {
      status: 500,
      headers: {
        'content-type': 'text/html; charset=utf-8',
      },
    },
  )
}

function getAssetsBinding(env?: RuntimeEnv): AssetFetcher | undefined {
  const assets = env?.ASSETS
  if (assets && typeof assets === 'object' && typeof (assets as AssetFetcher).fetch === 'function') {
    return assets as AssetFetcher
  }
  return undefined
}

function extensionForPath(pathname: string): string {
  const filename = pathname.split('/').pop() ?? ''
  const dot = filename.lastIndexOf('.')
  if (dot <= 0) return ''
  return filename.slice(dot).toLowerCase()
}

function isStaticAssetRequest(request: Request): boolean {
  const url = new URL(request.url)
  if (url.pathname.startsWith('/assets/')) return true
  if (url.pathname.endsWith('/')) return false
  const withoutLeadingSlash = url.pathname.replace(/^\/+/, '')
  if (withoutLeadingSlash.includes('/')) return false
  return ROOT_STATIC_FILE_EXTENSIONS.has(extensionForPath(url.pathname))
}

export default createServerEntry({
  async fetch(request, env?: RuntimeEnv, executionContext?: ExecutionContext) {
    try {
      preparePlatformRuntime(request, env)

      const platformResponse = await handlePlatformRequest(request, env)
      if (platformResponse) return platformResponse

      if (isStaticAssetRequest(request)) {
        const assets = getAssetsBinding(env)
        if (assets) return await assets.fetch(request)
      }

      const response = await handler.fetch(request, {
        context: {
          env,
          executionContext,
        },
      })
      return await transformPlatformResponse(response, request, env)
    } catch (error) {
      console.error('[server-entry] Unhandled render error', error)
      return renderServerError()
    } finally {
      clearPlatformRuntime()
    }
  },
})
