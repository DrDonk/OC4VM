#!/usr/bin/env zsh
#set -x
echo Creating Opencore DMG images

# Build the DMG & VMDK
build_dmg() {
  msg_status "Building $1"
  
  hdiutil attach ./DMG/opencore.dmg
  diskutil eraseVolume FAT32 OPENCORE /Volumes/OPENCORE
  cp -r $3 /Volumes/OPENCORE
  cp -r $4 /Volumes/OPENCORE/EFI/OC
  rm -rf /Volumes/OPENCORE/.fseventsd
  dot_clean -m /Volumes/OPENCORE
  ls -a /Volumes/OPENCORE
  hdiutil detach /Volumes/OPENCORE
  
  /Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -e ./DMG/opencore.vmdk
  /Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -r ./DMG/opencore.vmdk -t 0 $2

  if [[ -f "$2" ]]; then
    msg_status "Built .vmdk file is available at $2"
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

rm -rf ./VMDK
mkdir -p ./VMDK/locked
mkdir -p ./VMDK/unlocked

MSG="Release VMware"
VMDK="./VMDK/unlocked/oc-rel-vmware.vmdk"
BASE="./DiskContents/Release-Base/."
CONFIG="./Release-VMWARE/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="Debug VMware"
VMDK="./VMDK/unlocked/oc-dbg-vmware.vmdk"
BASE="./DiskContents/Debug-Base/."
CONFIG="./Config/Debug-VMWARE/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="Release VMware+AVX2Fix"
VMDK="./VMDK/unlocked/oc-rel-vmware-avx2.vmdk"
BASE="./DiskContents/Release-Base/."
CONFIG="./Config/Release-VMWARE-AVX2FIX/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="Debug VMware+AVX2Fix"
VMDK="./VMDK/unlocked/oc-dbg-vmware-avx2.vmdk"
BASE="./DiskContents/Debug-Base/."
CONFIG="./Config/Debug-VMWARE-AVX2FIX/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="Release VirtualSMC"
VMDK="./VMDK/locked/oc-rel-smc.vmdk"
BASE="./DiskContents/Release-Base/."
CONFIG="./Config/Release-SMC/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="Debug VirtualSMC"
VMDK="./VMDK/locked/oc-dbg-smc.vmdk"
BASE="./DiskContents/Debug-Base/."
CONFIG="./Config/Debug-SMC/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="Release VirtualSMC+AVX2Fix"
VMDK="./VMDK/locked/oc-rel-smc-avx2.vmdk"
BASE="./DiskContents/Release-Base/."
CONFIG="./Config/Release-SMC-AVX2FIX/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

MSG="Debug VirtualSMC+AVX2Fix"
VMDK="./VMDK/locked/oc-dbg-smc-avx2.vmdk"
BASE="./DiskContents/Debug-Base/."
CONFIG="./Config/Debug-SMC-AVX2FIX/config.plist"
build_dmg "$MSG" $VMDK $BASE $CONFIG

exit