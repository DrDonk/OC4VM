# Spoofing Virtual Apple Mac Model

If you want to make the VM look like a specific Mac model the settings can be configued in the 
VMware VMX file. Currently the VMX file is configured as a 2020 iMac which is still supported for Tahoe.

*Note: It looks like iCloud and Apple AppStore is not working in Intel macOS VMs even with spoofing.*

Supplied settings:

```
__Apple_Model__ = "iMac 5K Retina 2020"
board-id = "Mac-AF89B6D9451A490B"
hw.model = "iMac20,2"
_serialNumber = "C02CVXY9046M"
_efi.nvram.var.MLB = "C02024270GU0000AD"
_efi.nvram.var.ROM = "0ED6AE9B4774"       # !!This seems broken in current VMware builds!! 
_hypervisor.cpuid.v0 = "FALSE"
```

The process is:

1. Shutdown the VM
2. Open the guest VMX file in a text editor
3. Open a terminal/command window and change directory to the OC4VM tools folder.
4. Remove the "_" character from the bgining of any lines you want to change.
5. Run the version of macserial for you host OS using:

`macserial -m iMac20,1 -n 1`

6. Use the first number for the serial number and the second number for MLB setting.

`C02CJ1YQ046M | C02014306GU00001M`

7. For the ROM power up the VM once and then use the VMs MAC address from the VMX file.

As an example:

`ethernet0.generatedAddress = "00:0C:29:AA:BB:CC"`

remove the ":"s and add:

`efi.nvram.var.ROM = "000C29AABBCC"`

*NOTE: It looks like ROM value setting is broken using VMX or OCLP settings*

8. Save the VMX file
9. Run the VM and use System Profiler to check settings

Example:

```
__Apple_Model__ = "iMac 5K Retina 2020"
board-id = "Mac-AF89B6D9451A490B"
hw.model = "iMac20,2"
serialNumber = "C02CJ1YQ046M"
efi.nvram.var.MLB = "C02014306GU00001M"
efi.nvram.var.ROM = "112233445566"       # !!This seems broken in current VMware builds!! 
hypervisor.cpuid.v0 = "FALSE"
```