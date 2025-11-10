#!/bin/bash
# {{VERSION}}-{{COMMIT}}
# SPDX-FileCopyrightText: © 2023-25 David Parsons
# SPDX-License-Identifier: MIT

# macOS version mapping (using arrays to preserve order)
MACOS_KEYS=(
    "darwin25-64" "darwin24-64" "darwin23-64" "darwin22-64" "darwin21-64"
    "darwin20-64" "darwin19-64" "darwin18-64" "darwin17-64" "darwin16-64"
    "darwin15-64" "darwin14-64" "darwin13-64" "darwin12-64" "darwin11-64"
    "darwin11" "darwin10-64" "darwin10" "darwin-64" "darwin"
)

declare -A MACOS_VERSION_MAP=(
    ["darwin25-64"]="macOS 26.0 (Tahoe)"
    ["darwin24-64"]="macOS 15.0 (Sequoia)"
    ["darwin23-64"]="macOS 14.0 (Sonoma)"
    ["darwin22-64"]="macOS 13.0 (Ventura)"
    ["darwin21-64"]="macOS 12.0 (Monterey)"
    ["darwin20-64"]="macOS 11.0 (Big Sur)"
    ["darwin19-64"]="macOS 10.15 (Catalina)"
    ["darwin18-64"]="macOS 10.14 (Mojave)"
    ["darwin17-64"]="macOS 10.13 (High Sierra)"
    ["darwin16-64"]="MacOS 10.12 (Sierra)"
    ["darwin15-64"]="OS X 10.11 (El Capitan)"
    ["darwin14-64"]="OS X 10.10 (Yosemite)"
    ["darwin13-64"]="OS X 10.9 (Mavericks)"
    ["darwin12-64"]="OS X 10.8 (Mountain Lion)"
    ["darwin11-64"]="Mac OS X 10.7 (Lion)"
    ["darwin11"]="Mac OS X 10.7 (Lion 32-bit)"
    ["darwin10-64"]="Mac OS X 10.6 (Snow Leopard)"
    ["darwin10"]="Mac OS X 10.6 (Snow Leopard 32-bit)"
    ["darwin-64"]="Mac OS X 10.5 (Leopard)"
    ["darwin"]="Mac OS X 10.5 (Leopard 32-bit)"
)

# Function to get current guestOS from VMX file
get_guest_os() {
    local vmx_path="$1"
    if [[ ! -f "$vmx_path" ]]; then
        echo "Error: VMX file not found" >&2
        return 1
    fi

    local guestos_line=$(grep -E '^guestOS\s*=\s*"' "$vmx_path" | head -1)
    if [[ -n "$guestos_line" ]]; then
        echo "$guestos_line" | sed -E 's/^guestOS[[:space:]]*=[[:space:]]*"([^"]*)".*/\1/'
        return 0
    else
        echo "Error: guestOS setting not found in VMX file" >&2
        return 1
    fi
}

# Function to set guestOS in VMX file
set_guest_os() {
    local vmx_path="$1"
    local new_os="$2"

    # Backup original file
    local backup_path="${vmx_path}.bak"
    if [[ ! -f "$backup_path" ]]; then
        cp "$vmx_path" "$backup_path" || {
            echo "Error: Failed to create backup" >&2
            return 1
        }
    fi

    # Update VMX file
    local temp_file="${vmx_path}.tmp"
    sed -E "s/^guestOS[[:space:]]*=.*/guestOS = \"${new_os}\"/" "$vmx_path" > "$temp_file" || {
        echo "Error: Failed to update VMX file" >&2
        rm -f "$temp_file"
        return 1
    }

    mv "$temp_file" "$vmx_path" || {
        echo "Error: Failed to replace VMX file" >&2
        return 1
    }

    # Verify change
    local updated_os
    updated_os=$(get_guest_os "$vmx_path")
    if [[ "$updated_os" != "$new_os" ]]; then
        echo "Error: Failed to update guestOS setting" >&2
        return 1
    fi

    return 0
}

# Function to display menu and get user selection
show_menu() {
    local current_vmx="$1"
    local current_os="$2"

    clear
    echo "================================================"
    echo "    VMware macOS guestOS Configuration"
    echo "================================================"
    echo
    echo "VMX File: $current_vmx"
    echo

    if [[ -n "$current_os" ]]; then
        local display_name="${MACOS_VERSION_MAP[$current_os]}"
        if [[ -n "$display_name" ]]; then
            echo "Current guestOS: $display_name ($current_os)"
        else
            echo "Current guestOS: $current_os (Not a macOS VM)"
        fi
    else
        echo "Current guestOS: Not available"
    fi

    echo
    echo "Available macOS versions:"
    echo "------------------------"

    local i=1
    for key in "${MACOS_KEYS[@]}"; do
        echo "  $i) ${MACOS_VERSION_MAP[$key]}"
        ((i++))
    done

    echo
    echo "  b) Browse for VMX file"
    echo "  q) Quit"
    echo
}

# Function to browse for VMX file
browse_vmx_file() {
    local start_dir="${1:-$HOME}"

    # Try to use graphical file browser if available
    if command -v zenity >/dev/null 2>&1; then
        zenity --file-selection --file-filter="VMX files (*.vmx) | *.vmx" --filename="$start_dir/" 2>/dev/null
    elif command -v kdialog >/dev/null 2>&1; then
        kdialog --getopenfilename "$start_dir/" "VMX files (*.vmx) | *.vmx" 2>/dev/null
    else
        # Fallback to text-based browser
        echo "Please enter the path to your VMX file:"
        read -e -p "VMX file: " -i "$start_dir/" selected_file
        echo "$selected_file"
    fi
}

# Main function
main() {
    local vmx_file=""
    local current_os=""

    while true; do
        show_menu "$vmx_file" "$current_os"

        read -p "Please select an option: " choice

        case $choice in
            [1-9]|[1-9][0-9])
                if [[ -z "$vmx_file" ]]; then
                    echo "Error: No VMX file selected. Please browse for a VMX file first."
                    read -p "Press Enter to continue..."
                    continue
                fi

                local selected_index=$choice
                if [[ $selected_index -le ${#MACOS_KEYS[@]} ]]; then
                    local selected_key="${MACOS_KEYS[$((selected_index-1))]}"
                    local selected_value="${MACOS_VERSION_MAP[$selected_key]}"

                    echo
                    echo "Selected: $selected_value"
                    read -p "Are you sure you want to update the guestOS to this version? (y/n): " confirm

                    if [[ "$confirm" =~ ^[Yy]$ ]]; then
                        if set_guest_os "$vmx_file" "$selected_key"; then
                            current_os="$selected_key"
                            echo "Success: guestOS updated to $selected_value"
                        else
                            echo "Error: Failed to update guestOS"
                        fi
                    else
                        echo "Operation cancelled"
                    fi
                else
                    echo "Error: Invalid selection"
                fi
                read -p "Press Enter to continue..."
                ;;
            b|B)
                local new_file
                new_file=$(browse_vmx_file "$HOME")
                if [[ -n "$new_file" && -f "$new_file" ]]; then
                    vmx_file="$new_file"
                    current_os=$(get_guest_os "$vmx_file" 2>/dev/null || echo "")
                    if [[ $? -ne 0 ]]; then
                        echo "Warning: $current_os"
                        current_os=""
                    fi
                elif [[ -n "$new_file" ]]; then
                    echo "Error: File not found: $new_file"
                    read -p "Press Enter to continue..."
                fi
                ;;
            q|Q)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Error: Invalid option '$choice'"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Check dependencies
check_dependencies() {
    local missing_deps=()

    for cmd in grep sed cp mv; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo "Error: Missing required dependencies: ${missing_deps[*]}" >&2
        echo "Please install them to use this script." >&2
        exit 1
    fi
}

# Run dependency check and main function
check_dependencies
main
