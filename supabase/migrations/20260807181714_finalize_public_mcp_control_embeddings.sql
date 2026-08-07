begin;

do $$
declare
  embedding_count integer;
  job_complete boolean;
begin
  select exists (
    select 1
    from ops.ingestion_jobs
    where job_id = 'LP-EMBED-PUBLIC-MCP-CONTROLS-2026-08-07'
      and status = 'succeeded'
      and counts @> '{"expected_chunks":4,"embedded":4,"pending":0}'::jsonb
  ) into job_complete;

  select count(*)
  into embedding_count
  from kb.chunks c
  join rag.chunk_embeddings ce on ce.chunk_id = c.id
  join rag.embedding_models em on em.id = ce.embedding_model_id
  where c.chunk_id in ('LP-RAG-025','LP-RAG-026','LP-RAG-027','LP-RAG-028')
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
      'public_mcp_control_document_embedded',
      'controlled_document',
      'LP-DOC-ARCH-025',
      jsonb_build_object(
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
    where j.job_id = 'LP-EMBED-PUBLIC-MCP-CONTROLS-2026-08-07'
      and not exists (
        select 1 from ops.audit_log
        where action = 'public_mcp_control_document_embedded'
          and stable_record_id = 'LP-DOC-ARCH-025'
      );
  else
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
    where job_id = 'LP-EMBED-PUBLIC-MCP-CONTROLS-2026-08-07';

    insert into ops.audit_log (
      actor_user_id, actor_role, action, record_type, stable_record_id, details
    )
    select
      j.initiated_by,
      'system',
      'public_mcp_control_embedding_replay_pending',
      'controlled_document',
      'LP-DOC-ARCH-025',
      jsonb_build_object(
        'job_id', j.job_id,
        'embedded', embedding_count,
        'pending', 4 - embedding_count,
        'reason', 'environment_specific_embeddings_not_copied',
        'paid_embedding_request_performed', false,
        'temporary_rpc_surface_removed', true
      )
    from ops.ingestion_jobs j
    where j.job_id = 'LP-EMBED-PUBLIC-MCP-CONTROLS-2026-08-07'
      and not exists (
        select 1 from ops.audit_log
        where action = 'public_mcp_control_embedding_replay_pending'
          and stable_record_id = 'LP-DOC-ARCH-025'
      );

    raise notice 'Public MCP control embeddings are pending in this preview or restore environment; no paid Voyage request was issued.';
  end if;
end $$;

drop function if exists public.claim_public_mcp_control_embedding_job(text);
drop function if exists public.get_public_mcp_control_embedding_document(text);
drop function if exists public.store_public_mcp_control_embedding_results(text, jsonb);
drop function if exists public.finish_public_mcp_control_embedding_job(text, text);

create policy public_mcp_rate_limits_no_client_access
  on ops.public_mcp_rate_limits
  as restrictive
  for all
  to anon, authenticated
  using (false)
  with check (false);

create policy public_mcp_daily_budgets_no_client_access
  on ops.public_mcp_daily_budgets
  as restrictive
  for all
  to anon, authenticated
  using (false)
  with check (false);

create policy public_mcp_search_cache_no_client_access
  on ops.public_mcp_search_cache
  as restrictive
  for all
  to anon, authenticated
  using (false)
  with check (false);

create policy public_mcp_audit_log_no_client_access
  on ops.public_mcp_audit_log
  as restrictive
  for all
  to anon, authenticated
  using (false)
  with check (false);

insert into ops.schema_versions (version, description)
values (
  '2026-08-07-public-mcp-control-embedding-final-v1',
  'Finalizes the LP-DOC-ARCH-025 Voyage embedding state, removes the temporary service-role RPC surface, and adds explicit deny-all client policies to the four public MCP control tables.'
)
on conflict (version) do nothing;

commit;
