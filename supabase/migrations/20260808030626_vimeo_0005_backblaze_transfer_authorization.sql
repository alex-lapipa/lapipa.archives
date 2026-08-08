begin;

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
     or requested_action is null
     or requested_action not in ('vimeo_download', 'backblaze_transfer_bundle') then
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
  if active_session.video_id is distinct from '844151157' then
    raise exception 'runner session is outside the acceptance scope' using errcode = '22023';
  end if;

  insert into ops.audit_log (
    actor_user_id, actor_role, action, record_type, stable_record_id, details
  ) values (
    active_session.requested_by,
    'owner',
    'vimeo_runner_capability_used',
    'vimeo_video',
    'LP-MEDIA-VIMEO-VIDEO-' || active_session.video_id,
    jsonb_build_object(
      'session_id', active_session.session_id,
      'requested_action', requested_action,
      'use_count', active_session.use_count
    )
  );

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
  '2026-08-08-vimeo-runner-authorization-v3',
  'Adds a service-only, owner-capability-backed Backblaze transfer bundle action restricted to accession LP-ACC-2026-0005 and Vimeo 844151157.'
)
on conflict (version) do nothing;

commit;
