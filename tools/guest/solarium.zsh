#!/usr/bin/env zsh
# {{VERSION}}-{{COMMIT}}
# SPDX-FileCopyrightText: © 2023-2026 David Parsons
# SPDX-License-Identifier: MIT

# Enable debug mode if DEBUG environment variable is set to any non-empty value
[[ -n "$DEBUG" ]] && set -x

PLIST_DIR="/Library/Preferences/FeatureFlags/Domain"
PLIST_FILE="$PLIST_DIR/SwiftUI.plist"
LOCAL_SOURCE="SwiftUI.plist"

echo "OC4VM Liquid Glass Utility"
echo "--------------------------"

# 1. Handle "status" or check for missing arguments early
if [[ -z "$1" ]]; then
    echo "Usage: $0 {on|off|status}"
    exit 1
fi

if [[ "$1" == "status" ]]; then
    CURRENT_VAL=$(plutil -extract Solarium.Enabled raw "$PLIST_FILE" 2>/dev/null)
    echo "Current Solarium status: ${CURRENT_VAL:-"Unknown (File or Key missing)"}"
    exit 0
fi

# 2. Set variables based on toggle
case "$1" in
    on)
        echo "Action: Enabling Liquid Glass (Solarium)..."
        FLAG="true"          # Solarium Enabled = true
        DISABLE_FLAG="false" # DisableSolarium = false
        ;;
    off)
        echo "Action: Disabling Liquid Glass (Solarium)..."
        FLAG="false"         # Solarium Enabled = false
        DISABLE_FLAG="true"  # DisableSolarium = true
        ;;
    *)
        echo "Usage: $0 {on|off|status}"
        exit 1
        ;;
esac

# 3. Check for local source file before proceeding
if [[ ! -f "$PLIST_FILE" ]]; then
    echo "Target plist not found in $PLIST_DIR."
    if [[ -f "$LOCAL_SOURCE" ]]; then
        echo "Found local $LOCAL_SOURCE. Copying to system directory..."
        sudo mkdir -p "$PLIST_DIR"
        sudo cp -v "$LOCAL_SOURCE" "$PLIST_FILE"
    else
        echo "Error: Local '$LOCAL_SOURCE' is missing. Cannot initialize system plist."
        exit 1
    fi
fi

# 4. Apply Desktop appearance settings
echo "Configuring Desktop appearance settings..."
defaults write -g com.apple.SwiftUI.DisableSolarium -bool $DISABLE_FLAG

# 5. Apply FeatureFlag settings
echo "Updating SwiftUI Solarium feature flags (root required)..."
sudo plutil -replace Solarium.Enabled -bool $FLAG "$PLIST_FILE"

echo "--------------------------"
echo "Done! Please reboot the system for changes to take effect."
