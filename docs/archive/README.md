# La Pipa Documentary Archive handbook

Version: 1.0  
Status: controlled draft  
Owner: La Pipa Archives  
Review cycle: annual, and after any material platform, legal, or collecting-policy change

## Purpose

The La Pipa Documentary Archive preserves and makes responsibly discoverable the evidence of La Pipa: its identity, beginnings, people, places, activities, works, gatherings, communications, and afterlives. It is both an archive and a documentary production system. It must retain original evidence, make every transformation auditable, distinguish verified fact from interpretation, and protect people whose rights or safety outweigh immediate access.

This handbook governs the documentary archive layer. The existing knowledge base and RAG corpus remain the evidence-aware discovery layer. Archival objects may support knowledge claims; knowledge claims never replace archival objects.

## Control documents

1. [Collecting and appraisal policy](collecting-and-appraisal.md)
2. [Metadata application profile](metadata-application-profile.md)
3. [Digital preservation policy](digital-preservation-policy.md)
4. [Accessioning and ingest runbook](accessioning-and-ingest.md)
5. [Audiovisual and transcription workflow](audiovisual-and-transcription.md)
6. [Rights, ethics, privacy, and access](rights-ethics-and-access.md)
7. [Documentary production workflow](documentary-production-workflow.md)
8. [Publication and citation policy](publication-and-citation.md)
9. [Continuity and disaster recovery](continuity-and-disaster-recovery.md)
10. [Operating roadmap](operating-roadmap.md)
11. [Quality assurance and release gates](quality-assurance-and-release-gates.md)
12. [Storage and replication plan](storage-and-replication-plan.md)
13. [Accession package profile](accession-package-profile.md)
14. [Authority and controlled vocabulary plan](authority-and-vocabulary-plan.md)
15. [Initial preservation assessment](initial-preservation-assessment.md)
16. [Owner and role register](owner-and-role-register.md)
17. [First accession runbook](first-accession-runbook.md)
18. [Access-control acceptance tests](access-control-acceptance-tests.md)
19. [First accession report](first-accession-report.md)
20. [Website and media accession — 5 August 2026](website-accession-2026-08-05.md)

## Standards profile

The implementation is an application profile, not a claim of formal certification.

| Concern | Baseline | How La Pipa applies it |
|---|---|---|
| Archive responsibilities | OAIS, ISO 14721:2025 | Preserve information for a defined community through governed ingest, storage, management, access, and preservation planning. |
| Preservation metadata | PREMIS Data Dictionary 3.0 | Model intellectual items, file objects, events, rights, and agents with durable identifiers. |
| Audiovisual description | PBCore 2.1 | Separate intellectual content from representations and essence-track technical metadata. |
| General description | DCMI Metadata Terms | Maintain interoperable title, creator, subject, description, date, type, format, language, relation, coverage, rights, and identifier semantics. |
| Transfer packages | BagIt 1.0, RFC 8493 | Package payloads with UTF-8 tags and SHA-256 or SHA-512 manifests. |
| Preservation maturity | NDSA Levels of Digital Preservation 2.1 | Assess storage, integrity, control, metadata, and content maturity at least annually. |
| Rich access | IIIF Presentation API 3.0 | Future manifests for compound image, audio, video, transcript, and annotation experiences. |
| Timed text | WebVTT | Exchange access subtitles and time-aligned text; preserve richer transcript metadata in the database. |

## Non-negotiable principles

- Original evidence is never silently overwritten.
- Every managed file has a stable ID, byte count, MIME type, storage location, and cryptographic digest.
- Derivatives remain linked to the representation and source files from which they were produced.
- Every preservation action records what happened, when, by whom or what, and with what outcome.
- Descriptive claims retain source links and verification status.
- Rights, consent, privacy, cultural sensitivity, and potential harm are reviewed before access.
- Public access is an affirmative decision, not a default.
- Automated transcripts, OCR, entity extraction, and summaries are labeled as automated until reviewed.
- Voyage embeddings are discovery aids. They are reproducible derivatives, not archival masters.
- Notion supports editorial review; GitHub controls policies and implementation; Supabase controls structured records and managed objects; Vercel provides the access surface.

## Current maturity boundary

The platform has a working private knowledge/RAG foundation, a standards-aligned archival schema, and an assigned human owner. It does not yet claim trustworthy digital repository certification, geographic redundancy, preservation-format normalization for all media, or public availability. Those outcomes require operating evidence, a backup administrator, tested recovery, and continuing review.

## Authoritative references

- [ISO 14721:2025 OAIS reference model](https://www.iso.org/standard/87471.html)
- [PREMIS preservation metadata](https://www.loc.gov/standards/premis/)
- [PBCore 2.1](https://pbcore.org/xsd)
- [DCMI Metadata Terms](https://www.dublincore.org/specifications/dublin-core/dcmi-terms/)
- [BagIt RFC 8493](https://www.rfc-editor.org/info/rfc8493)
- [NDSA Levels of Digital Preservation 2.1](https://www.ndsa.org/publications/levels-of-digital-preservation/)
- [IIIF Presentation API 3.0](https://iiif.io/api/presentation/3.0/)
- [WebVTT](https://www.w3.org/TR/webvtt1/)
- [Library of Congress Sustainability of Digital Formats](https://www.loc.gov/preservation/digital/formats/)
