#!/bin/zsh

set -u

launcher_directory="${0:A:h}"
runner_path="$launcher_directory/scripts/archive/vimeo-acceptance-runner.mjs"

if [[ ! -f "$runner_path" ]]; then
  clear
  echo "LA PIPA VIMEO ARCHIVE — LAUNCHER NOT STARTED"
  echo
  echo "The launcher text appears to have been pasted into Terminal instead of"
  echo "the .command file being opened directly. Nothing was changed."
  echo
  echo "Open 'Run La Pipa One Video Acceptance.command' from the project folder."
  echo
  read "reply?Press Return to close. "
  exit 1
fi

cd "$launcher_directory"
clear

echo "LA PIPA VIMEO ARCHIVE — ONE-VIDEO ACCEPTANCE"
echo
echo "This controlled test downloads exactly one 46-second La Pipa video:"
echo "Subterranea @ LA PIPA :: VIUDA (Vimeo 844151157)"
echo
echo "It writes only to G-DRIVE 02. It does not delete sources or upload to Backblaze."
echo
read -s "runner_code?Paste the short-lived code from Owner Access, then press Return: "
echo
if [[ -z "${runner_code//[[:space:]]/}" ]]; then
  echo "No authorization code was received. Nothing was changed."
  echo
  read "reply?Press Return to close. "
  exit 1
fi
echo "Authorization code received securely; it remains hidden."
echo
read "confirmation?Type YES to begin the one-video download: "
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
  echo "The local one-video acceptance stage completed."
else
  echo "The acceptance stage stopped safely. Read the message above; no source was deleted."
fi
echo
read "reply?Press Return to close. "
exit $result
