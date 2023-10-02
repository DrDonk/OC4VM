#!/usr/bin/env zsh
#set -x
echo Creating OpenCore VMware templates

# Read current version
VERSION=$(<VERSION)
VERSION+=-$(git rev-parse --short HEAD)
echo "$VERSION"

# Clear previous build
rm -rf ./build/templates/* 2>/dev/null

# Build VMX files
mkdir -p ./build/templates/vmware
cp -v macos.vmdk ./build/templates/vmware
cp -v ./build/vmdk/intel-release/opencore.vmdk ./build/templates/vmware
jinja2 --format=toml --section=intel-release -D VERSION=$VERSION --outfile=./build/templates/vmware/macos.vmx vmx.j2 vmx.toml
exit