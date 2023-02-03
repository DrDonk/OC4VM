#!/usr/bin/env zsh
#set -x
echo Creating OpenCore DMG/VMDK Images

# Read current version
VERSION=$(<VERSION)
echo "$VERSION"
q
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
rm -rfv ./VMDK/*

# Create new output folders
mkdir -p ./VMDK/release_intel
mkdir -p ./VMDK/release_amd
mkdir -p ./VMDK/debug_intel
mkdir -p ./VMDK/debug_amd

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
BASE="./DiskContents/Debug-Base/."
CONFIG="./Config/debug_intel/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="AMD Debug"
VMDK="./VMDK/debug_amd/"
BASE="./DiskContents/Debug-Base/."
CONFIG="./Config/debug_amd/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

exit