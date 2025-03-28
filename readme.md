# OC4VM - OpenCore for Virtual Machines

## 1. Introduction
OpenCore for Virtual Machines (OC4VM) has been built to run macOS VMs primarily on Intel 
based Apple Macs. It may also be used on other PC hardware using VMware Workstation. It 
provides an OpenCore disk image that can be used to boot Intel based macOS using VMware 
Fusion and Workstation, and the open source QEMU program.

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
* QEMU 9.2

CPUs will need to support the following instructions:

* AVX
* AVX2
* F16C
* RDRAND

## 3. Using OC4VM
### 3.1 Download Release

* Download a binary release from https://github.com/DrDonk/oc4vm/releases
* Optionally check the sha512 checksum matches with the one published with the release
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
| iso        | VMware Mac OS X and macOS guest tools iso images      |
| qemu       | Template VMs for QEMU                                 |
| tools      | OC4VM tools to manage config.plist                    |
| vmware     | Template VMs for VMware                               |

The most import folders are the 'qemu' and 'vmware' folders. 

### 3.3 VMware Templates

The 'vmware' folder contains 2 folders with a VM template for VMware macOS virtual 
machines. The folders are for AMD and Intel CPUs. You will need to use the one that 
matches the host CPU.

The template is designed for maximum compatibilty between different releases and 
platforms, and you should not upgrade the virtual hardware if prompted to by the VMware 
software. Also do not change the 'guestOS' settings in the VMX file. It will not change any 
of the behaviours of the guest and could cause issues in the future.

Each folder contains these files:

| File          | Function                          |
|:--------------|-----------------------------------|
| opencore.vmdk | OpenCore boot virtual disk        |
| macos.vmx     | macOS VMX settings file           |
| macos.vmdk    | Pre-formated HFS+J virtual disk   |
| macos.plist   | VMware Fusion config file         |

#### 3.3.1 New VM
To create a new virtual machine copy either the Intel or AMD template to a new folder.
Open the VM in the new folder in VMware. Change any memory settings you may need.

You will need to add some installation media to the new VM to install macOS, and set the
ISO or virtual disk to point to the installation media.

Power on and install macOS as normal.

#### 3.3.2 Existing VM
Please follow these instructions to add to an existing macOS guest.

1. Copy the opencore.vmdk from the template folder to the existing VMs folder.
2. Use the guest settings to add the opencore.vmdk disk as a SATA drive.
3. Boot to the firmware and select the OpenCore drive as the boot device.

#### 3.3.3 VMware macOS Guest Tools
OC4VM provides a copy of the VMware macOS guest tools ISO images. These are useful for 
VMware Fusion and also QEMU/UTM. To install mount the darwin.iso file using the VMs 
virtual CD/DVD drive. You will then need to manually install the tools inside the
guest OS.

### 3.4 QEMU templates

The QEMU template is only supported on Intel based Macs running macOS. There are other 
solutions for Linux, and QEMU fails to run macOS on Windows. It has also proved to be
non-functional when used on Apple Silicon M-series Macs.

To run the VM you need to use the qemu-macos shell script, passing in different parameters. 

```
OC4VM QEMU Runner
 NAME:
        qemu-macos

 SYNOPSIS:
        qemu-macos [-a {hvf | kvm | tcg}] [-m <memory-size>] [-d <macos-image>] [-o <opencore-image>] [-r <recovery-image>] [-s] [-v password]
        
 DESCRIPTION:
	Run macOS using QEMU

 OPTIONS:
	-a ACCEL              QEMU accelerator to use.
	-c CPU                CPU to use.
	-d DISK-IMAGE         species a macOS drive image to use.
	-m MEMORY             specifies amount of memory to allocate to VM.
	-o OPENCORE-IMAGE     specifies OpenCore boot image.
	-r RECOVERY-IMAGE     specifies macOS installation/recovery image.
	-s                    enable serial output.
	-v VNC-PASSWORD       enable VNC output on port 5959 with password.
```

| Option | Default        |
|:-------|----------------|
| -a     | hvf            |
| -c     | max            |
| -d     | macos.qcow2    |
| -m     | 4GB RAM        |
| -o     | opencore.qcow2 | 
| -r     | \<none\>       |
| -s     | \<false\>      |

#### 3.4.1 Installing macOS
To create a new virtual machine copy either the Intel or AMD template to a new folder.
You will need to provide a macOS installation image for the setup of the macOS guest.

Start the vm using:

`./qemu-macos -r <installation image>`

You may want to add more memory with the -m parameter depending on your needs.

Once you have installed macOS proceed to the next section.

### 3.4.2 Running macOS

Start the installed macOS guest using:

`./qemu-macos`

Again you may want to alter the memory presented to the guest VM.

## 4. Building OC4VM

Building must be done on macOS, either real or virtualized. The Homebrew package manager 
will need to be installed to allow installation of the following pre-requisites. Please 
follow the instructions at https://brew.sh.

Once brew is installed run the following commands to install the required software:
```
brew install qemu
brew install p7zip
brew install go
```

Now clone the OC4VM repository using:
```git clone https://github.com/DrDonk/OC4VM.git```

Using the terminal OC4VM can be built by simply running the make.sh command from tbe 
cloned repository.

```./make.sh```

The build artefacts will be found in the "build" folder and the release zip file in the 
"dist" folder.

The current variables used to define the different files in OC4VM are stored in 
oc4vm.toml and used in the OpenCore config.plist, VMware VMX and QEMU templates.

| Name        | Type            | Description                                   |
|:------------|-----------------|-----------------------------------------------|
| BUILD       | \<0/1\>         | build config switch for make.sh               |
| AMD         | \<0/1\>         | building for AMD                              |
| BOOTARGS    | \<string\>      | macOS NVRAM boot-args                         |
| CSRCONFIG   | \<data\>        | base64 encoded macOS CSR SIP value            |
| DEBUG       | \<0/1\>         | enable debug options in OpenCore              |
| DESCRIPTION | \<string\>      | description of configuration                  |
| DMG         | <release/debug> | specify release or debug version of OpenCore  |
| RESOLUTION  | \<string\>      | screen resolution WxH@Bpp or Max              |
| TIMEOUT     | \<integer\>     | timeout for OpenCore boot picker (0 disables) |

## 5. Support
If you are trying a specific combination, hypervisor/CPU/OS, please start a discussion instead
of an issue. It is impossible for us to test all combinations out there and so
discussions are a better place to help one another. If an actual bug or enhancement
is identified whilst discussing a specific scenario an issue can then be created 
to track it. Better still a pull request with a fix would be useful.

Any obvious bugs should be logged as an issue. Please give all relevant information
to help diagnose the issue.

Most importantly let us be supportive of each other with respectful discussions.

## 6. Thanks

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
