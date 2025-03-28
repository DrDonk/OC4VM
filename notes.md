# Random Notes

## Opencore
#### Cores for AMD Patches

From https://github.com/AMD-OSX/AMD_Vanilla/blob/master/README.md

The Core Count patch needs to be modified to boot your system. Find the four `algrey - Force cpuid_cores_per_package` patches and alter the `Replace` value only.

|   macOS Version      | Replace Value | New Value                   |
|----------------------|---------------|-----------------------------|
| 10.13.x, 10.14.x     | B8000000 0000 | B8 < Core Count > 0000 0000 |
| 10.15.x, 11.x        | BA000000 0000 | BA < Core Count > 0000 0000 |
| 12.x, 13.0 to 13.2.1 | BA000000 0090 | BA < Core Count > 0000 0090 |
| 13.3 +               |  BA000000 00  | BA < Core Count > 0000 00   |

From the table above substitue `< Core Count >` with the hexadecimal value matching your physical core count. Do not use your CPU's thread count. See the table below for the values matching your CPU core count.


| Core Count | Hexadecimal |
|------------|-------------|
|   4 Core   |     `04`    |
|   6 Core   |     `06`    |
|   8 Core   |     `08`    |
|   12 Core  |     `0C`    |
|   16 Core  |     `10`    |
|   24 Core  |     `18`    |
|   32 Core  |     `20`    |

So for example, a user with a 6-core processor should use these `Replace` values: `B8 06 0000 0000` / `BA 06 0000 0000` / `BA 06 0000 0090` / `BA 06 0000 00`

Which gives these values when correclty base64 encoded:

| Cores | 10.13/10.14<br/>uAAAAAAA | 10.15/11.0<br/>ugAAAAAA | 12.0/13.0<br/>ugAAAACQ | 13.3+<br/>ugAAAAA= |
|-------|--------------------------------------------|-------------------------------------------|------------------------------------------|---------------------------------|
| 1     | uAEAAAAA                                   | ugEAAAAA                                  | ugEAAACQ                                 | ugEAAAA=                        |
| 2     | uAIAAAAA                                   | ugIAAAAA                                  | ugIAAACQ                                 | ugIAAAA=                        |
| 4     | uAQAAAAA                                   | ugQAAAAA                                  | ugQAAACQ                                 | ugQAAAA=                        |
| 8     | uAgAAAAA                                   | uggAAAAA                                  | uggAAACQ                                 | uggAAAA=                        |
| 16    | uBAAAAAA                                   | uhAAAAAA                                  | uhAAAACQ                                 | uhAAAAA=                        |
| 24    | uBgAAAAA                                   | uhgAAAAA                                  | uhgAAACQ                                 | uhgAAAA=                        |
| 32    | uCAAAAAA                                   | uiAAAAAA                                  | uiAAAACQ                                 | uiAAAAA=                        |
| 64    | uEAAAAAA                                   | ukAAAAAA                                  | ukAAAACQ                                 | ukAAAAA=                        |

## macOS
### Useful boot-args
[default]<br/>
`keepsyms=1 -lilubetaall -no_compat_check -no_panic_dialog vmhState=disabled`

[stealth]<br/>
`keepsyms=1 -lilubetaall -no_compat_check -no_panic_dialog vmhState=enabled`

[verbose]<br/>
`keepsyms=1 -lilubetaall -no_compat_check -no_panic_dialog vmhState=disabled -v`

[trace]<br/>
`keepsyms=1 -lilubetaall -no_compat_check -no_panic_dialog vmhState=disabled -v serial=1`

[debug]<br/>
`keepsyms=1 -lilubetaall -no_compat_check -no_panic_dialog vmhState=disabled -v serial=1 debug=2`

[kdk]<br/>
`keepsyms=1 -lilubetaall -v -no_compat_check serial=1 debug=2 -no_panic_dialog -liludbgall -topo -cpuid kcsuffix=development`

Useful for AMD deugging using KDK:
`avx512=0 cwad`

## VMware
### VMware Mac OS X & macOS table

| macOS                 | Name          | guestOS             |  GOS   |
|:----------------------|---------------|---------------------|--------|
| macOS 10.5 (32-bit)   | Leopard       | darwin              | 0x5054 |
| macOS 10.5 (64-bit)   | Leopard       | darwin-64           | 0x5055 |
| macOS 10.6 (32-bit)   | Snow Leopard  | darwin10            | 0x5056 |
| macOS 10.6 (64-bit)   | Snow Leopard  | darwin10-64         | 0x5057 |
| macOS 10.7 (32-bit)   | Lion          | darwin11            | 0x5058 |
| macOS 10.7 (64-bit)   | Lion          | darwin11-64         | 0x5059 |
| macOS 10.8            | Mountain Lion | darwin12-64         | 0x505a |
| macOS 10.9            | Mavericks     | darwin13-64         | 0x505b |
| macOS 10.10           | Yosemite      | darwin14-64         | 0x505c |
| macOS 10.11           | El Capitan    | darwin15-64         | 0x505d |
| macOS 10.12           | Sierra        | darwin16-64         | 0x505e |
| macOS 10.13           | High Sierra   | darwin17-64         | 0x505f |
| macOS 10.14           | Mojave        | darwin18-64         | 0x5060 |
| macOS 10.15           | Catalina      | darwin19-64         | 0x5061 |
| macOS 11              | Big Sur       | darwin20-64         | 0x5062 |
| macOS 12              | Monterey      | darwin21-64         | 0x5063 |
| macOS 13              | Ventura       | darwin22-64         | 0x5064 |
| macOS 14              | Sonoma        | darwin23-64         | 0x5065 |
| macOS 15              | Sequoia       | darwin24-64         | 0x5066 |

### VMware Socket Calculations

| numvcpus | cpuid.coresPerSocket | sockets |
|----------|----------------------|---------|
| 1        | 1                    | 1       |
| 2        | 2                    | 1       |
| 2        | 1                    | 2       |
| 4        | 4                    | 1       |
| 4        | 2                    | 2       |
| 4        | 1                    | 4       |
| 8        | 8                    | 1       |
| 8        | 2                    | 4       |
| 8        | 4                    | 2       |
| 8        | 1                    | 8       |

### VMware machine spoofing

Spoof Mac mini 2018 in VMware VMX
```
# Mac mini 2018
board-id = "Mac-7BA5B2DFE22DDD8C"
board-id.reflectHost = "FALSE"
efi.nvram.var.MLB = "C07801609GUKXPGJA"
efi.nvram.var.MLB.reflectHost = "FALSE"
efi.nvram.var.ROM = "EFA3707116CA"
efi.nvram.var.ROM.reflectHost = "FALSE"
hw.model = "Macmini8,1"
hw.model.reflectHost = "FALSE"
serialNumber = "C07W20B5JYVX"
serialNumber.reflectHost = "FALSE"
smbios.reflectHost = "TRUE"
```

## QEMU
### QEMU Socket Calculations

| # of cores | QEMU SMP                                                          |
|------------|-------------------------------------------------------------------|
| 1 2 4 8    | SMP="cpus=$CPU_CORES,sockets=1,dies=1,cores=$CPU_CORES,threads=1" |
| 6 7        | SMP="cpus=$CPU_CORES,sockets=3,dies=1,cores=2,threads=1"          |
| 10 11      | SMP="cpus=$CPU_CORES,sockets=5,dies=1,cores=2,threads=1"          |
| 12 13      | SMP="cpus=$CPU_CORES,sockets=3,dies=1,cores=4,threads=1"          |
| 14 15      | SMP="cpus=$CPU_CORES,sockets=7,dies=1,cores=2,threads=1"          |
| 16 32 64   | SMP="cpus=$CPU_CORES,sockets=1,dies=1,cores=$CPU_CORES,threads=1" |

### QEMU on Windows
Windows enable WHPX:

`Dism /Online /Enable-Feature:HypervisorPlatform`

### QEMU host folder virtual drive

`-device usb-storage,drive=fat16 -drive file=fat:rw:fat-type=16:"<full path to host folder>",id=fat16,format=raw,if=none`

## Random Stuff

Encode a base64 encoded binary:

`print 0x087f | xxd -r | base64`

Decode a base64 encoded binary:

`print AAAf/w== | base64 -D | xxd -u -g 4 -e`