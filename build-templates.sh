#!/usr/bin/env zsh
set -x
echo Creating OpenCore VMware Templates

# Read current version
VERSION=$(<VERSION)
echo "$VERSION"

# Clear previous build
rm -rfv ./build/Templates/*

# Build VMX files
mkdir -p ./build/Templates/intel
cp -v macos.vmdk ./build/Templates/intel
cp -v ./build/VMDK/release_intel/opencore.* ./build/Templates/intel

mkdir -p ./build/Templates/amd
cp -v macos.vmdk ./build/Templates/amd
cp -v ./build/VMDK/release_amd/opencore.* ./build/Templates/amd

jinja2 --format=toml --section=intel_macos_10_15 -D VERSION=$VERSION --outfile=./build/Templates/intel/macos1015.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=intel_macos_11 -D VERSION=$VERSION --outfile=./build/Templates/intel/macos11.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=intel_macos_12 -D VERSION=$VERSION --outfile=./build/Templates/intel/macos12.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=intel_macos_13 -D VERSION=$VERSION --outfile=./build/Templates/intel/macos13.vmx vmx.j2 vmx.toml

jinja2 --format=toml --section=amd_macos_10_15 -D VERSION=$VERSION --outfile=./build/Templates/amd/macos1015.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=amd_macos_11 -D VERSION=$VERSION --outfile=./build/Templates/amd/macos11.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=amd_macos_12 -D VERSION=$VERSION --outfile=./build/Templates/amd/macos12.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=amd_macos_13 -D VERSION=$VERSION --outfile=./build/Templates/amd/macos13.vmx vmx.j2 vmx.toml

exit