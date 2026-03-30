#!/usr/bin/env bash
# {{VERSION}}-{{COMMIT}}
# SPDX-FileCopyrightText: © 2023-2026 David Parsons
# SPDX-License-Identifier: MIT

# Enable debug mode if DEBUG environment variable is set to any non-empty value
[[ -n "$DEBUG" ]] && set -x

# Do the change
echo "OC4VM cloak"
echo "-----------"
echo "Cloaking the VM..."
sudo nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:revpatch=sbvmm,asset,novmm
