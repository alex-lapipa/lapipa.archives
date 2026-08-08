begin;

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
  allowed_video_ids constant text[] := array[
    '844151157',
    '727814369',
    '727847829',
    '729180279',
    '730068690',
    '732187995'
  ];
begin
  if actor_id is null or not private.has_workspace_role(array['owner']) then
    raise exception 'archive owner authorization required' using errcode = '42501';
  end if;
  if requested_video_id is null or not (requested_video_id = any(allowed_video_ids)) then
    raise exception 'video is outside the reviewed Vimeo operator scope' using errcode = '22023';
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
  set status = case when code_expires_at <= now() then 'expired' else 'revoked' end
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
      'operator_scope', case
        when requested_video_id = '844151157' then 'one_video_acceptance'
        else 'reviewed_batch2'
      end
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
  allowed_video_ids constant text[] := array[
    '844151157',
    '727814369',
    '727847829',
    '729180279',
    '730068690',
    '732187995'
  ];
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
  if not (active_session.video_id = any(allowed_video_ids)) then
    raise exception 'runner session is outside the reviewed Vimeo operator scope' using errcode = '22023';
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
      'use_count', active_session.use_count,
      'operator_scope', case
        when active_session.video_id = '844151157' then 'one_video_acceptance'
        else 'reviewed_batch2'
      end
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

insert into ops.schema_versions (version, description)
values (
  '2026-08-08-vimeo-batch2-operator-v1',
  'Extends the owner-capability Vimeo runner only to the five appraised Batch 2 video IDs while retaining the accepted one-video scope and held-item exclusion.'
)
on conflict (version) do nothing;

commit;
