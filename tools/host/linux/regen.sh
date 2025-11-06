#!/usr/bin/env bash
# {{VERSION}}-{{COMMIT}}
# SPDX-FileCopyrightText: © 2023-25 David Parsons
# SPDX-License-Identifier: MIT

# Enable debug mode if DEBUG environment variable is set to any non-empty value
[[ -n "$DEBUG" ]] && set -x

# Get script directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
MACSERIAL_BIN="macserial"
MACSERIAL_PATH="$SCRIPT_DIR/$MACSERIAL_BIN"
VMXTOOL_BIN="vmxtool"
VMXTOOL_PATH="$SCRIPT_DIR/$VMXTOOL_BIN"

# Check if macserial binary exists and is executable
if [[ ! -f "$MACSERIAL_PATH" ]]; then
    echo "Error: $MACSERIAL_BIN not found at $MACSERIAL_PATH" >&2
    echo "Please ensure the macserial binary is in the same directory as this script" >&2
    exit 1
fi

if [[ ! -x "$MACSERIAL_PATH" ]]; then
    echo "Error: $MACSERIAL_BIN is not executable" >&2
    echo "Please run: chmod +x '$MACSERIAL_PATH'" >&2
    exit 1
fi

# Check if vmxtool binary exists and is executable
if [[ ! -f "$VMXTOOL_PATH" ]]; then
    echo "Error: $VMXTOOL_BIN not found at $VMXTOOL_PATH" >&2
    echo "Please ensure the macserial binary is in the same directory as this script" >&2
    exit 1
fi

if [[ ! -x "$VMXTOOL_PATH" ]]; then
    echo "Error: $VMXTOOL_BIN is not executable" >&2
    echo "Please run: chmod +x '$VMXTOOL_PATH'" >&2
    exit 1
fi

# Generate serial and MLB
input=$("$MACSERIAL_PATH" -m iMac19,2 -n 1 $(date +"-w %U -y %Y"))

# Check if macserial executed successfully
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to execute $MACSERIAL_BIN" >&2
    echo "Command output: $input" >&2
    exit 1
fi

# Split into an array using the pipe as delimiter
IFS='|' read -ra parts <<< "$input"

# Verify we got the expected number of parts
if [[ ${#parts[@]} -lt 2 ]]; then
    echo "Error: Unexpected output from $MACSERIAL_BIN" >&2
    echo "Expected format: 'serial | mlb'" >&2
    echo "Got: $input" >&2
    exit 1
fi

# Trim whitespace from each part and assign to variables
serial="${parts[0]// /}"
mlb="${parts[1]// /}"

# Validate the generated values are not empty
if [[ -z "$serial" || -z "$mlb" ]]; then
    echo "Error: Generated serial or MLB is empty" >&2
    echo "Serial: '$serial'" >&2
    echo "MLB: '$mlb'" >&2
    exit 1
fi

# Generate ROM
rom=$(xxd -l6 -p /dev/random | tr -d '\n' | tr '[:lower:]' '[:upper:]' | sed 's/\(..\)/%\1/g')

# Check if ROM generation succeeded
if [[ -z "$rom" ]]; then
    echo "Error: Failed to generate ROM value" >&2
    exit 1
fi

# Do the change
echo "OC4VM regen"
echo "-----------"
echo "Regenerating Mac identifiers..."
echo "Adding these settings to VMX file:"
echo ""
echo "__Apple_Model__ = \"iMac 2019\""
echo "board-id = \"Mac-63001698E7A34814\""
echo "hw.model = \"iMac19,2\""
echo "serialNumber = \"$serial\""
echo "efi.nvram.var.MLB = \"$mlb\""
echo "efi.nvram.var.ROM = \"$rom\""
echo "hypervisor.cpuid.v0 = \"FALSE\""
echo ""
echo "Running vmxtool to update file."

VMX_FILE="test.vmx"
if [[ ! -f "$VMX_PATH" ]]; then
    echo "Error: VMX file $VMXPATH not found" >&2
    exit 1
fi
"$VMXTOOL_PATH" set $VMX_FILE __Apple_Model__ = "iMac 2019"
"$VMXTOOL_PATH" set $VMX_FILE board-id = "Mac-63001698E7A34814"
"$VMXTOOL_PATH" set $VMX_FILE hw.model = "iMac19,2"
"$VMXTOOL_PATH" set $VMX_FILE serialNumber = "$serial"
"$VMXTOOL_PATH" set $VMX_FILE efi.nvram.var.MLB = "$mlb"
"$VMXTOOL_PATH" set $VMX_FILE efi.nvram.var.ROM = "$rom"
"$VMXTOOL_PATH" set $VMX_FILE hypervisor.cpuid.v0 = "FALSE"
