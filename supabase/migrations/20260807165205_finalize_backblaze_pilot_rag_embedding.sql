begin;

do $$
begin
  if not exists (
    select 1
    from ops.ingestion_jobs
    where job_id = 'LP-EMBED-PRESERVATION-2026-08-07'
      and status = 'succeeded'
      and counts @> '{"expected_chunks":4,"embedded":4,"pending":0}'::jsonb
  ) then
    raise exception 'Preservation evidence embedding job is not complete';
  end if;

  if (
    select count(*)
    from kb.chunks c
    join rag.chunk_embeddings ce on ce.chunk_id = c.id
    join rag.embedding_models em on em.id = ce.embedding_model_id
    where c.chunk_id between 'LP-RAG-021' and 'LP-RAG-024'
      and c.active
      and ce.status = 'active'
      and ce.content_sha256 = c.content_sha256
      and em.provider = 'voyage'
      and em.model = 'voyage-context-4'
      and em.dimensions = 1024
  ) <> 4 then
    raise exception 'Preservation evidence embeddings are incomplete or stale';
  end if;
end $$;

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
  and j.status = 'succeeded'
  and not exists (
    select 1 from ops.audit_log
    where action = 'preservation_evidence_rag_embedded'
      and stable_record_id = 'LP-DOC-ARCH-024'
  );

drop function public.claim_lapipa_preservation_embedding_job(text);
drop function public.get_lapipa_preservation_embedding_document(text);
drop function public.store_lapipa_preservation_embedding_results(text, jsonb);
drop function public.finish_lapipa_preservation_embedding_job(text, text);

insert into ops.schema_versions (version, description)
values (
  '2026-08-07-backblaze-pilot-rag-final-v1',
  'Verifies four current Voyage embeddings for LP-DOC-ARCH-024 and removes the temporary service-role embedding RPC surface.'
)
on conflict (version) do nothing;

commit;
