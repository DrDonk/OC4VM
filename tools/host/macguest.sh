#!/bin/bash
# SPDX-FileCopyrightText: © 2023-25 David Parsons
# SPDX-License-Identifier: MIT
# macOS GuestOS Configuration Tool (Shell Script with gum)

# Check if required tools are installed
check_dependencies() {
    local missing=()
    for cmd in gum jq; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "The following required tools are missing:"
        for cmd in "${missing[@]}"; do
            echo " - $cmd"
        done
        echo "Please install them before running this script."
        exit 1
    fi
}

# macOS version mapping
setup_version_map() {
    cat <<EOF > /tmp/macos_versions.json
{
    "darwin24-64": "macOS 15.0 (Sequoia)",
    "darwin23-64": "macOS 14.0 (Sonoma)",
    "darwin22-64": "macOS 13.0 (Ventura)",
    "darwin21-64": "macOS 12.0 (Monterey)",
    "darwin20-64": "macOS 11.0 (Big Sur)",
    "darwin19-64": "macOS 10.15 (Catalina)",
    "darwin18-64": "macOS 10.14 (Mojave)",
    "darwin17-64": "macOS 10.13 (High Sierra)",
    "darwin16-64": "MacOS 10.12 (Sierra)",
    "darwin15-64": "OS X 10.11 (El Capitan)",
    "darwin14-64": "OS X 10.10 (Yosemite)",
    "darwin13-64": "OS X 10.9 (Mavericks)",
    "darwin12-64": "OS X 10.8 (Mountain Lion)",
    "darwin11-64": "Mac OS X 10.7 (Lion)",
    "darwin11": "Mac OS X 10.7 (Lion 32-bit)",
    "darwin10-64": "Mac OS X 10.6 (Snow Leopard)",
    "darwin10": "Mac OS X 10.6 (Snow Leopard 32-bit)",
    "darwin-64": "Mac OS X 10.5 (Leopard)",
    "darwin": "Mac OS X 10.5 (Leopard 32-bit)"
}
EOF
}

# Get current guestOS from VMX file
get_guest_os() {
    local vmx_path="$1"
    if [ ! -f "$vmx_path" ]; then
        gum style --foreground 1 "Error: VMX file not found"
        return 1
    fi

    local guest_os_line=$(grep -E '^guestOS\s*=\s*"' "$vmx_path" | head -1)
    if [ -z "$guest_os_line" ]; then
        gum style --foreground 1 "Error: guestOS setting not found in VMX file"
        return 1
    fi

    local guest_os=$(echo "$guest_os_line" | sed -E 's/^guestOS[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/')
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
    sed -i.bak -E "s/^guestOS[[:space:]]*=.*/guestOS = \"${new_os}\"/" "$vmx_path" || {
        gum style --foreground 1 "Error: Failed to update VMX file"
        return 1
    }

    # Verify change
    local updated_os=$(get_guest_os "$vmx_path")
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
            vmx_path=$(gum file --padding "3 3" --header.foreground 212 --header="VMware macOS guestOS Configuration Tool
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
        local display_name=$(jq -r ".\"${current_os}\" // empty" /tmp/macos_versions.json)

        # Show current setting
        if [ -n "$display_name" ]; then
            gum style --margin "1" "Current guestOS: $display_name ($current_os)"
        else
            gum style --margin "1" --foreground 3 "Current guestOS: $current_os (Not a macOS VM)"
        fi

        # Select new OS version
        local versions=()
        while IFS= read -r line; do
            versions+=("$line")
        done < <(jq -r 'to_entries[] | "\(.value) (\(.key))"' /tmp/macos_versions.json)

        local selected=$(printf "%s\n" "${versions[@]}" | gum choose --header "Select new macOS version:")

        if [ -z "$selected" ]; then
            gum confirm "Try another file?" && continue || exit 0
        fi

        # Extract the key from selection (part in parentheses)
        local new_os=$(echo "$selected" | sed -E 's/.*\(([^)]+)\)$/\1/')

        # Confirm change
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

    rm /tmp/macos_versions.json
}

main "$@"
