# OC4VM OpenCore for VMware
## x. Introduction
OpenCore 4 VMware provides a set of VMware macOS templates and boot disks to allow macOS to run on ESXi, Linux and 
Windows. This system does not require patching VMware using the Unlocker, and also allows fixes to limitations which
cannot be patched in VMware, for example, running Ventura on pre-Haswll CPUs without AVX2 support. It can also be used
with VMware Fusion to fix issues such as booting to Recovery mode which is not enabled in VMware UEFI firmware.

## x. Limitations
The only downside of not using the unlocker is the guest OS type cannot be changed in the VMware UI. This should not 
be a problem as the OC4VM package provides template VMs for 10.15 (Catalina) through to 13 (Ventura). 

The OC4VM system cannot enable para-virtualised GPU as that reqiuores macOS specific libraries and support on a real
macOS host system.


## x. Running the Unlocker
### x.y Download Release

* Download a binary release from https://github.com/DrDonk/oc4vm/releases
* Optionally check the sha256 checksum matches that published in the release
* Unzip the archive to extract the files
* Navigate to the folder with the extracted files


## x.x VMware Tools
OC4VM provides the VMware tools ISO images. Version 16/17 of Workstation Pro recognises the darwin.iso files and the
tools can be installed in the usual way by using the "Install VMware Tools" menu item. The Player version does not
automatically pick up the ISO images and so the ISO must be maually attached to the VM via the guest's settings.

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

(c) 2023 David Parsons
