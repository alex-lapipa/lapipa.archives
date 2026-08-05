# Accession package profile — LP-BAG 1.0

## Scope

LP-BAG 1.0 defines a minimal, verifiable Submission Information Package for transfer into the La Pipa Documentary Archive. It follows BagIt 1.0, RFC 8493, using UTF-8 tag files and SHA-256 manifests.

## Required structure

```text
LP-ACC-YYYY-NNNN/
├── bagit.txt
├── bag-info.txt
├── manifest-sha256.txt
├── tagmanifest-sha256.txt
└── data/
    └── received files and directories
```

`bagit.txt` declares BagIt 1.0 and UTF-8. `manifest-sha256.txt` lists every payload file. `tagmanifest-sha256.txt` verifies the declaration, package metadata, and payload manifest. `bag-info.txt` records source organization, external identifier, bagging date, payload oxum, and software agent.

## Repository tools

Create a read-only inventory outside the accession source:

```sh
npm run archive:inventory -- /path/to/source /path/to/output/inventory.json
```

Create a new BagIt package without overwriting any existing output:

```sh
npm run archive:create-bag -- /path/to/source /path/to/LP-ACC-2026-0001
```

Validate a package:

```sh
npm run archive:validate-bag -- /path/to/LP-ACC-2026-0001
```

The tools reject filesystem root input, source/output nesting, symbolic links, unsafe manifest paths, existing package destinations, missing payload files, unlisted payloads, and digest mismatches. Package creation uses a temporary sibling directory and only publishes the package after every copied file re-verifies.

## Filename and path rules

Preserve received names in the original inventory. Normalize only in a new managed representation and record the mapping. Paths are relative, use forward slashes in manifests, contain no `..`, and must not depend on a case-insensitive filesystem. Unicode normalization and prohibited platform characters are assessed before transfer between systems.

## Database handoff

Create `archive.transfer_packages` and one `archive.transfer_package_files` row per manifest entry. Link accepted entries to file objects. Record duplicate, excluded, quarantined, and failed decisions rather than dropping them from reconciliation. A package becomes `valid` only after payload and tag validation, and `ingested` only after database, Storage, preservation event, rights, and count reconciliation.

## Boundary

BagIt verifies package completeness and byte integrity. It does not establish authenticity, rights, consent, privacy, format validity, usability, or sufficient preservation copies. Those are separate quality gates.

## Reference

- [RFC 8493: The BagIt File Packaging Format 1.0](https://www.rfc-editor.org/info/rfc8493/)
