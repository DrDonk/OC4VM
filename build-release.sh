#!/usr/bin/env zsh
#set -x
echo Creating OC4VM Release

# Read current version
VERSION=$(<VERSION)
echo "$VERSION"

rm -rfv ./dist/*
cp -v README.md ./dist/
cp -v LICENSE ./dist/
cp -vr ./ISO ./dist/
cp -vr ./VMDK ./dist/
cp -vr ./Templates ./dist/
cp -vr ./RecoveryMaker ./dist/
7z a ./build/oc4vm-$VERSION.zip ./dist/*

exit 0