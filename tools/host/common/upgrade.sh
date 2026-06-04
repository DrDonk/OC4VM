#!/usr/bin/env bash
# {{VERSION}}-{{COMMIT}}
# SPDX-FileCopyrightText: © 2023-2026 David Parsons
# SPDX-License-Identifier: MIT

# Enable debug mode if DEBUG environment variable is set to any non-empty value
[[ -n "$DEBUG" ]] && set -x

# Get script directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
VMXTOOL_BIN="vmxtool"
VMXTOOL_PATH="$SCRIPT_DIR/$VMXTOOL_BIN"

# Check if vmxtool binary exists and is executable
if [[ ! -f "$VMXTOOL_PATH" ]]; then
    echo "Error: $VMXTOOL_BIN not found at $VMXTOOL_PATH" >&2
    echo "Please ensure the vmxtool binary is in the same directory as this script" >&2
    exit 1
fi

if [[ ! -x "$VMXTOOL_PATH" ]]; then
    echo "Error: $VMXTOOL_BIN is not executable" >&2
    echo "Please run: chmod +x '$VMXTOOL_PATH'" >&2
    exit 1
fi

VMXFILE="$1"
if [[ ! -f "$VMXFILE" ]]; then
    echo "Error: VMX file $VMXFILE not found" >&2
    exit 1
fi

# Do the change
echo "Upgrade OC4VM"
echo "-------------"
echo ""
echo "Upgrading to OC4VM 3.0.1..."
"$VMXTOOL_PATH" set "$VMXFILE" guestinfo.oc4vm.version="3.0.1"
"$VMXTOOL_PATH" set "$VMXFILE" guestinfo.oc4vm.revision="b28843f"
"$VMXTOOL_PATH" set "$VMXFILE" guestinfo.oc4vm.upgraded="TRUE"
"$VMXTOOL_PATH" set "$VMXFILE" __USB_Mouse_Fix__=""
"$VMXTOOL_PATH" set "$VMXFILE" mouse.vusb.enable="TRUE"
"$VMXTOOL_PATH" set "$VMXFILE" mouse.vusb.useBasicMouse="FALSE"
"$VMXTOOL_PATH" set "$VMXFILE" usb.generic.allowHID="TRUE"
