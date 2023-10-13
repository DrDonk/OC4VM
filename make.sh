#!/usr/bin/env zsh
#set -x

# Provide custom colors in Terminal for status and error messages
msg_status() {
  echo "\033[0;32m$1\033[0m"
}
msg_error() {
  echo "\033[0;31m$1\033[0m"
}
msg_status "Creating OpenCore for Virtualization"

# Read current version
VERSION=$(<VERSION)
VERSION+=-$(git rev-parse --short HEAD)
msg_status "Version: $VERSION"

# Build the DMG & VMDK
build_dmg() {

  # Make a copy of base image
  mkdir -v -p $1
  cp -v ./dmg/opencore.dmg $1/

  # Attach blank DMG and create OC setup
  hdiutil attach $1/opencore.dmg -noverify -nobrowse -noautoopen
  cp -r $2 /Volumes/OPENCORE
  cp -r $3 /Volumes/OPENCORE/EFI/OC
  rm -rf /Volumes/OPENCORE/.fseventsd
  dot_clean -m /Volumes/OPENCORE
  #ls -la /Volumes/OPENCORE
  hdiutil detach /Volumes/OPENCORE

  # Convert DMG to VMDK & QCOW2
  qemu-img convert -f raw -O vmdk $1/opencore.dmg $1/opencore.vmdk
  qemu-img check -f vmdk $1/opencore.vmdk
  if [[ -f "$1/opencore.vmdk" ]]; then
    msg_status "VMware vmdk file is available at $1/opencore.vmdk"
  else
    msg_error "Build failure! opencore.vmdk file not found!"
  fi
  qemu-img convert -f raw -O qcow2 $1/opencore.dmg $1/opencore.qcow2
  qemu-img check -f qcow2 $1/opencore.qcow2
  if [[ -f "$1/opencore.qcow2" ]]; then
    msg_status "QEMU qcow2 file is available at $1/opencore.qcow2"
  else
    msg_error "Build failure! opencore.qcow2 file not found!"
  fi
}

# Clear previous build
rm -rfv ./build/* 2>&1 >/dev/null
rm -rf ./recovery-maker/__pycache__ 2>&1 >/dev/null

msg_status "\nCopying files..."
cp -v README.md ./build/
cp -v LICENSE ./build/
cp -vr ./iso ./build/
cp -vr ./recovery-maker ./build/

msg_status "\nCreating OpenCore disk images..."
variants=("${(f)$(./utilities/stoml_darwin_arm64 config.toml . | tr ' ' '\n')}")
for variant in $variants
do
    DESCRIPTION=$(./utilities/stoml_darwin_arm64 config.toml $variant.DESCRIPTION)
    msg_status "$DESCRIPTION variant:"

    # Build config.plist
    mkdir -p ./build/config/$variant 2>&1 >/dev/null
    jinja2 --format=toml --section=$variant -D VERSION=$VERSION --outfile=./build/config/$variant/config.plist config.j2 config.toml

    # Build the OpenCore DMG/vmdk files
    mkdir -p ./build/vmdk/$variant
    FILES=$(./utilities/stoml_darwin_arm64 config.toml $variant.FILES)
    VMDK="./build/vmdk/$variant"
    BASE="./disk_contents/$FILES/."
    CONFIG="./build/config/$variant/config.plist"
    build_dmg $VMDK $BASE $CONFIG
done

msg_status "\nCreating VMware templates..."
variants=("${(f)$(./utilities/stoml_darwin_arm64 vmx.toml . | tr ' ' '\n')}")
for variant in $variants
do
    msg_status "$variant variant"
    mkdir -p ./build/templates/vmware/$variant 2>&1 >/dev/null
    cp -v macos.vmdk ./build/templates/vmware/$variant 2>&1 >/dev/null
    cp -v ./build/vmdk/$variant/opencore.vmdk ./build/templates/vmware/$variant
    jinja2 --format=toml --section=$variant -D VERSION=$VERSION --outfile=./build/templates/vmware/$variant/macos.vmx vmx.j2 vmx.toml
done

msg_status "\nZipping OC4VM Release..."
rm ./dist/oc4vm-$VERSION.* 2>&1 >/dev/null
7z a ./dist/oc4vm-$VERSION.zip ./build/*
cd ./dist
shasum -a 512 oc4vm-$VERSION.zip > oc4vm-$VERSION.sha512
cd ..
