# Spoofing Virtual Apple Mac Model

## _It is recommended that you do not do this unless absolutely neccessary. VMs can be unstable and have kernel panics when setup to mimic an actual piece of Apple hardware. iCloud and Apple AppStore can be problematic in macOS VMs even with spoofing._

If you want to make the VM look like a specific Mac model settings can be configured in the
VMware VMX file to emulate a real Mac. The VMX template file is configured as a regular VMware virtual machine (VMware20,1) which is supported in all recent versions of macOS.

If you want to mimic a real machine iMac 2019 (iMac19,1 or iMac19,2) is recommended.

It is important that you avoid the following Apple Mac models until after macOS has been installed as it can cause a failure during installation. This is because the macOS installer thinks it is on a
real Mac and tries to do firmware updates.

T1 enabled Macs:
* 2016-2017 13″ & 15″ Macbook Pro

T2 enabled Macs:
* 2019-2020 16″ MacBook Pro
* 2018-2019 13″ & 15″ Macbook Pro
* 2018-2020 MacBook Air
* 2018 Mac Mini
* 2020 iMac
* 2017 iMac Pro
* 2019 Mac Pro

There is a command line tool available which will generate the lines for the VMX file in tools/host:

* regen.sh - Linux and macOS
* regen.ps1 - Windows PowerShell

```
Usage: regen.sh/regen.ps1 path_to_vmx_file
```
The tool will show you the settings being set and write them to the specified VMX file.

Here is some example output:
```
OC4VM regen
-----------
Regenerating Mac identifiers...
Adding these settings to VMX file:

__Apple_Model_Start__ = "iMac 2019"
board-id = "Mac-63001698E7A34814"
hw.model = "iMac19,2"
serialNumber = "C02DR0SFJWDW"
efi.nvram.var.MLB = "C020483004NKGQGJC"
efi.nvram.var.ROM = "%48%F3%3E%B7%14%C9"
__Apple_Model_End__ = "iMac 2019"

Running vmxtool to update file...
```
If you want to also hide the fact that macOS is running in a VM change this line:

```
hypervisor.cpuid.v0 = "TRUE"
```
to
```
hypervisor.cpuid.v0 = "FALSE"
```
*Note: that this is not always reliable in VMware Fusion and can cause macOS to kernel panic.*

The sysinfo tool can show you the details of the changes inside the macOS guest.

Settings from a default VM before regen has been used:
```
         Model: VMware20,1
      Board ID: 440BX Desktop Reference Platform
    FW Version: VMW201.00V.24866131.B64.2507211911
 Hardware UUID: 977FB2EB-3CE3-5973-9C0A-F63172B36495

 Serial Number: VMaXcEADBles
WARN: Invalid symbol 'a' in serial!
WARN: Invalid symbol 'c' in serial!
WARN: Invalid symbol 'l' in serial!
WARN: Invalid symbol 'e' in serial!
WARN: Invalid symbol 's' in serial!
WARN: Invalid week symbol 'c'!
WARN: Decoded week -1 is out of valid range [1, 53]!
       Country:  VMa - Unknown, please report!
          Year:    X - 2018
          Week:    c - -1
          Line:  EAD - 1305 (copy 12)
         Model: Bles - Unknown
   SystemModel: Unknown, please report!
         Valid: Unlikely

     System ID: 564DF979-6BC1-2DA9-526F-A4B42E68942C
           ROM: 564DF9796BC1
           MLB: LalSb6S0LmiULA...
WARN: Invalid MLB checksum!

    Gq3489ugfi: E6ABE54622099326A2EC09D7D4C813AA88
     Fyp98tpgj: 224869C683CE62A45250D7686EF90A9725
    kbjfrfpoJU: 86CD846FF168DE2BCC7887A913DF1DB6B6
  oycqAZloTNDm: 7E4C502DDD62FAE3AE8A88C84116C38266
  abKPld1EcMni: E359A16C151FBBD57D0113BB6E065EB7D2

Version 2.1.8. Use -h argument to see usage options.
```
After spoofing settings added to VMX file:
```
         Model: iMac19,2
      Board ID: Mac-63001698E7A34814
    FW Version: VMW201.00V.24866131.B64.2507211911
 Hardware UUID: 977FB2EB-3CE3-5973-9C0A-F63172B36495

 Serial Number: C02DR0SFJWDW
       Country:  C02 - China (Quanta Computer)
          Year:    D - 2020
          Week:    R - 48 (25.11.2020-01.12.2020)
          Line:  0SF - 899 (copy 1)
         Model: JWDW - iMac19,2
   SystemModel: iMac (Retina 4K, 21.5-inch, 2019)
         Valid: Possibly

     System ID: 564DF979-6BC1-2DA9-526F-A4B42E68942C
           ROM: 48F33EB714C9
           MLB: C020483004NKGQGJC

    Gq3489ugfi: F50C5390E57DAB58245455E4096C3F1E60
     Fyp98tpgj: 224869C683CE62A45250D7686EF90A9725
    kbjfrfpoJU: 86CD846FF168DE2BCC7887A913DF1DB6B6
  oycqAZloTNDm: 5A7D716E9D2CAED3710B99ECFAE5E0CE96
  abKPld1EcMni: 4E3C7E00D3EB8A9DA58AD21D79E1E806DF

Version 2.1.8. Use -h argument to see usage options.
```

## **Thanks**

Thanks to **tamta0** for providing more details for ROM and SmUUID spoofing settings.
