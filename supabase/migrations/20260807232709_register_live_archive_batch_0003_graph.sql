begin;

insert into kb.entities (
  entity_id, canonical_name, entity_type, description,
  verification_status, access_scope
) values
  (
    'archive-item:lp-item-2026-0002',
    'La Pipa 2021 logos and early video files',
    'archive_item',
    'Preservation item LP-ITEM-2026-0002, registered from live accession LP-ACC-2026-0003 and documented by LP-SRC-041.',
    'live_connector_verified',
    'restricted'
  ),
  (
    'platform:backblaze-b2',
    'Backblaze B2',
    'storage_platform',
    'Cloud object-storage platform used by the La Pipa living archive. This record contains no credential material.',
    'live_connector_verified',
    'internal'
  ),
  (
    'storage:miramonte-lapipa-archive',
    'miramonte-lapipa-archive',
    'storage_container',
    'Private encrypted Backblaze B2 bucket for the live La Pipa archive. Object Lock is disabled and no default retention period is configured.',
    'live_connector_verified',
    'restricted'
  )
on conflict (entity_id) do update set
  canonical_name = excluded.canonical_name,
  entity_type = excluded.entity_type,
  description = excluded.description,
  verification_status = excluded.verification_status,
  access_scope = excluded.access_scope,
  updated_at = now();

with proposed(relationship_id, subject_id, predicate, object_id) as (values
  (
    'LP-REL-014',
    'entity:la-pipa-archives',
    'HAS_COMPONENT',
    'archive-item:lp-item-2026-0002'
  ),
  (
    'LP-REL-015',
    'entity:la-pipa-archives',
    'USES_PLATFORM',
    'platform:backblaze-b2'
  ),
  (
    'LP-REL-016',
    'platform:backblaze-b2',
    'HAS_COMPONENT',
    'storage:miramonte-lapipa-archive'
  ),
  (
    'LP-REL-017',
    'archive-item:lp-item-2026-0002',
    'USES_PLATFORM',
    'storage:miramonte-lapipa-archive'
  )
)
insert into kg.relationships (
  relationship_id, subject_entity_id, predicate, object_entity_id,
  valid_from, confidence, verification_status, review_status
)
select
  p.relationship_id,
  subject.id,
  p.predicate,
  object.id,
  '2026-08-08'::date,
  1.000,
  'live_connector_verified',
  'approved'
from proposed p
join kb.entities subject on subject.entity_id = p.subject_id
join kb.entities object on object.entity_id = p.object_id
on conflict (relationship_id) do update set
  subject_entity_id = excluded.subject_entity_id,
  predicate = excluded.predicate,
  object_entity_id = excluded.object_entity_id,
  valid_from = excluded.valid_from,
  confidence = excluded.confidence,
  verification_status = excluded.verification_status,
  review_status = excluded.review_status,
  updated_at = now();

insert into kg.relationship_sources (
  relationship_id, source_id, locator, support_type
)
select
  r.id,
  s.id,
  'LP-DOC-ARCH-029',
  'supports'
from kg.relationships r
cross join kb.sources s
where r.relationship_id in ('LP-REL-014','LP-REL-015','LP-REL-016','LP-REL-017')
  and s.source_id = 'LP-SRC-041'
on conflict (relationship_id, source_id) do update set
  locator = excluded.locator,
  support_type = excluded.support_type;

insert into ops.schema_versions(version,description)
values (
  '2026-08-08-live-archive-batch-0003-graph-v1',
  'Provenance-linked graph entities and relationships for LP-ITEM-2026-0002, Backblaze B2, and the private live archive bucket.'
)
on conflict (version) do nothing;

commit;
