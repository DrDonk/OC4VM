#!/usr/bin/env zsh
# SPDX-FileCopyrightText: © 2023-2026 David Parsons
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
  exit 1
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

# Build the ISO
build_dmg() {

    # Make a copy of base image and ESXi descriptor file
    mkdir -v -p $1
    cp -v ./opencore/dmg/$2/opencore.iso $1/

    # Attach blank DMG and create OC setup
    hdiutil attach $1/opencore.iso -noverify -nobrowse -noautoopen
    touch /Volumes/OPENCORE/oc4vm-$VARIANT-$VERSION-$COMMIT
    cp -rv $3 /Volumes/OPENCORE/EFI/OC
    mkdir -v -p /Volumes/OPENCORE/OC4VM/tools
    cp -rv ./build/tools/guest/* /Volumes/OPENCORE/OC4VM/tools
    cp -rv ./iso /Volumes/OPENCORE/OC4VM
    rm -rf /Volumes/OPENCORE/.fseventsd
    dot_clean -m /Volumes/OPENCORE
    SetFile -a C /Volumes/OPENCORE
    hdiutil detach /Volumes/OPENCORE -force
}

run_jinja(){
    local input_file="$1"
    local output_file="$2"
    ./utilities/minijinja-cli \
        --format=toml \
        -D VERSION=$VERSION \
        -D COMMIT=$COMMIT \
        -s comment-start="{|" \
        -s comment-end="|}" \
        -o $output_file \
        $input_file
    chmod +x $output_file
}

# Clear previous build
rm -rfv ./build 2>&1 >/dev/null

msg_status "Step 1. Compile tools"

# Fixup version/commit in tools scripts
mkdir -p ./build/tools/guest 2>&1 >/dev/null
mkdir -p ./build/tools/linux 2>&1 >/dev/null
mkdir -p ./build/tools/macos 2>&1 >/dev/null
mkdir -p ./build/tools/windows 2>&1 >/dev/null

# Build guest tools
run_jinja ./tools/guest/shrinkdisk ./build/tools/guest/shrinkdisk
run_jinja ./tools/guest/sysinfo ./build/tools/guest/sysinfo
cp -v ./tools/guest/macserial ./build/tools/guest/macserial
cp -v ./tools/guest/cpuid ./build/tools/guest/cpuid
chmod +x ./build/tools/guest/*

# Build host tools
# - Linux
run_jinja ./tools/host/common/macguest.sh ./build/tools/linux/macguest.sh
run_jinja ./tools/host/common/regen.sh ./build/tools/linux/regen.sh
cp -v ./tools/host/linux/cpuid ./build/tools/linux/cpuid
cp -v ./tools/host/linux/macserial ./build/tools/linux/macserial
cp -v ./tools/host/linux/vmxtool ./build/tools/linux/vmxtool
chmod +x ./build/tools/linux/*

# - macOS
run_jinja ./tools/host/common/macguest.sh ./build/tools/macos/macguest.sh
run_jinja ./tools/host/common/regen.sh ./build/tools/macos/regen.sh
cp -v ./tools/host/macos/cpuid ./build/tools/macos/cpuid
cp -v ./tools/host/macos/macserial ./build/tools/macos/macserial
cp -v ./tools/host/macos/vmxtool ./build/tools/macos/vmxtool
chmod +x ./build/tools/macos/*

# - Windows
run_jinja ./tools/host/windows/regen.ps1 ./build/tools/windows/regen.ps1
cp -v ./tools/host/windows/cpuid.exe ./build/tools/windows/cpuid.exe
cp -v ./tools/host/windows/macguest.exe ./build/tools/windows/macguest.exe
cp -v ./tools/host/windows/macserial.exe ./build/tools/windows/macserial.exe
cp -v ./tools/host/windows/vmxtool.exe ./build/tools/windows/vmxtool.exe

# Build OC4VM disk images
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
    msg_status "Step 2. Create config.plist for $VARIANT"
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

    # Build the OpenCore ISO files
    msg_status "Step 3. Create ISO image for $VARIANT"
    mkdir -p ./build/disks/$VARIANT
    DMG=$(./utilities/stoml oc4vm.toml $VARIANT.DMG)
    build_dmg ./build/disks/$VARIANT $DMG ./build/config/$VARIANT/config.plist
done

# Build the VMware templates
VARIANTS=("intel" "amd")
for VARIANT in $VARIANTS
do
    msg_status "Step 4. Create VMware templates for $VARIANT"
    mkdir -p ./build/vmware/$VARIANT 2>&1 >/dev/null
    cp -v ./vmware/macos.plist ./build/vmware/$VARIANT 2>&1 >/dev/null
    cp -v ./vmware/macos.vmdk ./build/vmware/$VARIANT 2>&1 >/dev/null
    cp -v ./vmware/macos.nvram ./build/vmware/$VARIANT 2>&1 >/dev/null
    cp -v ./vmware/opencore.vmdk ./build/vmware/$VARIANT 2>&1 >/dev/null
    cp -v ./build/disks/$VARIANT/opencore.iso ./build/vmware/$VARIANT

    if [[ $VARIANT == 'amd' ]]; then
        AMD=1
    else
        AMD=0
    fi

    ./utilities/minijinja-cli \
        --format=toml \
        -D VERSION=$VERSION \
        -D COMMIT=$COMMIT \
        -D DESCRIPTION="macOS ${VARIANT:u}" \
        -D AMD=$AMD \
        -o ./build/vmware/$VARIANT/macos.vmx \
        ./vmware/macos.vmx

done

msg_status "\nStep 5. Copying misc files"
cp -v LICENSE ./build/
cp -vr ./iso ./build/

msg_status "\nStep 6. Zipping OC4VM Release"
rm ./dist/oc4vm-$VERSION.* 2>&1 >/dev/null
7z a ./dist/oc4vm-$VERSION.zip ./build/*
cd ./dist
shasum -a 512 oc4vm-$VERSION.zip > oc4vm-$VERSION.sha512
cd ..

# eza -alT ./build
