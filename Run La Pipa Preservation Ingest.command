#!/bin/zsh

set -u

launcher_directory="${0:A:h}"
runner_path="$launcher_directory/scripts/archive/vimeo-preservation-ingest-runner.mjs"

if [[ ! -f "$runner_path" ]]; then
  clear
  echo "LA PIPA VIMEO ARCHIVE — INGEST NOT STARTED"
  echo
  echo "Open this .command file directly from the La Pipa project folder."
  echo "Do not paste the launcher text into Terminal. Nothing was changed."
  echo
  read "reply?Press Return to close. "
  exit 1
fi

cd "$launcher_directory"
clear

echo "LA PIPA VIMEO ARCHIVE — PRESERVATION INGEST"
echo
echo "This controlled stage uploads and restore-verifies exactly one accession:"
echo "LP-ACC-2026-0005 · Subterranea @ LA PIPA :: VIUDA (Vimeo 844151157)"
echo
echo "It does not delete, move, rename, or rewrite the Vimeo source or local master."
echo
read -s "runner_code?Paste a fresh short-lived code from Owner Access, then press Return: "
echo
if [[ -z "${runner_code//[[:space:]]/}" ]]; then
  echo "No authorization code was received. Nothing was changed."
  echo
  read "reply?Press Return to close. "
  exit 1
fi
echo "Authorization code received securely; it remains hidden."
echo
read "confirmation?Type YES to upload and restore-verify this accession: "
if [[ "${confirmation:u}" != "YES" ]]; then
  unset runner_code
  echo "Cancelled. Nothing was changed."
  read "reply?Press Return to close. "
  exit 0
fi

export LAPIPA_VIMEO_AUTHORIZATION_CODE="$runner_code"
unset runner_code
set +e
/usr/bin/env node "$runner_path"
result=$?
set -e
unset LAPIPA_VIMEO_AUTHORIZATION_CODE

echo
if [[ $result -eq 0 ]]; then
  echo "The one-video preservation ingest completed."
else
  echo "The preservation ingest stopped safely. Read the message above; no source was deleted."
fi
echo
read "reply?Press Return to close. "
exit $result
