#!/bin/sh

# Bump build number to a unique, monotonically increasing value.
# Uses Xcode Cloud's CI_BUILD_NUMBER plus a safety offset so it always
# exceeds any pre-existing build numbers in TestFlight.

OFFSET=100
NEW_BUILD_NUMBER=$((CI_BUILD_NUMBER + OFFSET))

echo "→ CI_BUILD_NUMBER=$CI_BUILD_NUMBER  OFFSET=$OFFSET"
echo "→ Setting CURRENT_PROJECT_VERSION to $NEW_BUILD_NUMBER"

cd "$CI_PRIMARY_REPOSITORY_PATH"

echo "→ Before:"
grep "CURRENT_PROJECT_VERSION" FacturaInvent.xcodeproj/project.pbxproj | sort -u

sed -i.bak -E "s/CURRENT_PROJECT_VERSION = [0-9]+;/CURRENT_PROJECT_VERSION = $NEW_BUILD_NUMBER;/g" FacturaInvent.xcodeproj/project.pbxproj
rm -f FacturaInvent.xcodeproj/project.pbxproj.bak

echo "→ After:"
grep "CURRENT_PROJECT_VERSION" FacturaInvent.xcodeproj/project.pbxproj | sort -u

echo "→ Done."
