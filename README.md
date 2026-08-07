# Ottermind VibeCoding Template

Thin TanStack Start shell for Ottermind website generation. The template keeps routing, Cloudflare Worker build config, Tailwind CSS, UI primitives, and VibeCoding policy files stable so product work can stay focused on source edits.

## Commands

```bash
bun install
bun run dev
bun run build
bun run test
```

Use `bun run build` as the local build command. In Ottermind, the normal completion gate is `mcp__ottermind__build_vibecoding_version`, which builds the TanStack Start worker and registers the platform version.

## Editing Boundaries

- Start normal page work in `src/routes/index.tsx`.
- Add reusable feature components under `src/components`.
- Keep business UI and state out of `src/routes/__root.tsx`; it owns the HTML shell, metadata, stylesheet link, and scripts.
- Do not manually edit `src/routeTree.gen.ts`.
- Keep `vite.config.ts` as a thin `defineVibeCodingConfig()` wrapper.
- Do not add real auth, database, storage, or server functions unless the user explicitly requests backend behavior.

## Runtime Notes

The production artifact must include `dist/client` plus a server entrypoint under `dist/server`. Static-only `dist/index.html` output is not a valid VibeCoding artifact.

Server-only logic belongs in TanStack Start server functions or `.server.ts` modules. Do not put secrets, service-role keys, database clients, or server-only side effects in client-reachable code.
