# OC4VM Tools

## 1.0 OC4VM - Guest Tools
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

### 1.1 cpuid

This program dumps the guests CPUID data which is used for debugging certain issues
within the guest. The cpuid utiltiy has many parameters but the recommended options
are these:

```
Usage: cpuid -d -c0
```

### 1.2 sysinfo

Use this tool if you have spoofed a real Mac and want to check the details in the guest.
It will show the settings and NVRAM variables that are set when imitation a real Mac such
as serial number, ROM, MLB etc..

```
Usage: sysinfo
```

## 2.0 OC4VM - Host Tools
There are some tools located in the distribution package which are for use on the host
machine to modify the VMware VMX file. The host tools are located in the folder:
```
tools/host
```
## 2.1 macguest
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

## 2.2 regen
