# Changes

All dates are UK DD/MM/YY format.

## dd/mm/25 1.0.3
* macserial utility was missing from the tools folder on the images

## 22/04/25 1.0.2
* Default AMD core patch set to 2 cores
* New amdcpu tool allows AMD core patch to be modified in the guest
* Default memory for VMs is now set to 8GB
* New verbose OC4VM to allow macOS boot process to be viewed
* Modified debug OC4VM variant with in-depth OpenCore and macOS kernel traces

## 30/03/25 1.0.1
* Fixed opencore.vmdk and recovery vmdk not being updateable in VMware
* Ported siputil from Python 3 to Go
* New tool to regenerate the spoofed Mac serial, uuid, ROM and MLB.

## 27/03/25 1.0.0
* Initial release
