#!/usr/bin/env zsh

# TODO: Needs some better cleanup if an error occurs
#set -x

# Provide custom colors in Terminal for status and error messages
msg_status() {
  echo "\033[0;32m$1\033[0m"
}
msg_error() {
  echo "\033[0;31m$1\033[0m"
}
msg_status "Creating Base Disk Images"

# Build the DMG & VMDK
build_dmg() {

  # Make a copy of base image
  cp -v ./dmg/opencore.dmg ./dmg/$1/

  # Attach blank DMG and copy neccessary files
  hdiutil attach ./dmg/$1/opencore.dmg -noverify -nobrowse -noautoopen
  cp -r $2 /Volumes/OPENCORE
  rm -rf /Volumes/OPENCORE/.fseventsd
  dot_clean -m /Volumes/OPENCORE
  SetFile -a C /Volumes/OPENCORE
  hdiutil detach /Volumes/OPENCORE -force
}

  # Build the OpenCore DMG/vmdk files
msg_status "Creating release image..."
build_dmg release ./disk_contents/release-base/.
msg_status "Creating debug image"
build_dmg debug ./disk_contents/debug-base/.
