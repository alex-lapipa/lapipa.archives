begin;

do $$
declare
  owner_agent_id bigint;
begin
  select id into owner_agent_id
  from archive.agents where agent_id = 'LP-AGENT-ALEX-LAWTON';

  if owner_agent_id is null then
    raise notice 'Owner agent is absent in this environment; characterization evidence skipped.';
    return;
  end if;

  insert into archive.preservation_events (
    event_id, event_type, event_at, outcome, outcome_detail,
    agent_id, software_agent, command_or_process, event_detail
  ) values (
    'LP-PRESEVENT-2026-0003', 'metadata_extraction', '2026-08-05T00:29:00Z', 'warning',
    'PDF format and metadata characterization completed. Malware and deep structural validation remain pending because ClamAV and qpdf were not installed.',
    owner_agent_id, 'file + macOS Metadata + Poppler pdfinfo',
    'Read-only identification of the original source object.',
    jsonb_build_object(
      'package_id','LP-BAG-2026-0001',
      'payload_sha256','c2fcbc5fa2eb5539da56c217318fc9699e7f7b44b5ed072c78a3b0ffeebcf04e',
      'characterization_evidence_sha256','2c3a4d28cb4fcae9739c199a5b417164f2b19be6517ef0d6c499938cd7c9e588',
      'mime_type','application/pdf',
      'format_name','PDF',
      'file_command_version','1.3',
      'pdfinfo_version','1.4',
      'page_count',36,
      'title','LABPIPAPROJECT_jun19._FINAL2',
      'creator','PowerPoint',
      'producer','macOS 10.15.1 Quartz PDFContext AppendMode 1.1',
      'created_at_source','2019-06-10T18:29:48+02:00',
      'modified_at_source','2020-03-11T03:12:53+01:00',
      'encrypted',false,
      'javascript',false,
      'tagged_for_accessibility',false,
      'optimized',false,
      'page_size_points','960x540',
      'malware_scan_status','pending_tool_unavailable',
      'structural_validation_status','pending_qpdf_unavailable',
      'format_version_discrepancy','file reported 1.3; pdfinfo reported 1.4; resolve during deep validation'
    )
  )
  on conflict (event_id) do nothing;

  update archive.transfer_packages
  set validation_detail = validation_detail || jsonb_build_object(
        'characterization_status','partial_complete',
        'mime_type','application/pdf',
        'page_count',36,
        'encrypted',false,
        'javascript',false,
        'accessibility_tagged',false,
        'malware_scan_status','pending_tool_unavailable',
        'structural_validation_status','pending_qpdf_unavailable'
      ),
      updated_at = now()
  where package_id = 'LP-BAG-2026-0001';
end $$;

insert into ops.schema_versions (version, description)
values (
  '2026-08-05-origin-deck-characterization-v1',
  'Read-only PDF metadata characterization with explicit malware, structural-validation, accessibility, and format-version gaps.'
)
on conflict (version) do nothing;

commit;
