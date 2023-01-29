#!/usr/bin/env zsh
set -x
echo Creating Opencore DMG images

# Build the DMG & VMDK
build_dmg() {
  msg_status "Building $1"

  # Make a copy of base image
  cp -v ./DMG/opencore.* $2

  # Attach blank DMG and create OC setup
  hdiutil attach $2/opencore.dmg -noverify -nobrowse -noautoopen
  diskutil eraseVolume FAT32 OPENCORE /Volumes/OPENCORE
  cp -r $3 /Volumes/OPENCORE
  cp -r $4 /Volumes/OPENCORE/EFI/OC
  rm -rf /Volumes/OPENCORE/.fseventsd
  dot_clean -m /Volumes/OPENCORE
  ls -a /Volumes/OPENCORE
  hdiutil detach /Volumes/OPENCORE

  # Validate VMDK is OK
  /Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -e $2/opencore.vmdk

  # Write a message
  if [[ -f "$2/opencore.vmdk" ]]; then
    msg_status "Built .vmdk file is available at $2/opencore.vmdk"
  else
    msg_error "Build failure! Built .vmdk file not found!"
  fi

  msg_status "Building process complete.\n"
}

# Provide custom colors in Terminal for status and error messages
msg_status() {
  echo "\033[0;32m-- $1\033[0m"
}
msg_error() {
  echo "\033[0;31m-- $1\033[0m"
}

# Clear previous build
rm -rfv ./Config/*
rm -rfv ./Templates/*
rm -rfv ./VMDK/*

# Create new output folders
mkdir -p ./Config/release_intel
mkdir -p ./Config/release_amd
mkdir -p ./Config/debug_intel
mkdir -p ./Config/debug_amd

mkdir -p ./VMDK/release_intel
mkdir -p ./VMDK/release_amd
mkdir -p ./VMDK/debug_intel
mkdir -p ./VMDK/debug_amd

# Build config.plist files
jinja2 --format=toml --section=release_intel --outfile=./Config/release_intel/config.plist config.j2 config.toml
jinja2 --format=toml --section=release_amd --outfile=./Config/release_amd/config.plist config.j2 config.toml
jinja2 --format=toml --section=debug_intel --outfile=./Config/debug_intel/config.plist config.j2 config.toml
jinja2 --format=toml --section=debug_amd --outfile=./Config/debug_amd/config.plist config.j2 config.toml

# Build the OpenCore DMG/VMDK files
MSG="Intel Release"
VMDK="./VMDK/release_intel/"
BASE="./DiskContents/Release-Base/."
CONFIG="./Config/release_intel/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="AMD Release"
VMDK="./VMDK/release_amd/"
BASE="./DiskContents/Release-Base/."
CONFIG="./Config/release_amd/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="Intel Debug"
VMDK="./VMDK/debug_intel/"
BASE="./DiskContents/Release-Base/."
CONFIG="./Config/debug_intel/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="AMD Debug"
VMDK="./VMDK/debug_amd/"
BASE="./DiskContents/Release-Base/."
CONFIG="./Config/debug_amd/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

# Build VMX files
mkdir -p ./Templates/intel
cp -v macos.vmdk ./Templates/intel
cp -v ./VMDK/release_intel/opencore.* ./Templates/intel

mkdir -p ./Templates/amd
cp -v macos.vmdk ./Templates/amd
cp -v ./VMDK/release_amd/opencore.* ./Templates/amd

jinja2 --format=toml --section=intel_macos_10_15 --outfile=./Templates/intel/macos1015.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=intel_macos_11 --outfile=./Templates/intel/macos11.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=intel_macos_12 --outfile=./Templates/intel/macos12.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=intel_macos_13 --outfile=./Templates/intel/macos13.vmx vmx.j2 vmx.toml

jinja2 --format=toml --section=amd_macos_10_15 --outfile=./Templates/amd/macos1015.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=amd_macos_11 --outfile=./Templates/amd/macos11.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=amd_macos_12 --outfile=./Templates/amd/macos12.vmx vmx.j2 vmx.toml
jinja2 --format=toml --section=amd_macos_13 --outfile=./Templates/amd/macos13.vmx vmx.j2 vmx.toml

exit