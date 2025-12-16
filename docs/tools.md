# OC4VM Tools

## 1.0 OC4VM - Guest Tools
The OpenCore boot disk contains some useful tools to  provide information about the macOS guest.
These tools are rarely needed but can be useful for diagnosing guest issues.

The OC4VM boot drive should be mounted at in the macOS guest:
```
/Volumes/OPENCORE
```

and the tools are found at:
```
/Volumes/OPENCORE/OC4VM/tools/guest
```

### 1.1 shrinkdisk
The shrinkdisk tool is used to recover unused disk space from the virtual drive. This
can potentially reduce the amount of space used on the host system.

```
Usage: shrinkdisk
```

### 1.2 cpuid

This program dumps the guests CPUID data which is used for debugging certain issues
within the guest. The cpuid utiltiy has many parameters but the recommended options
are these:

```
Usage: cpuid -d -c0
```

### 1.3 sysinfo

Use this tool if you have spoofed a real Mac and want to check the details in the guest.
It will show the settings and NVRAM variables that are set when imitation a real Mac such
as serial number, ROM, MLB etc..

```
Usage: sysinfo
```

## 2.0 OC4VM - Host Tools
There are also tools located in the distribution package which are for use on the host
machine to modify the VMware VMX file. The host tools are located in the folder:
```
<installation_path>/tools/<linux/macos/windows>
```
where there is a folder for each host operating system.

## 2.1 macguest
VMware Workstation does not allow the selection of the macOS Guest types in the user interface.
This small program allows a VMX file to be opened and the version of macOS selected and written
back to the file.

There are two separate versions one for Windows and another for Linux. This is not needed on
VMware Fusion as the product allows selection of macOS guests directly.

The Windows version is a small executable created in PowerShell. Run macguest.exe program and select
the VMX file to modify.

The Linux version provides a shell script to update the geustOS setting. It should be run from 
```
<installation_path>/tools/linux
```

You can pass in a VMX file via the command parameters or select a file to work on from the menu.

```
Usage: macguest.sh [OPTIONS]

Options:
  -f, --file PATH    Specify VMX file path (bypasses file selector)
  -h, --help         Show this help message

Example:
  macguest.sh -f ~/VMs/macos.vmx
```

## 2.2 regen
This tool allows the guest to mimic an iMac 2019 (iMac19,2). There are 2 versions command line tool available 
in tools/<host_os_name>:

* regen.sh - Linux and macOS
* regen.ps1 - Windows PowerShell

```
Usage: regen.sh or regen.ps1 path_to_vmx_file
```
The tool will show you the settings being set and write them to the specified VMX file.
For more details see [spoofing](docs/spoof.md).
