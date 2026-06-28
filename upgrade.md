# Upgrade a VM

## Check
1. No snapshots
2. No linked clones
3. 


"$VMXTOOL_PATH" set "$VMXFILE" guestinfo.oc4vm.version="3.0.1"
"$VMXTOOL_PATH" set "$VMXFILE" guestinfo.oc4vm.revision="b28843f"
"$VMXTOOL_PATH" set "$VMXFILE" guestinfo.oc4vm.upgraded="TRUE"
"$VMXTOOL_PATH" set "$VMXFILE" tools.upgrade.policy="manual"
"$VMXTOOL_PATH" set "$VMXFILE" __USB_Mouse_Fix__=""
"$VMXTOOL_PATH" set "$VMXFILE" mouse.vusb.enable="TRUE"
"$VMXTOOL_PATH" set "$VMXFILE" mouse.vusb.useBasicMouse="FALSE"
"$VMXTOOL_PATH" set "$VMXFILE" usb.generic.allowHID="TRUE"