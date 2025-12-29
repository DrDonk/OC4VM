#!/usr/bin/env zsh
# {{VERSION}}-{{COMMIT}}
# SPDX-FileCopyrightText: © 2023-2026 David Parsons
# SPDX-License-Identifier: MIT

# Enable debug mode if DEBUG environment variable is set to any non-empty value
[[ -n "$DEBUG" ]] && set -x

# Define storage file location
DEFAULT_FILE="/Volumes/OPENCORE/EFI/OC/config.plist"
PLIST_FILE=${FILE:-$DEFAULT_FILE}

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

# Function to print usage information
print_usage() {
    cat << EOF
Usage: amdcpu <cores>
Valid values: 1, 2, 4, 8, 16, 24, 32, 64
EOF
}

set_value(){
	local index="$1"
    local value="$2"
	plutil -replace Kernel.Patch.$index.Replace -data ${value} -- "${PLIST_FILE}"
	# plutil -extract Kernel.Patch.$index.Replace raw -expect data -- "${PLIST_FILE}"
}

# Accepts values: 0, 1, 2, 4, 8, 16, 24, 32, 64
# 0 is hidden and resets the patch to 0
# Check if argument was provided
if [[ $# -eq 0 ]]; then
    print_usage
    exit 1
fi

# Validate input
valid_values=(0 1 2 4 8 16 32 64)
if [[ ! " ${valid_values[@]} " =~ " $1 " ]]; then
    print_usage
    exit 1
fi
value=$1

# Table of values
# ===============
# 
# | Cores | 10.13/10.14 | 10.15/11.0 | 12.0/13.0 | 13.3+     |
# |-------|-------------|------------|-----------|-----------|
# | 0     | uAAAAAAA    | ugAAAAAA   | ugAAAACQ  | ugAAAAA=  |
# | 1     | uAEAAAAA    | ugEAAAAA   | ugEAAACQ  | ugEAAAA=  |
# | 2     | uAIAAAAA    | ugIAAAAA   | ugIAAACQ  | ugIAAAA=  |
# | 4     | uAQAAAAA    | ugQAAAAA   | ugQAAACQ  | ugQAAAA=  |
# | 8     | uAgAAAAA    | uggAAAAA   | uggAAACQ  | uggAAAA=  |
# | 12    | uAwAAAAA    | ugwAAAAA   | ugwAAACQ  | ugwAAAA=  |
# | 16    | uBAAAAAA    | uhAAAAAA   | uhAAAACQ  | uhAAAAA=  |
# | 24    | uBgAAAAA    | uhgAAAAA   | uhgAAACQ  | uhgAAAA=  |
# | 28    | uBwAAAAA    | uhwAAAAA   | uhwAAACQ  | uhwAAAA=  |
# | 32    | uCAAAAAA    | uiAAAAAA   | uiAAAACQ  | uiAAAAA=  |
# | 64    | uEAAAAAA    | ukAAAAAA   | ukAAAACQ  | ukAAAAA=  |

# CAVEAT PROGRAMMER
# This is dependant on 1st 4 entries in Kernel/Patch are the 
# AMD patches in the same order as columns in table.
echo "OC4VM amdcpu"
echo "------------"
print Setting cores to $value
case $value in
0)
	# Hidden reset value
	set_value 0 uAAAAAAA
	set_value 1 ugAAAAAA
	set_value 2 ugAAAACQ
	set_value 3 ugAAAAA=
	;;
1)
	set_value 0 uAEAAAAA
	set_value 1 ugEAAAAA
	set_value 2 ugEAAACQ
	set_value 3 ugEAAAA=
	;;
2)
	set_value 0 uAIAAAAA
	set_value 1 ugIAAAAA 
	set_value 2 ugIAAACQ 
	set_value 3 ugIAAAA= 
	;;
4)
	set_value 0 uAQAAAAA
	set_value 1 ugQAAAAA
	set_value 2 ugQAAACQ
	set_value 3 ugQAAAA=
	;;
8)
	set_value 0 uAgAAAAA
	set_value 1 uggAAAAA
	set_value 2 uggAAACQ
	set_value 3 uggAAAA= 
	;;
16)
	set_value 0 uBAAAAAA
	set_value 1 uhAAAAAA
	set_value 2 uhAAAACQ
	set_value 3 uhAAAAA= 
	;;
32)
	set_value 0 uCAAAAAA
	set_value 1 uiAAAAAA
	set_value 2 uiAAAACQ
	set_value 3 uiAAAAA=
	;;
64)
	set_value 0 uEAAAAAA
	set_value 1 ukAAAAAA
	set_value 2 ukAAAACQ
	set_value 3 ukAAAAA= 
	;;
*)
	msg_error "RED ALERTS: Should never get here!"
	exit 1
	;;
esac
msg_warning "IMPORTANT: VM cores must match the new setting or VM will panic."
exit 0
