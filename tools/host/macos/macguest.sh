#!/usr/bin/env bash
# {{VERSION}}-{{COMMIT}}
# SPDX-FileCopyrightText: © 2023-25 David Parsons
# SPDX-License-Identifier: MIT

# Enable debug mode if DEBUG environment variable is set to any non-empty value
[[ -n "$DEBUG" ]] && set -x

# Get script directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Check if required tools are installed
check_dependencies() {
    # Setup essential file paths
    GUM_BIN="gum"
    GUM_PATH="$SCRIPT_DIR/$GUM_BIN"
    VMXTOOL_BIN="vmxtool"
    VMXTOOL_PATH="$SCRIPT_DIR/$VMXTOOL_BIN"
    DATA="guestos.dat"
    DATA_PATH="$SCRIPT_DIR/$DATA"
    
    # Check if gum binary exists and is executable
    if [[ ! -f "$GUM_PATH" ]]; then
        echo "Error: $GUM_BIN not found at $GUM_PATH" >&2
        echo "Please ensure the macserial binary is in the same directory as this script" >&2
        exit 1
    fi
    
    if [[ ! -x "$GUM_PATH" ]]; then
        echo "Error: $GUM_BIN is not executable" >&2
        echo "Please run: chmod +x '$GUM_PATH'" >&2
        exit 1
    fi
    
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
    
    # Check if vmxtool binary exists and is executable
    if [[ ! -f "$DATA_PATH" ]]; then
        echo "Error: $DATA not found at $DATA_PATH" >&2
        echo "Please ensure the guestos.dat file is in the same directory as this script" >&2
        exit 1
    fi
}

# Get current guestOS from VMX file
get_guest_os() {
    local vmx_path="$1"
    if [ ! -f "$vmx_path" ]; then
        gum style --foreground 1 "Error: VMX file not found"
        return 1
    fi

    local guest_os=$($VMXTOOL_PATH query "$vmx_path" guestOS)
    if [ $? -eq 1 ]; then
        gum style --foreground 1 $guest_os
        return 1
    fi

    echo "$guest_os"
}

# Set guestOS in VMX file
set_guest_os() {
    local vmx_path="$1"
    local new_os="$2"

    # Create backup
    if [ ! -f "${vmx_path}.bak" ]; then
        cp "$vmx_path" "${vmx_path}.bak" || {
            gum style --foreground 1 "Error: Failed to create backup file"
            return 1
        }
    fi

    # Update the file
    local output=$($VMXTOOL_PATH set "$vmx_path" guestOS=$new_os)
    if [ $? -eq 1 ]; then
        gum style --foreground 1 $output
        return 1
    fi
    
    # Verify change
    updated_os=$(get_guest_os "${vmx_path}")
    if [ "$updated_os" != "$new_os" ]; then
        gum style --foreground 1 "Error: Failed to update guestOS setting"
        return 1
    fi

    return 0
}

# Show usage information
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -f, --file PATH    Specify VMX file path (bypasses file selector)"
    echo "  -h, --help         Show this help message"
    echo
    echo "Example:"
    echo "  $0 -f ~/VMs/macos.vmx"
    exit 0
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--file)
                VMX_FILE="$2"
                shift # past argument
                shift # past value
                ;;
            -h|--help)
                show_help
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Main UI
main() {
    local VMX_FILE=""
    parse_args "$@"

    check_dependencies
    setup_version_map

    while true; do
        clear
        # Get VMX file path (either from argument or via selector)
        local vmx_path
        if [ -n "$VMX_FILE" ]; then
            vmx_path="$VMX_FILE"
            # Clear the VMX_FILE variable so subsequent loops will use the selector
            VMX_FILE=""
        else
            vmx_path=$(gum file --padding "3 3" --header.foreground 212 --header "VMware macOS guestOS Configuration Tool
Select VMX file:" --file)
            if [ -z "$vmx_path" ]; then
                exit 0
            fi
        fi

        gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
            "VMware macOS guestOS Configuration Tool"

        # Get current setting
        local current_os=$(get_guest_os "$vmx_path")
        if [ $? -ne 0 ]; then
            gum confirm "Try another file?" && continue || exit 0
        fi

        # Get display name for current OS
        local display_name=$($VMXTOOL_PATH query $DATA $current_os)

        # Show current setting
        if [ -n "$display_name" ]; then
            gum style --margin "1" "Current guestOS: $display_name ($current_os)"
        else
            gum style --margin "1" --foreground 3 "Current guestOS: $current_os (Not a macOS VM)"
        fi

        # Select new OS version
        local selected=$(gum table --height 21 --columns "guestOS,Name" --separator = --file $DATA_PATH)
        if [ -z "$selected" ]; then
            gum confirm "Try another file?" && continue || exit 0
        fi

        # Extract the key from selection (part in parentheses)
        local new_os=${selected%%=*}
        local new_display_name=$(echo "$selected" | cut -d'=' -f2 | xargs)
        
        gum confirm "Change guestOS from '$current_os' to '$new_os'?" || {
            gum confirm "Try another file?" && continue || exit 0
        }

        # Make the change
        if set_guest_os "$vmx_path" "$new_os"; then
            gum style --foreground 2 "guestOS updated successfully"
        else
            gum style --foreground 1 "Failed to update guestOS"
        fi

        gum confirm "Make another change?" || break
    done

}

main "$@"
