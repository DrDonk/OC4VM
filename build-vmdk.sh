#!/usr/bin/env zsh
#set -x
echo Creating OpenCore DMG/vmdk Images

# Read current version
VERSION=$(<VERSION)
echo "$VERSION"

# Build the DMG & VMDK
build_dmg() {
  msg_status "Building $1"

  # Make a copy of base image
  cp -v ./dmg/opencore.* $2

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
rm -rfv ./build/vmdk/*

# Create new output folders
mkdir -p ./build/vmdk/release_intel
mkdir -p ./build/vmdk/release_amd
mkdir -p ./build/vmdk/debug_intel
mkdir -p ./build/vmdk/debug_amd

# Build the OpenCore DMG/vmdk files
MSG="Intel Release"
VMDK="./build/vmdk/release_intel/"
BASE="./disk_contents/Release-Base/."
CONFIG="./build/config/release_intel/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="AMD Release"
VMDK="./build/vmdk/release_amd/"
BASE="./disk_contents/Release-Base/."
CONFIG="./build/config/release_amd/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="Intel Debug"
VMDK="./build/vmdk/debug_intel/"
BASE="./disk_contents/Debug-Base/."
CONFIG="./build/config/debug_intel/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="AMD Debug"
VMDK="./build/vmdk/debug_amd/"
BASE="./disk_contents/Debug-Base/."
CONFIG="./build/config/debug_amd/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

exit