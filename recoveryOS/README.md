# OC4VM - recoveryOS VMDK Maker

## Introduction
This is a utility to download the recovery image, recoveryOS, for macOS from Apple's servers and create a bootable 
VMDK file that can be used to start an Internet installtion of macOS.

## Pre-requisites

###  Python 3
The tool is written in Python 3 and so Python must be installed on the host computer. Python 3.10 was used for 
the development of the tool.

* Linux   - Use your distro package manager
* macOS   - `brew install python3`
* Windows - Recommended way is to install Python 3.10 from the Microsoft App Store, or use Chocolatey or Scoop.

### qemu-img

You will need to have qemu-img utility, from QEMU, on the path.

* Linux - These can be installed from Linux repos, for example Debian based distros:

    `sudo apt install -y qemu-utils`


* macOS - The [brew](https://brew.sh) package manager is the best way to install on macOS, 
but the full Qemu package must be installed:

    `brew install qemu`


* Windows - use [Chocolatey](https://chocolatey.org) or [Scoop](https://scoop.sh) to install the programs:

    `choco/scoop install qemu`
   

## Instructions
1. Unzip the archive maintaining the folder structure
2. Open a console/shell in the folder with the tool
3. Run the tool: `python3 recovery-vmdk.py`
4. The menu will be displayed and just select the macOS version you want using the number on the menu.
```
OC4VM recoveryOS VMDK Maker
===========================
(c) David Parsons 2022-23

Create a VMware VMDK recoveryOS Image
1. Catalina
2. Big Sur
3. Monterey
4. Ventura
5. Sonoma
Input menu number: 
```
The tool will  download the BaseSystem.dmg for the macOS version you selected and convert it to a VMDK.

After the tool has finished there will be 3 files present in the folder. For example if downloading Sonoma
there will be:

1. sonoma.dmg
2. sonoma.chunklist
3. sonoma.vmdk

The .vmdk file is the only one needed for VMware, and can also be used for QEMU. The .dmg and .chunklist files are the 
original files downloaded from Apple and can be removed if not needed.

Occasionally you may get this error:

`ERROR: "HTTP Error 403: " when connecting to http://osrecovery.apple.com/InstallationPayload/RecoveryImage`

Just re-run the command and it should work.


## Acknowledgements
This tool wraps several other great open source commands. Thanks to the authors of those tools.

* macrecovery.py - https://github.com/acidanthera/OpenCorePkg
* qemu - https://www.qemu.org
* qemu-img for Windows - https://cloudbase.it/qemu-img-windows
