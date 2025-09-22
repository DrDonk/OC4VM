#!/usr/bin/env bash
# {{VERSION}}-{{COMMIT}}
# SPDX-FileCopyrightText: © 2023-25 David Parsons
# SPDX-License-Identifier: MIT

# Enable debug mode if DEBUG environment variable is set to any non-empty value
[[ -n "$DEBUG" ]] && set -x

# Get script directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Generate serial and MLB
input=$("$SCRIPT_DIR/macserial.macos" -m Macmini8,1 -n 1 $(date +"-w %U -y %Y"))

# Split into an array using the pipe as delimiter
IFS='|' read -ra parts <<< "$input"

# Trim whitespace from each part and assign to variables
serial="${parts[0]// /}"
mlb="${parts[1]// /}"

# Generate ROM
rom=$(xxd -l6 -p /dev/random | tr -d '\n' | tr '[:lower:]' '[:upper:]' | sed 's/\(..\)/%\1/g')

# Do the change
echo "OC4VM regen"
echo "-----------"
echo "Regenerating Mac identifiers..."
echo "Add these settings in the VMX file between lines:"
echo "# >>> Start Spoofing <<<"
echo "# >>> End Spoofing <<<"
echo ""
echo "__Apple_Model__ = \"Mac mini 2018\""
echo "board-id = \"Mac-7BA5B2DFE22DDD8C\""
echo "hw.model = \"Macmini8,1\""
echo "serialNumber = \"$serial\""
echo "efi.nvram.var.MLB = \"$mlb\""
echo "efi.nvram.var.ROM = \"$rom\""
echo "system-id.enable = \"TRUE\""
echo "hypervisor.cpuid.v0 = \"TRUE\""             # !!Not always reliable and can cause a panic!!
echo ""
echo "End"
