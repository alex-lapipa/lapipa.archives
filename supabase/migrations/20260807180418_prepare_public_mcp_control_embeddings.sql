begin;

create or replace function public.claim_public_mcp_control_embedding_job(requested_job_id text)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $$
declare
  affected integer;
begin
  if requested_job_id <> 'LP-EMBED-PUBLIC-MCP-CONTROLS-2026-08-07' then
    raise exception 'unknown embedding job' using errcode = '22023';
  end if;

  update ops.ingestion_jobs
  set status = 'running',
      started_at = coalesce(started_at, now()),
      completed_at = null,
      error_summary = null
  where job_id = requested_job_id
    and status in ('queued','running','partially_succeeded','failed');

  get diagnostics affected = row_count;
  return affected = 1;
end;
$$;

create or replace function public.get_public_mcp_control_embedding_document(requested_job_id text)
returns jsonb
language plpgsql
stable
security invoker
set search_path = ''
as $$
declare
  result jsonb;
begin
  if requested_job_id <> 'LP-EMBED-PUBLIC-MCP-CONTROLS-2026-08-07'
     or not exists (
       select 1 from ops.ingestion_jobs
       where job_id = requested_job_id and status = 'running'
     ) then
    raise exception 'embedding job is not running' using errcode = '55000';
  end if;

  select jsonb_build_object(
    'document_id', d.document_id,
    'chunks', jsonb_agg(jsonb_build_object(
      'chunk_id', c.chunk_id,
      'content', c.content,
      'content_sha256', c.content_sha256
    ) order by c.ordinal)
  ) into result
  from kb.documents d
  join kb.document_versions dv on dv.document_id = d.id and dv.version = '2026-08-07-v1'
  join kb.chunks c on c.document_version_id = dv.id
  where d.document_id = 'lp-public-mcp-access-controls-2026-08-07-v1'
    and c.active
    and c.chunk_id in ('LP-RAG-025','LP-RAG-026','LP-RAG-027','LP-RAG-028')
  group by d.document_id;

  if result is null or jsonb_array_length(result->'chunks') <> 4 then
    raise exception 'public MCP control embedding document is incomplete' using errcode = '55000';
  end if;

  return result;
end;
$$;

create or replace function public.store_public_mcp_control_embedding_results(
  requested_job_id text,
  requested_items jsonb
)
returns integer
language plpgsql
security invoker
set search_path = ''
as $$
declare
  item jsonb;
  target_chunk kb.chunks%rowtype;
  target_model bigint;
  stored integer := 0;
begin
  if requested_job_id <> 'LP-EMBED-PUBLIC-MCP-CONTROLS-2026-08-07'
     or not exists (
       select 1 from ops.ingestion_jobs
       where job_id = requested_job_id and status = 'running'
     ) then
    raise exception 'embedding job is not running' using errcode = '55000';
  end if;

  if jsonb_typeof(requested_items) <> 'array'
     or jsonb_array_length(requested_items) <> 4 then
    raise exception 'invalid embedding result batch' using errcode = '22023';
  end if;

  select id into target_model
  from rag.embedding_models
  where provider = 'voyage'
    and model = 'voyage-context-4'
    and dimensions = 1024
    and status in ('pilot','active');

  if target_model is null then
    raise exception 'embedding model is not approved' using errcode = '22023';
  end if;

  for item in select value from jsonb_array_elements(requested_items)
  loop
    select * into target_chunk
    from kb.chunks
    where chunk_id = item->>'chunk_id'
      and active
      and chunk_id in ('LP-RAG-025','LP-RAG-026','LP-RAG-027','LP-RAG-028');

    if target_chunk.id is null
       or target_chunk.content_sha256 <> item->>'content_sha256'
       or jsonb_typeof(item->'embedding') <> 'array'
       or jsonb_array_length(item->'embedding') <> 1024 then
      raise exception 'invalid embedding result item' using errcode = '22023';
    end if;

    insert into rag.chunk_embeddings (
      chunk_id, embedding_model_id, embedding, content_sha256,
      status, embedded_at, metadata
    ) values (
      target_chunk.id,
      target_model,
      (item->'embedding')::text::extensions.vector,
      target_chunk.content_sha256,
      'active',
      now(),
      jsonb_build_object(
        'provider', 'voyage',
        'api', 'contextualizedembeddings',
        'input_type', 'document',
        'job_id', 'LP-EMBED-PUBLIC-MCP-CONTROLS-2026-08-07',
        'controlled_document_id', 'LP-DOC-ARCH-025'
      )
    )
    on conflict (chunk_id, embedding_model_id, content_sha256)
    do update set
      embedding = excluded.embedding,
      status = 'active',
      embedded_at = excluded.embedded_at,
      metadata = excluded.metadata;

    stored := stored + 1;
  end loop;

  return stored;
end;
$$;

create or replace function public.finish_public_mcp_control_embedding_job(
  requested_job_id text,
  requested_error text default null
)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $$
declare
  embedded_count integer;
  pending_count integer;
  final_status text;
begin
  if requested_job_id <> 'LP-EMBED-PUBLIC-MCP-CONTROLS-2026-08-07' then
    raise exception 'unknown embedding job' using errcode = '22023';
  end if;

  select
    count(*) filter (where ce.id is not null),
    count(*) filter (where ce.id is null)
  into embedded_count, pending_count
  from kb.chunks c
  left join rag.embedding_models em
    on em.provider = 'voyage'
   and em.model = 'voyage-context-4'
   and em.dimensions = 1024
  left join rag.chunk_embeddings ce
    on ce.chunk_id = c.id
   and ce.embedding_model_id = em.id
   and ce.content_sha256 = c.content_sha256
   and ce.status = 'active'
  where c.active
    and c.chunk_id in ('LP-RAG-025','LP-RAG-026','LP-RAG-027','LP-RAG-028');

  final_status := case
    when pending_count = 0 then 'succeeded'
    when embedded_count > 0 then 'partially_succeeded'
    else 'failed'
  end;

  update ops.ingestion_jobs
  set status = final_status,
      counts = jsonb_build_object(
        'expected_chunks', 4,
        'embedded', embedded_count,
        'pending', pending_count
      ),
      error_summary = left(requested_error, 2000),
      completed_at = case when pending_count = 0 then now() else null end
  where job_id = requested_job_id;

  return jsonb_build_object(
    'status', final_status,
    'embedded', embedded_count,
    'pending', pending_count
  );
end;
$$;

revoke all on function public.claim_public_mcp_control_embedding_job(text)
  from public, anon, authenticated;
revoke all on function public.get_public_mcp_control_embedding_document(text)
  from public, anon, authenticated;
revoke all on function public.store_public_mcp_control_embedding_results(text, jsonb)
  from public, anon, authenticated;
revoke all on function public.finish_public_mcp_control_embedding_job(text, text)
  from public, anon, authenticated;

grant execute on function public.claim_public_mcp_control_embedding_job(text)
  to service_role;
grant execute on function public.get_public_mcp_control_embedding_document(text)
  to service_role;
grant execute on function public.store_public_mcp_control_embedding_results(text, jsonb)
  to service_role;
grant execute on function public.finish_public_mcp_control_embedding_job(text, text)
  to service_role;

do $$
declare
  function_name text;
begin
  foreach function_name in array array[
    'claim_public_mcp_control_embedding_job',
    'get_public_mcp_control_embedding_document',
    'store_public_mcp_control_embedding_results',
    'finish_public_mcp_control_embedding_job'
  ]
  loop
    if exists (
      select 1
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
        and p.proname = function_name
        and (
          p.prosecdef
          or has_function_privilege('anon', p.oid, 'EXECUTE')
          or has_function_privilege('authenticated', p.oid, 'EXECUTE')
          or not has_function_privilege('service_role', p.oid, 'EXECUTE')
        )
    ) then
      raise exception 'unsafe temporary embedding function privileges: %', function_name;
    end if;
  end loop;
end $$;

insert into ops.audit_log (
  actor_user_id, actor_role, action, record_type, stable_record_id, details
)
select
  j.initiated_by,
  'system',
  'public_mcp_control_embedding_prepared',
  'controlled_document',
  'LP-DOC-ARCH-025',
  jsonb_build_object(
    'job_id', j.job_id,
    'chunk_ids', jsonb_build_array('LP-RAG-025','LP-RAG-026','LP-RAG-027','LP-RAG-028'),
    'provider', 'voyage',
    'model', 'voyage-context-4',
    'dimensions', 1024,
    'temporary_rpc_surface', true,
    'client_execute_roles', jsonb_build_array('service_role')
  )
from ops.ingestion_jobs j
where j.job_id = 'LP-EMBED-PUBLIC-MCP-CONTROLS-2026-08-07'
  and not exists (
    select 1 from ops.audit_log
    where action = 'public_mcp_control_embedding_prepared'
      and stable_record_id = 'LP-DOC-ARCH-025'
  );

insert into ops.schema_versions (version, description)
values (
  '2026-08-07-public-mcp-control-embedding-preparation-v1',
  'Creates four exact, service-role-only, invoker-rights RPCs for the controlled Voyage embedding run for LP-DOC-ARCH-025.'
)
on conflict (version) do nothing;

commit;
