# OC4VM - OpenCore for VMware
## 1. Introduction
OpenCore 4 VMware provides a set of VMware macOS templates and boot disks to allow macOS to run on ESXi, Linux and 
Windows. This system does not require patching VMware using the Unlocker and also allows fixes to limitations which
cannot be patched in VMware. For example, running Ventura on pre-Haswell CPUs without AVX2 support. It can also be used
with VMware Fusion to fix issues such as booting to Recovery mode which is not enabled in VMware UEFI firmware.

## 2. Limitations
The only downside of not using the unlocker is the guest OS type cannot be changed in the VMware UI. This should not 
be a problem as the OC4VM package provides template VMs for 10.15 (Catalina) through to 13 (Ventura). The "guestos"
VMX file setting can be matched up to this table if the version of macOS needs to be changed.

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


## 3. Using OC4VM
### 3.1 Download Release

* Download a binary release from https://github.com/DrDonk/oc4vm/releases
* Optionally check the sha512 checksum matches that published in the release
* Unzip the archive to extract the files
* Navigate to the folder with the extracted files


## x.x VMware Tools
OC4VM provides a copy of the VMware tools ISO images. Version 16/17 of Workstation Pro recognises the darwin.iso files 
and the tools can be installed in the usual way by using the "Install VMware Tools" menu item. The Player version does
not automatically pick up the ISO images and so the ISO must be maually attached to the VM via the guest's settings.

Copy the tools ISOs to these folders:

* Windows
* Linux
* ESXi

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

OCLP
OpenCore
Lilu
DebugEnhancer
VirtualSMC
NoAVXFSCompressionTypeZlib-AVXPel

(c) 2023 David Parsons
