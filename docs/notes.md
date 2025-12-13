# Research Notes

These are my random notes whilst I was working on OC4VM. They may prove useful for other people.

## 1.0 Opencore

### 1.1 Core Count for AMD CPUs

Cores for AMD CPUs can now be set in VMware using the UI in the same way as for Intel CPUs.

#### 1.1.1 Current Method
The setting of the number of cores for an AMD processor needs to carefully managed as AMD CPUs
use different methods compared to an Intel CPU. To allow VMware to boot macOS on an AMD CPU OC4VM
uses OpenCore capabilities to emulate an Intel CPU when using an AMD CPU.

### 1.1.2 Patch List
List of AMD patches in AMD_Vanilla and their current status in OC4VM. All these patches modify code in
the XNU kernel and is found in the open source code in the /xnu/osfmk/i386/cpuid.c file.

| Function/Target                             | Patch Name                            | Comment                                     |
| ------------------------------------------- | --------------------------------------| ------------------------------------------- |
| _cpuid_set_info                             | cpuid_cores_per_package set to const  | Not used                                    |
| _cpuid_set_info                             | GenuineIntel to AuthenticAMD          | Required                                    |
| _cpuid_set_generic_info                     | Remove wrmsr(0x8B)                    | Not used                                    |
| _cpuid_set_generic_info                     | Replace rdmsr(0x8B) with constant 186 | Not used                                    |
| _cpuid_set_generic_info                     | Set flag=1                            | Not used                                    |
| _cpuid_set_generic_info                     | Disable check for Leaf 7              | Not used                                    |
| _cpuid_set_cpufamily                        | Force CPUFAMILY_INTEL_PENRYN          | Not used                                    |
| _cpuid_set_cache_info                       | CPUID 0x8000001d instead of 4         | Required                                    |
| _commpage_populate                          | Remove rdmsr                          | Not used                                    |
| _i386_init/_commpage_populate/_pstate_trace | Remove rdmsr calls                    | Not used                                    |
| _lapic_init                                 | Remove version check panic            | Not used                                    |
| _mtrr_update_action                         | Set PAT MSR to 00070106h              | Not used                                    |

#### 1.1.3 Set CPU as Haswell
Older patches used a Penrhyn CPU and constant patching inside the OC boot disk. 
By setting the CPU type to be Haswell the cpuid.c code reads the MSR 0x35 for the
core and thread count. VMware will pass through these core counts and OpenCore
will ensure MSR 0x35 is correctly set in VMs.

This is configured in the config.plist Kernel->Emulate section Cpuid1Data and Cpuid1Mask
settings mapped to Haswell CPU.
```
		<key>Emulate</key>
		<dict>
	    <key>Cpuid1Data</key>
			<data>wwYDAAAAAAAAAAAAAAAAAA==</data>
			<key>Cpuid1Mask</key>
			<data>////AAAAAAAAAAAAAAAAAA==</data>
			<key>DummyPowerManagement</key>
			<true/>
			<key>MaxKernel</key>
			<string></string>
			<key>MinKernel</key>
			<string></string>
		</dict>
```

#### 1.1.4 MSR 0x35
MSR 0x35 is setup by OpenCore in the config.plist Kernel->Quirks->ProvideCurrentCpuInfo setting.

#### 1.1.5 CPU Vendor String

Modified in the macOS XNU kernel cpuid_set_info code. macOS expects the 'GenuineIntel' string 
in cpuid 0 leaf. If it is not this string the kernel will panic very early on during boot. 
This patch switches the comparison string from GeunuineIntel to AuthenticAMD.

#### 1.1.6 Set CPU cache info
Intel CPUs provide cache information in CPUID leaf 0x4. AMD uses CPUID leaf 0x8000001d 
and patch cpuid_set_cache_info to use the AMD leaf instead of the Intel leaf.

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
