create table if not exists public.agent_sessions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid(),
  title text not null default 'New session',
  base_url text not null,
  api_key text not null,
  model text not null,
  status text not null default 'idle' check (status in ('idle','running','completed','failed','cancelled','archived')),
  last_error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists agent_sessions_owner_updated_idx on public.agent_sessions(owner_id, updated_at desc);

create table if not exists public.agent_messages (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.agent_sessions(id) on delete cascade,
  role text not null check (role in ('user','assistant','system')),
  content text not null default '',
  created_at timestamptz not null default now()
);
create index if not exists agent_messages_session_created_idx on public.agent_messages(session_id, created_at asc);

create table if not exists public.agent_runs (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.agent_sessions(id) on delete cascade,
  status text not null default 'queued' check (status in ('queued','running','completed','failed','cancelled')),
  prompt text not null,
  error text,
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists agent_runs_session_created_idx on public.agent_runs(session_id, created_at desc);

create table if not exists public.agent_events (
  seq bigint generated always as identity primary key,
  session_id uuid not null references public.agent_sessions(id) on delete cascade,
  run_id uuid not null references public.agent_runs(id) on delete cascade,
  type text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index if not exists agent_events_session_seq_idx on public.agent_events(session_id, seq asc);

alter table public.agent_sessions enable row level security;
alter table public.agent_messages enable row level security;
alter table public.agent_runs enable row level security;
alter table public.agent_events enable row level security;

grant select, insert, update, delete on public.agent_sessions to authenticated;
grant select, insert, update, delete on public.agent_messages to authenticated;
grant select, insert, update, delete on public.agent_runs to authenticated;
grant select, insert, update, delete on public.agent_events to authenticated;
grant usage, select on all sequences in schema public to authenticated;

create policy agent_sessions_owner_all on public.agent_sessions
  for all to authenticated
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

create policy agent_messages_owner_all on public.agent_messages
  for all to authenticated
  using (exists (select 1 from public.agent_sessions s where s.id = session_id and s.owner_id = auth.uid()))
  with check (exists (select 1 from public.agent_sessions s where s.id = session_id and s.owner_id = auth.uid()));

create policy agent_runs_owner_all on public.agent_runs
  for all to authenticated
  using (exists (select 1 from public.agent_sessions s where s.id = session_id and s.owner_id = auth.uid()))
  with check (exists (select 1 from public.agent_sessions s where s.id = session_id and s.owner_id = auth.uid()));

create policy agent_events_owner_all on public.agent_events
  for all to authenticated
  using (exists (select 1 from public.agent_sessions s where s.id = session_id and s.owner_id = auth.uid()))
  with check (exists (select 1 from public.agent_sessions s where s.id = session_id and s.owner_id = auth.uid()));
