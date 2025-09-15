# OC4VM - OpenCore for VMware

## 1. Introduction
OpenCore for VMware (OC4VM) has been built to run macOS VMs primarily on Intel
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
* Run macOS on AMD CPUs
* Boot to macOS Recovery mode which is broken in VMware's EFI implementation
* Add Intel e1000e virtual NIC compatibility for Ventura and later versions of macOS

What OC4VM cannot do:
* Boot Intel macOS on an Apple Silicon CPU
* Use the Apple para-virtualised GPU on non-Apple hardware
* Use the Apple para-virtualised GPU on older Macs using OCLP and macOS Sonoma or later

The OC4VM system has been tested on an Intel Mac mini mid-2014 and an AMD Ryzen based HP T740
with these guest OSes:
* Big Sur
* Monterey
* Ventura
* Sonoma
* Sequoia
* Tahoe

using:
* VMware Fusion 13.6
* VMware Workstation 17.6 (Windows and Linux)

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


### 3.2 Folder Contents

OC4VM has 6 sub-folders:

| Folder     | Function                                              |
|:-----------|-------------------------------------------------------|
| config     | OpenCore config.plist files for reference             |
| disks      | OpenCore boot variants in DMG and VMDK formats        |
| docs       | Documents in Markdown format                          |
| iso        | VMware Mac OS X and macOS guest tools iso images      |
| tools      | OC4VM tools to manage config.plist                    |
| vmware     | Template VMs for VMware                               |

The most import folder is the 'vmware' folders.

### 3.3 VMware Templates

The 'vmware' folder contains 2 folders with a VM template for VMware macOS virtual
machines. The folders are for AMD and Intel CPUs. You will need to use the one that
matches the host CPU.

Each folder contains these files:

| File          | Function                          |
|:--------------|-----------------------------------|
| opencore.vmdk | OpenCore boot virtual disk        |
| macos.vmx     | macOS VMX settings file           |
| macos.vmdk    | Pre-formatted APFS virtual disk   |
| macos.plist   | VMware Fusion config file         |

#### 3.3.1 New VM
To create a new virtual machine copy either the Intel or AMD template to a new folder.
Open the VM in the new folder in VMware. Change any memory settings you may need.

You will need to add some installation media to the new VM to install macOS, and set the
ISO or virtual disk to point to the installation media.

Power on and install macOS as normal.

#### 3.3.2 Existing macOS VM
Please follow these instructions to add to an existing macOS guest.

1. Make sure the VM is shutdown.
2. Copy the opencore.vmdk from the template folder to the existing VMs folder.
3. Use the guest settings to add the opencore.vmdk disk as a SATA drive.
4. Boot to the firmware and select the OpenCore drive as the boot device.

#### 3.3.3 Upgrading OC4VM VM
To upgrade the exisitng OC4VM enabled VM you will need to do these steps:

1. Make sure the VM is shutdown.
2. If there are any snapshots they must be removed.
3. Copy the new opencore.vmdk from the template folder to VM folder.
4. (Optionally) There may be changes to the template VMX file you may want to
add to the VM. You will have to check the differences and copy any changed lines you want
to the existing VMX file.

### 3.4 VMware macOS Guest Tools
OC4VM provides a copy of the VMware macOS guest tools [ISO](https://packages-prod.broadcom.com/tools/frozen/darwin/darwin.iso)
images on the OC4VM boot disk. To install mount the file from /Volumes/OPENCORE/OC4VM/iso/darwin.iso inside the guest and
install the tools.

### 3.5 OC4VM Guest & Host Tools
There are some tools written specially for use in the macOS guest. They are documented in the
[tools](docs/tools.md) help.

### 3.6 VMware macOS Guest Setting
VMware on Linux and Windows cannot edit the guestOS setting to another version of mac OS X/macOS.
To get around this limitation the VMware template folder has a small Windows program, macguest.exe,
that can be used to open the guest's VMX file and change the setting. Linux progrm is currently
under development.

## 4. Spoofing the Virtual Apple Mac
If you want to make the VM look like a specific Mac model the settings can be configued in the
VMware VMX file. Details are in the [spoofing](docs/spoof.md) help.

## 5. Building OC4VM

Building must be done on macOS, either real or virtualized. Details are in the
[building](docs/build.md) help.

There are also some [notes](docs/notes.md) I collated when building OCVM which may be useful
to others who want to better understand the system or modify it.


## 6. Support
If you are trying a specific combination, hypervisor/CPU/OS, please start a discussion instead
of an issue. It is impossible for us to test all combinations out there and so
discussions are a better place to help one another. If an actual bug or enhancement
is identified whilst discussing a specific scenario an issue can then be created
to track it. Better still a pull request with a fix would be useful.

Any obvious bugs should be logged as an issue. Please give all relevant information
to help diagnose the issue.

Most importantly let us be supportive of each other with respectful discussions.

## 7. Thanks

Many thanks to the great developers and community around the OpenCore scene. The OC4VM
package uses the following:

* OpenCore - https://github.com/acidanthera/OpenCorePkg
* Lilu - https://github.com/acidanthera/Lilu
* DebugEnhancer - https://github.com/acidanthera/DebugEnhancer
* VirtualSMC - https://github.com/acidanthera/VirtualSMC
* AMD_Vanilla - https://github.com/AMD-OSX/AMD_Vanilla
* minijinja - https://github.com/mitsuhiko/minijinja
* stoml - https://github.com/freshautomations/stoml

Also thanks to the testers who helped me out with the project.

(c) 2023-5 David Parsons
