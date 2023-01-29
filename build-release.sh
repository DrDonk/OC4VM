#!/usr/bin/env zsh
set -x
echo Creating OC4VM Release
if ! [ $# -eq 1 ] ; then
  echo "Product version not found: xyz (e.g. 1.2.3)" >&2
  exit 1
fi

rm -rfv ./dist/*
cp -v README.md ./dist/
cp -v LICENSE ./dist/
cp -vr ./ISO ./dist/
cp -vr ./VMDK ./dist/
cp -vr ./Templates ./dist/
7z a ./build/oc4vm-$1.zip ./dist/*

exit 0