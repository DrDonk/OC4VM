// {{VERSION}}-{{COMMIT}}
// SPDX-FileCopyrightText: © 2023-25 David Parsons
// SPDX-License-Identifier: MIT

package main

import (
	"encoding/base64"
	"encoding/binary"
	"encoding/hex"
	"encoding/xml"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"

	"howett.net/plist"
)

// CSR configuration flags (from xnu csr.h file)
const (
	CSR_ALLOW_UNTRUSTED_KEXTS               uint32 = 1 << 0
	CSR_ALLOW_UNRESTRICTED_FS               uint32 = 1 << 1
	CSR_ALLOW_TASK_FOR_PID                  uint32 = 1 << 2
	CSR_ALLOW_KERNEL_DEBUGGER               uint32 = 1 << 3
	CSR_ALLOW_APPLE_INTERNAL                uint32 = 1 << 4
	CSR_ALLOW_UNRESTRICTED_DTRACE           uint32 = 1 << 5
	CSR_ALLOW_UNRESTRICTED_NVRAM            uint32 = 1 << 6
	CSR_ALLOW_DEVICE_CONFIGURATION          uint32 = 1 << 7
	CSR_ALLOW_ANY_RECOVERY_OS               uint32 = 1 << 8
	CSR_ALLOW_UNAPPROVED_KEXTS              uint32 = 1 << 9
	CSR_ALLOW_EXECUTABLE_POLICY_OVERRIDE    uint32 = 1 << 10
	CSR_ALLOW_UNAUTHENTICATED_ROOT          uint32 = 1 << 11
	CSR_ALLOW_RESEARCH_GUESTS               uint32 = 1 << 12
)

var (
	CSR_VALID_FLAGS = CSR_ALLOW_UNTRUSTED_KEXTS |
		CSR_ALLOW_UNRESTRICTED_FS |
		CSR_ALLOW_TASK_FOR_PID |
		CSR_ALLOW_KERNEL_DEBUGGER |
		CSR_ALLOW_APPLE_INTERNAL |
		CSR_ALLOW_UNRESTRICTED_DTRACE |
		CSR_ALLOW_UNRESTRICTED_NVRAM |
		CSR_ALLOW_DEVICE_CONFIGURATION |
		CSR_ALLOW_ANY_RECOVERY_OS |
		CSR_ALLOW_UNAPPROVED_KEXTS |
		CSR_ALLOW_EXECUTABLE_POLICY_OVERRIDE |
		CSR_ALLOW_UNAUTHENTICATED_ROOT |
		CSR_ALLOW_RESEARCH_GUESTS

	CSR_ALWAYS_ENFORCED_FLAGS = CSR_ALLOW_DEVICE_CONFIGURATION |
		CSR_ALLOW_ANY_RECOVERY_OS

	CSR_DISABLE_FLAGS = CSR_ALLOW_UNTRUSTED_KEXTS |
		CSR_ALLOW_UNRESTRICTED_FS |
		CSR_ALLOW_TASK_FOR_PID |
		CSR_ALLOW_KERNEL_DEBUGGER |
		CSR_ALLOW_APPLE_INTERNAL |
		CSR_ALLOW_UNRESTRICTED_DTRACE |
		CSR_ALLOW_UNRESTRICTED_NVRAM

	// Flags used by this utility
	SIP_ENABLE_ALL   uint32 = 0
	SIP_DISABLE_ALL  uint32 = CSR_DISABLE_FLAGS | CSR_ALLOW_UNAUTHENTICATED_ROOT
	MASK_ENABLE_FLAGS uint32 = ^SIP_DISABLE_ALL & 0xFFFFFFFF // Ensure 32-bit

	// Option flags
	DEBUG         = false
	CONFIG_PLIST  = "/Volumes/OPENCORE/EFI/OC/config.plist"

	// NVRAM variables
	APPLE_NVRAM_VARIABLE_GUID = "7C436110-AB2A-4BBB-A880-FE41995C9F82"
)

type NVRAM struct {
	Add map[string]map[string]interface{} `plist:"Add"`
}

type ConfigPlist struct {
	NVRAM NVRAM `plist:"NVRAM"`
}

func hexswap(inputHex string) string {
	// Pad with leading zero if odd length
	if len(inputHex)%2 != 0 {
		inputHex = "0" + inputHex
	}

	// Split into pairs and reverse
	hexPairs := make([]string, 0, len(inputHex)/2)
	for i := 0; i < len(inputHex); i += 2 {
		hexPairs = append(hexPairs, inputHex[i:i+2])
	}

	// Reverse the pairs
	for i, j := 0, len(hexPairs)-1; i < j; i, j = i+1, j-1 {
		hexPairs[i], hexPairs[j] = hexPairs[j], hexPairs[i]
	}

	return strings.ToUpper(strings.Join(hexPairs, ""))
}

func stringToHex(input string) []byte {
	swapped := hexswap(input)
	decoded, err := hex.DecodeString(swapped)
	if err != nil {
		log.Fatalf("Error decoding hex: %v", err)
	}
	return decoded
}

func printHelp() {
	helpText := `
Modify the System Integrity Protection configuration stored in the OpenCore config.plist.

Usage:
  siputil [global flags] <command> [command arguments]

Global Flags:
  -h, --help       Show this help
  -f, --file       Override default config.plist location
  -d, --debug      Show debugging information

Commands:
  clear
    Clear the existing configuration (enable all protections)

  disable [--with <feature>]...
    Disable SIP protections while optionally keeping specific features enabled
    Valid features: apple, authroot, basesystem, debug, dtrace, fs, kext, nvram

  enable [--without <feature>]...
    Enable SIP protections while optionally keeping specific features disabled
    Valid features: apple, authroot, basesystem, debug, dtrace, fs, kext, nvram

  status
    Display the current configuration

Examples:
  siputil disable
  siputil disable --with fs
  siputil disable --with fs --with nvram
  siputil enable --without dtrace
  siputil enable --without kext --without fs
`
	fmt.Println(helpText)
}

func printValue(prefix string, value uint32, suffix string) {
    raw := stringToHex(fmt.Sprintf("%08X", value))
    b64 := base64.StdEncoding.EncodeToString(raw)
    fmt.Printf("%s %4d 0x%08X %X %s %s\n", prefix, value, value, raw, b64, suffix)
}

func getConfig() *ConfigPlist {
	data, err := os.ReadFile(CONFIG_PLIST)
	if err != nil {
		log.Fatalf("Error reading config.plist: %v", err)
	}

	var config ConfigPlist
	_, err = plist.Unmarshal(data, &config)
	if err != nil {
		log.Fatalf("Error parsing config.plist: %v\nTry converting to XML first:\nplutil -convert xml1 %s", err, CONFIG_PLIST)
	}

	return &config
}

func setConfig(config *ConfigPlist) {
	data, err := plist.MarshalIndent(config, plist.XMLFormat, "  ")
	if err != nil {
		log.Fatalf("Error marshaling config.plist: %v", err)
	}

	err = os.WriteFile(CONFIG_PLIST, data, 0644)
	if err != nil {
		log.Fatalf("Error writing config.plist: %v", err)
	}
}

func getValue() uint32 {
	config := getConfig()
	
	if csrConfig, ok := config.NVRAM.Add[APPLE_NVRAM_VARIABLE_GUID]["csr-active-config"].([]byte); ok {
		if len(csrConfig) != 4 {
			log.Fatal("csr-active-config has unexpected length")
		}
		return binary.LittleEndian.Uint32(csrConfig)
	}
	
	log.Fatal("csr-active-config not found in plist")
	return 0
}

func setValue(value uint32) {
    config := getConfig()
    
    // Convert value to little-endian bytes
    buf := make([]byte, 4)
    binary.LittleEndian.PutUint32(buf, value)
    
    // Initialize NVRAM structure if it doesn't exist
    if config.NVRAM.Add == nil {
        config.NVRAM.Add = make(map[string]map[string]interface{})
    }
    if _, exists := config.NVRAM.Add[APPLE_NVRAM_VARIABLE_GUID]; !exists {
        config.NVRAM.Add[APPLE_NVRAM_VARIABLE_GUID] = make(map[string]interface{})
    }
    
    // Only modify the csr-active-config value
    config.NVRAM.Add[APPLE_NVRAM_VARIABLE_GUID]["csr-active-config"] = buf
    
    // Read the original file to preserve formatting
    originalData, err := os.ReadFile(CONFIG_PLIST)
    if err != nil {
        log.Fatalf("Error reading config.plist: %v", err)
    }
    
    // Unmarshal into generic interface to preserve all content
    var fullPlist interface{}
    _, err = plist.Unmarshal(originalData, &fullPlist)
    if err != nil {
        log.Fatalf("Error parsing config.plist: %v", err)
    }
    
    // Navigate through the plist structure to update just our value
    if plistDict, ok := fullPlist.(map[string]interface{}); ok {
        if nvram, ok := plistDict["NVRAM"].(map[string]interface{}); ok {
            if add, ok := nvram["Add"].(map[string]interface{}); ok {
                if guid, ok := add[APPLE_NVRAM_VARIABLE_GUID].(map[string]interface{}); ok {
                    guid["csr-active-config"] = buf
                } else {
                    add[APPLE_NVRAM_VARIABLE_GUID] = map[string]interface{}{
                        "csr-active-config": buf,
                    }
                }
            } else {
                add := map[string]interface{}{
                    APPLE_NVRAM_VARIABLE_GUID: map[string]interface{}{
                        "csr-active-config": buf,
                    },
                }
                nvram["Add"] = add
            }
        } else {
            nvram := map[string]interface{}{
                "Add": map[string]interface{}{
                    APPLE_NVRAM_VARIABLE_GUID: map[string]interface{}{
                        "csr-active-config": buf,
                    },
                },
            }
            plistDict["NVRAM"] = nvram
        }
    }
    
    // Marshal with proper formatting
    data, err := plist.MarshalIndent(fullPlist, plist.XMLFormat, "    ")
    if err != nil {
        log.Fatalf("Error marshaling config.plist: %v", err)
    }
    
    // Add XML header
    data = []byte(xml.Header + string(data))
    
    // Write back to file
    err = os.WriteFile(CONFIG_PLIST, data, 0644)
    if err != nil {
        log.Fatalf("Error writing config.plist: %v", err)
    }

    if DEBUG {
        check := getValue()
        if check != value {
            log.Fatal("Error: value not correctly saved")
        }
    }
}
func siputilClear() {
	if DEBUG {
		printValue("[debug] clear:", SIP_ENABLE_ALL, "")
	}
	setValue(SIP_ENABLE_ALL)
}

type stringSlice []string

func (s *stringSlice) String() string {
	return strings.Join(*s, ", ")
}

func (s *stringSlice) Set(value string) error {
	validFeatures := map[string]bool{
		"apple": true, "authroot": true, "basesystem": true,
		"debug": true, "dtrace": true, "fs": true, 
		"kext": true, "nvram": true,
	}
	
	if !validFeatures[value] {
		return fmt.Errorf("invalid feature: %s", value)
	}
	*s = append(*s, value)
	return nil
}

func siputilDisable(args []string) {
	var withLists []string
	
	disableFlags := flag.NewFlagSet("disable", flag.ExitOnError)
	disableFlags.Var((*stringSlice)(&withLists), "with", "Feature to keep enabled (may be repeated)")
	disableFlags.Parse(args)

	value := getValue()

	if DEBUG {
		printValue("[debug] disable initial: ", value, "")
	}

	value = value | SIP_DISABLE_ALL

	if DEBUG {
		printValue("[debug] disable masked:  ", value, "")
	}

	// Process any --with options
	for _, withItem := range withLists {
		switch withItem {
		case "apple":
			value = value &^ CSR_ALLOW_APPLE_INTERNAL
		case "authroot":
			value = value &^ CSR_ALLOW_UNAUTHENTICATED_ROOT
		case "basesystem":
			value = value &^ CSR_ALLOW_ANY_RECOVERY_OS
		case "debug":
			value = value &^ CSR_ALLOW_TASK_FOR_PID
		case "dtrace":
			value = value &^ CSR_ALLOW_UNRESTRICTED_DTRACE
		case "fs":
			value = value &^ CSR_ALLOW_UNRESTRICTED_FS
		case "kext":
			value = value &^ CSR_ALLOW_UNTRUSTED_KEXTS
		case "nvram":
			value = value &^ CSR_ALLOW_UNRESTRICTED_NVRAM
		}

		if DEBUG {
			printValue("[debug] disable with:    ", value, withItem)
		}
	}

	if DEBUG {
		printValue("[debug] disable final:   ", value, "")
	}

	setValue(value)
	siputilStatus()
}

func siputilEnable(args []string) {
	var withoutLists []string
	
	enableFlags := flag.NewFlagSet("enable", flag.ExitOnError)
	enableFlags.Var((*stringSlice)(&withoutLists), "without", "Feature to keep disabled (may be repeated)")
	enableFlags.Parse(args)

	value := getValue()

	if DEBUG {
		printValue("[debug] enable initial:  ", value, "")
	}

	value = value & MASK_ENABLE_FLAGS

	if DEBUG {
		printValue("[debug] enable masked:   ", value, "")
	}

	// Process any --without options
	for _, withoutItem := range withoutLists {
		switch withoutItem {
		case "apple":
			value = value | CSR_ALLOW_APPLE_INTERNAL
		case "authroot":
			value = value | CSR_ALLOW_UNAUTHENTICATED_ROOT
		case "basesystem":
			value = value | CSR_ALLOW_ANY_RECOVERY_OS
		case "debug":
			value = value | CSR_ALLOW_KERNEL_DEBUGGER
		case "dtrace":
			value = value | CSR_ALLOW_UNRESTRICTED_DTRACE
		case "fs":
			value = value | CSR_ALLOW_UNRESTRICTED_FS
		case "kext":
			value = value | CSR_ALLOW_UNTRUSTED_KEXTS
		case "nvram":
			value = value | CSR_ALLOW_UNRESTRICTED_NVRAM
		}

		if DEBUG {
			printValue("[debug] enable with:     ", value, withoutItem)
		}
	}

	if DEBUG {
		printValue("[debug] enable final:    ", value, "")
	}

	setValue(value)
	siputilStatus()
}

func printFlagStatus(msg string, value, flag uint32) {
	if value&flag != 0 {
		fmt.Printf("\t%s disabled\n", msg)
	} else {
		fmt.Printf("\t%s enabled\n", msg)
	}
}

func siputilStatus() {
	value := getValue()

	if value == SIP_ENABLE_ALL {
		fmt.Println("Status: enabled")
	} else if value == SIP_DISABLE_ALL {
		fmt.Println("Status: disabled")
	} else {
		fmt.Println("Status: custom")
	}

	fmt.Println("Configuration:")
	printFlagStatus("Apple Internal: ", value, CSR_ALLOW_APPLE_INTERNAL)
	printFlagStatus("Authenticated Root: ", value, CSR_ALLOW_UNAUTHENTICATED_ROOT)
	printFlagStatus("Kext Signing: ", value, CSR_ALLOW_UNTRUSTED_KEXTS)
	printFlagStatus("Filesystem Protections: ", value, CSR_ALLOW_UNRESTRICTED_FS)
	printFlagStatus("Debugging Restrictions: ", value, CSR_ALLOW_KERNEL_DEBUGGER)
	printFlagStatus("DTrace Restrictions: ", value, CSR_ALLOW_UNRESTRICTED_DTRACE)
	printFlagStatus("NVRAM Protections: ", value, CSR_ALLOW_UNRESTRICTED_NVRAM)
	printFlagStatus("BaseSystem Verification: ", value, CSR_ALLOW_ANY_RECOVERY_OS)
	
	printValue("csr-active-config:", value, "")

}

func main() {
	fmt.Println("OC4VM siputil")
	fmt.Println("-------------")

	var help bool
	var debug bool
	var configFile string

	flag.BoolVar(&help, "h", false, "Show help")
	flag.BoolVar(&help, "help", false, "Show help")
	flag.BoolVar(&debug, "d", false, "Enable debug output")
	flag.BoolVar(&debug, "debug", false, "Enable debug output")
	flag.StringVar(&configFile, "f", "", "Override config.plist location")
	flag.StringVar(&configFile, "file", "", "Override config.plist location")

	flag.Parse()

	if help || len(flag.Args()) == 0 {
		printHelp()
		return
	}

	DEBUG = debug
	if configFile != "" {
		CONFIG_PLIST = configFile
	}

	// Check file exists
	if _, err := os.Stat(CONFIG_PLIST); os.IsNotExist(err) {
		log.Fatalf("Error: %s not found!", CONFIG_PLIST)
	}

	// Dispatch commands
	args := flag.Args()
	switch args[0] {
	case "disable":
		siputilDisable(args[1:])
	case "enable":
		siputilEnable(args[1:])
	case "status":
		siputilStatus()
	case "clear":
		siputilClear()
	default:
		printHelp()
	}
}