@echo off
:: {{VERSION}}-{{COMMIT}}
:: SPDX-FileCopyrightText: © 2023-25 David Parsons
:: SPDX-License-Identifier: MIT

:: Enable debug mode if DEBUG environment variable is set to any non-empty value
if not "%DEBUG%"=="" echo on

:: Get script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"  :: Remove trailing backslash

:: Generate serial and MLB
for /f "tokens=1,2 delims=|" %%a in ('"%SCRIPT_DIR%\macserial.exe" -m Macmini8,1 -n 1 -w %DATE:~-10,2% -y %DATE:~-4%') do (
    set "serial=%%a"
    set "mlb=%%b"
)

:: Remove spaces from serial and MLB
set "serial=%serial: =%"
set "mlb=%mlb: =%"

:: Generate ROM (6 random bytes in hex format)
set "rom="
for /l %%i in (1,1,6) do (
    set /a "rand=!random! %% 256"
    set "hex=0!rand!"
    set "hex=!hex:~-2!"
    set "rom=!rom!%%!hex!"
)
set "rom=%rom:~0,18%"  :: Ensure exactly 6 bytes (18 characters including % symbols)

:: Convert to uppercase
set "rom=%rom:a=A%"
set "rom=%rom:b=B%"
set "rom=%rom:c=C%"
set "rom=%rom:d=D%"
set "rom=%rom:e=E%"
set "rom=%rom:f=F%"

:: Do the change
echo OC4VM regen
echo -----------
echo Regenerating Mac identifiers...
echo "Add these settings in the VMX file between lines:"
echo "# >>> Start Spoofing <<<"
echo "# >>> End Spoofing <<<"
echo.
echo __Apple_Model__ = "Mac mini 2018"
echo board-id = "Mac-7BA5B2DFE22DDD8C"
echo hw.model = "Macmini8,1"
echo serialNumber = "%serial%"
echo efi.nvram.var.MLB = "%mlb%"
echo efi.nvram.var.ROM = "%rom%"
echo system-id.enable = "TRUE"
echo hypervisor.cpuid.v0 = "TRUE"             !!Not always reliable and can cause a panic!!
echo.
echo End

:: Clean up variables
set "SCRIPT_DIR="
set "serial="
set "mlb="
set "rom="
set "rand="
set "hex="
