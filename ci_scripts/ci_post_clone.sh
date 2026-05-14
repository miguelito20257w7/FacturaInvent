#!/bin/sh
set -e

echo "→ Setting build number to $CI_BUILD_NUMBER (from Xcode Cloud)"
cd "$CI_PRIMARY_REPOSITORY_PATH"
agvtool new-version -all "$CI_BUILD_NUMBER"
echo "→ Done. Current build number:"
agvtool what-version -terse
