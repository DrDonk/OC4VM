# OC4VM - OpenCore for Virtual Machines

# WORK IN PROGRESS

## 1. Introduction
OpenCore for Virtual Machines (OC4VM) has been built to run macOS VMs primarily on Intel 
based Apple Macs. It may also be used on other PC hardware using VMware Workstation. It 
provides an OpenCore disk image that can be used to boot Intel based macOS using VMware 
Fusion and Workstation.

Using OpenCore allows for a flexible patching system to overcome limitations of the 
virtualisation software. It basically creates a virtual Hackintosh, which is similar in 
implementation to the OpenCore Legacy Patcher used to run unsupported macOS versions on 
older Apple Mac computers.

It is also a replacement for the Unlocker and does not require patching VMware, but that 
is not the primary purpose of OC4VM which was originally created to fix issues on VMware 
Fusion when running macOS guests. 

## 2. Functionality
What OC4VM can do?
* Run macOS on Intel CPUs
* Run macOS on AMD CPUs (experimental)
* Boot to macOS Recovery mode which is broken in VMware's EFI implementation
* Easily change SIP settings using an EFI utility
* Add Intel e1000e virtual NIC compatibility for Ventura and later versions of macOS

What OC4VM cannot do:
* Boot Intel macOS on an Apple Silicon CPU
* Use the Apple para-virtualised GPU on non-Apple hardware 

The OC4VM system has been tested on an Intel Mac mini mid-2014 with these guest OSes:
* Big Sur
* Monterey
* Ventura
* Sonoma
* Sequoia

using:
* VMware Fusion 13.6
* VMware Workstation 17.6

CPUs will need to support the following instructions:

* AVX
* AVX2
* F16C
* RDRAND

## 3. Using OC4VM
### 3.1 Download Release

* Download a binary release from https://github.com/DrDonk/oc4vm/releases
* Optionally check the sha512 checksum matches that published with the release
* Unzip the archive to extract the files
* Navigate to the folder with the extracted files

***
Note:
If you are not using an Apple computer and have installed the VMware Unlocker it is 
recommended that the Unlocker is uninstalled. OC4VM does not alter anything in the VMware 
program folders and allows macOS to run without patching VMware.
***

### 3.2 Folder Contents

OC4VM has 4 sub-folders:

| Folder     | Function                                              |
|:-----------|-------------------------------------------------------|
| config     | OpenCore config.plist files for reference             |
| disks      | OpenCore boot variants in DMG, VMDK and QCOW2 formats |
| qemu       | Template VM for QEMU                                  |
| tools      | VMware Mac OS X and macOS guest tools iso image       |
| vmware     | Template VM for VMware                                |

The most import folders are the 'qemu' and 'vmware' folders. 

### 3.3 VMware Templates

The 'vmware' folder has contains 2 folders with a VM template for VMware macOS virtual 
machines. The folders are for AMD and intel CPUs. You will need to use the one that 
matches the host CPU.

The template is designed for maximum compatibilty between different releases and 
platforms, and you should not upgrade the virtual hardware if prompted to by the VMware 
software. Also do not change the guestOS settings in the VMX file. It will not change any 
of the behaviours of the guest and could cause issues in the future.

Each folder contains these files:

| File          | Function                        |
|:--------------|---------------------------------|
| opencore.vmdk | OpenCore boot virtual disk      |
| macos.vmx     | macOS VMX settings file         |
| macos.vmdk    | Pre-formated HFS+J virtual disk |

To create a new virtual machine copy either the Intel or AMD template to a new folder:

* opencore.vmdk
* macos.vmx
* macos.vmdk

TODO:
How to use with exisitng VM
Copy oc VMDK
Add existing disk
Change the boot disk
Set startup disk

OC4VM provides a copy of the VMware macOS guest tools ISO images. These are useful for 
VMware Fusion and also QEMU/UTM. To install mount the darwin.iso file using the VMs 
virtual CD/DVD drive.

### 3.4 QEMU templates
```
OC4VM QEMU Runner
 NAME:
        qemu-macos.sh

 SYNOPSIS:
        qemu-macos.sh [-a {hvf | kvm | tcg}] [-m <memory-size>] [-d <macos-image>] [-o <opencore-image>] [-r <recovery-image>] [-s]

 DESCRIPTION:
        Run macOS using QEMU

 OPTIONS:
        -a ACCEL              QEMU accelerator to use.
        -c CPU                CPU to use.
        -d DISK-IMAGE         species a macOS drive image to use.
        -m MEMORY             specifies amount of memory to allocate to VM.
        -o OPENCORE-IMAGE     specifies OpenCore boot image.
        -r RECOVERY-IMAGE     specifies macOS recoveryOS image.
        -s                    enable serial output.
```
TODO:
Use only on macOS
Describe the command parameters
Apple Silicon does not work
Windows does not work
Linux recommend other projects


## 4. Building OC4VM

Building must be done on macOS, either real or virtualized. The Homebrew package manager 
will need to be installed to allow installation of the following pre-requisites. Please 
follow the instructions at https://brew.sh.

Once brew is installed run the following commands to install the required software:
```
brew install qemu
brew install p7zip
```

Now clone the OC4VM repository using:
```git clone https://github.com/DrDonk/OC4VM.git```

Using the terminal OC4VM can be built by simply running the make.sh command from tbe 
cloned repository.

```./make.sh```

The build artefacts will be found in the "build" folder and the release zip file in the 
"dist" folder.

TODO:
Add the current variables in the TOML/Jinja2 files


## 5. Thanks

Many thanks to the great developers and community around the OpenCore scene. The OC4VM 
package uses the following:

* OpenCore - https://github.com/acidanthera/OpenCorePkg
* Lilu - https://github.com/acidanthera/Lilu
* CryptexFixup - https://github.com/acidanthera/CryptexFixup
* DebugEnhancer - https://github.com/acidanthera/DebugEnhancer
* VirtualSMC - https://github.com/acidanthera/VirtualSMC
* AppleHDA - https://github.com/acidanthera/AppleHDA
* AMD_Vanilla - https://github.com/AMD-OSX/AMD_Vanilla
* VMHide - https://github.com/Carnations-Botanica/VMHide
* minijinja - https://github.com/mitsuhiko/minijinja
* stoml - https://github.com/freshautomations/stoml

Also thanks to the testers who helped me out with the project.

(c) 2023-5 David Parsons
