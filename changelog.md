# Changes

Changelogs can also be found online https://github.com/DrDonk/OC4VM/releases

All dates are UK DD/MM/YY format.

## dd/01/26 2.0.2
* Fix a VMware issue with Nvidia GPUs and 25H2

## 16/01/26 2.0.1
* Docs migrated to GitHub wiki
* Windows regen command now a batch file to avoid Powershell issues
* Fix to regen command to allow for week 0 in a year
* VoodooHDA installer package added to packages folder
* SMBIOS settings added to OpenCore to present an Apple compatible BIOS version
* Boot chime and audio enabled in OpenCore
* Mouse enabled in OpenCore boot picker
* Improve virtual mouse pointer responsiveness in macOS

## 16/12/25 2.0.0
**All spoofing of hardware should use iMac 2019 to ensure maximum compatibilty with macOS upgrades
and avoid models with T1 or T2 security chips. The iMac 2019 supports Catalina to Sequoia, and can also
run Tahoe in a VM.**
* Now uses an ISO file to boot using a hidden virtual USB CD drive
* AMD core patching no longer required use regular VMware CPU settings
* Support for Tahoe setting in VMX - only supported with new Fusion and Workstation 25H2
* Added guest tool shrinkdisk to shrink virtual disks from guest
* Added guest tool sysinfo to see if spoofing values are correctly set in guest
* Modified regen code to use iMac 2019 (iMac19,2) to remove any possible issues with T2 chip
* Updated OC to 1.0.6

## 18/09/25 1.2.0
**Tahoe support is now available but be aware it runs slowly and there are no Liquid Glass effects as 
there is no guest GPU available to render them**
* Support for macOS 26 Tahoe
* Updated OC to 1.0.5
* Updated KEXTs to match OC 1.0.5
* Updates in VMX file to spoofing section
* Documents and notes now delivered as HTML

## 10/07/25 1.1.1
* Updated the VMX spoof settings thanks to **tamta0** (see docs/spoof.md)
* New version of regen tool which is used for VMX spoofing
* Removed unused KEXTs
* Removed some unused VMX settings
* Set VM default resolution to 1440x900
* Disable VM secure boot for macOS VMs
* Added macguest command for Linux

## 01/07/25 1.1.0
**This is a breaking release and should only be used to create new VMs**
* Re-branded as OpenCore 4 VMware
* Removed QEMU support as it is problematic and not stable
* Added macguest.exe to change guest OS settings in Windows VMware Workstation
* Upgraded OpenCore to 1.0.4
* Upgraded VirtualSMC to 1.3.6
* Upgraded AppleALC to 1.9.4
* Moved Apple model spoofing to the VMware VMX file
* Apple spoofing disabled by default
* Hiding VM is now done via kernel patches
* ESXi compatible VMDK now created in disks folder

## 06/05/25 1.0.3
* macserial utility was missing from the tools folder on the images

## 22/04/25 1.0.2
* Default AMD core patch set to 2 cores
* New amdcpu tool allows AMD core patch to be modified in the guest
* Default memory for VMs is now set to 8GB
* New verbose OC4VM to allow macOS boot process to be viewed
* Modified debug OC4VM variant with in-depth OpenCore and macOS kernel traces

## 30/03/25 1.0.1
* Fixed opencore.vmdk and recovery vmdk not being updateable in VMware
* Ported siputil from Python 3 to Go
* New tool to regenerate the spoofed Mac serial, uuid, ROM and MLB.

## 27/03/25 1.0.0
* Initial release
