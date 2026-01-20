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
echo "OC4VM cloak"
echo "-----------"
echo "Uncloaking the VM..."
"$VMXTOOL_PATH" set "$VMXFILE" board-id="VMM-x86_64"
