#### VMware Mac OS X & macOS table

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


#### Cores for AMD Patches

| Cores | 10.13/10.14<br/>uAAAAAAA<br/>B8000000 0000 | 10.15/11.0<br/>ugAAAAAA<br/>BA000000 0000 | 12.0/13.0<br/>ugAAAACQ<br/>BA000000 0090 | 13.3+<br/>ugAAAAA=<br/>BA000000 |
|-------|--------------------------------------------|-------------------------------------------|------------------------------------------|---------------------------------|
| 1     | uAEAAAAA                                   | ugEAAAAA                                  | ugEAAACQ                                 | ugEAAAA=                        |
| 2     | uAIAAAAA                                   | ugIAAAAA                                  | ugIAAACQ                                 | ugIAAAA=                        |
| 4     | uAQAAAAA                                   | ugQAAAAA                                  | ugQAAACQ                                 | ugQAAAA=                        |
| 8     | uAgAAAAA                                   | uggAAAAA                                  | uggAAACQ                                 | uggAAAA=                        |
| 16    | uBAAAAAA                                   | uhAAAAAA                                  | uhAAAACQ                                 | uhAAAAA=                        |
| 24    | uBgAAAAA                                   | uhgAAAAA                                  | uhgAAACQ                                 | uhgAAAA=                        |
| 32    | uCAAAAAA                                   | uiAAAAAA                                  | uiAAAACQ                                 | uiAAAAA=                        |
| 64    | uEAAAAAA                                   | ukAAAAAA                                  | ukAAAACQ                                 | ukAAAAA=                        |

#### VMware Socket Calculations

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

Encode a base64 encoded binary:

`print 0x087f | xxd -r | base64`

Decode a base64 encoded binary:

`print MduAPQAAAAAGdQA= | base64 -D | xxd -u -g 4 -e`

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

Windows enable WHPX:

```Dism /Online /Enable-Feature:HypervisorPlatform```

QEMU host folder as drive:

```-device usb-storage,drive=fat16 -drive file=fat:rw:fat-type=16:"<full path to host folder>",id=fat16,format=raw,if=none```
