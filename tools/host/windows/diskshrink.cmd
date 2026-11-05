@echo off
REM {{VERSION}}-{{COMMIT}}
REM SPDX-FileCopyrightText: © 2023-2026 David Parsons
REM SPDX-License-Identifier: MIT

REM Enable debug mode if DEBUG environment variable is set
if defined DEBUG echo on

echo "OC4VM VMware Disk Shrink"

REM Get VMX file from command line argument
set "VMDKFILE=%~1"
if "%VMDKFILE%"=="" (
    echo Error: No VMDK file specified >&2
    exit /b 1
)

if not exist "%VMDKFILE%" (
    echo Error: VMDK file %VMDKFILE% not found >&2
    exit /b 1
)

echo "VMware disk shrinking started"
vmware-vdiskmanager.exe -k "%VMDKFILE%"
echo "VMware disk shrinking completed"
