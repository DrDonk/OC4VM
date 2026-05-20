#!/usr/bin/env zsh
# 3.0.0-b85a2d3
# SPDX-FileCopyrightText: © 2023-2026 David Parsons
# SPDX-License-Identifier: MIT

# Enable debug mode if DEBUG environment variable is set to any non-empty value
[[ -n "$DEBUG" ]] && set -x

NVRAM_KEY="4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:revpatch"

echo "OC4VM Cloak Utility"
echo "-------------------"

case "$1" in
    on)
        echo "Cloaking the VM..."
        sudo nvram "$NVRAM_KEY"=sbvmm,asset,novmm
        nvram "$NVRAM_KEY"
        echo "Please now reboot the VM."
        ;;
    off)
        echo "Uncloaking the VM..."
        # Specifically setting to sbvmm,asset to avoid breaking the VM
        sudo nvram "$NVRAM_KEY"=sbvmm,asset
        nvram "$NVRAM_KEY"
        echo "Please now reboot the VM."
        ;;
    status)
        echo "Checking Cloak status..."
        CURRENT_VAL=$(nvram "$NVRAM_KEY" 2>/dev/null)
        echo "Current NVRAM Value: ${CURRENT_VAL:-"Not Set"}"
        if [[ "$CURRENT_VAL" =~ "novmm" ]]; then
            echo "Cloaking is enabled"
        else
            echo "Cloaking is disabled"
        fi
        ;;
    *)
        echo "Usage: $0 {on|off|status}"
        exit 1
        ;;
esac
