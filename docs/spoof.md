# Spoofing Virtual Apple Mac Model

If you want to make the VM look like a specific Mac model the settings can be configued in the
VMware VMX file.

*Note: iCloud and Apple AppStore can be problematic in Intel macOS VMs even with spoofing.*

Currently the VMX file example is configured as a regular VMware virtual machine (VMware20,1) which is supported in all recent
version of macOS.

If you want to mimic a real Mac 2018 Mac mini (Macmini8,1) is recommended.

**It is important that you do not enable the commented out lines until after macOS has been installed as
it can cause a failure during installation when the macOS installer thinks it is on a real Mac and
tries to do firmware updates.**


```
__Default_Model__ = "VMware20,1"
board-id = "VMM-x86_64"

__Apple_Model__ = "Mac mini 2018"
__WARNING__ = "DO NOT UNCOMMENT UNTIL AFTER macOS INSTALLED"
_board-id = "Mac-7BA5B2DFE22DDD8C"
_hw.model = "Macmini8,1"
_hypervisor.cpuid.v0 = "FALSE"             # !!Not always reliable and can cause a panic!!
__IMPORTANT__ = "These are samples and MUST be replaced with unique values"
_serialNumber = "C07LL5Y8JYVX"
_efi.nvram.var.MLB = "C07343102GUKXPGCB"
_efi.nvram.var.ROM = "%66%C9%75%99%89%AC"
```

The process to mimic a Mac mini 2018 is:

1. Shutdown the VM
2. Open the guest VMX file in a text editor
3. Open a terminal/command window and change directory to the OC4VM tools folder
4. Add a "_" character to the line:

```
__Default_Model__ = "VMware20,1"
board-id = "VMM-x86_64"

```

so it looks like this:

```
__Default_Model__ = "VMware20,1"
_board-id = "VMM-x86_64"

```

5. Remove the "_" character from the begining of any lines you want to change
6. Run the version of macserial for you host OS using:

```
macserial -m Macmini8,1 -n 1
```

7. Use the first number for the serial number and the second number for MLB setting.

```
C07ZD06BJYVX | C079374014NKXPG1M
```

8. For the ROM power up the VM once and then use the VMs MAC address from the VMX file.

As an example:

```
ethernet0.generatedAddress = "00:0C:29:AA:BB:CC"
```

remove the ":"s and add "%" every 2 characters:

```
efi.nvram.var.ROM = "%00%0C%29%AA%BB%CC"
```

9. Save the VMX file
10. Run the VM and use System Profiler to check settings

Example of a modified section in the VMX file:

```
__Default_Model__ = "VMware20,1"
_board-id = "VMM-x86_64"

__Apple_Model__ = "Mac mini 2018"
board-id = "Mac-7BA5B2DFE22DDD8C"
hw.model = "Macmini8,1"
_hypervisor.cpuid.v0 = "FALSE"             # !!Not always relaible and can cause a panic!!
serialNumber = "C07ZD06BJYVX"
efi.nvram.var.MLB = "C079374014NKXPG1M"
efi.nvram.var.ROM = "%00%0C%29%AA%BB%CC"
```

If you want to also hide the fact that macOS is running in a VM change this line:

```
_hypervisor.cpuid.v0 = "FALSE"             # !!Not always relaible and can cause a panic!!
```

to

```
hypervisor.cpuid.v0 = "FALSE"             # !!Not always relaible and can cause a panic!!
```

*Note that this is not always reliable and can cause macOS to kernel panic.*

## **Thanks**

Thanks to **tamta0** for providing more details for ROM and SmUUID spoofing settings.
