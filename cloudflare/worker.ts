interface Env {
  ASSETS: Fetcher
  API_ORIGIN: string
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const incoming = new URL(request.url)

    if (incoming.pathname === "/api" || incoming.pathname.startsWith("/api/")) {
      if (!env.API_ORIGIN) {
        return new Response("API_ORIGIN no está configurado.", { status: 503 })
      }

      const origin = new URL(env.API_ORIGIN)
      origin.pathname = incoming.pathname
      origin.search = incoming.search
      return fetch(new Request(origin, request))
    }

    return env.ASSETS.fetch(request)
  },
}
