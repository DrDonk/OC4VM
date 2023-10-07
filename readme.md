# OC4VM - OpenCore for Virtual Machines
## 1. Introduction
OpenCore 4 Virtual Machines (OC4VM) has been built to run macOS VMs on Intel based Apple Macs. It provides an OpenCore 
disk image that can be used to boot Intel based macOS using QEMU, UTM and VMware.

Using OpenCore allows for a flexible patching system to overcome limitations of the virtualisation software. It 
basically creates a virtual Hackintosh, "Virtualtosh", which is similar in implementation to the OpenCore Legacy Patcher
used to run unsupported macOS versions on older Apple Mac computers.

OC4VM can be used on other host operating systems to run macOS but that is not the primary purpose of OC4VM. It can 
replace the Unlocker to run macOS on Linux and Windows.

What OC4VM can do?
* Run macOS on Intel CPUs
* Boot to macOS Recovery mode which is broken in VMware's EFI implementation
* Easily change SIP settings using an EFI utility
* Add Intel e1000e virtual NIC compatibility for Ventura and later versions of macOS

What OC4VM cannot do:
* Boot macOS on an AMD CPU
* Boot macOS on an Apple Silicon CPU

The OC4VM system has been tested on an Intel Mac mini mid-2014 with these guest OSes:
* Big Sur
* Monterey
* Ventura
* Sonoma

using:
* QEMU 8
* UTM 4
* VMware Fusion 13


## 2. Using OC4VM
### 2.1 Download Release

* Download a binary release from https://github.com/DrDonk/oc4vm/releases
* Optionally check the sha512 checksum matches that published with the release
* Unzip the archive to extract the files
* Navigate to the folder with the extracted files

***
Note:
If you have installed the VMware Unlocker it is recommended that the Unlocker is uninstalled. OC4VM does 
not alter anything in the VMware program folders.
***

### 2.2 Folder Contents

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

### 2.3 VMware Tools
OC4VM provides a copy of the VMware macOS guest tools ISO images. These are useful for VMware Fusion and also QEMU/UTM.
To install mount the darwin.iso file using the VMs virtual CD/DVD drive.

## x. Platform specific notes

TODO
### VMware
### UTM
### QEMU

## x. VMware Downloads
These URLs will link to the latest versions of VMware's products:

* VMware Fusion https://vmware.com/go/getfusion
* VMware Workstation for Windows https://www.vmware.com/go/getworkstation-win
* VMware Workstation for Linux https://www.vmware.com/go/getworkstation-linux
* VMware Player for Windows https://www.vmware.com/go/getplayer-win
* VMware Player for Linux https://www.vmware.com/go/getplayer-linux
* VMware ESXi https://customerconnect.vmware.com/en/evalcenter?p=free-esxi8
* VMware Guest Tools https://vmware.com/go/tools

## x. Building OC4VM
```brew install qemu```

```brew install jinja2-cli```

```brew install p7zip```

## x. Thanks

Many thanks to the great developers and community around the OpenCore scene. The OC4VM pacakge uses the following:

* OpenCore - https://github.com/acidanthera/OpenCorePkg
* Lilu - https://github.com/acidanthera/Lilu
* CryptexFixup - https://github.com/acidanthera/CryptexFixup
* DebugEnhancer - https://github.com/acidanthera/DebugEnhancer
* VirtualSMC - https://github.com/acidanthera/VirtualSMC
* AppleHDA - https://github.com/acidanthera/AppleHDA

Also thanks to the testers who helped me out with the project.

(c) 2023 David Parsons

