# Upgrade a VM

This will explain how nto upgrade OC4VM version 3 releases.

## Pre-upgrade checks
1. No snapshots
2. No linked clones

## Upgrade 3.0.0 to 3.0.1

The boot drive opencore.iso and opencore.vmdk will need to be copied to the existing VM overwiting the currenty files.


The VMX file parameters:

```
<vmxtool_path> set <vmx_file_path> guestinfo.oc4vm.version="3.0.1"
<vmxtool_path> set <vmx_file_path> guestinfo.oc4vm.revision="b28843f"
<vmxtool_path> set <vmx_file_path> guestinfo.oc4vm.upgraded="TRUE"
<vmxtool_path> set <vmx_file_path> tools.upgrade.policy="manual"
<vmxtool_path> set <vmx_file_path> __USB_Mouse_Fix__=""
<vmxtool_path> set <vmx_file_path> mouse.vusb.enable="TRUE"
<vmxtool_path> set <vmx_file_path> mouse.vusb.useBasicMouse="FALSE"
<vmxtool_path> set <vmx_file_path> usb.generic.allowHID="TRUE"
```