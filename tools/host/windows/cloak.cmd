@echo off
REM {{VERSION}}-{{COMMIT}}
REM SPDX-FileCopyrightText: © 2023-2026 David Parsons
REM SPDX-License-Identifier: MIT

REM Enable debug mode if DEBUG environment variable is set
if defined DEBUG echo on

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "VMXTOOL_BIN=vmxtool.exe"
set "VMXTOOL_PATH=%SCRIPT_DIR%%VMXTOOL_BIN%"

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

REM Display the changes
echo "OC4VM cloak"
echo "-----------"
echo "Cloaking the VM..."
"%VMXTOOL_PATH%" set "%VMXFILE%" board-id="Mac-63001698E7A34814"
