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

msg_status "OC4VM VMware Disk Zero Fill"

# Get free space in GB on /System/Volumes/Data
free_gb=$(df -k /System/Volumes/Data | awk 'NR==2 { print int($4 / 1048576) }')

# Subtract 5GB as a safety buffer
target_gb=$(( $free_gb - 5 ))

# Bail out if there isn't more than 5GB free
if (( $target_gb <= 0 )); then
  msg_error "Insufficient free space on /System/Volumes/Data (less than 5GB available)"
  exit 1
fi

msg_status "Free space: ${free_gb}GB — writing ${target_gb}GB zero filled file"
msg_warning "Ignore any disk space errors"
dd if=/dev/zero of=zerofile bs=1g count=${target_gb} #status=progress
sync
msg_status "Deleting temporary zero filled file"
rm ~/zerofile
sync
exit 0

