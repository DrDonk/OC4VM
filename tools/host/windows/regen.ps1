#!/usr/bin/env pwsh
# {{VERSION}}-{{COMMIT}}
# SPDX-FileCopyrightText: © 2023-2026 David Parsons
# SPDX-License-Identifier: MIT

# Enable debug mode if DEBUG environment variable is set to any non-empty value
if ($env:DEBUG) {
    $DebugPreference = "Continue"
    Write-Debug "Debug mode enabled"
}

# Get script directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$MACSERIAL_BIN = "macserial.exe"
$MACSERIAL_PATH = Join-Path $SCRIPT_DIR $MACSERIAL_BIN
$VMXTOOL_BIN = "vmxtool.exe"
$VMXTOOL_PATH = Join-Path $SCRIPT_DIR $VMXTOOL_BIN

# Check if macserial binary exists
if (-not (Test-Path $MACSERIAL_PATH)) {
    Write-Error "Error: $MACSERIAL_BIN not found at $MACSERIAL_PATH"
    Write-Error "Please ensure the macserial binary is in the same directory as this script"
    exit 1
}

# Check if vmxtool binary exists
if (-not (Test-Path $VMXTOOL_PATH)) {
    Write-Error "Error: $VMXTOOL_BIN not found at $VMXTOOL_PATH"
    Write-Error "Please ensure the vmxtool binary is in the same directory as this script"
    exit 1
}

$VMX_FILE = $args[0]
if (-not (Test-Path $VMX_FILE)) {
    Write-Error "Error: VMX file $VMX_FILE not found"
    exit 1
}

# Generate serial and MLB
$week = Get-Date -UFormat "%U"
$year = Get-Date -UFormat "%Y"
$input = & $MACSERIAL_PATH -m iMac19,2 -n 1 -w $week -y $year

# Check if macserial executed successfully
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error: Failed to execute $MACSERIAL_BIN"
    Write-Error "Command output: $input"
    exit 1
}

# Split into an array using the pipe as delimiter
$parts = $input -split '\|'

# Verify we got the expected number of parts
if ($parts.Count -lt 2) {
    Write-Error "Error: Unexpected output from $MACSERIAL_BIN"
    Write-Error "Expected format: 'serial | mlb'"
    Write-Error "Got: $input"
    exit 1
}

# Trim whitespace from each part and assign to variables
$serial = $parts[0].Trim()
$mlb = $parts[1].Trim()

# Validate the generated values are not empty
if ([string]::IsNullOrEmpty($serial) -or [string]::IsNullOrEmpty($mlb)) {
    Write-Error "Error: Generated serial or MLB is empty"
    Write-Error "Serial: '$serial'"
    Write-Error "MLB: '$mlb'"
    exit 1
}

# Generate ROM
$romBytes = New-Object byte[] 6
$rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
$rng.GetBytes($romBytes)
$rom = [System.BitConverter]::ToString($romBytes).Replace("-", "%").ToUpper()

# Check if ROM generation succeeded
if ([string]::IsNullOrEmpty($rom)) {
    Write-Error "Error: Failed to generate ROM value"
    exit 1
}

# Do the change
Write-Host "OC4VM regen"
Write-Host "-----------"
Write-Host "Regenerating Mac identifiers..."
Write-Host "Adding these settings to VMX file:"
Write-Host ""
Write-Host "__Apple_Model__ = `"iMac 2019`""
Write-Host "board-id = `"Mac-63001698E7A34814`""
Write-Host "hw.model = `"iMac19,2`""
Write-Host "serialNumber = `"$serial`""
Write-Host "efi.nvram.var.MLB = `"$mlb`""
Write-Host "efi.nvram.var.ROM = `"$rom`""
Write-Host ""
Write-Host "Running vmxtool to update file..."

& $VMXTOOL_PATH set $VMX_FILE __Apple_Model__ "iMac 2019"
& $VMXTOOL_PATH set $VMX_FILE board-id "Mac-63001698E7A34814"
& $VMXTOOL_PATH set $VMX_FILE hw.model "iMac19,2"
& $VMXTOOL_PATH set $VMX_FILE serialNumber $serial
& $VMXTOOL_PATH set $VMX_FILE efi.nvram.var.MLB $mlb
& $VMXTOOL_PATH set $VMX_FILE efi.nvram.var.ROM $rom
