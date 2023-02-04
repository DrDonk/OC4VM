#!/usr/bin/env zsh
#set -x
echo Creating OC4VM Release

# Read current version
VERSION=$(<VERSION)
echo "$VERSION"

cp -v README.md ./build/
cp -v LICENSE ./build/
cp -vr ./ISO ./build/
cp -vr ./RecoveryMaker ./build/
7z a ./dist/oc4vm-$VERSION.zip ./build/*

exit 0