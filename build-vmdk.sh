#!/usr/bin/env zsh
#set -x
echo Creating OpenCore DMG/VMDK Images

# Read current version
VERSION=$(<VERSION)
VERSION+=-$(git rev-parse --short HEAD)
echo "$VERSION"

# Build the DMG & VMDK
build_dmg() {
  msg_status "Building $1"

  # Make a copy of base image
  mkdir -v -p $2/esxi
  cp -v ./dmg/opencore.* $2/esxi/

  # Attach blank DMG and create OC setup
  hdiutil attach $2/esxi/opencore.dmg -noverify -nobrowse -noautoopen
  diskutil eraseVolume FAT32 OPENCORE /Volumes/OPENCORE
  cp -r $3 /Volumes/OPENCORE
  cp -r $4 /Volumes/OPENCORE/EFI/OC
  rm -rf /Volumes/OPENCORE/.fseventsd
  dot_clean -m /Volumes/OPENCORE
  ls -a /Volumes/OPENCORE
  hdiutil detach /Volumes/OPENCORE

  # Convert and validate VMDK
  /Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -e $2/esxi/opencore.vmdk
  /Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -r $2/esxi/opencore.vmdk -t 0 $2/opencore.vmdk
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
rm -rf ./build/vmdk/* 2>/dev/null

# Create new output folders
mkdir -p ./build/vmdk/intel-release
mkdir -p ./build/vmdk/amd-release
mkdir -p ./build/vmdk/intel-verbose
mkdir -p ./build/vmdk/amd-verbose
mkdir -p ./build/vmdk/intel-debug
mkdir -p ./build/vmdk/amd-debug
mkdir -p ./build/vmdk/intel-kdk
mkdir -p ./build/vmdk/amd-kdk

# Build the OpenCore DMG/vmdk files
MSG="Intel Release"
VMDK="./build/vmdk/intel-release"
BASE="./disk_contents/release-base/."
CONFIG="./build/config/intel-release/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="AMD Release"
VMDK="./build/vmdk/amd-release"
BASE="./disk_contents/release-base/."
CONFIG="./build/config/amd-release/config.plist"

build_dmg "$MSG" $VMDK $BASE $CONFIG
MSG="Intel Verbose"
VMDK="./build/vmdk/intel-verbose"
BASE="./disk_contents/release-base/."
CONFIG="./build/config/intel-verbose/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="AMD Verbose"
VMDK="./build/vmdk/amd-verbose"
BASE="./disk_contents/release-base/."
CONFIG="./build/config/amd-verbose/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="Intel Debug"
VMDK="./build/vmdk/intel-debug"
BASE="./disk_contents/debug-base/."
CONFIG="./build/config/intel-debug/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="AMD Debug"
VMDK="./build/vmdk/amd-debug"
BASE="./disk_contents/debug-base/."
CONFIG="./build/config/amd-debug/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="Intel KDK"
VMDK="./build/vmdk/intel-kdk"
BASE="./disk_contents/debug-base/."
CONFIG="./build/config/intel-kdk/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="AMD KDK"
VMDK="./build/vmdk/amd-kdk"
BASE="./disk_contents/debug-base/."
CONFIG="./build/config/amd-kdk/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

exit