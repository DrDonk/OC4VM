# OC4VM - Tools

```
OC4VM boot-args
---------------
Usage: bootargs [options] [value]
Options:
    -get            Print boot-args variable
    -set value      Set the boot-args variable
    -h              Print this help message
```

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

```
OC4VM vmhide
------------
Usage: vmhide [options]
Options:
    -on            Enable VMHide
    -off           Disable VMHide
    -h             Print this help message
```