begin;

do $$
declare
  embedded_count integer;
  mismatched_count integer;
  retrieval_passed boolean;
begin
  select
    count(*) filter (where ce.id is not null),
    count(*) filter (
      where ce.id is null
         or ce.content_sha256 <> c.content_sha256
         or ce.status <> 'active'
    )
  into embedded_count, mismatched_count
  from kb.chunks c
  left join rag.embedding_models em
    on em.provider = 'voyage'
   and em.model = 'voyage-context-4'
   and em.dimensions = 1024
  left join rag.chunk_embeddings ce
    on ce.chunk_id = c.id
   and ce.embedding_model_id = em.id
   and ce.content_sha256 = c.content_sha256
  where c.active
    and c.chunk_id in (
      'LP-RAG-033','LP-RAG-034','LP-RAG-035','LP-RAG-036',
      'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC-CH-001'
    );

  select exists (
    select 1
    from ops.ingestion_jobs
    where job_id = 'LP-EMBED-VIMEO-0005-2026-08-08'
      and status = 'succeeded'
      and counts @> '{"expected_chunks":5,"embedded":5,"pending":0,"retrieval_test_status":"passed","retrieval_test_top_chunk":"LP-RAG-035","retrieval_test_model":"voyage-context-4","retrieval_test_dimensions":1024}'::jsonb
      and (counts->>'retrieval_test_top_similarity')::numeric = 0.533008
  ) into retrieval_passed;

  if embedded_count = 5 and mismatched_count = 0 and retrieval_passed then
    update ops.ingestion_jobs
    set error_summary = null,
        counts = counts || jsonb_build_object(
          'temporary_edge_function_removed', true,
          'temporary_rpc_surface_removed', true,
          'acceptance_status', 'passed'
        )
    where job_id = 'LP-EMBED-VIMEO-0005-2026-08-08';

    update kb.sources
    set metadata = metadata || jsonb_build_object(
      'embedding_status', 'complete',
      'embedding_model', 'voyage-context-4',
      'embedding_dimensions', 1024,
      'embedded_chunk_count', 5,
      'semantic_retrieval_test', 'passed',
      'semantic_retrieval_top_chunk', 'LP-RAG-035',
      'semantic_retrieval_top_similarity', 0.533008,
      'temporary_edge_function_removed', true,
      'temporary_rpc_surface_removed', true
    ),
    updated_at = now()
    where source_id in ('LP-SRC-042','LP-MEDIA-VIMEO-VIDEO-844151157');

    update archive.accessions
    set metadata = metadata || jsonb_build_object(
      'supabase_registration_status', 'complete',
      'voyage_embedding_status', 'complete',
      'voyage_embedding_model', 'voyage-context-4',
      'voyage_embedding_dimensions', 1024,
      'semantic_retrieval_test', 'passed',
      'semantic_retrieval_top_chunk', 'LP-RAG-035'
    )
    where accession_id = 'LP-ACC-2026-0005';

    update archive.items
    set metadata = metadata || jsonb_build_object(
      'rag_embedding_status', 'complete',
      'rag_embedding_model', 'voyage-context-4',
      'rag_retrieval_test', 'passed'
    ),
    updated_at = now()
    where item_id = 'LP-MEDIA-VIMEO-VIDEO-844151157';

    insert into ops.audit_log (
      actor_user_id, actor_role, action, record_type,
      stable_record_id, details
    )
    select
      j.initiated_by,
      'owner',
      'vimeo_0005_rag_embedded_and_retrieval_verified',
      'controlled_document',
      'LP-DOC-ARCH-030',
      jsonb_build_object(
        'accession_id', 'LP-ACC-2026-0005',
        'vimeo_video_id', '844151157',
        'job_id', j.job_id,
        'status', j.status,
        'embedded_chunks', 5,
        'provider', 'voyage',
        'model', 'voyage-context-4',
        'dimensions', 1024,
        'retrieval_test_status', 'passed',
        'retrieval_test_top_chunk', 'LP-RAG-035',
        'retrieval_test_top_similarity', 0.533008,
        'temporary_edge_function_removed', true,
        'temporary_rpc_surface_removed', true,
        'credential_values_recorded', false
      )
    from ops.ingestion_jobs j
    where j.job_id = 'LP-EMBED-VIMEO-0005-2026-08-08'
      and not exists (
        select 1 from ops.audit_log
        where action = 'vimeo_0005_rag_embedded_and_retrieval_verified'
          and stable_record_id = 'LP-DOC-ARCH-030'
      );
  else
    update ops.ingestion_jobs
    set status = 'queued',
        counts = jsonb_build_object(
          'expected_chunks', 5,
          'embedded', embedded_count,
          'pending', greatest(5 - embedded_count, 0),
          'retrieval_test_status', 'pending',
          'temporary_rpc_surface_removed', true
        ),
        error_summary = 'Voyage embeddings are environment-specific and were not copied into this preview or restore; regenerate through an approved controlled runtime before retrieval validation.',
        started_at = null,
        completed_at = null
    where job_id = 'LP-EMBED-VIMEO-0005-2026-08-08';

    update kb.sources
    set metadata = metadata || jsonb_build_object(
      'embedding_status', 'pending_runtime_ingestion',
      'embedding_model', 'voyage-context-4',
      'embedding_dimensions', 1024,
      'semantic_retrieval_test', 'pending',
      'temporary_rpc_surface_removed', true
    ),
    updated_at = now()
    where source_id in ('LP-SRC-042','LP-MEDIA-VIMEO-VIDEO-844151157');

    raise notice 'LP-ACC-2026-0005 embeddings are pending in this preview or restore environment; no paid Voyage request was issued.';
  end if;
end;
$$;

drop function if exists public.claim_lapipa_vimeo_0005_embedding_job(text);
drop function if exists public.get_lapipa_vimeo_0005_embedding_documents(text);
drop function if exists public.store_lapipa_vimeo_0005_embedding_results(text, jsonb);
drop function if exists public.finish_lapipa_vimeo_0005_embedding_job(text, text);
drop function if exists public.search_lapipa_vimeo_0005_test(jsonb);
drop function if exists public.record_lapipa_vimeo_0005_retrieval_test(text, text, jsonb);

do $$
declare remaining_functions integer;
begin
  select count(*) into remaining_functions
  from pg_catalog.pg_proc p
  join pg_catalog.pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
    and p.proname in (
      'claim_lapipa_vimeo_0005_embedding_job',
      'get_lapipa_vimeo_0005_embedding_documents',
      'store_lapipa_vimeo_0005_embedding_results',
      'finish_lapipa_vimeo_0005_embedding_job',
      'search_lapipa_vimeo_0005_test',
      'record_lapipa_vimeo_0005_retrieval_test'
    );

  if remaining_functions <> 0 then
    raise exception 'LP-ACC-2026-0005 temporary RPC cleanup failed' using errcode = '55000';
  end if;
end;
$$;

insert into ops.schema_versions (version, description)
values (
  '2026-08-08-vimeo-0005-rag-final-v1',
  'Finalizes five current Voyage context-4 embeddings and the LP-RAG-035 retrieval acceptance result for LP-ACC-2026-0005 when present, records truthful replay state otherwise, and removes every one-time RPC.'
)
on conflict (version) do nothing;

commit;
