#!/usr/bin/env zsh
#set -x
echo Creating OC4VM Release

# Read current version
# Read current version
VERSION=$(<VERSION)
VERSION+=-$(git rev-parse --short HEAD)
echo "$VERSION"

rm -rf ./build/iso 2>/dev/null
rm -rf ./build/recovery-maker 2>/dev/null
rm ./dist/oc4vm-$VERSION.* 2>/dev/null

cp -v README.md ./build/
cp -v LICENSE ./build/
cp -vr ./iso ./build/
cp -vr ./recovery-maker ./build/

exit 0