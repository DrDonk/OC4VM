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
msg_status "Creating OpenCore for Virtual Machines"

# Read current version
VERSION=$(<VERSION)
VERSION+=-$(git rev-parse --short HEAD)
msg_status "Version: $VERSION"

# Build the DMG & VMDK
build_dmg() {

  # Make a copy of base image
  mkdir -v -p $1
  cp -v ./opencore/dmg/$2/opencore.dmg $1/

  # Attach blank DMG and create OC setup
  hdiutil attach $1/opencore.dmg -noverify -nobrowse -noautoopen
  cp -r $3 /Volumes/OPENCORE/EFI/OC
  rm -rf /Volumes/OPENCORE/.fseventsd
  dot_clean -m /Volumes/OPENCORE
  SetFile -a C /Volumes/OPENCORE
  hdiutil detach /Volumes/OPENCORE -force

  # Convert DMG to VMDK & QCOW2
  qemu-img convert -f raw -O vmdk $1/opencore.dmg $1/opencore.vmdk 2>&1 >/dev/null
  qemu-img check -f vmdk $1/opencore.vmdk
  if [[ -f "$1/opencore.vmdk" ]]; then
    msg_status "VMware vmdk file is available at $1/opencore.vmdk"
  else
    msg_error "Build failure! opencore.vmdk file not found!"
  fi
  qemu-img convert -f raw -O qcow2 $1/opencore.dmg $1/opencore.qcow2 2>&1 >/dev/null
  qemu-img check -f qcow2 $1/opencore.qcow2
  if [[ -f "$1/opencore.qcow2" ]]; then
    msg_status "QEMU qcow2 file is available at $1/opencore.qcow2"
  else
    msg_error "Build failure! opencore.qcow2 file not found!"
  fi
}

# Clear previous build
rm -rfv ./build/* 2>&1 >/dev/null
rm -rf ./recoveryOS/__pycache__ 2>&1 >/dev/null

variants=("${(f)$(./utilities/stoml_darwin_amd64 oc4vm.toml . | tr ' ' '\n')}")
for variant in $variants
do
    DESCRIPTION=$(./utilities/stoml_darwin_amd64 oc4vm.toml $variant.DESCRIPTION)

    # Check if build disabled
    BUILD=$(./utilities/stoml_darwin_amd64 oc4vm.toml $variant.BUILD)
    if [[ $BUILD == "0" ]]
    then
      msg_error "\nSkipping $DESCRIPTION variant!"
      continue
    else
      msg_status "\nBuilding $DESCRIPTION variant..."
    fi

    # Build config.plist
    msg_status "Step 1. Create config.plist"
    mkdir -p ./build/config/$variant 2>&1 >/dev/null
    jinja2 --format=toml \
      --section=$variant \
      -D VERSION=$VERSION \
      --outfile=./build/config/$variant/config.plist \
      ./opencore/config.j2 \
      oc4vm.toml

    # Build the OpenCore DMG/vmdk files
    msg_status "Step 2. Create disk images DMG/VMDK/QCOW2"
    mkdir -p ./build/disks/$variant
    DMG=$(./utilities/stoml_darwin_amd64 oc4vm.toml $variant.DMG)
    build_dmg ./build/disks/$variant $DMG ./build/config/$variant/config.plist

    # Build the VMware templates
    msg_status "Step 3. Create VMware templates"
    mkdir -p ./build/templates/vmware/$variant 2>&1 >/dev/null
    cp -v ./vmware/macos.vmdk ./build/templates/vmware/$variant 2>&1 >/dev/null
    cp -v ./build/disks/$variant/opencore.vmdk ./build/templates/vmware/$variant
    jinja2 --format=toml \
      --section=$variant \
      -D \
      VERSION=$VERSION \
      --outfile=./build/templates/vmware/$variant/macos.vmx \
      ./vmware/vmx.j2 \
      oc4vm.toml

    # Build the QEMU templates
    msg_status "Step 4. Create QEMU templates"
    mkdir -p ./build/templates/qemu/$variant 2>&1 >/dev/null
    cp -v ./qemu/edk2-x86_64-code.fd ./build/templates/qemu/$variant 2>&1 >/dev/null
    cp -v ./qemu/efi_vars.fd ./build/templates/qemu/$variant 2>&1 >/dev/null
    cp -v ./qemu/macos.qcow2 ./build/templates/qemu/$variant 2>&1 >/dev/null
    cp -v ./build/disks/$variant/opencore.qcow2 ./build/templates/qemu/$variant
    jinja2 --format=toml \
      --section=$variant \
      -D VERSION=$VERSION \
      --outfile=./build/templates/qemu/$variant/qemu-macos.sh \
      ./qemu/qemu-macos.j2 \
      oc4vm.toml
    chmod +x ./build/templates/qemu/$variant/qemu-macos.sh
done

msg_status "\nStep 5. Copying misc files"
cp -v README.md ./build/
cp -v LICENSE ./build/
cp -vr ./vmware/iso ./build/
cp -vr ./recoveryOS ./build/

msg_status "\nStep 6. Zipping OC4VM Release"
rm ./dist/oc4vm-$VERSION.* 2>&1 >/dev/null
7z a ./dist/oc4vm-$VERSION.zip ./build/*
cd ./dist
shasum -a 512 oc4vm-$VERSION.zip > oc4vm-$VERSION.sha512
cd ..
