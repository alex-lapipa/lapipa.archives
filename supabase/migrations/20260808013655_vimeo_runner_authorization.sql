begin;

create table ops.vimeo_runner_sessions (
  id uuid primary key default gen_random_uuid(),
  session_id text not null unique,
  video_id text not null check (video_id ~ '^[0-9]{6,12}$'),
  code_sha256 text not null unique check (code_sha256 ~ '^[0-9a-f]{64}$'),
  runner_token_sha256 text unique check (
    runner_token_sha256 is null or runner_token_sha256 ~ '^[0-9a-f]{64}$'
  ),
  status text not null default 'code_issued' check (
    status in ('code_issued','authorized','completed','expired','revoked')
  ),
  requested_by uuid not null references auth.users(id) on delete cascade,
  code_expires_at timestamptz not null,
  session_expires_at timestamptz,
  claimed_at timestamptz,
  last_used_at timestamptz,
  completed_at timestamptz,
  use_count integer not null default 0 check (use_count >= 0 and use_count <= 5),
  created_at timestamptz not null default now(),
  check (code_expires_at > created_at),
  check (session_expires_at is null or session_expires_at > created_at)
);

create index vimeo_runner_sessions_status_expiry_idx
  on ops.vimeo_runner_sessions (status, code_expires_at, session_expires_at);
create index vimeo_runner_sessions_requested_by_created_idx
  on ops.vimeo_runner_sessions (requested_by, created_at desc);

alter table ops.vimeo_runner_sessions enable row level security;
revoke all on table ops.vimeo_runner_sessions from public, anon, authenticated;

create or replace function private.create_vimeo_runner_session_internal(
  requested_video_id text,
  requested_code_sha256 text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid := (select auth.uid());
  created_session ops.vimeo_runner_sessions%rowtype;
  source_title text;
begin
  if actor_id is null or not private.has_workspace_role(array['owner']) then
    raise exception 'archive owner authorization required' using errcode = '42501';
  end if;
  if requested_video_id is distinct from '844151157' then
    raise exception 'video is outside the one-video acceptance scope' using errcode = '22023';
  end if;
  if requested_code_sha256 is null or requested_code_sha256 !~ '^[0-9a-f]{64}$' then
    raise exception 'invalid authorization-code digest' using errcode = '22023';
  end if;

  select s.title into source_title
  from kb.sources s
  join kb.documents d
    on d.primary_source_id = s.id
   and d.document_id = s.source_id || '-DOC'
  where s.source_id = 'LP-MEDIA-VIMEO-VIDEO-' || requested_video_id
    and s.origin_uri = 'https://vimeo.com/' || requested_video_id
    and s.access_scope = 'public'
    and s.description = 'vimeo video discovered from lapipa.io.'
    and d.lifecycle_status = 'approved'
  limit 1;
  if source_title is null then
    raise exception 'video lacks approved lapipa.io archive evidence' using errcode = '22023';
  end if;

  update ops.vimeo_runner_sessions
  set status = case
    when code_expires_at <= now() then 'expired'
    else 'revoked'
  end
  where requested_by = actor_id
    and video_id = requested_video_id
    and status in ('code_issued','authorized');

  insert into ops.vimeo_runner_sessions (
    session_id, video_id, code_sha256, requested_by, code_expires_at
  ) values (
    'LP-VIMEO-RUN-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 16)),
    requested_video_id,
    requested_code_sha256,
    actor_id,
    now() + interval '10 minutes'
  )
  returning * into created_session;

  insert into ops.audit_log (
    actor_user_id, actor_role, action, record_type, stable_record_id, details
  ) values (
    actor_id,
    'owner',
    'vimeo_runner_code_issued',
    'vimeo_video',
    'LP-MEDIA-VIMEO-VIDEO-' || requested_video_id,
    jsonb_build_object(
      'session_id', created_session.session_id,
      'code_expires_at', created_session.code_expires_at,
      'acceptance_scope', true
    )
  );

  return jsonb_build_object(
    'session_id', created_session.session_id,
    'video_id', created_session.video_id,
    'title', source_title,
    'code_expires_at', created_session.code_expires_at
  );
end;
$$;

revoke all on function private.create_vimeo_runner_session_internal(text,text)
  from public, anon;
grant execute on function private.create_vimeo_runner_session_internal(text,text)
  to authenticated, service_role;

create or replace function public.create_vimeo_runner_session(
  requested_video_id text,
  requested_code_sha256 text
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.create_vimeo_runner_session_internal(
    requested_video_id,
    requested_code_sha256
  );
$$;

revoke all on function public.create_vimeo_runner_session(text,text)
  from public, anon;
grant execute on function public.create_vimeo_runner_session(text,text)
  to authenticated, service_role;

create or replace function private.exchange_vimeo_runner_code_internal(
  requested_code_sha256 text,
  requested_runner_token_sha256 text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  claimed ops.vimeo_runner_sessions%rowtype;
begin
  if requested_code_sha256 is null
     or requested_code_sha256 !~ '^[0-9a-f]{64}$'
     or requested_runner_token_sha256 is null
     or requested_runner_token_sha256 !~ '^[0-9a-f]{64}$' then
    raise exception 'invalid runner capability digest' using errcode = '22023';
  end if;

  update ops.vimeo_runner_sessions
  set status = 'expired'
  where status = 'code_issued' and code_expires_at <= now();

  update ops.vimeo_runner_sessions
  set status = 'authorized',
      runner_token_sha256 = requested_runner_token_sha256,
      claimed_at = now(),
      last_used_at = now(),
      session_expires_at = now() + interval '2 hours',
      use_count = 0
  where code_sha256 = requested_code_sha256
    and status = 'code_issued'
    and code_expires_at > now()
  returning * into claimed;

  if claimed.id is null then
    raise exception 'authorization code is invalid, expired, or already used' using errcode = '22023';
  end if;

  insert into ops.audit_log (
    actor_user_id, actor_role, action, record_type, stable_record_id, details
  ) values (
    claimed.requested_by,
    'owner',
    'vimeo_runner_authorized',
    'vimeo_video',
    'LP-MEDIA-VIMEO-VIDEO-' || claimed.video_id,
    jsonb_build_object(
      'session_id', claimed.session_id,
      'session_expires_at', claimed.session_expires_at
    )
  );

  return jsonb_build_object(
    'session_id', claimed.session_id,
    'video_id', claimed.video_id,
    'session_expires_at', claimed.session_expires_at
  );
end;
$$;

revoke all on function private.exchange_vimeo_runner_code_internal(text,text)
  from public, anon, authenticated;
grant execute on function private.exchange_vimeo_runner_code_internal(text,text)
  to service_role;

create or replace function public.exchange_vimeo_runner_code(
  requested_code_sha256 text,
  requested_runner_token_sha256 text
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.exchange_vimeo_runner_code_internal(
    requested_code_sha256,
    requested_runner_token_sha256
  );
$$;

revoke all on function public.exchange_vimeo_runner_code(text,text)
  from public, anon, authenticated;
grant execute on function public.exchange_vimeo_runner_code(text,text)
  to service_role;

create or replace function private.use_vimeo_runner_session_internal(
  requested_runner_token_sha256 text,
  requested_action text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  active_session ops.vimeo_runner_sessions%rowtype;
begin
  if requested_runner_token_sha256 is null
     or requested_runner_token_sha256 !~ '^[0-9a-f]{64}$'
     or requested_action is distinct from 'vimeo_download' then
    raise exception 'invalid runner-session request' using errcode = '22023';
  end if;

  update ops.vimeo_runner_sessions
  set status = 'expired'
  where status = 'authorized' and session_expires_at <= now();

  update ops.vimeo_runner_sessions
  set last_used_at = now(),
      use_count = use_count + 1
  where runner_token_sha256 = requested_runner_token_sha256
    and status = 'authorized'
    and session_expires_at > now()
    and use_count < 5
  returning * into active_session;

  if active_session.id is null then
    raise exception 'runner session is invalid or expired' using errcode = '22023';
  end if;

  return jsonb_build_object(
    'session_id', active_session.session_id,
    'video_id', active_session.video_id,
    'requested_by', active_session.requested_by,
    'action', requested_action,
    'session_expires_at', active_session.session_expires_at,
    'use_count', active_session.use_count
  );
end;
$$;

revoke all on function private.use_vimeo_runner_session_internal(text,text)
  from public, anon, authenticated;
grant execute on function private.use_vimeo_runner_session_internal(text,text)
  to service_role;

create or replace function public.use_vimeo_runner_session(
  requested_runner_token_sha256 text,
  requested_action text
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.use_vimeo_runner_session_internal(
    requested_runner_token_sha256,
    requested_action
  );
$$;

revoke all on function public.use_vimeo_runner_session(text,text)
  from public, anon, authenticated;
grant execute on function public.use_vimeo_runner_session(text,text)
  to service_role;

insert into ops.schema_versions (version, description)
values (
  '2026-08-08-vimeo-runner-authorization-v1',
  'Owner-issued, hashed, expiring capability sessions restricted to the one-video Vimeo acceptance test for LP-MEDIA-VIMEO-VIDEO-844151157.'
)
on conflict (version) do nothing;

commit;
