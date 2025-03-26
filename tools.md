# OC4VM - Tools

The OpenCore boot disk constains some useful tools to modify
the OpenCore configuration file config.plist.

The OC4VM boot drive should be mounted at:

`/Volumes/OPENCORE`

and the tools are found at:

`/Volumes/OPENCORE/tools`

All these tools depend on the OC4VM boot drive being mounted at that path and
will raise an error if the config.plist file cannot be found on the boot drive.

## bootargs

This utility alters the macOS kernel boot-args that are stored in config.plist.

Note: OC4VM overrides any values stored in NVRAM. You will need to restart the system
for the settings to take effect.

```
OC4VM bootargs
--------------
Usage: bootargs [options] [value]
Options:
    -get            Print boot-args variable
    -set value      Set the boot-args variable
    -h              Print this help message
```

## siputil
This utility alters the macOS kernel csrconfig SIP settings that are stored in config.plist. It is very similar to the macOS csrutil command but can be run as a regular user
in normal mode, unlike csrutil which requires recovery mode.

One difference is the disable and enable commands include the 'authenticated-root' 
sub-command of csrutil.

Python3 must be installed to use this tool which can be easily setup using Homebrew (https://brew.sh):

`brew install python3`

Note: OC4VM overrides any values stored in NVRAM. You will need to restart the system
for the settings to take effect.

```
OC4VM siputil
-------------

usage: siputil <options> <command>
Modify the System Integrity Protection configuration stored in the OpenCore config.plist.
All configuration changes apply to the entire machine.

Available options:
-h/--help       Show this help
-f/--file       Override the default config.plist location
-d/--debug      Show some additonal debugging information

Available commands:

    clear
        Clear the existing configuration.
    disable
        Disable the protection on the machine.
    enable
        Enable the protection on the machine.
    status
        Display the current configuration.
```

## vmhide
vmhide tool toggkles the VMHide.kext on and off to mask the VMM bit in the guest macOS.

More details can be found here https://github.com/Carnations-Botanica/VMHide.

Note: You will need to restart the system for the settings to take effect.

```
OC4VM vmhide
------------
Usage: vmhide [options]
Options:
    -on            Enable VMHide
    -off           Disable VMHide
    -h             Print this help message
```