@echo off
REM {{VERSION}}-{{COMMIT}}
REM SPDX-FileCopyrightText: © 2023-2026 David Parsons
REM SPDX-License-Identifier: MIT

REM Enable debug mode if DEBUG environment variable is set
if defined DEBUG echo on

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "MACSERIAL_BIN=macserial.exe"
set "MACSERIAL_PATH=%SCRIPT_DIR%%MACSERIAL_BIN%"
set "VMXTOOL_BIN=vmxtool.exe"
set "VMXTOOL_PATH=%SCRIPT_DIR%%VMXTOOL_BIN%"

REM Check if macserial binary exists
if not exist "%MACSERIAL_PATH%" (
    echo Error: %MACSERIAL_BIN% not found at %MACSERIAL_PATH% >&2
    echo Please ensure the macserial binary is in the same directory as this script >&2
    exit /b 1
)

REM Check if vmxtool binary exists
if not exist "%VMXTOOL_PATH%" (
    echo Error: %VMXTOOL_BIN% not found at %VMXTOOL_PATH% >&2
    echo Please ensure the vmxtool binary is in the same directory as this script >&2
    exit /b 1
)

REM Get VMX file from command line argument
set "VMXFILE=%~1"
if "%VMXFILE%"=="" (
    echo Error: No VMX file specified >&2
    exit /b 1
)

if not exist "%VMXFILE%" (
    echo Error: VMX file %VMXFILE% not found >&2
    exit /b 1
)

REM Generate random week number (1-53)
set /a "WEEK=%RANDOM% %% 53 + 1"

REM Generate serial and MLB
for /f "delims=" %%i in ('"%MACSERIAL_PATH%" -m iMac19^,2 -n 1 -w %WEEK% -y 2020') do set "input=%%i"

REM Check if macserial executed successfully
if errorlevel 1 (
    echo Error: Failed to execute %MACSERIAL_BIN% >&2
    echo Command output: %input% >&2
    exit /b 1
)

REM Split the output by pipe delimiter
for /f "tokens=1,2 delims=|" %%a in ("%input%") do (
    set "serial=%%a"
    set "mlb=%%b"
)

REM Trim whitespace
set "serial=%serial: =%"
set "mlb=%mlb: =%"

REM Validate the generated values are not empty
if "%serial%"=="" (
    echo Error: Generated serial is empty >&2
    echo Serial: '%serial%' >&2
    echo MLB: '%mlb%' >&2
    exit /b 1
)

if "%mlb%"=="" (
    echo Error: Generated MLB is empty >&2
    echo Serial: '%serial%' >&2
    echo MLB: '%mlb%' >&2
    exit /b 1
)

REM Generate ROM using pure batch - generate 6 random hex bytes
setlocal enabledelayedexpansion
set "hex=0123456789ABCDEF"
set "rom="
for /l %%i in (1,1,6) do (
    set /a "byte1=!RANDOM! %% 16"
    set /a "byte2=!RANDOM! %% 16"
    for %%a in (!byte1!) do for %%b in (!byte2!) do (
        set "rom=!rom!%%!hex:~%%a,1!!hex:~%%b,1!"
    )
)
endlocal & set "rom=%rom%"

REM Check if ROM generation succeeded
if "%rom%"=="" (
    echo Error: Failed to generate ROM value >&2
    exit /b 1
)

REM Display the changes
echo OC4VM regen
echo -----------
echo Regenerating Mac identifiers...
echo Adding these settings to VMX file:
echo.
echo __Apple_Model_Start__ = "iMac 2019"
echo board-id = "Mac-63001698E7A34814"
echo hw.model = "iMac19,2"
echo serialNumber = "%serial%"
echo efi.nvram.var.MLB = "%mlb%"
echo efi.nvram.var.ROM = "%rom%"
echo __Apple_Model_End__ = "iMac 2019"
echo.
echo Running vmxtool to update file...

REM Run vmxtool to update the VMX file
"%VMXTOOL_PATH%" set "%VMXFILE%" __Apple_Model_Start__="iMac 2019"
"%VMXTOOL_PATH%" set "%VMXFILE%" board-id="Mac-63001698E7A34814"
"%VMXTOOL_PATH%" set "%VMXFILE%" hw.model="iMac19,2"
"%VMXTOOL_PATH%" set "%VMXFILE%" serialNumber="%serial%"
"%VMXTOOL_PATH%" set "%VMXFILE%" efi.nvram.var.MLB="%mlb%"
"%VMXTOOL_PATH%" set "%VMXFILE%" efi.nvram.var.ROM="%rom%"
"%VMXTOOL_PATH%" set "%VMXFILE%" __Apple_Model_End__="iMac 2019"
