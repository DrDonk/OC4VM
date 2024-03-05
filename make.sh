#!/usr/bin/env zsh

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

files=(./opencore/*.toml)
for file in $files
do
    # Get variant, description and build flag
    VARIANT=$(./utilities/stoml $file VARIANT)
    DESCRIPTION=$(./utilities/stoml $file DESCRIPTION)
    BUILD=$(./utilities/stoml $file BUILD)

    # Check if build disabled
    if [[ $BUILD == "0" ]]
    then
        msg_error "\nSkipping $DESCRIPTION VARIANT!"
        continue
    else
        msg_status "\nBuilding $DESCRIPTION VARIANT..."
    fi

    # Build config.plist
    msg_status "Step 1. Create config.plist"
    mkdir -p ./build/config/$VARIANT 2>&1 >/dev/null
    ./utilities/minijinja-cli \
        --format=toml \
        -D VERSION=$VERSION \
        -D VARIANT=$VARIANT \
        -o ./build/config/$VARIANT/config.plist \
        ./opencore/config.j2 \
        $file

    xmllint ./build/config/$VARIANT/config.plist --valid --noout
    RETURN=$?
    if [ $RETURN -eq 0 ];
    then
      msg_status "config.plist correctly formatted"
    else
      msg_error "config.plist incorrectly formatted"
      exit $RETURN
    fi

    # Build the OpenCore DMG/vmdk files
    msg_status "Step 2. Create disk images DMG/VMDK/QCOW2"
    mkdir -p ./build/disks/$VARIANT
    DMG=$(./utilities/stoml $file DMG)
    build_dmg ./build/disks/$VARIANT $DMG ./build/config/$VARIANT/config.plist

    # Build the VMware templates
    msg_status "Step 3. Create VMware templates"
    mkdir -p ./build/templates/vmware/$VARIANT 2>&1 >/dev/null
    cp -v ./vmware/macos.vmdk ./build/templates/vmware/$VARIANT 2>&1 >/dev/null
    cp -v ./build/disks/$VARIANT/opencore.vmdk ./build/templates/vmware/$VARIANT
    ./utilities/minijinja-cli \
        --format=toml \
        -D VERSION=$VERSION \
        -D VARIANT=$VARIANT \
        -o ./build/templates/vmware/$VARIANT/macos.vmx \
        ./vmware/vmx.j2 \
        $file

    # Build the QEMU templates
    msg_status "Step 4. Create QEMU templates"
    mkdir -p ./build/templates/qemu/$VARIANT 2>&1 >/dev/null
    cp -v ./qemu/edk2-x86_64-code.fd ./build/templates/qemu/$VARIANT 2>&1 >/dev/null
    cp -v ./qemu/efi_vars.fd ./build/templates/qemu/$VARIANT 2>&1 >/dev/null
    cp -v ./qemu/macos.qcow2 ./build/templates/qemu/$VARIANT 2>&1 >/dev/null
    cp -v ./build/disks/$VARIANT/opencore.qcow2 ./build/templates/qemu/$VARIANT
    ./utilities/minijinja-cli \
        --format=toml \
        -D VERSION=$VERSION \
        -D VARIANT=$VARIANT \
        -o ./build/templates/qemu/$VARIANT/qemu-macos.sh \
        ./qemu/qemu-macos.j2 \
        $file
    chmod +x ./build/templates/qemu/$VARIANT/qemu-macos.sh
done

msg_status "\nStep 5. Copying misc files"
cp -v README.md ./build/
cp -v LICENSE ./build/
cp -vr ./vmware/tools ./build/templates/vmware

msg_status "\nStep 6. Zipping OC4VM Release"
rm ./dist/oc4vm-$VERSION.* 2>&1 >/dev/null
7z a ./dist/oc4vm-$VERSION.zip ./build/*
cd ./dist
shasum -a 512 oc4vm-$VERSION.zip > oc4vm-$VERSION.sha512
cd ..
