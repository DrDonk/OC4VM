#!/usr/bin/env zsh
#set -x
echo Creating OpenCore VMware Templates

# Read current version
VERSION=$(<VERSION)
echo "$VERSION"

# Clear previous build
rm -rfv ./Templates/*

# Build VMX files
mkdir -p ./Templates/intel
cp -v macos.vmdk ./Templates/intel
cp -v ./VMDK/release_intel/opencore.* ./Templates/intel

mkdir -p ./Templates/amd
cp -v macos.vmdk ./Templates/amd
cp -v ./VMDK/release_amd/opencore.* ./Templates/amd

jinja2 --format=toml --section=intel_macos_10_15 -D VERSION=$VERSION --outfile=./Templates/intel/macos1015.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=intel_macos_11 -D VERSION=$VERSION --outfile=./Templates/intel/macos11.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=intel_macos_12 -D VERSION=$VERSION --outfile=./Templates/intel/macos12.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=intel_macos_13 -D VERSION=$VERSION --outfile=./Templates/intel/macos13.vmx vmx.j2 vmx.toml

jinja2 --format=toml --section=amd_macos_10_15 -D VERSION=$VERSION --outfile=./Templates/amd/macos1015.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=amd_macos_11 -D VERSION=$VERSION --outfile=./Templates/amd/macos11.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=amd_macos_12 -D VERSION=$VERSION --outfile=./Templates/amd/macos12.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=amd_macos_13 -D VERSION=$VERSION --outfile=./Templates/amd/macos13.vmx vmx.j2 vmx.toml

exit