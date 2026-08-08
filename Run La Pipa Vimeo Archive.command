#!/bin/zsh

set -eu

launcher_directory="${0:A:h}"
cd "$launcher_directory"

clear
echo "LA PIPA VIMEO ARCHIVE"
echo "Safe planning mode — no files or cloud services will be changed."
echo

set +e
/usr/bin/env node scripts/archive/vimeo-batch-runner.mjs --batch-size 5
result=$?
set -e

echo
if [[ $result -eq 0 ]]; then
  echo "Planning finished safely. You can close this window."
else
  echo "The safety check stopped. Nothing was changed."
fi
echo
read "reply?Press Return to close. "
exit $result
