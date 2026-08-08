#!/bin/zsh

set -u

launcher_directory="${0:A:h}"
runner_path="$launcher_directory/scripts/archive/vimeo-batch2-runner.mjs"

if [[ ! -f "$runner_path" ]]; then
  clear
  echo "LA PIPA VIMEO ARCHIVE — BATCH 2 NOT STARTED"
  echo
  echo "Open this .command file directly from the La Pipa project folder."
  echo "Do not paste the launcher text into Terminal. Nothing was changed."
  echo
  read "reply?Press Return to close. "
  exit 1
fi

cd "$launcher_directory"
clear

echo "LA PIPA VIMEO ARCHIVE — BATCH 2"
echo
echo "Choose exactly one reviewed accession:"
echo
echo "  1  LP-ACC-2026-0006 · Data Clean Rooms: Remotive@LA PIPA"
echo "  2  LP-ACC-2026-0007 · Future of Strategic Design"
echo "  3  LP-ACC-2026-0008 · Future of Circular Economies"
echo "  4  LP-ACC-2026-0009 · Future Innovation Ecosystems 2022"
echo "  5  LP-ACC-2026-0010 · Industry-Automation-whats-next? LA PIPA"
echo
read "selection?Type 1, 2, 3, 4, or 5: "
case "$selection" in
  1) video_id="727814369"; accession_id="LP-ACC-2026-0006" ;;
  2) video_id="727847829"; accession_id="LP-ACC-2026-0007" ;;
  3) video_id="729180279"; accession_id="LP-ACC-2026-0008" ;;
  4) video_id="730068690"; accession_id="LP-ACC-2026-0009" ;;
  5) video_id="732187995"; accession_id="LP-ACC-2026-0010" ;;
  *)
    echo
    echo "That is not a reviewed Batch 2 selection. Nothing was changed."
    read "reply?Press Return to close. "
    exit 1
    ;;
esac

echo
echo "Selected: $accession_id · Vimeo $video_id"
echo "This may take several hours. It is resumable and works on one accession only."
echo "It never deletes a Vimeo source or local master and never overwrites a differing Backblaze object."
echo
read -s "runner_code?Paste the matching short-lived code from Owner Access, then press Return: "
echo
if [[ -z "${runner_code//[[:space:]]/}" ]]; then
  echo "No authorization code was received. Nothing was changed."
  echo
  read "reply?Press Return to close. "
  exit 1
fi
echo "Authorization code received securely; it remains hidden."
echo
read "confirmation?Type YES to preserve, transcribe, upload, and restore-verify this one accession: "
if [[ "${confirmation:u}" != "YES" ]]; then
  unset runner_code
  echo "Cancelled. Nothing was changed."
  read "reply?Press Return to close. "
  exit 0
fi

export LAPIPA_VIMEO_AUTHORIZATION_CODE="$runner_code"
export LAPIPA_VIMEO_VIDEO_ID="$video_id"
unset runner_code video_id accession_id selection confirmation
set +e
/usr/bin/env node "$runner_path"
result=$?
set -e
unset LAPIPA_VIMEO_AUTHORIZATION_CODE LAPIPA_VIMEO_VIDEO_ID

echo
if [[ $result -eq 0 ]]; then
  echo "The selected Batch 2 preservation accession completed."
else
  echo "The accession stopped safely. Read the message above; no source was deleted."
  echo "A later run with a fresh matching code can resume verified local work."
fi
echo
read "reply?Press Return to close. "
exit $result
