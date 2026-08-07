begin;

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
  join kb.document_versions dv on dv.document_id = d.id
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

revoke all on function public.get_public_mcp_control_embedding_document(text)
  from public, anon, authenticated;
grant execute on function public.get_public_mcp_control_embedding_document(text)
  to service_role;

do $$
declare
  controlled_chunk_count integer;
  target_function regprocedure :=
    'public.get_public_mcp_control_embedding_document(text)'::regprocedure;
begin
  select count(*) into controlled_chunk_count
  from kb.documents d
  join kb.document_versions dv on dv.document_id = d.id
  join kb.chunks c on c.document_version_id = dv.id
  where d.document_id = 'lp-public-mcp-access-controls-2026-08-07-v1'
    and c.active
    and c.chunk_id in ('LP-RAG-025','LP-RAG-026','LP-RAG-027','LP-RAG-028');

  if controlled_chunk_count <> 4 then
    raise exception 'LP-DOC-ARCH-025 exact active chunk boundary is incomplete';
  end if;

  if exists (
    select 1
    from pg_proc p
    where p.oid = target_function
      and (
        p.prosecdef
        or has_function_privilege('anon', p.oid, 'EXECUTE')
        or has_function_privilege('authenticated', p.oid, 'EXECUTE')
        or not has_function_privilege('service_role', p.oid, 'EXECUTE')
      )
  ) then
    raise exception 'unsafe corrected embedding document function privileges';
  end if;
end $$;

insert into ops.audit_log (
  actor_user_id, actor_role, action, record_type, stable_record_id, details
)
select
  j.initiated_by,
  'system',
  'public_mcp_control_embedding_reader_corrected',
  'controlled_document',
  'LP-DOC-ARCH-025',
  jsonb_build_object(
    'job_id', j.job_id,
    'incorrect_version_filter_removed', '2026-08-07-v1',
    'database_version', '1.0',
    'chunk_boundary', jsonb_build_array('LP-RAG-025','LP-RAG-026','LP-RAG-027','LP-RAG-028'),
    'provider_request_performed_before_correction', false
  )
from ops.ingestion_jobs j
where j.job_id = 'LP-EMBED-PUBLIC-MCP-CONTROLS-2026-08-07'
  and not exists (
    select 1 from ops.audit_log
    where action = 'public_mcp_control_embedding_reader_corrected'
      and stable_record_id = 'LP-DOC-ARCH-025'
  );

insert into ops.schema_versions (version, description)
values (
  '2026-08-07-public-mcp-control-embedding-reader-correction-v1',
  'Removes an incorrect document-version filter from the exact LP-DOC-ARCH-025 embedding reader while preserving its four-chunk and service-role-only boundaries.'
)
on conflict (version) do nothing;

commit;
