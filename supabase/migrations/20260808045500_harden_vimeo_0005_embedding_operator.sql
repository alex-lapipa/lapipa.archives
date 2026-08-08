begin;

create or replace function public.claim_lapipa_vimeo_0005_embedding_job(requested_job_id text)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare affected integer;
begin
  if requested_job_id <> 'LP-EMBED-VIMEO-0005-2026-08-08' then
    raise exception 'unknown embedding job' using errcode = '22023';
  end if;

  update ops.ingestion_jobs
  set status = 'running',
      started_at = now(),
      completed_at = null,
      error_summary = null
  where job_id = requested_job_id
    and status in ('queued','partially_succeeded','failed');

  get diagnostics affected = row_count;
  return affected = 1;
end;
$$;

create or replace function public.record_lapipa_vimeo_0005_retrieval_test(
  requested_job_id text,
  requested_query text,
  requested_results jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  top_result jsonb;
  top_chunk text;
  top_similarity numeric;
begin
  if requested_job_id <> 'LP-EMBED-VIMEO-0005-2026-08-08'
     or not exists (
       select 1 from ops.ingestion_jobs
       where job_id = requested_job_id and status = 'succeeded'
     ) then
    raise exception 'embedding job is not complete' using errcode = '55000';
  end if;

  if length(btrim(coalesce(requested_query, ''))) = 0
     or length(requested_query) > 500
     or jsonb_typeof(requested_results) <> 'array'
     or jsonb_array_length(requested_results) < 1
     or jsonb_array_length(requested_results) > 5 then
    raise exception 'invalid retrieval test result' using errcode = '22023';
  end if;

  top_result := requested_results->0;
  top_chunk := top_result->>'chunk_id';
  top_similarity := (top_result->>'similarity')::numeric;

  if top_chunk not in (
      'LP-RAG-033','LP-RAG-034','LP-RAG-035','LP-RAG-036',
      'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC-CH-001'
    )
    or top_similarity < -1 or top_similarity > 1 then
    raise exception 'retrieval test result is outside the controlled corpus' using errcode = '22023';
  end if;

  update ops.ingestion_jobs
  set counts = counts || jsonb_build_object(
        'retrieval_test_status', 'passed',
        'retrieval_test_query', requested_query,
        'retrieval_test_top_chunk', top_chunk,
        'retrieval_test_top_similarity', top_similarity,
        'retrieval_test_result_count', jsonb_array_length(requested_results),
        'retrieval_test_model', 'voyage-context-4',
        'retrieval_test_dimensions', 1024
      )
  where job_id = requested_job_id;

  return jsonb_build_object(
    'status', 'passed',
    'top_chunk', top_chunk,
    'top_similarity', top_similarity,
    'result_count', jsonb_array_length(requested_results)
  );
end;
$$;

revoke all on function public.claim_lapipa_vimeo_0005_embedding_job(text) from public, anon, authenticated;
revoke all on function public.record_lapipa_vimeo_0005_retrieval_test(text, text, jsonb) from public, anon, authenticated;
grant execute on function public.claim_lapipa_vimeo_0005_embedding_job(text) to service_role;
grant execute on function public.record_lapipa_vimeo_0005_retrieval_test(text, text, jsonb) to service_role;

do $$
declare unsafe_grants integer;
begin
  select count(*) into unsafe_grants
  from information_schema.routine_privileges
  where routine_schema = 'public'
    and routine_name in (
      'claim_lapipa_vimeo_0005_embedding_job',
      'record_lapipa_vimeo_0005_retrieval_test'
    )
    and grantee in ('PUBLIC','anon','authenticated');

  if unsafe_grants <> 0 then
    raise exception 'LP-ACC-2026-0005 one-time embedding RPC grant invariant failed' using errcode = '55000';
  end if;
end;
$$;

insert into ops.schema_versions (version, description)
values (
  '2026-08-08-vimeo-0005-embedding-operator-v2',
  'Makes the fixed LP-ACC-2026-0005 embedding claim single-use under concurrency and adds a service-role-only fixed-corpus retrieval evidence recorder.'
)
on conflict (version) do nothing;

commit;
