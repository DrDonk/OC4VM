#!/usr/bin/env zsh
# SPDX-FileCopyrightText: © 2023-25 David Parsons
# SPDX-License-Identifier: MIT

# Enable debug mode if DEBUG environment variable is set to any non-empty value
[[ -n "$DEBUG" ]] && set -x

# Provide custom colors in Terminal for status and error messages
msg_status() {
  echo "\033[0;32m$1\033[0m"
}

msg_warning() {
  echo "\033[0;33m$1\033[0m"
}

msg_error() {
  echo "\033[0;31m$1\033[0m"
}

# Bail out if not macOS
msg_status "Creating OpenCore for Virtual Machines"
if [[ $OSTYPE != 'darwin'* ]]; then
  msg_error 'OC4VM can only be built on macOS!'
fi

# Read current version
VERSION=$(<VERSION)
COMMIT=$(git rev-parse --short HEAD)
msg_status "Version: $VERSION Commit: $COMMIT"

# Build the DMG & VMDK
build_dmg() {

    # Make a copy of base image
    mkdir -v -p $1
    cp -v ./opencore/dmg/$2/opencore.dmg $1/

    # Attach blank DMG and create OC setup
    hdiutil attach $1/opencore.dmg -noverify -nobrowse -noautoopen
    cp -rv $3 /Volumes/OPENCORE/EFI/OC
    cp -rv ./build/tools /Volumes/OPENCORE
    cp -rv ./iso /Volumes/OPENCORE
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
}

# Clear previous build
rm -rfv ./build 2>&1 >/dev/null

msg_status "Step 0. Compile tools"

# Fixup version/commit in tools scripts
mkdir -p ./build/tools 2>&1 >/dev/null

./utilities/minijinja-cli \
    --format=toml \
    -D VERSION=$VERSION \
    -D COMMIT=$COMMIT \
    -o ./build/tools/amdcpu \
    ./tools/amdcpu
chmod +x ./build/tools/amdcpu

./utilities/minijinja-cli \
    --format=toml \
    -D VERSION=$VERSION \
    -D COMMIT=$COMMIT \
    -o ./build/tools/bootargs \
    ./tools/bootargs
chmod +x ./build/tools/bootargs

# ./utilities/minijinja-cli \
#     --format=toml \
#     -D VERSION=$VERSION \
#     -D COMMIT=$COMMIT \
#     -o ./build/tools/regen \
#     ./tools/regen
# chmod +x ./build/tools/regen

./utilities/minijinja-cli \
    --format=toml \
    -D VERSION=$VERSION \
    -D COMMIT=$COMMIT \
    -o ./build/tools/siputil.go \
    ./tools/siputil.go
go get howett.net/plist
env GOOS=darwin GOARCH=amd64 go build -o ./build/tools ./build/tools/siputil.go
rm ./build/tools/siputil.go 2>&1 >/dev/null

./utilities/minijinja-cli \
    --format=toml \
    -D VERSION=$VERSION \
    -D COMMIT=$COMMIT \
    -o ./build/tools/vmhide \
    ./tools/vmhide
chmod +x ./build/tools/vmhide

cp -v ./tools/cpuid ./build/tools/cpuid
cp -v ./tools/hostcaps ./build/tools/hostcaps
# cp -v ./tools/macserial ./build/tools/macserial

VARIANTS=("${(f)$(./utilities/stoml oc4vm.toml . | tr ' ' '\n')}")
for VARIANT in $VARIANTS
do

    # Get description and build flag
    DESCRIPTION=$(./utilities/stoml oc4vm.toml $VARIANT.DESCRIPTION)
    BUILD=$(./utilities/stoml oc4vm.toml $VARIANT.BUILD)

    # Check if build disabled
    if [[ $BUILD == "0" ]]
    then
        msg_error "\nSkipping $DESCRIPTION variant!"
        continue
    else
        msg_status "\nBuilding $DESCRIPTION variant..."
    fi

    # Build config.plist
    msg_status "Step 1. Create config.plist"
    mkdir -p ./build/config/$VARIANT 2>&1 >/dev/null
    ./utilities/minijinja-cli \
        --format=toml \
        -D VERSION=$VERSION \
        -D VARIANT=$VARIANT \
        -D COMMIT=$COMMIT \
        --select $VARIANT \
        -o ./build/config/$VARIANT/config.plist \
        ./opencore/config.plist \
        oc4vm.toml

    # Tests to ensure valid plist and OC configuration
    plutil -convert xml1 ./build/config/$VARIANT/config.plist
    xmllint ./build/config/$VARIANT/config.plist --valid --noout
    ./utilities/ocvalidate ./build/config/$VARIANT/config.plist
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
    DMG=$(./utilities/stoml oc4vm.toml $VARIANT.DMG)
    build_dmg ./build/disks/$VARIANT $DMG ./build/config/$VARIANT/config.plist
done

VARIANTS=("intel" "amd")
for VARIANT in $VARIANTS
do
    # Build the VMware templates
    msg_status "Step 3. Create VMware templates"
    mkdir -p ./build/vmware/$VARIANT 2>&1 >/dev/null
    cp -v ./vmware/macos.plist ./build/vmware/$VARIANT 2>&1 >/dev/null
    cp -v ./vmware/macos.vmdk ./build/vmware/$VARIANT 2>&1 >/dev/null
    cp -v ./build/disks/$VARIANT/opencore.vmdk ./build/vmware/$VARIANT

    if [[ $VARIANT == 'amd' ]]; then
        AMD=1
    else
        AMD=0
    fi

    ./utilities/minijinja-cli \
        --format=toml \
        -D VERSION=$VERSION \
        -D VARIANT=${VARIANT:u} \
        -D COMMIT=$COMMIT \
        -D DESCRIPTION="macOS ${VARIANT:u}" \
        -D AMD=$AMD \
        -o ./build/vmware/$VARIANT/macos.vmx \
        ./vmware/macos.vmx

done

msg_status "\nStep 4. Copying misc files"
cp -v ./vmware/macguest.exe ./build/vmware/
cp -v readme.md ./build/
cp -v notes.md ./build/
cp -v tools.md ./build/
cp -v LICENSE ./build/
cp -vr ./iso ./build/

msg_status "\nStep 6. Zipping OC4VM Release"
rm ./dist/oc4vm-$VERSION.* 2>&1 >/dev/null
7z a ./dist/oc4vm-$VERSION.zip ./build/*
cd ./dist
shasum -a 512 oc4vm-$VERSION.zip > oc4vm-$VERSION.sha512
cd ..
