# Research Notes

These are my random notes whilst I was working on OC4VM. They may prove useful for other people.

## 1.0 Opencore

### 1.1 Core Count for AMD CPUs

Cores for AMD CPUs can now be set in VMware using the UI in the same way as for Intel CPUs.

#### 1.1.1 Current Method
The setting of the number of cores for an AMD processor needs to carefully managed as AMD CPUs
use different methods those of an Intel CPU. To allow VMware to boot macOS on an AMD CPU OC4VM
uses OpenCore capabilities to emulate an Intel CPU when using an AMD CPU.

### 1.1.2 Patch List
List of AMD patches in config.plist and their current status in OC4VM

| Function/Target                             | Patch Name                            | Comment                                     |
| ------------------------------------------- | --------------------------------------| ------------------------------------------- |
| _cpuid_set_info                             | cpuid_cores_per_package set to const  | Not used                                    |
| _cpuid_set_info                             | GenuineIntel to AuthenticAMD          | Required                                    |
| _cpuid_set_generic_info                     | Remove wrmsr(0x8B)                    | Not used                                    |
| _cpuid_set_generic_info                     | Replace rdmsr(0x8B) with constant 186 | Not used                                    |
| _cpuid_set_generic_info                     | Set flag=1                            | Not used                                    |
| _cpuid_set_generic_info                     | Disable check for Leaf 7              | Required                                    |
| _cpuid_set_cpufamily                        | Force CPUFAMILY_INTEL_PENRYN          | Not used                                    |
| _cpuid_set_cache_info                       | CPUID 0x8000001d instead of 4         | Required                                    |
| _commpage_populate                          | Remove rdmsr                          | Not used                                    |
| _i386_init/_commpage_populate/_pstate_trace | Remove rdmsr calls                    | Not used                                    |
| _lapic_init                                 | Remove version check panic            | Not used                                    |
| _mtrr_update_action                         | Set PAT MSR to 00070106h              | Not used                                    |

#### 1.2.2 Details

OC changes

ProvideCurrentInfo MSR 0x35
Kernel->Emulate section Cpuid1Data and Cpuid1Mask settings mapped to Haswell CPU 
(Alternative using VMX file but possible will not work on Windows if Hyper-V active)
GeunuineIntel AuthenticAMD
CPUID leaf 0x4 needs to be replaced by 0x8000001d for cache Details
Disable a check for CPUID 0x7 leaf

```
#                                     Bit Position
#                        3           2            1           0
#                       1098:7654:3210:9876:5432:1098:7654:3210
# EAX/ECX Registers     ---------------------------------------

# Set CPU vendor to Intel (GenuineIntel)
#cpuid.0.eax.amd =     "0000:0000:0000:0000:0000:0000:0000:1101"
#cpuid.0.ebx.amd =     "0111:0101:0110:1110:0110:0101:0100:0111"
#cpuid.0.ecx.amd =     "0110:1100:0110:0101:0111:0100:0110:1110"
#cpuid.0.edx.amd =     "0100:1001:0110:0101:0110:1110:0110:1001"

Intel Haswell identification
cpuid.brandstring = "Intel® Core™ i5-9600K CPU @ 3.70GHz"

Haswell-S (Desktop): Family 6, Model 60 (3C), Stepping 3
cpuid.1.eax.amd = "0000:0000:0000:0011:0000:0110:1100:0011"  # 000306C3

or

featMask.vm.cpuid.FAMILY = "Val:6"
featMask.vm.cpuid.MODEL = "Val:60"
featMask.vm.cpuid.STEPPING = "Val:3"
```

#### 1.2.3 Deprecated Method
*NOTE: These are no longer used but kept for reference.*

From https://github.com/AMD-OSX/AMD_Vanilla/blob/master/README.md

> The Core Count patch needs to be modified to boot your system. 
> Find the four `algrey - Force cpuid_cores_per_package` patches and alter the `Replace` value only.
>
> |   macOS Version      | Replace Value | New Value                   |
> |----------------------|---------------|-----------------------------|
> | 10.13.x, 10.14.x     | B8000000 0000 | B8 < Core Count > 0000 0000 |
> | 10.15.x, 11.x        | BA000000 0000 | BA < Core Count > 0000 0000 |
> | 12.x, 13.0 to 13.2.1 | BA000000 0090 | BA < Core Count > 0000 0090 |
> | 13.3 +               | BA000000 00   | BA < Core Count > 0000 00   |
>
> From the table above substitute `< Core Count >` with the hexadecimal 
> value matching your physical core count. Do not use your CPU's thread count. 
> See the table below for the values matching your CPU core count.
>
>
> | Core Count | Hexadecimal |
> |------------|-------------|
> |   4 Core   |     `04`    |
> |   6 Core   |     `06`    |
> |   8 Core   |     `08`    |
> |   12 Core  |     `0C`    |
> |   16 Core  |     `10`    |
> |   24 Core  |     `18`    |
> |   32 Core  |     `20`    |
>
> So for example, a user with a 6-core processor should use these
>`Replace` values: `B8 06 0000 0000` / `BA 06 0000 0000` / `BA 06 0000 0090` / `BA 06 0000 00`

Which gives these values when correctly base64 encoded:

| Cores | 10.13/10.14 | 10.15/11.0  | 12.0/13.0   | 13.3+       |
|-------|-------------|-------------|-------------|-------------|
| 0     | uAAAAAAA    | ugAAAAAA    | ugAAAACQ    | ugAAAAA=    |
| 1     | uAEAAAAA    | ugEAAAAA    | ugEAAACQ    | ugEAAAA=    |
| 2     | uAIAAAAA    | ugIAAAAA    | ugIAAACQ    | ugIAAAA=    |
| 4     | uAQAAAAA    | ugQAAAAA    | ugQAAACQ    | ugQAAAA=    |
| 8     | uAgAAAAA    | uggAAAAA    | uggAAACQ    | uggAAAA=    |
| 12    | uAwAAAAA    | ugwAAAAA    | ugwAAACQ    | ugwAAAA=    |
| 16    | uBAAAAAA    | uhAAAAAA    | uhAAAACQ    | uhAAAAA=    |
| 24    | uBgAAAAA    | uhgAAAAA    | uhgAAACQ    | uhgAAAA=    |
| 28    | uBwAAAAA    | uhwAAAAA    | uhwAAACQ    | uhwAAAA=    |
| 32    | uCAAAAAA    | uiAAAAAA    | uiAAAACQ    | uiAAAAA=    |
| 64    | uEAAAAAA    | ukAAAAAA    | ukAAAACQ    | ukAAAAA=    |

## 2.0 macOS
### 2.1 Useful boot-args
```
[default]
keepsyms=1 -lilubetaall -no_compat_check -no_panic_dialog cwad

[verbose]
keepsyms=1 -lilubetaall -v -no_compat_check -no_panic_dialog -liludbgall cwad

[trace]
keepsyms=1 -lilubetaall -v -no_compat_check -no_panic_dialog -liludbgall serial=1 debug=2 -topo -cpuid cwad

[debug]
keepsyms=1 -lilubetaall -v -no_compat_check -no_panic_dialog -liludbgall serial=1 debug=2 -topo -cpuid cwad

[kdk]
keepsyms=1 -lilubetaall -v -no_compat_check -no_panic_dialog -liludbgall serial=1 debug=2 -topo -cpuid cwad kcsuffix=development
```

## 3.0 VMware

### 3.1 Virtual USB CD-ROM and Hard Drive

VMware has poorly documented virtual USB CD-ROM and drive capabilities. These can be either USB 2 or 3
depending on the settings used in the VMX file. These virtual devices cannot be added using the VMware
user interface.

The general settings are:

```
<usb>:#.present = "TRUE"
<usb>:#.deviceType = "disk" or "cdrom-image
<usb>:#.fileName = "pathToFile.vmdk" or "pathToFile.iso"
<usb>:#.readonly = "FALSE" or "TRUE"

where <usb> is ehci for USB2 or usb_xhci for USB3
where # is a number ranging from 0 to 5 (or 7 if you configure the USB ports in the configuration file).
```
There are other options but those are for attaching real devices such as video camera.

### 3.2 VMware VMX Comments
VMware uses "#" as the comment character, but the VMware code can re-write the VMX file with all the comments
aggregated at the top of the file. This means the positional comments are moved and the context is lost.

To bypass this issue the "_" characters are used to prefix commented out lines. VMware interprets these lines as
valid but cannot use them due to the prefix.

Example:

`_smbios.reflectHost = "FALSE"`

to use this edit it to:

`smbios.reflectHost = "FALSE"`

In addtion there are dummy section names using "__" as a prefix and suffix:

`__Apple_Model__ = ""`

### 3.4 VMware Mac OS X & macOS table

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
| macOS 26              | Tahoe         | darwin25-64         | 0x5067 |

### 3.5 VMware Socket Calculations

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

### 3.6 CPU Hacks

Allow setting more cores than host supports:
```
numvcpus.overcommit = "TRUE"
```

Force NUMA node sizing at each boot:
```
numa.autosize.once = "FALSE"            
```

### 3.7 New guestOS table patch
This patch allows all guest OS familes and types to be displayed on Windows and Linux. It's a simpler patch
than my patcher in the Unlocker. It is not essential but used for testing the OC4VM code.

VMware Workstation 17.6.3 for Windows vmwarebase.dll

```
Windows unpatched
                         LAB_103731ad                              XREF[1]:   1037319e(j)
      103731ad c6 85 e4      MOV       byte ptr [EBP + local_120],0x1
               fe ff ff
               01
      103731b4 eb 07         JMP       LAB_103731bd
                         LAB_103731b6                              XREF[3]:   1037318b(j), 10373194(j),
                                                                               103731ab(j)
      103731b6 c6 85 e4      MOV       byte ptr [EBP + local_120],0x0
               fe ff ff
               00
```

```
Windows patched
                         LAB_103731ad                              XREF[1]:   1037319e(j)
      103731ad c6 85 e4      MOV       byte ptr [EBP + local_120],0x1
               fe ff ff
               01
      103731b4 eb 07         JMP       LAB_103731bd
                         LAB_103731b6                              XREF[3]:   1037318b(j), 10373194(j),
                                                                               103731ab(j)
      103731b6 c6 85 e4      MOV       byte ptr [EBP + local_120],0x1
               fe ff ff
               01
```

Find:    `c6 85 e4 fe ff ff 01 eb 07 c6 85 e4 fe ff ff 00`

Replace: `c6 85 e4 fe ff ff 01 eb 07 c6 85 e4 fe ff ff 01`

VMware Workstation 17.6.3 for Linux libvmwarebase.so

```
Linux unpatched

      00624224 48 8b 43      MOV       RAX,qword ptr [RBX + 0x40]=>DAT_009aab60   = 0000000F77150690h
               40
      00624228 31 d2         XOR       EDX,EDX
      0062422a a8 01         TEST      AL,0x1
      0062422c 74 13         JZ        LAB_00624241

Linux patched:

      00624224 c7 c2 01      MOV       EDX,0x1
               00 00 00
      0062422a a8 01         TEST      AL,0x1
      0062422c eb 13         JMP       LAB_00624241
```

Find:    `48 8b 43 40 31 d2 a8 01 74 13`

Replace: `c7 c2 01 00 00 00 a8 01 eb 13`



## 4.0 Random Stuff

### 4.1 OpenCore DATA entries

The config.plist contains entries that are labelled as DATA which 
are base 64 encoded 

Encode a base64 encoded binary:

`printf "\xBA\x00\x00\x00\x00" | xxd -r | base64`

Decode a base64 encoded binary:

`printf AAAf/w== | base64 -D | xxd`

Examples from kernel patching section of config.plist:

```
Find:        wegaAAA= -> c1 e81a 0000 - 1100 0001 1110 1000 0001 1010 0000 0000 0000 0000 
Mask:        //3/AAA= -> ff fdff 0000 - 1111 1111 1111 1101 1111 1111 0000 0000 0000 0000 
Replace:     uggAAAA= -> ba 0800 0000 - 1011 1010 0000 0000 0000 0000 0000 0000 0000 0000
ReplaceMask: //////8= -> ff ffff ffff - 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111
```

Example for kernel Emulate section Cpuid1Data and Cpuid1Mask settings:

```
printf "\xC3\x06\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" | xxd
00000000: c306 0300 0000 0000 0000 0000 0000 0000  ................
printf "\xC3\x06\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" | base64
wwYDAAAAAAAAAAAAAAAAAA==
printf wwYDAAAAAAAAAAAAAAAAAA== | base64 -D | xxd
00000000: c306 0300 0000 0000 0000 0000 0000 0000  ................

printf "\xFF\xFF\xFF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" | xxd
00000000: ffff ff00 0000 0000 0000 0000 0000 0000  ................
printf "\xFF\xFF\xFF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" | base64
////AAAAAAAAAAAAAAAAAA==
printf ////AAAAAAAAAAAAAAAAAA== | base64 -D | xxd
00000000: ffff ff00 0000 0000 0000 0000 0000 0000  ................
```
Which would require these base64 strings adding to config.plist:

```
<key>Cpuid1Data</key>
<data>wwYDAAAAAAAAAAAAAAAAAA==</data>
<key>Cpuid1Mask</key>
<data>////AAAAAAAAAAAAAAAAAA==</data>
```