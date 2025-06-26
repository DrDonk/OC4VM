# Building OC4VM

Building must be done on macOS, either real or virtualized. The Homebrew package manager 
will need to be installed to allow installation of the following pre-requisites. Please 
follow the instructions at https://brew.sh.

Once brew is installed run the following commands to install the required software:
```
brew install qemu
brew install p7zip
brew install go
```

Now clone the OC4VM repository using:
```git clone https://github.com/DrDonk/OC4VM.git```

Using the terminal OC4VM can be built by simply running the make.sh command from tbe 
cloned repository.

```./make.sh```

The build artefacts will be found in the "build" folder and the release zip file in the 
"dist" folder.

The current variables used to define the different files in OC4VM are stored in 
oc4vm.toml and used in the OpenCore config.plist and VMware VMX template.

| Name        | Type            | Description                                   |
|:------------|-----------------|-----------------------------------------------|
| BUILD       | \<0/1\>         | build config switch for make.sh               |
| AMD         | \<0/1\>         | building for AMD                              |
| BOOTARGS    | \<string\>      | macOS NVRAM boot-args                         |
| CSRCONFIG   | \<data\>        | base64 encoded macOS CSR SIP value            |
| DEBUG       | \<0/1\>         | enable debug options in OpenCore              |
| DESCRIPTION | \<string\>      | description of configuration                  |
| DMG         | <release/debug> | specify release or debug version of OpenCore  |
| RESOLUTION  | \<string\>      | screen resolution WxH@Bpp or Max              |
| TIMEOUT     | \<integer\>     | timeout for OpenCore boot picker (0 disables) |
