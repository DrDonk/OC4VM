# OC4VM - OpenCore for VMware
## 1. Introduction
OpenCore 4 VMware (OC4VM) provides a set of VMware macOS templates and boot disks to allow macOS to run on Linux 
and Windows versions of VMware Workstation and Player. It can also be used with VMware Fusion on macOS.

Using OpenCore allows for a more flexible patching system over using the VMware Unlocker. It basically creates a 
virtual Hackintosh, a Virtualtosh, which is similar to what the OpenCore Legacy Patcher does for older Apple Mac 
computers.

OC4VM can be used with or without unlocking VMware. It is recommended that the Unlocker is not installed. OC4VM does 
not alter anything in the VMware program folders.

What can OC4VM do:
* Run macOS on Intel and AMD CPUs
* Run macOS on CPUs without these instructions, e.g., running Ventura on pre-Haswell CPUs without AVX2 support. 
  * AVX
  * AVX2
  * RANDR
* Boot to macOS Recovery mode which is broken in VMware's EFI implementation
* Easily change SIP settings using an EFI utility
* Add Intel e1000e virtual NIC compatibility for Ventura

The OC4VM system has been tested with Big Sur, Monterey and Ventura.

## 2. Using OC4VM
### 2.1 Download Release

* Download a binary release from https://github.com/DrDonk/oc4vm/releases
* Optionally check the sha512 checksum matches that published in the release
* Unzip the archive to extract the files
* Navigate to the folder with the extracted files

### 2.1 Folder Contents

OC4VM has several folders:

| Folder         | Function                                            |
|:---------------|-----------------------------------------------------|
| config         | OpenCore config.plist files for reference           |
| iso            | VMware macOS guest tools                            |
| recovery-maker | Tool to build a bootable VMware macOS recovery disk |
| templates      | Template VMs for Intel and AMD                      |
| vmdk           | Debug and Verbose OpenCore boot variants            |

The most import folders are the 'templates' and 'iso' folders. 

### 2.2 VM Templates
The 'templates' folder contains VM templates for either Intel or AMD CPU based macOS virtual machines. 
Each folder has an OpenCore booter and VMX file tailored for the CPU that is running on the host.

The templates are designed for maximum compatibilty between different releases and platforms, and you should not 
upgrade the virtual hardware if prompted to by the VMware software. Also do not change the guesOS settings in the 
VMX file. It will not change any of the behaviours of the guest and could cause issues in the future.

```
templates
├── intel
│  ├── opencore.vmdk
│  ├── macos.vmx
│  └── macos.vmdk
└── amd
   ├── opencore.vmdk
   ├── macos.vmx
   └── macos.vmdk
```
The folder contains these files:

| File          | Function                        |
|:--------------|---------------------------------|
| opencore.vmdk | OpenCore boot virtual disk      |
| macos.vmx     | macOS VMX settings file         |
| macos.vmdk    | Pre-formated HFS+J virtual disk |

To create a new virtual machine copy either the Intel or AMD template to a new folder:

* opencore.vmdk
* macos.vmx
* macos.vmdk

***
Note: 

Make sure you use the correct folder for your CPU as using the wrong one will cause the VM not to boot 
and give an error message.
***

Before powering on the new VM you will need to set networking up for your environment. The templates do not specify what
networking type is required and so will start disconnected.

## 2.3 VMware Tools
OC4VM provides a copy of the VMware macOS guest tools ISO images. To install mount the ISO file using the VMs virtual 
CD/DVD drive.

## x. Limitations

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
