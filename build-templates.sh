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
cp -v ./build/vmdk/intel-release/opencore.* ./build/templates/intel

mkdir -p ./build/templates/amd
cp -v macos.vmdk ./build/templates/amd
cp -v ./build/vmdk/amd-release/opencore.* ./build/templates/amd

jinja2 --format=toml --section=intel_generic -D VERSION=$VERSION --outfile=./build/templates/intel/macos.vmx vmx.j2 vmx.toml
#jinja2 --format=toml --section=intel_macos_10_15 -D VERSION=$VERSION --outfile=./build/templates/intel/macos1015.vmx vmx.j2 vmx.toml
#jinja2 --format=toml --section=intel_macos_11 -D VERSION=$VERSION --outfile=./build/templates/intel/macos11.vmx vmx.j2 vmx.toml
#jinja2 --format=toml --section=intel_macos_12 -D VERSION=$VERSION --outfile=./build/templates/intel/macos12.vmx vmx.j2 vmx.toml
#jinja2 --format=toml --section=intel_macos_13 -D VERSION=$VERSION --outfile=./build/templates/intel/macos13.vmx vmx.j2 vmx.toml
#jinja2 --format=toml --section=intel_macos_14 -D VERSION=$VERSION --outfile=./build/templates/intel/macos14.vmx vmx.j2 vmx.toml

jinja2 --format=toml --section=amd_generic -D VERSION=$VERSION --outfile=./build/templates/amd/macos.vmx vmx.j2 vmx.toml
#jinja2 --format=toml --section=amd_macos_10_15 -D VERSION=$VERSION --outfile=./build/templates/amd/macos1015.vmx vmx.j2 vmx.toml
#jinja2 --format=toml --section=amd_macos_11 -D VERSION=$VERSION --outfile=./build/templates/amd/macos11.vmx vmx.j2 vmx.toml
#jinja2 --format=toml --section=amd_macos_12 -D VERSION=$VERSION --outfile=./build/templates/amd/macos12.vmx vmx.j2 vmx.toml
#jinja2 --format=toml --section=amd_macos_13 -D VERSION=$VERSION --outfile=./build/templates/amd/macos13.vmx vmx.j2 vmx.toml
#jinja2 --format=toml --section=amd_macos_14 -D VERSION=$VERSION --outfile=./build/templates/amd/macos14.vmx vmx.j2 vmx.toml

exit