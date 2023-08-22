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
mkdir -p ./build/templates/intel
cp -v macos.vmdk ./build/templates/intel
cp -v ./build/vmdk/intel-release/opencore.vmdk ./build/templates/intel
jinja2 --format=toml --section=intel_generic -D VERSION=$VERSION --outfile=./build/templates/intel/macos.vmx vmx.j2 vmx.toml
exit