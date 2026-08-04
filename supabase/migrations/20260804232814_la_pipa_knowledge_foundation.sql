begin;

create extension if not exists vector with schema extensions;

create schema if not exists kb;
create schema if not exists kg;
create schema if not exists rag;
create schema if not exists ops;
create schema if not exists private;

revoke all on schema kb, kg, rag, ops, private from public, anon;
grant usage on schema kb, kg, rag, ops to authenticated, service_role;
grant usage on schema private to authenticated, service_role;

create table kb.workspace_members (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner', 'editor', 'reviewer', 'reader')),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id)
);

create table kb.collections (
  id bigint generated always as identity primary key,
  collection_id text not null unique,
  title text not null,
  description text,
  version text not null,
  status text not null check (status in ('draft', 'review', 'approved', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table kb.sources (
  id bigint generated always as identity primary key,
  source_id text not null unique,
  title text not null,
  source_type text not null,
  evidence_class text not null,
  source_date date,
  source_date_text text,
  origin_uri text,
  access_scope text not null default 'internal' check (access_scope in ('internal', 'restricted', 'public')),
  verification_status text not null,
  description text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table kb.documents (
  id bigint generated always as identity primary key,
  document_id text not null unique,
  primary_source_id bigint references kb.sources(id) on delete restrict,
  title text not null,
  language text not null default 'en',
  document_type text not null,
  lifecycle_status text not null check (lifecycle_status in ('draft', 'review', 'approved', 'archived')),
  access_scope text not null default 'internal' check (access_scope in ('internal', 'restricted', 'public')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index documents_primary_source_id_idx on kb.documents (primary_source_id);

create table kb.document_versions (
  id bigint generated always as identity primary key,
  document_id bigint not null references kb.documents(id) on delete cascade,
  version text not null,
  content_sha256 text not null check (content_sha256 ~ '^[0-9a-f]{64}$'),
  mime_type text not null,
  byte_count bigint check (byte_count is null or byte_count >= 0),
  storage_bucket text,
  storage_object_path text,
  extracted_text text,
  effective_from timestamptz,
  effective_to timestamptz,
  created_at timestamptz not null default now(),
  unique (document_id, version),
  unique (content_sha256)
);

create index document_versions_document_id_idx on kb.document_versions (document_id);

create table kb.chunks (
  id bigint generated always as identity primary key,
  chunk_id text not null unique,
  document_version_id bigint not null references kb.document_versions(id) on delete cascade,
  ordinal integer not null check (ordinal >= 0),
  heading_path text,
  content text not null check (length(btrim(content)) > 0),
  token_count integer check (token_count is null or token_count > 0),
  content_sha256 text not null check (content_sha256 ~ '^[0-9a-f]{64}$'),
  language text not null default 'en',
  verification_status text not null,
  access_scope text not null default 'internal' check (access_scope in ('internal', 'restricted', 'public')),
  active boolean not null default true,
  search_vector tsvector generated always as (to_tsvector('simple', coalesce(heading_path, '') || ' ' || content)) stored,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (document_version_id, ordinal),
  unique (document_version_id, content_sha256)
);

create index chunks_document_version_id_idx on kb.chunks (document_version_id);
create index chunks_search_vector_idx on kb.chunks using gin (search_vector);
create index chunks_active_verification_idx on kb.chunks (verification_status, id) where active;

create table kb.chunk_sources (
  chunk_id bigint not null references kb.chunks(id) on delete cascade,
  source_id bigint not null references kb.sources(id) on delete restrict,
  locator text,
  support_type text not null default 'supports' check (support_type in ('supports', 'contradicts', 'context', 'unverified_reference')),
  primary key (chunk_id, source_id)
);

create index chunk_sources_source_id_idx on kb.chunk_sources (source_id);

create table kb.claims (
  id bigint generated always as identity primary key,
  claim_id text not null unique,
  statement text not null,
  verification_status text not null,
  confidence numeric(4,3) check (confidence is null or confidence between 0 and 1),
  valid_from date,
  valid_to date,
  review_status text not null check (review_status in ('draft', 'review', 'approved', 'rejected', 'unresolved')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table kb.claim_sources (
  claim_id bigint not null references kb.claims(id) on delete cascade,
  source_id bigint not null references kb.sources(id) on delete restrict,
  locator text,
  support_type text not null check (support_type in ('supports', 'contradicts', 'context', 'unverified_reference')),
  primary key (claim_id, source_id)
);

create index claim_sources_source_id_idx on kb.claim_sources (source_id);

create table kb.entities (
  id bigint generated always as identity primary key,
  entity_id text not null unique,
  canonical_name text not null,
  entity_type text not null,
  description text,
  verification_status text not null,
  access_scope text not null default 'internal' check (access_scope in ('internal', 'restricted', 'public')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table kb.entity_aliases (
  id bigint generated always as identity primary key,
  entity_id bigint not null references kb.entities(id) on delete cascade,
  alias text not null,
  language text,
  alias_type text not null default 'name',
  unique (entity_id, alias)
);

create index entity_aliases_entity_id_idx on kb.entity_aliases (entity_id);

create table kb.events (
  id bigint generated always as identity primary key,
  event_id text not null unique,
  title text not null,
  event_type text not null,
  starts_at timestamptz,
  ends_at timestamptz,
  date_text text,
  location_entity_id bigint references kb.entities(id) on delete set null,
  status text not null check (status in ('documented', 'planned', 'inferred', 'unresolved')),
  description text,
  verification_status text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at is null or starts_at is null or ends_at >= starts_at)
);

create index events_location_entity_id_idx on kb.events (location_entity_id);
create index events_starts_at_idx on kb.events (starts_at, id);

create table kb.event_sources (
  event_id bigint not null references kb.events(id) on delete cascade,
  source_id bigint not null references kb.sources(id) on delete restrict,
  locator text,
  support_type text not null default 'supports' check (support_type in ('supports', 'contradicts', 'context', 'unverified_reference')),
  primary key (event_id, source_id)
);

create index event_sources_source_id_idx on kb.event_sources (source_id);

create table kb.event_entities (
  event_id bigint not null references kb.events(id) on delete cascade,
  entity_id bigint not null references kb.entities(id) on delete cascade,
  role text not null,
  primary key (event_id, entity_id, role)
);

create index event_entities_entity_id_idx on kb.event_entities (entity_id);

create table kb.collection_items (
  collection_id bigint not null references kb.collections(id) on delete cascade,
  record_type text not null,
  stable_record_id text not null,
  ordinal integer not null check (ordinal >= 0),
  primary key (collection_id, record_type, stable_record_id)
);

create table kg.predicate_registry (
  predicate text primary key,
  inverse_predicate text,
  description text not null,
  subject_type_guidance text,
  object_type_guidance text
);

create table kg.relationships (
  id bigint generated always as identity primary key,
  relationship_id text not null unique,
  subject_entity_id bigint not null references kb.entities(id) on delete cascade,
  predicate text not null references kg.predicate_registry(predicate) on delete restrict,
  object_entity_id bigint not null references kb.entities(id) on delete cascade,
  valid_from date,
  valid_to date,
  confidence numeric(4,3) check (confidence is null or confidence between 0 and 1),
  verification_status text not null,
  review_status text not null check (review_status in ('draft', 'review', 'approved', 'rejected', 'unresolved')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (subject_entity_id <> object_entity_id),
  check (valid_to is null or valid_from is null or valid_to >= valid_from),
  unique (subject_entity_id, predicate, object_entity_id, valid_from)
);

create index relationships_subject_predicate_idx on kg.relationships (subject_entity_id, predicate, object_entity_id);
create index relationships_object_predicate_idx on kg.relationships (object_entity_id, predicate, subject_entity_id);

create table kg.relationship_sources (
  relationship_id bigint not null references kg.relationships(id) on delete cascade,
  source_id bigint not null references kb.sources(id) on delete restrict,
  locator text,
  support_type text not null default 'supports' check (support_type in ('supports', 'contradicts', 'context', 'unverified_reference')),
  primary key (relationship_id, source_id)
);

create index relationship_sources_source_id_idx on kg.relationship_sources (source_id);

create table rag.embedding_models (
  id bigint generated always as identity primary key,
  provider text not null,
  model text not null,
  dimensions integer not null check (dimensions > 0 and dimensions <= 2000),
  output_type text not null default 'float',
  distance_metric text not null default 'cosine' check (distance_metric in ('cosine', 'inner_product', 'l2')),
  status text not null check (status in ('pilot', 'active', 'retired')),
  created_at timestamptz not null default now(),
  unique (provider, model, dimensions, output_type)
);

create table rag.chunk_embeddings (
  id bigint generated always as identity primary key,
  chunk_id bigint not null references kb.chunks(id) on delete cascade,
  embedding_model_id bigint not null references rag.embedding_models(id) on delete restrict,
  embedding extensions.vector(1024) not null,
  content_sha256 text not null check (content_sha256 ~ '^[0-9a-f]{64}$'),
  status text not null default 'active' check (status in ('pending', 'active', 'failed', 'superseded')),
  embedded_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb,
  unique (chunk_id, embedding_model_id, content_sha256)
);

create index chunk_embeddings_chunk_id_idx on rag.chunk_embeddings (chunk_id);
create index chunk_embeddings_model_id_idx on rag.chunk_embeddings (embedding_model_id);
create index chunk_embeddings_active_hnsw_idx on rag.chunk_embeddings using hnsw (embedding extensions.vector_cosine_ops) where status = 'active';

create table rag.retrieval_profiles (
  id bigint generated always as identity primary key,
  profile_id text not null unique,
  version text not null,
  keyword_weight numeric(5,4) not null check (keyword_weight between 0 and 1),
  vector_weight numeric(5,4) not null check (vector_weight between 0 and 1),
  candidate_count integer not null check (candidate_count between 1 and 200),
  reranker text,
  active boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  check (keyword_weight + vector_weight = 1)
);

create table rag.evaluation_questions (
  id bigint generated always as identity primary key,
  question_id text not null unique,
  question text not null,
  language text not null,
  expected_source_ids text[] not null default '{}',
  required_concepts text[] not null default '{}',
  forbidden_concepts text[] not null default '{}',
  active boolean not null default true
);

create table rag.evaluation_runs (
  id bigint generated always as identity primary key,
  run_id text not null unique,
  retrieval_profile_id bigint not null references rag.retrieval_profiles(id) on delete restrict,
  embedding_model_id bigint not null references rag.embedding_models(id) on delete restrict,
  metrics jsonb not null,
  result_snapshot jsonb not null,
  created_at timestamptz not null default now()
);

create index evaluation_runs_retrieval_profile_id_idx on rag.evaluation_runs (retrieval_profile_id);
create index evaluation_runs_embedding_model_id_idx on rag.evaluation_runs (embedding_model_id);

create table ops.ingestion_jobs (
  id bigint generated always as identity primary key,
  job_id text not null unique,
  job_type text not null,
  status text not null check (status in ('queued', 'running', 'succeeded', 'partially_succeeded', 'failed', 'cancelled')),
  initiated_by uuid references auth.users(id) on delete set null,
  input_manifest jsonb not null default '{}'::jsonb,
  counts jsonb not null default '{}'::jsonb,
  error_summary text,
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

create index ingestion_jobs_initiated_by_idx on ops.ingestion_jobs (initiated_by);
create index ingestion_jobs_status_created_idx on ops.ingestion_jobs (status, created_at);

create table ops.ingestion_items (
  id bigint generated always as identity primary key,
  ingestion_job_id bigint not null references ops.ingestion_jobs(id) on delete cascade,
  stable_record_id text,
  source_uri text,
  content_sha256 text,
  decision text not null check (decision in ('inserted', 'updated', 'unchanged', 'duplicate', 'rejected', 'failed')),
  error_detail text,
  created_at timestamptz not null default now()
);

create index ingestion_items_job_id_idx on ops.ingestion_items (ingestion_job_id);

create table ops.sync_runs (
  id bigint generated always as identity primary key,
  sync_id text not null unique,
  system text not null,
  direction text not null check (direction in ('inbound', 'outbound', 'bidirectional_dry_run')),
  status text not null check (status in ('queued', 'running', 'succeeded', 'partially_succeeded', 'failed')),
  cursor_state jsonb not null default '{}'::jsonb,
  reconciliation jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

create table ops.review_tasks (
  id bigint generated always as identity primary key,
  review_id text not null unique,
  record_type text not null,
  stable_record_id text not null,
  reason text not null,
  status text not null check (status in ('open', 'approved', 'rejected', 'resolved')),
  assigned_to uuid references auth.users(id) on delete set null,
  resolved_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

create index review_tasks_assigned_to_idx on ops.review_tasks (assigned_to);
create index review_tasks_status_created_idx on ops.review_tasks (status, created_at);

create table ops.audit_log (
  id bigint generated always as identity primary key,
  actor_user_id uuid references auth.users(id) on delete set null,
  actor_role text,
  action text not null,
  record_type text not null,
  stable_record_id text,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index audit_log_actor_user_id_idx on ops.audit_log (actor_user_id);
create index audit_log_record_created_idx on ops.audit_log (record_type, stable_record_id, created_at);

create table ops.schema_versions (
  version text primary key,
  description text not null,
  applied_at timestamptz not null default now()
);

create or replace function private.has_workspace_role(allowed_roles text[])
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select (select auth.uid()) is not null
    and exists (
      select 1
      from kb.workspace_members wm
      where wm.user_id = (select auth.uid())
        and wm.active
        and wm.role = any(allowed_roles)
    );
$$;

revoke all on function private.has_workspace_role(text[]) from public, anon;
grant execute on function private.has_workspace_role(text[]) to authenticated, service_role;

create or replace function public.current_workspace_role()
returns text
language sql
stable
security invoker
set search_path = ''
as $$
  select role
  from kb.workspace_members
  where user_id = (select auth.uid()) and active
  limit 1;
$$;

revoke all on function public.current_workspace_role() from public, anon;
grant execute on function public.current_workspace_role() to authenticated, service_role;

create or replace function public.search_knowledge(
  query_text text,
  query_embedding extensions.vector(1024) default null,
  match_count integer default 10,
  filter_verification text[] default null
)
returns table (
  chunk_id text,
  document_id text,
  heading_path text,
  content text,
  verification_status text,
  source_ids text[],
  keyword_rank real,
  semantic_similarity real,
  combined_score double precision
)
language sql
stable
security invoker
set search_path = ''
as $$
  with permitted as (
    select c.*, d.document_id
    from kb.chunks c
    join kb.document_versions dv on dv.id = c.document_version_id
    join kb.documents d on d.id = dv.document_id
    where c.active
      and (filter_verification is null or c.verification_status = any(filter_verification))
      and private.has_workspace_role(array['owner','editor','reviewer','reader'])
  ),
  keyword as (
    select p.id,
      row_number() over (order by ts_rank_cd(p.search_vector, websearch_to_tsquery('simple', query_text)) desc, p.id) as rank,
      ts_rank_cd(p.search_vector, websearch_to_tsquery('simple', query_text))::real as score
    from permitted p
    where nullif(btrim(query_text), '') is not null
      and p.search_vector @@ websearch_to_tsquery('simple', query_text)
    order by score desc, p.id
    limit greatest(match_count * 5, 20)
  ),
  semantic as (
    select p.id,
      row_number() over (order by ce.embedding operator(extensions.<=>) query_embedding, p.id) as rank,
      (1 - (ce.embedding operator(extensions.<=>) query_embedding))::real as score
    from permitted p
    join rag.chunk_embeddings ce on ce.chunk_id = p.id and ce.status = 'active'
    where query_embedding is not null
    order by ce.embedding operator(extensions.<=>) query_embedding, p.id
    limit greatest(match_count * 5, 20)
  ),
  candidates as (
    select coalesce(k.id, s.id) as id,
      k.score as keyword_rank,
      s.score as semantic_similarity,
      coalesce(1.0 / (60 + k.rank), 0) + coalesce(1.0 / (60 + s.rank), 0) as combined_score
    from keyword k
    full outer join semantic s on s.id = k.id
  )
  select p.chunk_id, p.document_id, p.heading_path, p.content, p.verification_status,
    coalesce(array_agg(src.source_id order by src.source_id) filter (where src.source_id is not null), '{}') as source_ids,
    c.keyword_rank, c.semantic_similarity, c.combined_score
  from candidates c
  join permitted p on p.id = c.id
  left join kb.chunk_sources cs on cs.chunk_id = p.id
  left join kb.sources src on src.id = cs.source_id
  group by p.chunk_id, p.document_id, p.heading_path, p.content, p.verification_status,
    c.keyword_rank, c.semantic_similarity, c.combined_score
  order by c.combined_score desc, p.chunk_id
  limit least(greatest(match_count, 1), 50);
$$;

revoke all on function public.search_knowledge(text, extensions.vector, integer, text[]) from public, anon;
grant execute on function public.search_knowledge(text, extensions.vector, integer, text[]) to authenticated, service_role;

grant select, insert, update, delete on all tables in schema kb, kg, rag, ops to authenticated, service_role;
grant usage, select on all sequences in schema kb, kg, rag, ops to authenticated, service_role;

do $$
declare
  table_record record;
begin
  for table_record in
    select schemaname, tablename
    from pg_tables
    where schemaname in ('kb', 'kg', 'rag', 'ops')
  loop
    execute format('alter table %I.%I enable row level security', table_record.schemaname, table_record.tablename);
    execute format(
      'create policy %I on %I.%I for select to authenticated using ((select private.has_workspace_role(array[''owner'',''editor'',''reviewer'',''reader''])))',
      table_record.tablename || '_member_select', table_record.schemaname, table_record.tablename
    );
    execute format(
      'create policy %I on %I.%I for insert to authenticated with check ((select private.has_workspace_role(array[''owner'',''editor''])))',
      table_record.tablename || '_editor_insert', table_record.schemaname, table_record.tablename
    );
    execute format(
      'create policy %I on %I.%I for update to authenticated using ((select private.has_workspace_role(array[''owner'',''editor'']))) with check ((select private.has_workspace_role(array[''owner'',''editor''])))',
      table_record.tablename || '_editor_update', table_record.schemaname, table_record.tablename
    );
    execute format(
      'create policy %I on %I.%I for delete to authenticated using ((select private.has_workspace_role(array[''owner''])))',
      table_record.tablename || '_owner_delete', table_record.schemaname, table_record.tablename
    );
  end loop;
end $$;

insert into storage.buckets (id, name, public, file_size_limit)
values
  ('source-originals', 'source-originals', false, 524288000),
  ('source-derivatives', 'source-derivatives', false, 524288000),
  ('knowledge-exports', 'knowledge-exports', false, 104857600)
on conflict (id) do update set public = excluded.public, file_size_limit = excluded.file_size_limit;

create policy source_objects_member_select on storage.objects
for select to authenticated
using (
  bucket_id in ('source-originals', 'source-derivatives', 'knowledge-exports')
  and (select private.has_workspace_role(array['owner','editor','reviewer','reader']))
);

create policy source_objects_editor_insert on storage.objects
for insert to authenticated
with check (
  bucket_id in ('source-originals', 'source-derivatives', 'knowledge-exports')
  and (storage.foldername(name))[1] = 'la-pipa'
  and (select private.has_workspace_role(array['owner','editor']))
);

create policy source_objects_editor_update on storage.objects
for update to authenticated
using (
  bucket_id in ('source-originals', 'source-derivatives', 'knowledge-exports')
  and (select private.has_workspace_role(array['owner','editor']))
)
with check (
  bucket_id in ('source-originals', 'source-derivatives', 'knowledge-exports')
  and (storage.foldername(name))[1] = 'la-pipa'
  and (select private.has_workspace_role(array['owner','editor']))
);

create policy source_objects_owner_delete on storage.objects
for delete to authenticated
using (
  bucket_id in ('source-originals', 'source-derivatives', 'knowledge-exports')
  and (select private.has_workspace_role(array['owner']))
);

insert into kb.collections (collection_id, title, description, version, status)
values ('LP-COLLECTION-001', 'La Pipa reviewed workspace corpus', 'Provenance-aware La Pipa corpus compiled from workspace, archive, Notion, and connected-platform evidence.', '2026-08-05-v1', 'approved');

insert into rag.embedding_models (provider, model, dimensions, output_type, distance_metric, status)
values ('voyage', 'voyage-context-4', 1024, 'float', 'cosine', 'pilot');

insert into rag.retrieval_profiles (profile_id, version, keyword_weight, vector_weight, candidate_count, reranker, active, metadata)
values ('LP-RETRIEVAL-HYBRID-001', '1', 0.4000, 0.6000, 40, 'rerank-2.5', true, '{"fusion":"rrf","rerank_default":false}'::jsonb);

insert into kg.predicate_registry (predicate, inverse_predicate, description) values
  ('HAS_COMPONENT', 'COMPONENT_OF', 'A broader entity has a separately modeled component.'),
  ('COMPONENT_OF', 'HAS_COMPONENT', 'An entity is a component of a broader entity.'),
  ('HISTORICALLY_BASED_AT', 'HISTORICAL_BASE_OF', 'An entity historically operated from a place.'),
  ('HISTORICAL_BASE_OF', 'HISTORICALLY_BASED_AT', 'A place historically hosted an entity.'),
  ('CO_FOUNDED', 'CO_FOUNDED_BY', 'A person is documented as a co-founder.'),
  ('CO_FOUNDED_BY', 'CO_FOUNDED', 'An entity is documented as co-founded by a person.'),
  ('OPERATES', 'OPERATED_BY', 'An organization operates or supports an entity.'),
  ('OPERATED_BY', 'OPERATES', 'An entity is operated or supported by an organization.'),
  ('GOVERNED_IN', 'GOVERNS', 'An entity is governed or documented in a knowledge base.'),
  ('GOVERNS', 'GOVERNED_IN', 'A knowledge base governs or documents an entity.'),
  ('LOCATED_IN', 'CONTAINS', 'A place or entity is located within another place.'),
  ('CONTAINS', 'LOCATED_IN', 'A place contains another place or entity.'),
  ('USES_PLATFORM', 'PLATFORM_FOR', 'An entity uses a digital platform.'),
  ('PLATFORM_FOR', 'USES_PLATFORM', 'A digital system is a platform for an entity.');

insert into ops.schema_versions (version, description)
values ('2026-08-05-v1', 'Initial La Pipa provenance, knowledge graph, RAG, operations, RLS, and private Storage foundation.');

alter default privileges for role postgres in schema kb, kg, rag, ops revoke all on tables from public, anon;
alter default privileges for role postgres in schema kb, kg, rag, ops revoke all on sequences from public, anon;
alter default privileges for role postgres in schema kb, kg, rag, ops grant select, insert, update, delete on tables to service_role;
alter default privileges for role postgres in schema kb, kg, rag, ops grant usage, select on sequences to service_role;

commit;
