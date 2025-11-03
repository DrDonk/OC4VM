# OC4VM Tools

## OC4VM - Guest Tools
The OpenCore boot disk constains some useful tools to modify
the OpenCore configuration file config.plist.

The OC4VM boot drive should be mounted at in the macOS guest:
```
/Volumes/OPENCORE
```

and the tools are found at:
```
/Volumes/OPENCORE/OC4VM/tools/guest
```

All these tools depend on the OC4VM boot drive being mounted at that path and
will raise an error if the config.plist file cannot be found on the boot drive.


### amdcpu

This utility alters the AMD cores patch settings that are stored in config.plist.

Note: You must ensure the guest VM cores match the setting when you restart the VM
or you will likely get a kernel panic.

```
Usage: amdcpu <cores>
Valid values: 1, 2, 4, 8, 16, 24, 32, 64
```

### bootargs

This utility alters the macOS kernel boot-args that are stored in config.plist.

Note: OC4VM overrides any values stored in NVRAM. You will need to restart the system
for the settings to take effect.

```
OC4VM bootargs
--------------
Usage: bootargs [options] [value]
Options:
    -get            Print boot-args variable
    -set value      Set the boot-args variable
    -h              Print this help message
```

## OC4VM - Host Tools
There are some tools located in the distribution package which are for use on the host
machine to modify the VMware VMX file. The host tools are located in the folder:
```
tools/host
```
## macguest
VMware Workstation does not allow the selection of the macOS Guest types in the user interface.
This small program allows a VMX file to be opened and the version of macOS selected and written
back to the file.

There are two separate versions one for Windows and another for Linux. This is not needed on
Vmware Fusion as the product allows selection of macOS guests directly.

The Windows version is a small executable created in PowerShell. Run macguest.exe program and select
the VMX file to modify.

```
Usage: macguest.sh [OPTIONS]

Options:
  -f, --file PATH    Specify VMX file path (bypasses file selector)
  -h, --help         Show this help message

Example:
  macguest.sh -f ~/VMs/macos.vmx
```

## regen