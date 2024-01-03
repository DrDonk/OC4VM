# WIP - currently no releases
# OC4VM - OpenCore for Virtual Machines
## 1. Introduction
OpenCore for Virtual Machines (OC4VM) has been built to run macOS VMs on Intel based Apple Macs. It provides an 
OpenCore disk image that can be used to boot Intel based macOS using QEMU, UTM and VMware Fusion.

Using OpenCore allows for a flexible patching system to overcome limitations of the virtualisation software. It 
basically creates a virtual Hackintosh, "Virtualtosh", which is similar in implementation to the 
OpenCore Legacy Patcher used to run unsupported macOS versions on older Apple Mac computers.

OC4VM can be used on other host operating systems to run macOS but that is not the primary purpose of OC4VM. It can 
replace the Unlocker to run macOS on Linux and Windows with VMware.

What OC4VM can do?
* Run macOS on Intel CPUs
* Boot to macOS Recovery mode which is broken in VMware's EFI implementation
* Easily change SIP settings using an EFI utility
* Add Intel e1000e virtual NIC compatibility for Ventura and later versions of macOS

What OC4VM can do but not recommended:
* Boot macOS on an Apple Silicon CPU

What OC4VM cannot do:
* Boot macOS on an AMD CPU


The OC4VM system has been tested on an Intel Mac mini mid-2014 with these guest OSes:
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
If you are not using an Apple computer and have installed the VMware Unlocker it is recommended that the Unlocker is 
uninstalled. OC4VM does not alter anything in the VMware program folders.
***

### 2.2 Folder Contents

OC4VM has several folders:

| Folder     | Function                                              |
|:-----------|-------------------------------------------------------|
| config     | OpenCore config.plist files for reference             |
| disks      | OpenCore boot variants in DMG, VMDK and QCOW2 formats |
| iso        | VMware Fusion macOS guest tools                       |
| recoveryOS | Tool to build a bootable macOS recoveryOS disk        |
| templates  | Template VMs for VMware and QEMU                      |


The most import folders are the 'templates' and 'iso' folders. 

### 2.2 OC4VM Variants
TODO

### 2.3 VMware Templates
The 'templates' folder has a sub-folder called "vmware" which contains VM templates for VMware macOS virtual machines. 
Each folder has an OpenCore booter and VMX file tailored for the OC4VM variant you choose.

The templates are designed for maximum compatibilty between different releases and platforms, and you should not 
upgrade the virtual hardware if prompted to by the VMware software. Also do not change the guestOS settings in the 
VMX file. It will not change any of the behaviours of the guest and could cause issues in the future.

```
 templates
   └── vmware
      ├── intel-release
      │  ├── macos.vmdk
      │  ├── macos.vmx
      │  └── opencore.vmdk
      └── intel-verbose
         ├── macos.vmdk
         ├── macos.vmx
         └── opencore.vmdk


```
Each  folder contains these files:

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
``` 
templates
   ├── qemu
   │  ├── intel-release
   │  │  ├── macos.vmdk
   │  │  ├── opencore.qcow2
   │  │  └── qemu-run.sh
   │  └── intel-verbose
   │     ├── macos.vmdk
   │     ├── opencore.qcow2
   │     └── qemu-run.sh
   └── vmware
      ├── intel-release
      │  ├── macos.vmdk
      │  ├── macos.vmx
      │  └── opencore.vmdk
      └── intel-verbose
         ├── macos.vmdk
         ├── macos.vmx
         └── opencore.vmdk
```
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

Building must be done on macOS, either real or virtualized. The Homebrew package manager will need to be installed to
allowm installation of the follwoing pre-requisites. Please follow the instructions at https://brew.sh.

Once brew is installed run the folowing commands to install the required software:
```
brew install qemu
brew install jinja2-cli
brew install p7zip
```

Now clone the OC4VM repository using:
```git clone https://github.com/DrDonk/OC4VM.git```

Using the terminal OC4VM can be built by simply running the make.sh command from tbe cloned repository.

```./make.sh```

The build artefacts will be found in the "build" folder and the release zip file in the "dist" folder.

## x. Thanks

Many thanks to the great developers and community around the OpenCore scene. The OC4VM pacakge uses the following:

* OpenCore - https://github.com/acidanthera/OpenCorePkg
* Lilu - https://github.com/acidanthera/Lilu
* CryptexFixup - https://github.com/acidanthera/CryptexFixup
* DebugEnhancer - https://github.com/acidanthera/DebugEnhancer
* VirtualSMC - https://github.com/acidanthera/VirtualSMC
* AppleHDA - https://github.com/acidanthera/AppleHDA

Also thanks to the testers who helped me out with the project.

(c) 2023-4 David Parsons

