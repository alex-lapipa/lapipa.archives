begin;

create index if not exists authorized_identities_authorized_by_idx
  on kb.authorized_identities (authorized_by);

create index if not exists authorized_identities_principal_agent_id_idx
  on kb.authorized_identities (principal_agent_id);

insert into ops.schema_versions (version, description)
values (
  '2026-08-05-authorized-identity-indexes-v1',
  'Covering indexes for authorized identity approver and principal-agent foreign keys.'
)
on conflict (version) do nothing;

commit;
