# Publication and citation policy

## Publication package

An approved public item should provide a stable item page, title, date or date statement, creator or contributor, description, collection context, identifier, language, rights statement, credit line, citation, access derivative, and contact or correction route. Compound objects may also provide an IIIF Presentation 3.0 manifest.

## Preferred citation

Use:

> Creator or contributor, “Item title,” date or date statement, item ID, collection title, La Pipa Documentary Archive, access date, stable URL.

For time-based quotation, append the representation ID and time range. For a transcript, append transcript ID, language, version or status, and segment ID.

## Citation integrity

Stable identifiers are never reused. A withdrawn object keeps a tombstone sufficient to explain its identity and availability, subject to safety and legal constraints. URLs may change; identifiers must not. Generated answers cite source IDs and should link to item-level descriptions when access permits.

## IIIF

IIIF Presentation 3.0 is the target for compound-object delivery. A manifest describes presentation and structure; it does not replace the archival catalog or discovery index. Rights uses an approved URI, required attribution uses `requiredStatement`, and time-based media uses canvases with durations and annotation bodies.

## Exports for RAG and research

Each export release includes:

- release ID, timestamp, schema and policy versions;
- records in Markdown and JSONL with stable IDs;
- provenance edges and verification status;
- rights/access fields sufficient to prevent downstream overexposure;
- SHA-256 manifest for every file;
- source inventory and counts;
- exclusions and unresolved issues;
- embedding model, dimensions, chunking version, and evaluation summary when vectors are included.

Exports do not contain credentials, private signed URLs, authentication tokens, or suppressed personal information.

