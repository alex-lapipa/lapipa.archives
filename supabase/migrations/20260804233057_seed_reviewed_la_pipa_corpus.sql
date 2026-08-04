begin;

insert into kb.sources (source_id, source_date, source_date_text, title, source_type, evidence_class, verification_status, description, origin_uri)
values
('LP-SRC-001','2019-06-10',null,'LAPIPAPROJECT June 2019 origin presentation','presentation','workspace_verified_document','workspace_verified','Earliest strong origin deck: identity, Gijón focus, network, place concept, leadership, AI/data/media vision.',null),
('LP-SRC-002','2019-06-10',null,'empresas pipalab company ecosystem chart','presentation','workspace_verified_document','workspace_verified','Company and ecosystem chart supporting active formation work.',null),
('LP-SRC-003',null,'2019','LABPIPA Budget 2019','spreadsheet','workspace_verified_document','workspace_verified','Planning model for income, events, services, coworking, staff, and operating costs.',null),
('LP-SRC-004','2020-05-10',null,'La Pipa strategy presentation','presentation','workspace_verified_document','workspace_verified','Strategic principles and repeated 2019 La Pipa origin framing.',null),
('LP-SRC-005',null,'2020-10 to 2021-09','LAPIPA Collective 001','presentation','workspace_verified_document','workspace_verified','Service Design Partners model; human data, empathy, experience, privacy, impact, and agile practice.',null),
('LP-SRC-006',null,'2020','LABPIPA Budget 2020','spreadsheet','workspace_verified_document','workspace_verified','Updated planning workbook; not an audited result.',null),
('LP-SRC-007','2021-04-21',null,'La Pipa collective chart for EDP','presentation','workspace_verified_document','workspace_verified','Independent collective in an 1800s cider mill; more than 35 people, five organizations, innovation domains, studio and broadcast.',null),
('LP-SRC-008',null,'2021-07','La Pipa equipment and membership workbooks','spreadsheet','workspace_verified_document','workspace_verified','Technical, music, video, lighting, immersive, robotics, and vintage-equipment inventory.',null),
('LP-SRC-009',null,'2021','La Pipa contributions workbook','spreadsheet','workspace_verified_document','workspace_verified','Organization and contribution planning model; does not prove payments.',null),
('LP-SRC-010',null,'2022-09','Springboard La Pipa agenda','document','workspace_verified_document','workspace_verified','Asturias ecosystem gathering, participants, agenda, and impact objectives.',null),
('LP-SRC-011','2023-01-13',null,'La Pipa Natural Foods memo','document','workspace_verified_document','workspace_verified','Plant-based food, sustainability, nutrition, affordability, local and rural opportunity exploration.',null),
('LP-SRC-012',null,'2023','Festival and website export artifacts','media_collection','filename_only_and_exported_media','mixed','La Pipa Festival, North of the South, Edition 00, and cultural media.',null),
('LP-SRC-013',null,'2024','La Pipa Studios cost workbook','spreadsheet','workspace_verified_document','workspace_verified','Audio and video podcast service costing and rate-card model.',null),
('LP-SRC-014','2025-10-20',null,'Squarespace and WordPress export','xml_export','workspace_verified_document','workspace_verified','Self-authored descriptions of La Pipa, location, innovation model, ReMotive origin, festival gallery, and articles.',null),
('LP-SRC-015',null,'2026-07','lapipa.ai redesign plan','local_handoff','local_handoff_not_live_verified','local_handoff_not_live_verified','Bilingual site architecture, content, services, graph, design, and start-date conflict.',null),
('LP-SRC-016','2026-07-28',null,'LAPIPA AI redesign handover','local_handoff','local_handoff_not_live_verified','local_handoff_not_live_verified','Repository, Vercel, Supabase, Notion, domain, redesign, and unresolved 2016/2019 facts.',null),
('LP-SRC-017',null,'2025-09 to 2026-07','Historical Supabase project listing','task_snapshot','historical_task_output','historical_task_output','Historical La Pipa Supabase project identifiers and creation dates.',null),
('LP-SRC-018','2026-07-27',null,'User statement about physical relocation','user_statement','user_supplied','user_supplied','Reported office departure, contract and purchase-option context, and downtown relocation.',null),
('LP-SRC-019','2026-08-05',null,'Current workspace and metadata audit','audit','workspace_verified','workspace_verified','Archive counts, access boundaries, inherited checkout finding, and review methodology.',null),
('LP-SRC-020',null,'2019-2026','Deduplicated La-Pipa-named artifact scan','archive_scan','filename_only','filename_only','Activity clues from 530 named files across 2,557 matching paths.',null),
('LP-SRC-021',null,'2026-07','Generated La Pipa research report','generated_research','secondary_generated_research','requires_primary_verification','Generated history, legal, event, podcast, and role claims requiring primary verification.',null),
('LP-SRC-022',null,'undated','LA PIPA FUTURE COMING namesake chat','chat','workspace_verified_namesake_only','namesake_only','Music production brief using La Pipa as a creative title; not evidence about the place.',null),
('LP-SRC-023','2026-08-05',null,'User-supplied connected-platform mapping','user_statement','user_supplied','user_supplied','GitHub, Supabase, and Vercel project mapping.',null),
('LP-SRC-024','2026-08-05',null,'Connected GitHub repository inspection','connector_observation','live_connector_verified','live_connector_verified','Repository access and minimal README confirmed.','https://github.com/alex-lapipa/lapipa.archives'),
('LP-SRC-025','2026-08-05',null,'Connected Supabase project metadata','connector_observation','live_connector_verified','live_connector_verified','LA PIPA ARCHIVE project identity, region, Postgres version, creation date, and health.',null),
('LP-SRC-026','2026-08-05',null,'Connected Vercel lookup boundary','connector_observation','live_access_boundary','superseded_by_current_verification','Initial connector lookup returned 404; authenticated CLI later confirmed the exact project in the La Pipa team.',null),
('LP-SRC-027','2026-08-05',null,'Connected Notion workspace identity','connector_observation','live_connector_verified','live_connector_verified','MIRAMONTE workspace identity and available integration scope.',null),
('LP-SRC-028','2026-04-25',null,'Notion onboarding documentation','notion_page','live_notion_source','live_connector_verified','La Pipa as an operating Surface; coffee, standups, workshops, and platform access.',null),
('LP-SRC-029','2026-04-25',null,'Notion diversity and inclusion documentation','notion_page','live_notion_source','live_connector_verified','ReMotive and La Pipa Equality Plan 2023–2028 scope and documentation gaps.',null),
('LP-SRC-030','2026-04-25',null,'Notion vision and strategy documentation','notion_page','live_notion_source','live_connector_verified','Build to learn and share for impact as founding spirit.',null),
('LP-SRC-031','2026-04-25',null,'Notion company culture documentation','notion_page','live_notion_source','live_connector_verified','Care for the Asturian community and suggested hackspace and studio norms.',null),
('LP-SRC-032','2026-08-05',null,'Notion linked-page access boundaries','connector_observation','live_access_boundary','live_access_boundary','Surface, Operations, and Platform IP pages outside integration fetch scope.',null),
('LP-SRC-033','2026-08-05',null,'Initial Supabase structure inspection','connector_observation','live_connector_verified','historical_snapshot','At inspection: zero public tables, migrations, and Edge Functions; one informational performance notice.',null),
('LP-SRC-034','2026-08-05',null,'User decision naming Notion official knowledge base','governance_decision','user_supplied','user_supplied','Authorization to create the official documentation, RAG, and graph workspace in Notion.',null),
('LP-SRC-035','2026-08-05',null,'Official Notion knowledge base creation verification','connector_observation','live_connector_verified','live_connector_verified','Official hub, seven databases, views, and persisted seed counts.','https://app.notion.com/p/3b2425866bb581f08befc9f930417991');

insert into kb.entities (entity_id, canonical_name, entity_type, description, verification_status) values
('entity:la-pipa','La Pipa','initiative','Independent people-led open-innovation community, workspace, and media/cultural platform.','mixed'),
('entity:la-pipa-place','La Pipa historical cider-mill site','place','Historical Somió/Gijón cider-mill base.','workspace_verified'),
('entity:la-pipa-community','La Pipa community','community','People and partner ecosystem.','workspace_verified'),
('entity:la-pipa-studios','La Pipa Studios','capability','Media, broadcast, podcast, and production capability.','workspace_verified'),
('entity:lapipa-ai','lapipa.ai','digital_platform','Digital platform and related systems.','mixed'),
('entity:la-pipa-archives','La Pipa Archives','knowledge_system','Official archive, documentation, RAG, and knowledge-graph project.','live_connector_verified'),
('entity:remotive-media','ReMotive Media','organization','Organization documented in La Pipa and Notion materials.','mixed'),
('person:alex-lawton','Alex Lawton','person','Named in historical materials and self-authored as a La Pipa co-founder.','mixed'),
('person:jose-diego','José Diego','person','Named in the 2019 historical ecosystem presentation.','historical_presentation'),
('person:sergio-maldonado','Sergio Maldonado','person','Named in the 2019 historical ecosystem presentation.','historical_presentation'),
('person:jaime-pire','Jaime Pire','person','Named in the 2019 historical ecosystem presentation.','historical_presentation'),
('person:jose-luis-quiros','José Luis Quirós','person','Named in the 2019 historical ecosystem presentation.','historical_presentation'),
('place:gijon','Gijón','city','City in Asturias, Spain.','workspace_verified'),
('place:asturias','Asturias','region','Autonomous community in northern Spain.','workspace_verified');

insert into kb.claims (claim_id, statement, verification_status, confidence, review_status) values
('LP-CLAIM-001','La Pipa is documented no later than 10 June 2019.','workspace_verified',0.990,'approved'),
('LP-CLAIM-002','2019 is the best-supported practical origin year, while the exact legal and public launch dates remain unresolved.','mixed',0.900,'approved'),
('LP-CLAIM-003','La Pipa historically operated from a nineteenth-century cider mill in Somió/Gijón.','workspace_verified',0.950,'approved'),
('LP-CLAIM-004','An April 2021 presentation described more than 35 people and five organizations at La Pipa in less than two years.','presentation_claim',0.900,'approved'),
('LP-CLAIM-005','La Pipa developed an in-house studio and broadcast capability by April 2021.','workspace_verified',0.950,'approved'),
('LP-CLAIM-006','The 2023 natural-foods file documents exploration, not proof of a launched venture.','workspace_verified',0.980,'approved'),
('LP-CLAIM-007','The 2026 physical relocation statement is user-supplied and not independently verified against property records.','user_supplied',0.990,'approved'),
('LP-CLAIM-008','The archive contains about 2.3 TB, 188,222 files, and 66,388 directories in the reviewed snapshot.','workspace_verified',0.950,'approved'),
('LP-CLAIM-009','Notion is the official human-readable knowledge base for La Pipa Archives.','live_connector_verified',1.000,'approved');

insert into kb.claim_sources (claim_id, source_id, support_type)
select c.id, s.id, 'supports'
from (values
('LP-CLAIM-001','LP-SRC-001'),('LP-CLAIM-002','LP-SRC-001'),('LP-CLAIM-002','LP-SRC-015'),
('LP-CLAIM-003','LP-SRC-007'),('LP-CLAIM-004','LP-SRC-007'),('LP-CLAIM-005','LP-SRC-007'),
('LP-CLAIM-006','LP-SRC-011'),('LP-CLAIM-007','LP-SRC-018'),('LP-CLAIM-008','LP-SRC-019'),
('LP-CLAIM-009','LP-SRC-034'),('LP-CLAIM-009','LP-SRC-035')) v(claim_id, source_id)
join kb.claims c on c.claim_id=v.claim_id join kb.sources s on s.source_id=v.source_id;

insert into kb.events (event_id,title,event_type,starts_at,date_text,location_entity_id,status,description,verification_status)
select v.event_id,v.title,v.event_type,v.starts_at::timestamptz,v.date_text,e.id,v.status,v.description,v.verification_status
from (values
('LP-EVENT-001','Earliest documented La Pipa origin presentation','formation','2019-06-10T00:00:00Z',null,'entity:la-pipa-place','documented','Earliest directly inspected project presentation.','workspace_verified'),
('LP-EVENT-002','La Pipa strategy development','strategy','2020-05-10T00:00:00Z',null,'entity:la-pipa-place','documented','Operating principles and 2019 origin framing.','workspace_verified'),
('LP-EVENT-003','Collective scale and studio capability documented','milestone','2021-04-21T00:00:00Z',null,'entity:la-pipa-place','documented','Collective, innovation domains, studio, and broadcast chart.','workspace_verified'),
('LP-EVENT-004','Springboard Asturias sessions','workshop',null,'2022-09','entity:la-pipa-place','documented','Multi-day ecosystem and regenerative-business gathering.','workspace_verified_document'),
('LP-EVENT-005','Natural foods exploration memo','research','2023-01-13T00:00:00Z',null,'entity:la-pipa-place','documented','Plant-based food and rural opportunity exploration.','workspace_verified_document'),
('LP-EVENT-006','La Pipa Festival and North of the South cluster','festival',null,'2023','entity:la-pipa-place','inferred','Dense creative-production and event artifact cluster.','filename_only_and_exported_media'),
('LP-EVENT-007','La Pipa Studios service costing','service_design',null,'2024','entity:la-pipa-studios','documented','Audio and video podcast production costs and rates.','workspace_verified_document'),
('LP-EVENT-008','Reported physical-site transition','relocation','2026-07-27T00:00:00Z',null,'entity:la-pipa-place','unresolved','User-reported departure from the historical offices.','user_supplied'),
('LP-EVENT-009','Official Notion knowledge base established','governance','2026-08-05T00:00:00Z',null,'entity:la-pipa-archives','documented','Official project documentation and governance hub created and verified.','live_connector_verified')
) v(event_id,title,event_type,starts_at,date_text,location_entity,status,description,verification_status)
left join kb.entities e on e.entity_id=v.location_entity;

insert into kg.relationships (relationship_id,subject_entity_id,predicate,object_entity_id,confidence,verification_status,review_status)
select v.relationship_id,s.id,v.predicate,o.id,v.confidence,v.verification_status,'approved'
from (values
('LP-REL-001','entity:la-pipa','HAS_COMPONENT','entity:la-pipa-place',0.95,'workspace_verified'),
('LP-REL-002','entity:la-pipa','HAS_COMPONENT','entity:la-pipa-community',0.95,'workspace_verified'),
('LP-REL-003','entity:la-pipa','HAS_COMPONENT','entity:la-pipa-studios',0.90,'workspace_verified'),
('LP-REL-004','entity:la-pipa','HAS_COMPONENT','entity:lapipa-ai',0.80,'mixed'),
('LP-REL-005','entity:la-pipa','HISTORICALLY_BASED_AT','entity:la-pipa-place',0.98,'workspace_verified'),
('LP-REL-006','entity:la-pipa-place','LOCATED_IN','place:gijon',0.95,'workspace_verified'),
('LP-REL-007','place:gijon','LOCATED_IN','place:asturias',1.00,'workspace_verified'),
('LP-REL-008','person:alex-lawton','CO_FOUNDED','entity:la-pipa',0.80,'self_authored_source'),
('LP-REL-009','entity:la-pipa','OPERATED_BY','entity:remotive-media',0.60,'unresolved_relationship'),
('LP-REL-010','entity:la-pipa','GOVERNED_IN','entity:la-pipa-archives',1.00,'live_connector_verified'),
('LP-REL-011','entity:la-pipa-archives','USES_PLATFORM','entity:lapipa-ai',0.50,'conceptual_unresolved')
) v(relationship_id,subject_id,predicate,object_id,confidence,verification_status)
join kb.entities s on s.entity_id=v.subject_id join kb.entities o on o.entity_id=v.object_id;

insert into kb.documents (document_id,title,language,document_type,lifecycle_status,access_scope)
values
('lp-rag-master-2026-08-05-v2','La Pipa comprehensive workspace record','en','rag_master_corpus','approved','internal'),
('lp-source-inventory-2026-08-05-v1','La Pipa source inventory','en','source_inventory','approved','internal'),
('lp-connected-platforms-2026-08-05-v1','La Pipa connected platforms','en','connected_platform_inventory','approved','internal');

insert into kb.document_versions (document_id,version,content_sha256,mime_type,extracted_text)
select d.id,'2026-08-05-v1',encode(extensions.digest(d.document_id || ':2026-08-05-v1','sha256'),'hex'),'text/markdown',d.title
from kb.documents d;

with chunk_seed(chunk_id, ordinal, heading_path, verification_status, content, source_ids) as (values
('LP-RAG-001',1,'entity definition','workspace_verified',
$$La Pipa is an independent, people-led open-innovation community, workspace, and media/cultural platform historically based in a nineteenth-century cider mill in Somió/Gijón, Asturias. It connects business building, service design, data, artificial intelligence, privacy, media, music, culture, content, and human-centred experiences through trust, collaboration, and shared intelligence.$$,
array['LP-SRC-001','LP-SRC-004','LP-SRC-007','LP-SRC-014']),
('LP-RAG-002',2,'origin date','mixed',
$$The earliest directly inspected La Pipa project material is dated 10 June 2019. Multiple 2019–2021 documents support 2019 as the practical origin year. A 2026 handover records a conflict between a 2016 brand-book date and a 2019 website date, so the exact legal, operational, and public launch dates remain unresolved.$$,
array['LP-SRC-001','LP-SRC-002','LP-SRC-003','LP-SRC-004','LP-SRC-007','LP-SRC-015']),
('LP-RAG-003',3,'place','workspace_verified',
$$La Pipa’s historical physical base was a solid-stone nineteenth-century cider mill in northern Spain, associated throughout the workspace with Somió/Gijón, Asturias. The site was used as offices, meeting and collaboration space, media studio, broadcast environment, technical workspace, cultural venue, and outdoor or garden setting.$$,
array['LP-SRC-001','LP-SRC-007','LP-SRC-014']),
('LP-RAG-004',4,'operating principles','workspace_verified',
$$La Pipa’s documented principles include independence, trust, people-led collaboration, co-management, flexibility, empathy, optimism, positive impact by design, privacy by design, shared intelligence, circular-economy thinking, listening to learn, and partnership across disciplines.$$,
array['LP-SRC-001','LP-SRC-004','LP-SRC-005']),
('LP-RAG-005',5,'technology and innovation','workspace_verified',
$$La Pipa’s technology work spans data, artificial intelligence, privacy, robotics, Internet of Things, edge computing, immersive media, virtual and augmented reality, connected services, and human-centred technology. Early strategy places data and AI at the centre of an ecosystem connecting people, objects, services, brands, products, and content.$$,
array['LP-SRC-001','LP-SRC-005','LP-SRC-007','LP-SRC-008']),
('LP-RAG-006',6,'media and studios','workspace_verified',
$$La Pipa developed an in-house media and broadcast capability documented by April 2021. The archive contains La Pipa TV, recurring programs, interviews, podcasts, music sessions, partner productions, and extensive audio/video equipment. A 2024 workbook costed La Pipa Studios audio-podcast and video-podcast services.$$,
array['LP-SRC-007','LP-SRC-008','LP-SRC-013','LP-SRC-020']),
('LP-RAG-007',7,'culture and events','mixed',
$$La Pipa’s cultural activity includes music sessions, talks, interviews, open days, hackspace work, visiting groups, Nomad Talks, Gijón Sound Festival artifacts, Subterránea-related media, and the 2023 La Pipa Festival / North of the South / Edition 00. Many details are supported only by filenames or exported media artifacts, so definitive event programs and attendance should be separately verified.$$,
array['LP-SRC-010','LP-SRC-012','LP-SRC-020']),
('LP-RAG-008',8,'Springboard Asturias','workspace_verified_document',
$$The 2022 Springboard agenda documents a multi-day gathering centred on La Pipa and Asturias. It brought together ecosystem, investment, education, construction, design, and digital-product perspectives to ask how business is generated in Asturias and to explore purpose-centred, regenerative business ecosystems with economic, social, and environmental value.$$,
array['LP-SRC-010']),
('LP-RAG-009',9,'natural foods exploration','workspace_verified_document',
$$La Pipa explored a natural-foods opportunity in a January 2023 memo focused on plant-based food, sustainability, nutrition, affordability, local production, and rural opportunity. The file is evidence of research and concept exploration, not evidence that a commercial food venture launched.$$,
array['LP-SRC-011']),
('LP-RAG-010',10,'2023 festival cluster','filename_only_and_exported_media',
$$The 2023 archive contains a dense cluster of La Pipa Festival, North of the South, Edition 00, Nomad Talks, Open Day, beach, mountain, garden, Gijón Sound Festival, Subterránea, and artist media artifacts. This supports substantial creative production and event preparation, while exact schedules, performers, attendance, and outcomes remain to be reconstructed from primary event records.$$,
array['LP-SRC-012','LP-SRC-020']),
('LP-RAG-011',11,'digital platform','local_handoff_not_live_verified',
$$Local July 2026 handover documents describe a mature bilingual lapipa.ai platform using a React-based front end, GitHub repository alex-lapipa/motion-ai-pulse, Vercel deployment, Supabase backend, and a Notion hub. A historical task snapshot also shows a Supabase project named lapipa-ai created on 28 July 2026. These facts were not refreshed against the live services in the original review.$$,
array['LP-SRC-015','LP-SRC-016','LP-SRC-017']),
('LP-RAG-012',12,'2026 physical relocation','user_supplied',
$$On 27 July 2026, the user stated that the organization was vacating the La Pipa offices and moving to downtown offices after a property-development venture-capital offer displaced the existing arrangement. The user reported a ten-year contract and first option to buy. No contract, title, transaction, or counterparty evidence was independently inspected.$$,
array['LP-SRC-018']),
('LP-RAG-013',13,'continuity after relocation','evidence_based_inference',
$$The 2026 evidence supports a physical-site transition, not the end of La Pipa. Digital-platform work, archive continuity, studio identity, community identity, and files titled LA PIPA WILL BE or La Pipa Will Always Be La Pipa indicate continued identity or activity beyond the cider-mill occupancy. This is an inference and should be updated when current organizational status is documented.$$,
array['LP-SRC-015','LP-SRC-016','LP-SRC-017','LP-SRC-018','LP-SRC-020']),
('LP-RAG-014',14,'archive scope','workspace_verified',
$$The local LA PIPA Studios Dropbox archive contains approximately 2.3 TB, 188,222 files, and 66,388 directories overall. A path-name scan found 2,557 paths containing “pipa,” including 530 files whose basenames contain “pipa.” The counts include copies, exports, and Final Cut backups and must not be interpreted as 530 unique projects.$$,
array['LP-SRC-019','LP-SRC-020']),
('LP-RAG-015',15,'evidence caution','workspace_verified',
$$La Pipa claims must retain their evidence class. Directly inspected files, user statements, historical task outputs, generated research, and filename-only artifacts are not equivalent. Forecasts are not outcomes; a named media file is not a full event record; a repository namespace is not entity proof; and a historical healthy-service snapshot is not confirmation of current service health.$$,
array['LP-SRC-019']),
('LP-RAG-016',16,'connected archive platforms','mixed',
$$The La Pipa archive uses GitHub repository alex-lapipa/lapipa.archives, Supabase project jxilnxchvdeiazmopslf, and Vercel project prj_avksBJw1Z3RIYBTQvs7m0ZbxKp4k. GitHub and Supabase identities were confirmed on 5 August 2026. The initial Vercel connector lookup returned a scoped 404; later authenticated CLI inspection confirmed the same project ID as lapipa-archives under the LA PIPA IS LA PIPA team.$$,
array['LP-SRC-023','LP-SRC-024','LP-SRC-025','LP-SRC-026']),
('LP-RAG-017',17,'Notion operating model','live_notion_sources',
$$The connected MIRAMONTE Notion workspace classifies La Pipa as an operating Surface within a wider portfolio. Accessible pages document onboarding that included coffee at La Pipa, daily standups, and collective workshops; identify build to learn and share for impact as its founding spirit; apply care, trust, transparency, and continuous improvement; and preserve a ReMotive Media plus La Pipa Equality Plan for 2023–2028. Several linked hubs remain outside the integration’s fetch scope.$$,
array['LP-SRC-027','LP-SRC-028','LP-SRC-029','LP-SRC-030','LP-SRC-031','LP-SRC-032']),
('LP-RAG-018',18,'archive infrastructure readiness','live_connector_verified',
$$The archive infrastructure was provisioned as a clean foundation on 5 August 2026. GitHub initially exposed only a minimal README, Supabase initially had no application tables, migrations, or Edge Functions, and the Vercel project had no production deployment. These are dated baseline facts and must be superseded by post-implementation verification.$$,
array['LP-SRC-024','LP-SRC-025','LP-SRC-026','LP-SRC-033']),
('LP-RAG-019',19,'official Notion knowledge base','live_connector_verified',
$$The MIRAMONTE Notion page LA PIPA ARCHIVES — Official Knowledge Base is the official human-readable source of truth for the project. It contains structured collections for documentation, sources and provenance, claims and facts, entities, events and activities, knowledge-graph relationships, and RAG chunks. Initial read-back verification found 5 documents, 33 sources, 9 claims, 14 entities, 9 events, 11 graph edges, and 5 retrieval-ready chunks.$$,
array['LP-SRC-034','LP-SRC-035'])
), master_version as (
  select dv.id
  from kb.document_versions dv join kb.documents d on d.id=dv.document_id
  where d.document_id='lp-rag-master-2026-08-05-v2'
), inserted as (
  insert into kb.chunks (chunk_id,document_version_id,ordinal,heading_path,content,content_sha256,language,verification_status,metadata)
  select cs.chunk_id,mv.id,cs.ordinal,cs.heading_path,cs.content,
    encode(extensions.digest(cs.content,'sha256'),'hex'),'en',cs.verification_status,
    jsonb_build_object('source_ids',cs.source_ids,'retrieval_scope','internal')
  from chunk_seed cs cross join master_version mv
  returning id,chunk_id
)
insert into kb.chunk_sources (chunk_id,source_id,support_type)
select i.id,s.id,'supports'
from chunk_seed cs join inserted i on i.chunk_id=cs.chunk_id
cross join lateral unnest(cs.source_ids) sid
join kb.sources s on s.source_id=sid;

insert into kb.collection_items (collection_id,record_type,stable_record_id,ordinal)
select c.id,'rag_chunk',ch.chunk_id,ch.ordinal
from kb.collections c cross join kb.chunks ch
where c.collection_id='LP-COLLECTION-001';

insert into rag.evaluation_questions (question_id,question,language,expected_source_ids,required_concepts,forbidden_concepts) values
('LP-EVAL-001','What is La Pipa?','en',array['LP-SRC-001','LP-SRC-007'],array['open innovation','community','Asturias'],array[]::text[]),
('LP-EVAL-002','¿Qué es La Pipa?','es',array['LP-SRC-001','LP-SRC-007'],array['innovación abierta','comunidad','Asturias'],array[]::text[]),
('LP-EVAL-003','When did La Pipa start?','en',array['LP-SRC-001','LP-SRC-015'],array['2019','unresolved'],array['exact legal launch confirmed']),
('LP-EVAL-004','What happened at Springboard Asturias?','en',array['LP-SRC-010'],array['ecosystem','regenerative'],array[]::text[]),
('LP-EVAL-005','Did La Pipa launch a natural-foods business?','en',array['LP-SRC-011'],array['exploration','not evidence of launch'],array['confirmed launch']),
('LP-EVAL-006','What media production happened at La Pipa?','en',array['LP-SRC-007','LP-SRC-013','LP-SRC-020'],array['studio','broadcast','podcast'],array[]::text[]),
('LP-EVAL-007','Did leaving the cider mill end La Pipa?','en',array['LP-SRC-018','LP-SRC-020'],array['physical-site transition','inference'],array['legally dissolved']),
('LP-EVAL-008','Which knowledge base is official?','en',array['LP-SRC-034','LP-SRC-035'],array['Notion','official'],array[]::text[]);

insert into ops.ingestion_jobs (job_id,job_type,status,input_manifest,counts,started_at,completed_at)
values ('LP-INGEST-2026-08-05-001','reviewed_seed','succeeded',
  '{"collection_id":"LP-COLLECTION-001","embedding_status":"pending_voyage_pilot"}'::jsonb,
  '{"sources":35,"claims":9,"entities":14,"events":9,"relationships":11,"chunks":19,"evaluation_questions":8}'::jsonb,
  now(),now());

commit;
