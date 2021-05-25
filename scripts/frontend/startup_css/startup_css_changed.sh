#!/bin/sh

echo "-----------------------------------------------------------"
echo "If you are run into any issues with Startup CSS generation,"
echo "please check out the feedback issue:"
echo ""
echo "https://gitlab.com/gitlab-org/gitlab/-/issues/331812"
echo "-----------------------------------------------------------"

if [ -n "$(git diff --name-only -- app/assets/stylesheets/startup/)" ]; then
  diff=$(git diff HEAD -- app/assets/stylesheets/startup/)
  cat <<EOF

Startup CSS changes detected!

It looks like there have been recent changes which require
regenerating the Startup CSS files.

Consider one of the following options:

  1. Regenerating locally with "yarn run generate:startup_css".
  2. Copy and apply the following diff:

$diff
EOF

  exit 1
fi
