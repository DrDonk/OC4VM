#!/usr/bin/env zsh
#set -x
echo Zipping OC4VM Release

# Read current version
VERSION=$(<VERSION)
VERSION+=-$(git rev-parse --short HEAD)
echo "$VERSION"

7z a ./dist/oc4vm-$VERSION.zip ./build/*

cd ./dist
shasum -a 512 oc4vm-$VERSION.zip > oc4vm-$VERSION.sha512
cd ..

exit 0