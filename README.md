# OC4VM - OpenCore for VMware
## 1. Introduction
OpenCore 4 VMware (OC4VM) provides a set of VMware macOS templates and boot disks to allow macOS to run on ESXi, Linux 
and Windows. This system does not require patching VMware using the Unlocker and also allows fixes to limitations which
cannot be patched in VMware. For example, running Ventura on pre-Haswell CPUs without AVX2 support. It can also be used
with VMware Fusion to fix issues such as booting to Recovery mode which is not enabled in VMware UEFI firmware.

The OC4VM has been tested with Catalina, Big Sur, Monterey and Ventura on Intel and AMD CPUs.

## 2. Using OC4VM
### 2.1 Download Release

* Download a binary release from https://github.com/DrDonk/oc4vm/releases
* Optionally check the sha512 checksum matches that published in the release
* Unzip the archive to extract the files
* Navigate to the folder with the extracted files

### 2.1 Folder Contents

OC4VM has 

### 2.2 VM Templates
There is a folder called "templates" that contain a VM template for either Intel or AMD CPU based macOS virtual 
machines. Each folder has an OpenCore booter and VMX file tailored for the CPU that is running on the host.

```
templates
├── intel
│  ├── opencore.vmdk
│  ├── opencore.dmg
│  ├── macos1015.vmx
│  ├── macos13.vmx
│  ├── macos12.vmx
│  ├── macos11.vmx
│  └── macos.vmdk
└── amd
   ├── opencore.vmdk
   ├── opencore.dmg
   ├── macos1015.vmx
   ├── macos13.vmx
   ├── macos12.vmx
   ├── macos11.vmx
   └── macos.vmdk
```
Each folder comprises of the following files:

| File          | Function                             |
|:--------------|--------------------------------------|
| opencore.vmdk | Virtual Disk descriptor for DMG file |
| opencore.dmg  | OpenCore boot DMG file               |
| macos1015.vmx | macOS 10.15 Catalina VMX file        |
| macos11.vmx   | macOS 11 Big Sur VMX file            |
| macos12.vmx   | macOS 12 Monterey VMX file           |
| macos13.vmx   | macOS 13 Ventura VMX file            |
| macos.vmdk    | Pre-formated HFS+J virtual disk      |

To create a new virtual machine copy either the Intel or AMD template to a new folder and remove the VMX files that
you do not need. For example, if you are building a Ventura VM remove macos1015.vmx. macos11.vmx and macos12.vmx. The
new folder should have:

* opencore.vmdk
* opencore.dmg
* macos13.vmx
* macos.vmdk

***
Note: 

Make sure you use the correct folder for your CPU as using the wrong one will cause the VM not to boot 
and give an error message.
***

Before powering on the new VM you will need to set networking up for your environment. The templates do not specify what
networking type is required and so start disconnected.

## x.x VMware Tools
OC4VM provides a copy of the VMware tools ISO images. Version 16/17 of Workstation Pro recognises the darwin.iso files 
and the tools can be installed in the usual way by using the "Install VMware Tools" menu item. The Player version does
not automatically pick up the ISO images and so the darinw.iso image must be maually attached to the VM via the guest's
settings.

Copy the tools ISOs to these folders if you want the tools to be found directly by Workstation:

* Windows - C:\Program Files (x86)\VMware\VMware Workstation\
* Linux
* ESXi

## x. Limitations
The only downside of not using the unlocker is the guest OS type cannot be changed in the VMware Workstation UI. 
This should not be a problem as the OC4VM package provides template VMs for 10.15 (Catalina) through to 13 (Ventura). 
The "guestos" VMX file setting can be matched up to this table if the version of macOS needs to be changed.

The templates for macOS 11-13 are set to darwin20-64 for maximum compatibilty between different releases and platforms, 
and later settings appear to be identical in terms of function and capabilities based on extensive testing.

| macOS                 | Name          | VMX guestOS Setting |
|:----------------------|---------------|---------------------|
| macOS 10.5 (32-bit)   | Leopard       | darwin              |
| macOS 10.5 (64-bit)   | Leopard       | darwin-64           |
| macOS 10.6 (32-bit)   | Snow Leopard  | darwin10            |
| macOS 10.6 (64-bit)   | Snow Leopard  | darwin10-64         |
| macOS 10.7 (32-bit)   | Lion          | darwin11            |
| macOS 10.7 (64-bit)   | Lion          | darwin11-64         |
| macOS 10.8            | Mountain Lion | darwin12-64         |
| macOS 10.9            | Mavericks     | darwin13-64         |
| macOS 10.10           | Yosemite      | darwin14-64         |
| macOS 10.11           | El Capitan    | darwin15-64         |
| macOS 10.12           | Sierra        | darwin16-64         |
| macOS 10.13           | High Sierra   | darwin17-64         |
| macOS 10.14           | Mojave        | darwin18-64         |
| macOS 10.15           | Catalina      | darwin19-64         |
| macOS 11              | Big Sur       | darwin20-64         |
| macOS 12              | Monterey      | darwin21-64         |
| macOS 13              | Ventura       | darwin22-64         |

## x. VMware Downloads
These URLs will link to the latest versions of VMware's products:

* VMware Fusion https://vmware.com/go/getfusion
* VMware Workstation for Windows https://www.vmware.com/go/getworkstation-win
* VMware Workstation for Linux https://www.vmware.com/go/getworkstation-linux
* VMware Player for Windows https://www.vmware.com/go/getplayer-win
* VMware Player for Linux https://www.vmware.com/go/getplayer-linux
* VMware ESXi https://customerconnect.vmware.com/en/evalcenter?p=free-esxi8
* VMware Guest Tools https://vmware.com/go/tools

## x. Thanks

Many thanks to the great developers and community around the OpenCore scene. The OC4VM pacakge uses the following:

* OpenCore - https://github.com/acidanthera/OpenCorePkg
* Lilu - https://github.com/acidanthera/Lilu
* CryptexFixup - https://github.com/acidanthera/CryptexFixup
* DebugEnhancer - https://github.com/acidanthera/DebugEnhancer
* VirtualSMC - https://github.com/acidanthera/VirtualSMC
* AMD Patches - https://github.com/AMD-OSX/AMD_Vanilla

Also thanks to the testers who helped me out with the project.

(c) 2023 David Parsons
