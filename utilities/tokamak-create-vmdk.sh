#!/bin/bash
# set -x

usage() {
	cat <<HELP
Usage:
$(basename "$0") "/path/to/flat.dmg" 

Description:
This script creates a .vmdk disk descriptor file for .dmg disk image file suitable for use
with VMware.

HELP
}

# Provide custom colors in Terminal for status and error messages

msg_status() {
	echo -e "\033[0;32m-- $1\033[0m"
}
msg_error() {
	echo -e "\033[0;31m-- $1\033[0m"
}

input_dmg="$1"

if [[ -z "$1" ]]; then
    msg_error "The path to the flat image file is required as the first argument."
    usage
	exit 1
fi

# Remove trailing slashes from input paths if needed
input_dmg=${input_dmg%%/}
output_vmdk=${input_dmg%.*}.vmdk

# Calculate # of 512 blocks required for flat file
byte_size="`stat -f '%z' $input_dmg`"
image_size=$((byte_size/512))

# Create the virtual disk descriptor.
cat <<VMDK >"$output_vmdk"
# Disk DescriptorFile
version=1
encoding="UTF-8"
CID=fffffffe
parentCID=ffffffff
isNativeSnapshot="no"
createType="monolithicFlat"

# Extent description
RW $image_size FLAT "$input_dmg" 0

# The Disk Data Base 
#DDB

ddb.adapterType = "lsilogic"
#ddb.geometry.cylinders is not used by Mac OS.
#ddb.geometry.heads is not used by Mac OS.
#ddb.geometry.sectors is not used by Mac OS.
#ddb.longContentID will be generated on the first write to the file.
#ddb.uuid is not used by Mac OS.
ddb.virtualHWVersion = "6"
VMDK

# Check VMDK is consistent
/Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -e "$installer_name.vmdk"

msg_status "Building process complete."

if [[ -f "$output_vmdk" ]]; then
  msg_status "Built .vmdk file is available at $output_vmdk"
else
  msg_error "Build failure! Built .vmdk file not found!"
fi
