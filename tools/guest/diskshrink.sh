#!/usr/bin/env zsh
# {{VERSION}}-{{COMMIT}}
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
}

msg_status "OC4VM VMware Disk Shrink"

# Get free space in bytes on /System/Volumes/Data
free_bytes=$(df -k /System/Volumes/Data | awk 'NR==2 {print $4}')
free_bytes=$((free_bytes * 1024))

# Subtract 5GB (5 * 1024^3 bytes) as a safety buffer
buffer_bytes=$((5 * 1024 * 1024 * 1024))
target_bytes=$(( free_bytes - buffer_bytes ))

# Bail out if there isn't more than 5GB free
if (( target_bytes <= 0 )); then
  msg_error "Insufficient free space on /System/Volumes/Data (less than 5GB available)"
  exit 1
fi

# Convert to MB for mkfile (mkfile uses bytes by default; use 'm' suffix for megabytes)
target_mb=$(( target_bytes / 1024 / 1024 ))

msg_status "Free space: $(( free_bytes / 1024 / 1024 ))MB — writing ${target_mb}MB zero filled file"
msg_warning "Ignore any disk space errors"
mkfile ${target_mb}m zerofile
sync
msg_status "Deleting temporary zero filled file"
rm ~/zerofile
sync
sleep 5

msg_warning "VMware disk shrinking started"
/Library/Application\ Support/VMware\ Tools/vmware-tools-daemon --cmd="disk.shrink"
msg_status "VMware disk shrinking completed"

exit 0
