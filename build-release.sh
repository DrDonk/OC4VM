#!/usr/bin/env zsh
#set -x
echo Creating OC4VM Release

# Read current version
VERSION=$(<VERSION)
echo "$VERSION"

rm -rf ./build/iso 2>/dev/null
rm -rf ./build/recovery-maker 2>/dev/null
rm ./dist/oc4vm-$VERSION.* 2>/dev/null

cp -v README.md ./build/
cp -v LICENSE ./build/
cp -vr ./iso ./build/
cp -vr ./recovery-maker ./build/
7z a ./dist/oc4vm-$VERSION.zip ./build/*

cd ./dist
shasum -a 512 oc4vm-$VERSION.zip > oc4vm-$VERSION.sha512
cd ..
exit 0