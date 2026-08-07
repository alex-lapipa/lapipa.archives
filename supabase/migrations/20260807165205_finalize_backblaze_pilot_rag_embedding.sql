begin;

do $$
declare
  embedding_count integer;
  job_complete boolean;
begin
  select exists (
    select 1
    from ops.ingestion_jobs
    where job_id = 'LP-EMBED-PRESERVATION-2026-08-07'
      and status = 'succeeded'
      and counts @> '{"expected_chunks":4,"embedded":4,"pending":0}'::jsonb
  ) into job_complete;

  select count(*)
  into embedding_count
  from kb.chunks c
  join rag.chunk_embeddings ce on ce.chunk_id = c.id
  join rag.embedding_models em on em.id = ce.embedding_model_id
  where c.chunk_id between 'LP-RAG-021' and 'LP-RAG-024'
    and c.active
    and ce.status = 'active'
    and ce.content_sha256 = c.content_sha256
    and em.provider = 'voyage'
    and em.model = 'voyage-context-4'
    and em.dimensions = 1024;

  if job_complete and embedding_count = 4 then
    insert into ops.audit_log (
      actor_user_id, actor_role, action, record_type, stable_record_id, details
    )
    select
      j.initiated_by,
      'owner',
      'preservation_evidence_rag_embedded',
      'controlled_document',
      'LP-DOC-ARCH-024',
      jsonb_build_object(
        'source_id', 'LP-SRC-039',
        'job_id', j.job_id,
        'status', j.status,
        'counts', j.counts,
        'provider', 'voyage',
        'model', 'voyage-context-4',
        'dimensions', 1024,
        'temporary_edge_function_removed', true,
        'temporary_rpc_surface_removed', true
      )
    from ops.ingestion_jobs j
    where j.job_id = 'LP-EMBED-PRESERVATION-2026-08-07'
      and not exists (
        select 1 from ops.audit_log
        where action = 'preservation_evidence_rag_embedded'
          and stable_record_id = 'LP-DOC-ARCH-024'
      );
  else
    -- Embedding vectors and production Auth rows are operational data and are
    -- intentionally not copied into clean previews or database restores. Keep
    -- the source, document, chunks, provenance, and truthful pending state
    -- replayable without issuing a paid Voyage request during schema setup.
    update ops.ingestion_jobs
    set status = 'queued',
        counts = jsonb_build_object(
          'expected_chunks', 4,
          'embedded', embedding_count,
          'pending', 4 - embedding_count
        ),
        error_summary = 'Voyage embeddings are not copied into this preview or restore environment; regenerate through an approved controlled ingestion run before retrieval validation.',
        started_at = null,
        completed_at = null
    where job_id = 'LP-EMBED-PRESERVATION-2026-08-07';

    insert into ops.audit_log (
      actor_user_id, actor_role, action, record_type, stable_record_id, details
    )
    select
      j.initiated_by,
      'system',
      'preservation_evidence_embedding_replay_pending',
      'controlled_document',
      'LP-DOC-ARCH-024',
      jsonb_build_object(
        'source_id', 'LP-SRC-039',
        'job_id', j.job_id,
        'embedded', embedding_count,
        'pending', 4 - embedding_count,
        'reason', 'environment_specific_embeddings_not_copied',
        'paid_embedding_request_performed', false,
        'temporary_rpc_surface_removed', true
      )
    from ops.ingestion_jobs j
    where j.job_id = 'LP-EMBED-PRESERVATION-2026-08-07'
      and not exists (
        select 1 from ops.audit_log
        where action = 'preservation_evidence_embedding_replay_pending'
          and stable_record_id = 'LP-DOC-ARCH-024'
      );

    raise notice 'Preservation evidence embeddings are pending in this preview or restore environment; no paid Voyage request was issued.';
  end if;
end $$;

drop function if exists public.claim_lapipa_preservation_embedding_job(text);
drop function if exists public.get_lapipa_preservation_embedding_document(text);
drop function if exists public.store_lapipa_preservation_embedding_results(text, jsonb);
drop function if exists public.finish_lapipa_preservation_embedding_job(text, text);

insert into ops.schema_versions (version, description)
values (
  '2026-08-07-backblaze-pilot-rag-final-v1',
  'Finalizes the LP-DOC-ARCH-024 embedding state: verifies four current Voyage vectors when present, otherwise records truthful preview or restore regeneration state, and removes the temporary embedding RPC surface.'
)
on conflict (version) do nothing;

commit;
