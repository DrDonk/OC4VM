#!/usr/bin/env pwsh
# {{VERSION}}-{{COMMIT}}
# SPDX-FileCopyrightText: © 2023-25 David Parsons
# SPDX-License-Identifier: MIT

# Enable debug mode if DEBUG environment variable is set to any non-empty value
if ($env:DEBUG) { $DebugPreference = "Continue" }

# Get script directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# Generate serial and MLB
$input = & "$SCRIPT_DIR\macserial.exe" -m Macmini8,1 -n 1 -w (Get-Date -UFormat "%U") -y (Get-Date -UFormat "%Y")
$parts = $input -split '\|'

# Trim whitespace from each part and assign to variables
$serial = $parts[0] -replace '\s',''
$mlb = $parts[1] -replace '\s',''

# Generate ROM (6 random bytes)
$randomBytes = New-Object byte[] 6
$rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
$rng.GetBytes($randomBytes)
$rom = ($randomBytes | ForEach-Object { "%{0:X2}" -f $_ }) -join ''
$rng.Dispose()

# Do the change
Write-Output "OC4VM regen"
Write-Output "-----------"
Write-Output "Regenerating Mac identifiers..."
Write-Output "Add these settings in the VMX file between lines:"
Write-Output "# >>> Start Spoofing <<<"
Write-Output "# >>> End Spoofing <<<"
Write-Output ""
Write-Output '__Apple_Model__ = "iMac 2019"'
Write-Output 'board-id = "Mac-63001698E7A34814"'
Write-Output 'hw.model = "iMac19,2"'
Write-Output "serialNumber = `"$serial`""
Write-Output "efi.nvram.var.MLB = `"$mlb`""
Write-Output "efi.nvram.var.ROM = `"$rom`""
Write-Output 'hypervisor.cpuid.v0 = "TRUE"'
Write-Output ""
Write-Output "End"
