#!/usr/bin/env pwsh
# {{VERSION}}-{{COMMIT}}
# SPDX-FileCopyrightText: © 2023-2026 David Parsons
# SPDX-License-Identifier: MIT

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# macOS version mapping (without TPM references)
$macOSVersionMap = [ordered]@{
    "darwin25-64" = "macOS 26.0 (Tahoe)"
    "darwin24-64" = "macOS 15.0 (Sequoia)"
    "darwin23-64" = "macOS 14.0 (Sonoma)"
    "darwin22-64" = "macOS 13.0 (Ventura)"
    "darwin21-64" = "macOS 12.0 (Monterey)"
    "darwin20-64" = "macOS 11.0 (Big Sur)"
    "darwin19-64" = "macOS 10.15 (Catalina)"
    "darwin18-64" = "macOS 10.14 (Mojave)"
    "darwin17-64" = "macOS 10.13 (High Sierra)"
    "darwin16-64" = "MacOS 10.12 (Sierra)"
    "darwin15-64" = "OS X 10.11 (El Capitan)"
    "darwin14-64" = "OS X 10.10 (Yosemite)"
    "darwin13-64" = "OS X 10.9 (Mavericks)"
    "darwin12-64" = "OS X 10.8 (Mountain Lion)"
    "darwin11-64" = "Mac OS X 10.7 (Lion)"
    "darwin11"    = "Mac OS X 10.7 (Lion 32-bit)"
    "darwin10-64" = "Mac OS X 10.6 (Snow Leopard)"
    "darwin10"    = "Mac OS X 10.6 (Snow Leopard 32-bit)"
    "darwin-64"   = "Mac OS X 10.5 (Leopard)"
    "darwin"      = "Mac OS X 10.5 (Leopard 32-bit)"
}

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "VMware macOS guestOS Configuration"
$form.Size = New-Object System.Drawing.Size(500,300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false

# VMX file selection controls
$labelFile = New-Object System.Windows.Forms.Label
$labelFile.Location = New-Object System.Drawing.Point(10,20)
$labelFile.Size = New-Object System.Drawing.Size(100,20)
$labelFile.Text = "VMX File:"
$form.Controls.Add($labelFile)

$textBoxFile = New-Object System.Windows.Forms.TextBox
$textBoxFile.Location = New-Object System.Drawing.Point(110,20)
$textBoxFile.Size = New-Object System.Drawing.Size(300,20)
$textBoxFile.ReadOnly = $true
$form.Controls.Add($textBoxFile)

$buttonBrowse = New-Object System.Windows.Forms.Button
$buttonBrowse.Location = New-Object System.Drawing.Point(420,20)
$buttonBrowse.Size = New-Object System.Drawing.Size(60,23)
$buttonBrowse.Text = "Browse"
$buttonBrowse.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "VMX files (*.vmx)|*.vmx"
    $openFileDialog.InitialDirectory = [Environment]::GetFolderPath("MyDocuments")
    if($openFileDialog.ShowDialog() -eq "OK") {
        $textBoxFile.Text = $openFileDialog.FileName
        UpdateCurrentSetting
    }
})
$form.Controls.Add($buttonBrowse)

# Current setting display
$labelCurrent = New-Object System.Windows.Forms.Label
$labelCurrent.Location = New-Object System.Drawing.Point(10,60)
$labelCurrent.Size = New-Object System.Drawing.Size(470,20)
$labelCurrent.Text = "Current guestOS: "
$form.Controls.Add($labelCurrent)

# New setting selection
$labelNew = New-Object System.Windows.Forms.Label
$labelNew.Location = New-Object System.Drawing.Point(10,100)
$labelNew.Size = New-Object System.Drawing.Size(100,20)
$labelNew.Text = "New guestOS:"
$form.Controls.Add($labelNew)

$comboBoxOS = New-Object System.Windows.Forms.ComboBox
$comboBoxOS.Location = New-Object System.Drawing.Point(110,100)
$comboBoxOS.Size = New-Object System.Drawing.Size(300,20)
$comboBoxOS.DropDownStyle = "DropDownList"
$macOSVersionMap.Values | ForEach-Object { [void]$comboBoxOS.Items.Add($_) }
$form.Controls.Add($comboBoxOS)

# Action buttons
$buttonSave = New-Object System.Windows.Forms.Button
$buttonSave.Location = New-Object System.Drawing.Point(150,150)
$buttonSave.Size = New-Object System.Drawing.Size(100,30)
$buttonSave.Text = "Save"
$buttonSave.Enabled = $false
$buttonSave.Add_Click({
    if($textBoxFile.Text -and $comboBoxOS.SelectedItem) {
        $selectedOS = $macOSVersionMap.GetEnumerator() | Where-Object { $_.Value -eq $comboBoxOS.SelectedItem } | Select-Object -First 1
        SetGuestOS -vmxPath $textBoxFile.Text -newOS $selectedOS.Key
        UpdateCurrentSetting
        [System.Windows.Forms.MessageBox]::Show("guestOS updated successfully!", "Success", "OK", "Information")
    }
})
$form.Controls.Add($buttonSave)

$buttonCancel = New-Object System.Windows.Forms.Button
$buttonCancel.Location = New-Object System.Drawing.Point(260,150)
$buttonCancel.Size = New-Object System.Drawing.Size(100,30)
$buttonCancel.Text = "Cancel"
$buttonCancel.Add_Click({
    $form.Close()
})
$form.Controls.Add($buttonCancel)

# Status bar
$statusBar = New-Object System.Windows.Forms.StatusStrip
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusBar.Items.Add($statusLabel) | Out-Null
$form.Controls.Add($statusBar)

# Function to update current setting display
function UpdateCurrentSetting {
    if($textBoxFile.Text -and (Test-Path $textBoxFile.Text)) {
        try {
            $currentOS = GetGuestOS -vmxPath $textBoxFile.Text
            $displayName = $macOSVersionMap[$currentOS]
            
            if($displayName) {
                $labelCurrent.Text = "Current guestOS: $displayName ($currentOS)"
                $comboBoxOS.SelectedItem = $displayName
            } else {
                $labelCurrent.Text = "Current guestOS: $currentOS (Not a macOS VM)"
                $comboBoxOS.SelectedIndex = -1
            }
            
            $buttonSave.Enabled = $true
            $statusLabel.Text = "Ready"
        } catch {
            $labelCurrent.Text = "Error reading VMX file"
            $statusLabel.Text = "Error: $($_.Exception.Message)"
            $buttonSave.Enabled = $false
        }
    }
}

# Function to get current guestOS
function GetGuestOS {
    param($vmxPath)
    
    $vmxContent = Get-Content $vmxPath
    $guestOSLine = $vmxContent | Where-Object { $_ -match '^guestOS\s*=\s*"' }
    
    if($guestOSLine) {
        return ($guestOSLine -split '"')[1]
    }
    
    throw "guestOS setting not found in VMX file"
}

# Function to set guestOS
function SetGuestOS {
    param($vmxPath, $newOS)
    
    # Backup original file
    $backupPath = "$vmxPath.bak"
    if(-not (Test-Path $backupPath)) {
        Copy-Item $vmxPath $backupPath
    }
    
    # Update VMX file
    $vmxContent = Get-Content $vmxPath
    $newContent = $vmxContent -replace '^guestOS\s*=.*', "guestOS = `"$newOS`""
    $newContent | Set-Content $vmxPath
    
    # Verify change
    $updatedOS = GetGuestOS -vmxPath $vmxPath
    if($updatedOS -ne $newOS) {
        throw "Failed to update guestOS setting"
    }
}

# Show the form
[void]$form.ShowDialog()