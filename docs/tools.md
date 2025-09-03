# OC4VM - Tools

The OpenCore boot disk constains some useful tools to modify
the OpenCore configuration file config.plist.

The OC4VM boot drive should be mounted at:

`/Volumes/OPENCORE`

and the tools are found at:

`/Volumes/OPENCORE/OC4VM/tools`

All these tools depend on the OC4VM boot drive being mounted at that path and
will raise an error if the config.plist file cannot be found on the boot drive.


## amdcpu

This utility alters the AMD cores patch settings that are stored in config.plist.

Note: You must ensure the guest VM cores match the setting when you restart the VM
or you will likely get a kernel panic.

```
Usage: amdcpu <cores>
Valid values: 1, 2, 4, 8, 16, 24, 32, 64
```

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
