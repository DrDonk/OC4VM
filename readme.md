# OC4VM - OpenCore for VMware

# For more information see the [Wiki](https://github.com/DrDonk/OC4VM/wiki/Home)

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

The OC4VM system has been tested on an Intel Mac mini (Late 2014) and an AMD Ryzen based HP T740
with these guest OSes:

* Big Sur
* Monterey
* Ventura
* Sonoma
* Sequoia
* Tahoe

What OC4VM can do?
* Run macOS on Intel CPUs
* Run macOS on AMD CPUs
* Boot to macOS Recovery mode which is broken in VMware's EFI implementation
* Add Intel e1000e virtual NIC compatibility for Ventura and later versions of macOS

What OC4VM cannot do:
* Boot Intel macOS on an Apple Silicon CPU
* Use the Apple para-virtualised GPU on non-Apple hardware
* Use the Apple para-virtualised GPU on older Macs using OCLP and macOS Sonoma or later
* Enable Tahoe Liquid Glass

> [!WARNING]
> Tahoe support is limited and not recommended. It works but peformance is poor. There is no way to have Liquid Glass effects work and
> sound support must be added post-installation.

using:

* VMware Fusion Pro 25H2
* VMware Workstation Pro 25H2 (Windows and Linux)

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
| iso        | VMware Mac OS X and macOS guest tools iso images      |
| packages   | Post install packages                                 |
| tools      | OC4VM tools                                           |
| vmware     | Template VMs for VMware                               |

The most import folder is the 'vmware' folder.

### 3.3 VMware Templates

The 'vmware' folder contains 2 folders with a VM template for VMware macOS virtual
machines. The folders are for AMD and Intel CPUs. You will need to use the one that
matches the host CPU.

Each folder contains these files:

| File          | Function                                 |
|:--------------|------------------------------------------|
| opencore.iso  | OpenCore boot ISO image                  |
| macos.nvram   | Preconfigured nvram settings             |
| macos.vmx     | macOS VMX settings file                  |
| macos.vmdk    | Pre-formatted APFS virtual disk          |
| macos.plist   | VMware Fusion config file                |

#### 3.3.1 New VM
To create a new virtual machine copy either the Intel or AMD template to a new folder.
Open the VM in the new folder in VMware.

You will need to add some installation media to the new VM to install macOS, and set the
ISO or virtual disk to point to the installation media.

Power on and install macOS as normal.

#### 3.3.2 Upgrading OC4VM 2.0 macOS VM
Please follow these instructions to add to an existing macOS guest.

1. Make sure the VM is shutdown.
2. Copy the opencore.iso from the new release template folder to the existing VMs folder.

#### 3.3.3 Upgrading OC4VM 1.x macOS VM
To upgrade a pre-2.0 VM you will need to do these steps. There is no simple upgrade script available
to do this as it may be too risky to automate.

1. Make sure the VM is shutdown and remove any snapshots.
2. Take a backup of the VM folder.
3. Copy a template from the distribution folder.
4. Copy the old guest's macos.vmdk to the new folder.
5. (Optionally) There may be changes to the template VMX file you may want to
add to the VM. You will have to check the differences and copy any changed lines you want
to the existing VMX file.

### 3.4 VMware macOS Guest Tools
OC4VM provides a copy of the VMware macOS guest tools [ISO](https://packages-prod.broadcom.com/tools/frozen/darwin/darwin.iso)
images on the OC4VM boot disk. To install mount the file from /Volumes/OPENCORE/OC4VM/iso/darwin.iso inside the guest and
install the tools.

### 3.5 OC4VM Guest & Host Tools
There are tools written specially for use in the macOS guest and on the host machine. 
They are documented in the [tools](https://github.com/DrDonk/OC4VM/wiki/OC4VM-Tools) help.

## 4. Building OC4VM

Building must be done on macOS, either real or virtualized. Details are in the
[building](https://github.com/DrDonk/OC4VM/wiki/Building-OC4VM) help.

There are also some [notes](https://github.com/DrDonk/OC4VM/wiki/Notes) I created when building OCVM 
which may be useful to others who want to better understand the system or modify it.

## 5. Support
If you are trying a specific combination, hypervisor/CPU/OS, please start a discussion instead
of an issue. It is impossible for us to test all combinations out there and so
discussions are a better place to help one another. If an actual bug or enhancement
is identified whilst discussing a specific scenario an issue can then be created
to track it. Better still a pull request with a fix would be useful.

Any obvious bugs should be logged as an issue. Please give all relevant information
to help diagnose the issue.

Most importantly let us be supportive of each other with respectful discussions.

## 6. Other Projects

* [recoveryOS](https://github.com/drdonk/recoveryos)
* [unlocker](https://github.com/drdonk/unlocker)
* [vmxtool](https://github.com/drdonk/vmxtool)

## 7. Thanks

Many thanks to the great developers and community around the OpenCore scene. The OC4VM
package uses the following:

* [OpenCore](https://github.com/acidanthera/OpenCorePkg)
* [Lilu](https://github.com/acidanthera/Lilu)
* [DebugEnhancer](https://github.com/acidanthera/DebugEnhancer)
* [VirtualSMC](https://github.com/acidanthera/VirtualSMC)
* [AMD_Vanilla](https://github.com/AMD-OSX/AMD_Vanilla)
* [minijinja](https://github.com/mitsuhiko/minijinja)
* [stoml](https://github.com/freshautomations/stoml)
* [VoodooHDA](https://github.com/CloverHackyColor/VoodooHDA)
* [VoodooHDA](https://github.com/chris1111/VoodooHDA-Tahoe)

Also thanks to the testers who helped me out with the project.

(c) 2023-2026 David Parsons
