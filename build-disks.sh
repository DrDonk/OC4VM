#!/usr/bin/env zsh
#set -x
echo Creating OpenCore DMG/VMDK/QCOW2 Images

# Read current version
VERSION=$(<VERSION)
VERSION+=-$(git rev-parse --short HEAD)
echo "$VERSION"

# Build the DMG & VMDK
build_dmg() {
  msg_status "Building $1"

  # Make a copy of base image
  mkdir -v -p $2
  cp -v ./dmg/opencore.* $2/

  # Attach blank DMG and create OC setup
  hdiutil attach $2/opencore.dmg -noverify -nobrowse -noautoopen
  diskutil eraseVolume FAT32 OPENCORE /Volumes/OPENCORE
  cp -r $3 /Volumes/OPENCORE
  cp -r $4 /Volumes/OPENCORE/EFI/OC
  rm -rf /Volumes/OPENCORE/.fseventsd
  dot_clean -m /Volumes/OPENCORE
  ls -a /Volumes/OPENCORE
  hdiutil detach /Volumes/OPENCORE

  # Convert DMG to VMDK & QCOW2
  qemu-img convert -f raw -O vmdk $2/opencore.dmg $2/opencore.vmdk
  qemu-img check -f vmdk $2/opencore.vmdk
  if [[ -f "$2/opencore.vmdk" ]]; then
    msg_status "VMware vmdk file is available at $2/opencore.vmdk"
  else
    msg_error "Build failure! opencore.vmdk file not found!"
  fi
  qemu-img convert -f raw -O qcow2 $2/opencore.dmg $2/opencore.qcow2
  qemu-img check -f qcow2 $2/opencore.qcow2
  if [[ -f "$2/opencore.qcow2" ]]; then
    msg_status "QEMU qcow2 file is available at $2/opencore.qcow2"
  else
    msg_error "Build failure! opencore.qcow2 file not found!"
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
rm -rf ./build/vmdk/* 2>/dev/null

# Create new output folders
mkdir -p ./build/vmdk/intel-release
mkdir -p ./build/vmdk/intel-verbose
mkdir -p ./build/vmdk/intel-debug
mkdir -p ./build/vmdk/intel-kdk

# Build the OpenCore DMG/vmdk files
MSG="Intel Release"
VMDK="./build/vmdk/intel-release"
BASE="./disk_contents/release-base/."
CONFIG="./build/config/intel-release/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="Intel Verbose"
VMDK="./build/vmdk/intel-verbose"
BASE="./disk_contents/release-base/."
CONFIG="./build/config/intel-verbose/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="Intel Debug"
VMDK="./build/vmdk/intel-debug"
BASE="./disk_contents/debug-base/."
CONFIG="./build/config/intel-debug/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="Intel KDK"
VMDK="./build/vmdk/intel-kdk"
BASE="./disk_contents/debug-base/."
CONFIG="./build/config/intel-kdk/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

exit