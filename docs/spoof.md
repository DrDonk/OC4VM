# Spoofing Virtual Apple Mac Model

If you want to make the VM look like a specific Mac model the settings can be configued in the 
VMware VMX file. Currently the VMX file is configured as a 2018 Mac mini which is supported in Sequoia.

*Note: It iCloud and Apple AppStore can be problematic in Intel macOS VMs even with spoofing.*

**It is important that you do not enable the commented out lines until after macOS has been installed as 
it can cause a failure during installation when the macOS installer thinks it is on a real Mac and 
tries to do firmware updates.**

Supplied settings:

```
__Apple_Model__ = "Mac mini 2018"
board-id = "Mac-7BA5B2DFE22DDD8C"
hw.model = "Macmini8,1"
_serialNumber = "C07LL5Y8JYVX"
_efi.nvram.var.MLB = "C07343102GUKXPGCB"
_efi.nvram.var.ROM = "%66%C9%75%99%89%AC"       
_system-id.enable = "TRUE"
_hypervisor.cpuid.v0 = "FALSE"             # !!Not always reliable and can cause a panic!!
```

The process is:

1. Shutdown the VM
2. Open the guest VMX file in a text editor
3. Open a terminal/command window and change directory to the OC4VM tools folder.
4. Remove the "_" character from the bgining of any lines you want to change.
5. Run the version of macserial for you host OS using:

`macserial -m Macmini8,1 -n 1`

6. Use the first number for the serial number and the second number for MLB setting.

`C07ZD06BJYVX | C079374014NKXPG1M`

7. For the ROM power up the VM once and then use the VMs MAC address from the VMX file.

As an example:

`ethernet0.generatedAddress = "00:0C:29:AA:BB:CC"`

remove the ":"s and add "%" every 2 characters:

`efi.nvram.var.ROM = "%00%0C%29%AA%BB%CC"`

8. Save the VMX file
9. Run the VM and use System Profiler to check settings

Example:

```
__Apple_Model__ = "Mac mini 2018"
board-id = "Mac-7BA5B2DFE22DDD8C"
hw.model = "Macmini8,1"
serialNumber = "C07ZD06BJYVX"
efi.nvram.var.MLB = "C079374014NKXPG1M"
efi.nvram.var.ROM = "%00%0C%29%AA%BB%CC"
system-id.enable = "TRUE"
hypervisor.cpuid.v0 = "FALSE"             # !!Not always relaible and can cause a panic!!
```

10. Power on and test the system

## **Thanks**

Thanks to **tamta0** for providing more details for ROM and SmUUID spoofing settings.
