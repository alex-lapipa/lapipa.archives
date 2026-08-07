begin;

-- Public publication is affirmative. Existing events pre-date an explicit
-- release field, so they remain internal until an owner review promotes them.
alter table kb.events
  add column access_scope text not null default 'internal'
  check (access_scope in ('internal', 'restricted', 'public'));

create index events_public_starts_at_idx
  on kb.events (starts_at, id)
  where access_scope = 'public';

create table ops.public_mcp_rate_limits (
  window_started_at timestamptz not null,
  client_hash text not null check (client_hash ~ '^[0-9a-f]{64}$'),
  action text not null check (action ~ '^[a-z0-9_:-]{1,80}$'),
  request_count integer not null default 1 check (request_count > 0),
  updated_at timestamptz not null default now(),
  primary key (window_started_at, client_hash, action)
);
create index public_mcp_rate_limits_updated_idx
  on ops.public_mcp_rate_limits (updated_at);

create table ops.public_mcp_daily_budgets (
  budget_date date not null,
  metric text not null check (metric ~ '^[a-z0-9_:-]{1,80}$'),
  usage_count integer not null default 0 check (usage_count >= 0),
  updated_at timestamptz not null default now(),
  primary key (budget_date, metric)
);

create table ops.public_mcp_search_cache (
  cache_key text primary key check (cache_key ~ '^[0-9a-f]{64}$'),
  result jsonb not null check (jsonb_typeof(result) = 'object'),
  expires_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index public_mcp_search_cache_expiry_idx
  on ops.public_mcp_search_cache (expires_at);

create table ops.public_mcp_audit_log (
  id bigint generated always as identity primary key,
  request_id uuid not null,
  client_hash text not null check (client_hash ~ '^[0-9a-f]{64}$'),
  action text not null check (action ~ '^[a-z0-9_:-]{1,80}$'),
  outcome text not null check (outcome in ('success', 'rejected', 'error')),
  paid_embedding boolean not null default false,
  cache_hit boolean not null default false,
  duration_ms integer check (duration_ms is null or duration_ms >= 0),
  details jsonb not null default '{}'::jsonb check (jsonb_typeof(details) = 'object'),
  created_at timestamptz not null default now(),
  unique (request_id)
);
create index public_mcp_audit_created_idx
  on ops.public_mcp_audit_log (created_at desc);
create index public_mcp_audit_action_outcome_idx
  on ops.public_mcp_audit_log (action, outcome, created_at desc);

alter table ops.public_mcp_rate_limits enable row level security;
alter table ops.public_mcp_daily_budgets enable row level security;
alter table ops.public_mcp_search_cache enable row level security;
alter table ops.public_mcp_audit_log enable row level security;

revoke all on ops.public_mcp_rate_limits from public, anon, authenticated;
revoke all on ops.public_mcp_daily_budgets from public, anon, authenticated;
revoke all on ops.public_mcp_search_cache from public, anon, authenticated;
revoke all on ops.public_mcp_audit_log from public, anon, authenticated;
revoke all on sequence ops.public_mcp_audit_log_id_seq from public, anon, authenticated;
grant select, insert, update, delete on ops.public_mcp_rate_limits to service_role;
grant select, insert, update, delete on ops.public_mcp_daily_budgets to service_role;
grant select, insert, update, delete on ops.public_mcp_search_cache to service_role;
grant select, insert, delete on ops.public_mcp_audit_log to service_role;
grant usage, select on sequence ops.public_mcp_audit_log_id_seq to service_role;

create or replace function public.mcp_consume_rate_limit(
  requested_client_hash text,
  requested_action text,
  requested_max_requests integer,
  requested_window_seconds integer
)
returns table (allowed boolean, remaining integer, reset_at timestamptz)
language plpgsql
volatile
security invoker
set search_path = ''
as $$
declare
  bucket_start timestamptz;
  observed_count integer;
begin
  if requested_client_hash !~ '^[0-9a-f]{64}$'
    or requested_action !~ '^[a-z0-9_:-]{1,80}$'
    or requested_max_requests not between 1 and 10000
    or requested_window_seconds not between 1 and 3600 then
    raise exception 'invalid rate-limit request' using errcode = '22023';
  end if;

  bucket_start := date_bin(
    make_interval(secs => requested_window_seconds),
    clock_timestamp(),
    '2000-01-01 00:00:00+00'::timestamptz
  );

  insert into ops.public_mcp_rate_limits (
    window_started_at, client_hash, action, request_count, updated_at
  ) values (
    bucket_start, requested_client_hash, requested_action, 1, now()
  )
  on conflict (window_started_at, client_hash, action)
  do update set
    request_count = ops.public_mcp_rate_limits.request_count + 1,
    updated_at = now()
  returning request_count into observed_count;

  return query select
    observed_count <= requested_max_requests,
    greatest(requested_max_requests - observed_count, 0),
    bucket_start + make_interval(secs => requested_window_seconds);
end;
$$;

create or replace function public.mcp_consume_daily_budget(
  requested_metric text,
  requested_max_units integer,
  requested_units integer default 1
)
returns table (allowed boolean, remaining integer, reset_at timestamptz)
language plpgsql
volatile
security invoker
set search_path = ''
as $$
declare
  today_utc date := (clock_timestamp() at time zone 'utc')::date;
  observed_count integer;
begin
  if requested_metric !~ '^[a-z0-9_:-]{1,80}$'
    or requested_max_units not between 1 and 1000000
    or requested_units not between 1 and requested_max_units then
    raise exception 'invalid budget request' using errcode = '22023';
  end if;

  insert into ops.public_mcp_daily_budgets (
    budget_date, metric, usage_count, updated_at
  ) values (
    today_utc, requested_metric, requested_units, now()
  )
  on conflict (budget_date, metric)
  do update set
    usage_count = ops.public_mcp_daily_budgets.usage_count + excluded.usage_count,
    updated_at = now()
  returning usage_count into observed_count;

  return query select
    observed_count <= requested_max_units,
    greatest(requested_max_units - observed_count, 0),
    ((today_utc + 1)::timestamp at time zone 'utc');
end;
$$;

create or replace function public.mcp_get_search_cache(requested_cache_key text)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select (
    select c.result
    from ops.public_mcp_search_cache c
    where c.cache_key = requested_cache_key
      and c.expires_at > now()
  );
$$;

create or replace function public.mcp_put_search_cache(
  requested_cache_key text,
  requested_result jsonb,
  requested_ttl_seconds integer
)
returns boolean
language plpgsql
volatile
security invoker
set search_path = ''
as $$
begin
  if requested_cache_key !~ '^[0-9a-f]{64}$'
    or jsonb_typeof(requested_result) <> 'object'
    or octet_length(requested_result::text) > 1048576
    or requested_ttl_seconds not between 60 and 86400 then
    raise exception 'invalid cache request' using errcode = '22023';
  end if;

  insert into ops.public_mcp_search_cache (
    cache_key, result, expires_at, created_at, updated_at
  ) values (
    requested_cache_key,
    requested_result,
    now() + make_interval(secs => requested_ttl_seconds),
    now(),
    now()
  )
  on conflict (cache_key)
  do update set
    result = excluded.result,
    expires_at = excluded.expires_at,
    updated_at = now();

  return true;
end;
$$;

create or replace function public.mcp_record_public_request(
  requested_request_id uuid,
  requested_client_hash text,
  requested_action text,
  requested_outcome text,
  requested_paid_embedding boolean default false,
  requested_cache_hit boolean default false,
  requested_duration_ms integer default null,
  requested_details jsonb default '{}'::jsonb
)
returns bigint
language plpgsql
volatile
security invoker
set search_path = ''
as $$
declare
  inserted_id bigint;
begin
  if requested_client_hash !~ '^[0-9a-f]{64}$'
    or requested_action !~ '^[a-z0-9_:-]{1,80}$'
    or requested_outcome not in ('success', 'rejected', 'error')
    or jsonb_typeof(requested_details) <> 'object'
    or octet_length(requested_details::text) > 4096
    or requested_duration_ms < 0 then
    raise exception 'invalid audit request' using errcode = '22023';
  end if;

  insert into ops.public_mcp_audit_log (
    request_id, client_hash, action, outcome, paid_embedding,
    cache_hit, duration_ms, details
  ) values (
    requested_request_id, requested_client_hash, requested_action,
    requested_outcome, requested_paid_embedding, requested_cache_hit,
    requested_duration_ms, requested_details
  )
  on conflict (request_id) do nothing
  returning id into inserted_id;

  return inserted_id;
end;
$$;

create or replace function public.mcp_prune_operational_state()
returns jsonb
language plpgsql
volatile
security invoker
set search_path = ''
as $$
declare
  rate_rows integer;
  budget_rows integer;
  cache_rows integer;
  audit_rows integer;
begin
  delete from ops.public_mcp_rate_limits
  where updated_at < now() - interval '2 days';
  get diagnostics rate_rows = row_count;

  delete from ops.public_mcp_daily_budgets
  where budget_date < (now() at time zone 'utc')::date - 31;
  get diagnostics budget_rows = row_count;

  delete from ops.public_mcp_search_cache
  where expires_at < now();
  get diagnostics cache_rows = row_count;

  delete from ops.public_mcp_audit_log
  where created_at < now() - interval '90 days';
  get diagnostics audit_rows = row_count;

  return jsonb_build_object(
    'rate_limit_rows', rate_rows,
    'budget_rows', budget_rows,
    'cache_rows', cache_rows,
    'audit_rows', audit_rows
  );
end;
$$;

revoke all on function public.mcp_consume_rate_limit(text,text,integer,integer) from public, anon, authenticated;
revoke all on function public.mcp_consume_daily_budget(text,integer,integer) from public, anon, authenticated;
revoke all on function public.mcp_get_search_cache(text) from public, anon, authenticated;
revoke all on function public.mcp_put_search_cache(text,jsonb,integer) from public, anon, authenticated;
revoke all on function public.mcp_record_public_request(uuid,text,text,text,boolean,boolean,integer,jsonb) from public, anon, authenticated;
revoke all on function public.mcp_prune_operational_state() from public, anon, authenticated;
grant execute on function public.mcp_consume_rate_limit(text,text,integer,integer) to service_role;
grant execute on function public.mcp_consume_daily_budget(text,integer,integer) to service_role;
grant execute on function public.mcp_get_search_cache(text) to service_role;
grant execute on function public.mcp_put_search_cache(text,jsonb,integer) to service_role;
grant execute on function public.mcp_record_public_request(uuid,text,text,text,boolean,boolean,integer,jsonb) to service_role;
grant execute on function public.mcp_prune_operational_state() to service_role;

-- The public MCP's content RPCs are callable only by the Edge Function server
-- role. Each function enforces publication scope in SQL; client-supplied scope
-- arguments may narrow public data but can never widen it.
create or replace function public.mcp_search_archive(
  query_text text,
  query_embedding extensions.vector(1024) default null,
  match_count integer default 8,
  scopes text[] default array['public']::text[],
  filter_verification text[] default null
)
returns table (
  chunk_id text,
  document_id text,
  document_title text,
  heading_path text,
  content text,
  language text,
  verification_status text,
  access_scope text,
  source_ids text[],
  source_uris text[],
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
    select c.*, d.document_id as doc_ref, d.title as doc_title
    from kb.chunks c
    join kb.document_versions dv on dv.id = c.document_version_id
    join kb.documents d on d.id = dv.document_id
    where c.active
      and c.access_scope = 'public'
      and d.access_scope = 'public'
      and (scopes is null or 'public' = any(scopes))
      and (filter_verification is null or c.verification_status = any(filter_verification))
  ), keyword as (
    select p.id,
      row_number() over (
        order by ts_rank_cd(p.search_vector, websearch_to_tsquery('simple', query_text)) desc, p.id
      ) rank,
      ts_rank_cd(p.search_vector, websearch_to_tsquery('simple', query_text))::real score
    from permitted p
    where nullif(btrim(query_text), '') is not null
      and p.search_vector @@ websearch_to_tsquery('simple', query_text)
    order by score desc, p.id
    limit greatest(least(match_count, 50) * 5, 20)
  ), semantic as (
    select p.id,
      row_number() over (
        order by ce.embedding operator(extensions.<=>) query_embedding, p.id
      ) rank,
      (1 - (ce.embedding operator(extensions.<=>) query_embedding))::real score
    from permitted p
    join rag.chunk_embeddings ce on ce.chunk_id = p.id and ce.status = 'active'
    where query_embedding is not null
      and ce.content_sha256 = p.content_sha256
    order by ce.embedding operator(extensions.<=>) query_embedding, p.id
    limit greatest(least(match_count, 50) * 5, 20)
  ), candidates as (
    select coalesce(k.id, s.id) id,
      k.score keyword_rank,
      s.score semantic_similarity,
      coalesce(1.0 / (60 + k.rank), 0) + coalesce(1.0 / (60 + s.rank), 0) combined_score
    from keyword k
    full outer join semantic s on s.id = k.id
  )
  select p.chunk_id, p.doc_ref, p.doc_title, p.heading_path, p.content, p.language,
    p.verification_status, p.access_scope,
    coalesce(array_agg(distinct src.source_id order by src.source_id)
      filter (where src.source_id is not null), '{}'),
    coalesce(array_agg(distinct src.origin_uri order by src.origin_uri)
      filter (where src.origin_uri is not null), '{}'),
    c.keyword_rank, c.semantic_similarity, c.combined_score
  from candidates c
  join permitted p on p.id = c.id
  left join kb.chunk_sources cs on cs.chunk_id = p.id
  left join kb.sources src on src.id = cs.source_id and src.access_scope = 'public'
  group by p.chunk_id, p.doc_ref, p.doc_title, p.heading_path, p.content, p.language,
    p.verification_status, p.access_scope, c.keyword_rank, c.semantic_similarity, c.combined_score
  order by c.combined_score desc nulls last, p.chunk_id
  limit least(greatest(match_count, 1), 50);
$$;

create or replace function public.mcp_get_entities(
  search text default null,
  entity_types text[] default null,
  max_rows integer default 25
)
returns table (
  entity_id text,
  canonical_name text,
  entity_type text,
  description text,
  verification_status text,
  access_scope text,
  aliases text[],
  relationships jsonb
)
language sql
stable
security invoker
set search_path = ''
as $$
  select e.entity_id, e.canonical_name, e.entity_type, e.description,
    e.verification_status, e.access_scope,
    coalesce(array_agg(distinct ea.alias order by ea.alias)
      filter (where ea.alias is not null), '{}'),
    coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'predicate', r.predicate,
          'object', o.canonical_name,
          'confidence', r.confidence,
          'verification_status', r.verification_status
        ) order by r.predicate, o.canonical_name
      )
      from kg.relationships r
      join kb.entities o on o.id = r.object_entity_id and o.access_scope = 'public'
      where r.subject_entity_id = e.id
        and r.review_status = 'approved'
    ), '[]'::jsonb)
  from kb.entities e
  left join kb.entity_aliases ea on ea.entity_id = e.id
  where e.access_scope = 'public'
    and (
      search is null
      or e.canonical_name ilike '%' || search || '%'
      or e.description ilike '%' || search || '%'
      or exists (
        select 1 from kb.entity_aliases a
        where a.entity_id = e.id and a.alias ilike '%' || search || '%'
      )
    )
    and (entity_types is null or e.entity_type = any(entity_types))
  group by e.id, e.entity_id, e.canonical_name, e.entity_type, e.description,
    e.verification_status, e.access_scope
  order by e.canonical_name
  limit least(greatest(max_rows, 1), 100);
$$;

create or replace function public.mcp_get_events(
  search text default null,
  max_rows integer default 25
)
returns table (
  event_id text,
  title text,
  event_type text,
  date_text text,
  starts_at timestamptz,
  status text,
  description text,
  verification_status text,
  location text,
  participants jsonb
)
language sql
stable
security invoker
set search_path = ''
as $$
  select ev.event_id, ev.title, ev.event_type, ev.date_text, ev.starts_at, ev.status,
    ev.description, ev.verification_status, loc.canonical_name,
    coalesce((
      select jsonb_agg(
        jsonb_build_object('name', en.canonical_name, 'role', ee.role)
        order by en.canonical_name, ee.role
      )
      from kb.event_entities ee
      join kb.entities en on en.id = ee.entity_id and en.access_scope = 'public'
      where ee.event_id = ev.id
    ), '[]'::jsonb)
  from kb.events ev
  left join kb.entities loc
    on loc.id = ev.location_entity_id and loc.access_scope = 'public'
  where ev.access_scope = 'public'
    and (
      search is null
      or ev.title ilike '%' || search || '%'
      or ev.description ilike '%' || search || '%'
    )
  order by ev.starts_at nulls last, ev.title
  limit least(greatest(max_rows, 1), 100);
$$;

create or replace function public.mcp_get_document(doc_ref text)
returns table (
  document_id text,
  title text,
  document_type text,
  language text,
  lifecycle_status text,
  access_scope text,
  source_title text,
  origin_uri text,
  evidence_class text,
  chunks jsonb
)
language sql
stable
security invoker
set search_path = ''
as $$
  select d.document_id, d.title, d.document_type, d.language, d.lifecycle_status,
    d.access_scope, s.title, s.origin_uri, s.evidence_class,
    coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'chunk_id', c.chunk_id,
          'heading_path', c.heading_path,
          'content', c.content,
          'verification_status', c.verification_status
        ) order by c.ordinal
      )
      from kb.chunks c
      join kb.document_versions dv2 on dv2.id = c.document_version_id
      where dv2.document_id = d.id
        and c.active
        and c.access_scope = 'public'
    ), '[]'::jsonb)
  from kb.documents d
  left join kb.sources s
    on s.id = d.primary_source_id and s.access_scope = 'public'
  where d.access_scope = 'public'
    and (d.document_id = doc_ref or d.title ilike '%' || doc_ref || '%')
  limit 5;
$$;

create or replace function public.mcp_archive_status()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'documents', (select count(*) from kb.documents where access_scope = 'public'),
    'chunks_active', (select count(*) from kb.chunks where active and access_scope = 'public'),
    'chunks_embedded', (
      select count(*)
      from rag.chunk_embeddings ce
      join kb.chunks c on c.id = ce.chunk_id
      join kb.document_versions dv on dv.id = c.document_version_id
      join kb.documents d on d.id = dv.document_id
      where ce.status = 'active'
        and ce.content_sha256 = c.content_sha256
        and c.active
        and c.access_scope = 'public'
        and d.access_scope = 'public'
    ),
    'entities', (select count(*) from kb.entities where access_scope = 'public'),
    'events', (select count(*) from kb.events where access_scope = 'public'),
    'claims', (
      select count(distinct c.id)
      from kb.claims c
      join kb.claim_sources cs on cs.claim_id = c.id
      join kb.sources s on s.id = cs.source_id
      where c.review_status = 'approved' and s.access_scope = 'public'
    ),
    'sources', (select count(*) from kb.sources where access_scope = 'public'),
    'relationships', (
      select count(*)
      from kg.relationships r
      join kb.entities subject on subject.id = r.subject_entity_id
      join kb.entities object on object.id = r.object_entity_id
      where r.review_status = 'approved'
        and subject.access_scope = 'public'
        and object.access_scope = 'public'
    )
  );
$$;

revoke all on function public.mcp_search_archive(text,extensions.vector,integer,text[],text[]) from public, anon, authenticated;
revoke all on function public.mcp_get_entities(text,text[],integer) from public, anon, authenticated;
revoke all on function public.mcp_get_events(text,integer) from public, anon, authenticated;
revoke all on function public.mcp_get_document(text) from public, anon, authenticated;
revoke all on function public.mcp_archive_status() from public, anon, authenticated;
grant execute on function public.mcp_search_archive(text,extensions.vector,integer,text[],text[]) to service_role;
grant execute on function public.mcp_get_entities(text,text[],integer) to service_role;
grant execute on function public.mcp_get_events(text,integer) to service_role;
grant execute on function public.mcp_get_document(text) to service_role;
grant execute on function public.mcp_archive_status() to service_role;

do $$
declare
  function_record record;
begin
  for function_record in
    select p.oid, p.proname, p.prosecdef
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in (
        'mcp_search_archive', 'mcp_get_entities', 'mcp_get_events',
        'mcp_get_document', 'mcp_archive_status',
        'mcp_consume_rate_limit', 'mcp_consume_daily_budget',
        'mcp_get_search_cache', 'mcp_put_search_cache',
        'mcp_record_public_request', 'mcp_prune_operational_state'
      )
  loop
    if function_record.prosecdef then
      raise exception 'MCP function % must be SECURITY INVOKER', function_record.proname;
    end if;
    if has_function_privilege('anon', function_record.oid, 'EXECUTE')
      or has_function_privilege('authenticated', function_record.oid, 'EXECUTE') then
      raise exception 'MCP function % has a non-server execute grant', function_record.proname;
    end if;
    if not has_function_privilege('service_role', function_record.oid, 'EXECUTE') then
      raise exception 'MCP function % lacks the required server execute grant', function_record.proname;
    end if;
  end loop;
end $$;

comment on function public.mcp_search_archive(text,extensions.vector,integer,text[],text[]) is
  'Server-only public archive retrieval. Public scope is enforced in SQL and cannot be widened by caller input.';
comment on function public.mcp_get_entities(text,text[],integer) is
  'Server-only public entity retrieval. Both entity rows and relationship objects require public release scope.';
comment on function public.mcp_get_events(text,integer) is
  'Server-only public event retrieval. Events must have explicit public scope; related entities are independently filtered.';
comment on function public.mcp_get_document(text) is
  'Server-only public document retrieval. Document, chunks, and provenance are independently publication-scoped.';
comment on function public.mcp_archive_status() is
  'Server-only aggregate counts for the approved public corpus; non-public scope counts are not disclosed.';

-- Register the controlled implementation record and its retrieval-ready chunks.
-- Production embeddings are generated through a separate approved Voyage run;
-- clean previews preserve a truthful queued state without issuing a paid call.
do $$
declare
  source_pk bigint;
  document_pk bigint;
  version_pk bigint;
  collection_pk bigint;
  doc_text text;
begin
  doc_text := array_to_string(array[
    'Decision: pipa-mcp is a deliberately anonymous, read-only interface to the owner-approved public portion of the La Pipa Documentary Archive. PostgreSQL is the final publication boundary. Existing events default to internal until an owner review explicitly releases them.',
    'Scope enforcement: public search requires public documents and chunks and returns only public sources. Entity relationships require an approved relationship and public subject and object entities. Documents return only public chunks and provenance. Events, locations, and participants require independent public scope. Server-only RPCs use SECURITY INVOKER and are executable only by service_role.',
    'Abuse and cost controls: requests and searches have database-atomic per-client limits; request bodies, query lengths, filters, and result counts are bounded; identical searches use a one-hour hash-keyed cache; and a default budget of 250 Voyage query-embedding attempts per UTC day falls back to keyword search when exhausted or unavailable.',
    'Privacy and acceptance: client identifiers are one-way hashes and audit records exclude query text, response content, credentials, authorization headers, and raw network addresses. Release requires negative-scope, grant, rate-limit, cache, budget-fallback, and sanitized-audit tests plus GitHub, Supabase, Vercel, and Notion reconciliation.'
  ], E'\n\n');

  insert into kb.sources (
    source_id, title, source_type, evidence_class, source_date,
    origin_uri, access_scope, verification_status, description, metadata
  ) values (
    'LP-SRC-040',
    'LP-DOC-ARCH-025 — Public MCP access and abuse controls',
    'controlled_document',
    'live_connector_verified_and_workspace_verified',
    '2026-08-07',
    'https://github.com/alex-lapipa/lapipa.archives/blob/main/docs/archive/public-mcp-access-and-abuse-controls.md',
    'restricted',
    'verified',
    'Controlled implementation and publication-boundary record for the public La Pipa MCP interface.',
    jsonb_build_object(
      'document_id', 'LP-DOC-ARCH-025',
      'migration', '20260807174127_secure_public_mcp_boundary',
      'query_text_stored', false
    )
  )
  on conflict (source_id) do update
  set title = excluded.title,
      source_type = excluded.source_type,
      evidence_class = excluded.evidence_class,
      source_date = excluded.source_date,
      origin_uri = excluded.origin_uri,
      access_scope = excluded.access_scope,
      verification_status = excluded.verification_status,
      description = excluded.description,
      metadata = kb.sources.metadata || excluded.metadata,
      updated_at = now()
  returning id into source_pk;

  insert into kb.documents (
    document_id, primary_source_id, title, language, document_type,
    lifecycle_status, access_scope
  ) values (
    'lp-public-mcp-access-controls-2026-08-07-v1',
    source_pk,
    'LP-DOC-ARCH-025 — Public MCP access and abuse controls',
    'en',
    'archive_control_document',
    'approved',
    'restricted'
  )
  on conflict (document_id) do update
  set primary_source_id = excluded.primary_source_id,
      title = excluded.title,
      language = excluded.language,
      document_type = excluded.document_type,
      lifecycle_status = excluded.lifecycle_status,
      access_scope = excluded.access_scope,
      updated_at = now()
  returning id into document_pk;

  insert into kb.document_versions (
    document_id, version, content_sha256, mime_type, byte_count,
    storage_bucket, storage_object_path, extracted_text, effective_from
  ) values (
    document_pk,
    '1.0',
    encode(extensions.digest(convert_to(doc_text, 'UTF8'), 'sha256'), 'hex'),
    'text/markdown',
    octet_length(doc_text),
    null,
    'docs/archive/public-mcp-access-and-abuse-controls.md',
    doc_text,
    '2026-08-07 17:41:27+00'::timestamptz
  )
  on conflict (document_id, version) do update
  set content_sha256 = excluded.content_sha256,
      mime_type = excluded.mime_type,
      byte_count = excluded.byte_count,
      storage_bucket = excluded.storage_bucket,
      storage_object_path = excluded.storage_object_path,
      extracted_text = excluded.extracted_text,
      effective_from = excluded.effective_from
  returning id into version_pk;

  insert into kb.chunks (
    chunk_id, document_version_id, ordinal, heading_path, content,
    token_count, content_sha256, language, verification_status,
    access_scope, active, metadata
  )
  select
    value.chunk_id,
    version_pk,
    value.ordinal,
    value.heading_path,
    value.content,
    value.token_count,
    encode(extensions.digest(convert_to(value.content, 'UTF8'), 'sha256'), 'hex'),
    'en',
    'documented',
    'restricted',
    true,
    jsonb_build_object(
      'control_document', 'LP-DOC-ARCH-025',
      'embedding_state', 'queued',
      'public_mcp_exposure', false
    )
  from (values
    ('LP-RAG-025', 0, 'Decision and publication boundary', split_part(doc_text, E'\n\n', 1), 43),
    ('LP-RAG-026', 1, 'Database scope enforcement', split_part(doc_text, E'\n\n', 2), 58),
    ('LP-RAG-027', 2, 'Abuse and Voyage cost controls', split_part(doc_text, E'\n\n', 3), 52),
    ('LP-RAG-028', 3, 'Privacy and acceptance evidence', split_part(doc_text, E'\n\n', 4), 47)
  ) as value(chunk_id, ordinal, heading_path, content, token_count)
  on conflict (chunk_id) do update
  set document_version_id = excluded.document_version_id,
      ordinal = excluded.ordinal,
      heading_path = excluded.heading_path,
      content = excluded.content,
      token_count = excluded.token_count,
      content_sha256 = excluded.content_sha256,
      language = excluded.language,
      verification_status = excluded.verification_status,
      access_scope = excluded.access_scope,
      active = excluded.active,
      metadata = kb.chunks.metadata || excluded.metadata,
      updated_at = now();

  insert into kb.chunk_sources (chunk_id, source_id, locator, support_type)
  select c.id, source_pk, c.heading_path, 'supports'
  from kb.chunks c
  where c.chunk_id between 'LP-RAG-025' and 'LP-RAG-028'
  on conflict (chunk_id, source_id) do update
  set locator = excluded.locator, support_type = excluded.support_type;

  select id into collection_pk
  from kb.collections
  where collection_id = 'LP-COLLECTION-001';

  if collection_pk is not null then
    insert into kb.collection_items (collection_id, record_type, stable_record_id, ordinal)
    values (collection_pk, 'document', 'lp-public-mcp-access-controls-2026-08-07-v1', 25)
    on conflict (collection_id, record_type, stable_record_id) do update
    set ordinal = excluded.ordinal;
  end if;

  insert into ops.ingestion_jobs (
    job_id, job_type, status, initiated_by, input_manifest, counts, error_summary
  ) values (
    'LP-EMBED-PUBLIC-MCP-CONTROLS-2026-08-07',
    'voyage_contextual_embedding',
    'queued',
    (select id from auth.users where id = '827fa26f-df7f-4d24-9521-0e44bcf37696' limit 1),
    jsonb_build_object(
      'document_id', 'lp-public-mcp-access-controls-2026-08-07-v1',
      'chunk_ids', array['LP-RAG-025','LP-RAG-026','LP-RAG-027','LP-RAG-028'],
      'provider', 'voyage',
      'model', 'voyage-context-4',
      'dimensions', 1024
    ),
    jsonb_build_object('expected_chunks', 4, 'embedded', 0, 'pending', 4),
    'Embedding is environment-specific operational data. Production completes this through a separately controlled Voyage run; clean previews remain truthfully queued.'
  )
  on conflict (job_id) do update
  set job_type = excluded.job_type,
      status = case when ops.ingestion_jobs.status = 'succeeded' then 'succeeded' else 'queued' end,
      input_manifest = excluded.input_manifest,
      counts = case when ops.ingestion_jobs.status = 'succeeded' then ops.ingestion_jobs.counts else excluded.counts end,
      error_summary = case when ops.ingestion_jobs.status = 'succeeded' then null else excluded.error_summary end;
end $$;

insert into ops.review_tasks (
  review_id, record_type, stable_record_id, reason, status
) values (
  'LP-REV-PUBLIC-EVENTS-2026-001',
  'public_release',
  'kb.events',
  'Review each historical event and its source support before explicitly changing access_scope from internal to public. The public MCP returns no event until this affirmative release review is complete.',
  'open'
)
on conflict (review_id) do update
set reason = excluded.reason, status = 'open', resolved_by = null, resolved_at = null;

insert into ops.audit_log (
  actor_role, action, record_type, stable_record_id, details
) values (
  'system',
  'public_mcp_boundary_hardened',
  'edge_function',
  'pipa-mcp',
  jsonb_build_object(
    'event_publication_default', 'internal',
    'database_scope_enforcement', true,
    'server_only_rpc_execution', true,
    'rate_limit_ledger', 'ops.public_mcp_rate_limits',
    'daily_budget_ledger', 'ops.public_mcp_daily_budgets',
    'search_cache', 'ops.public_mcp_search_cache',
    'privacy_preserving_audit_log', 'ops.public_mcp_audit_log',
    'query_text_logged', false
  )
);

insert into ops.schema_versions (version, description)
values (
  '2026-08-07-public-mcp-boundary-v1',
  'Versions the public La Pipa MCP database surface; enforces public scope in SQL, adds affirmative event release state, server-only grants, atomic rate and Voyage budgets, bounded cache, and privacy-preserving audit records.'
)
on conflict (version) do nothing;

commit;
