@echo off
REM Wesley's dev environment one-shot installer
REM Double-click or run from cmd/PowerShell. Must be Administrator.
REM Usage: install.bat [repo-owner/repo] [branch]
REM   e.g. install.bat ur-wesley/dotfiles main

setlocal
set REPO=%~1
if "%REPO%"=="" set REPO=ur-wesley/dotfiles
set BRANCH=%~2
if "%BRANCH%"=="" set BRANCH=main

echo.
echo ============================================================
echo  Wesley's dev environment installer
echo  Repo:  %REPO%
echo  Branch: %BRANCH%
echo ============================================================
echo.

REM Check for admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] This script must be run as Administrator.
    pause
    exit /b 1
)

REM Download + run the PowerShell installer
set PSURL=https://raw.githubusercontent.com/%REPO%/%BRANCH%/install/install.ps1
set PSFILE=%TEMP%\install.ps1
echo Downloading %PSURL% ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm '%PSURL%' -OutFile '%PSFILE%'"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%" -Repo "%REPO%" -Branch "%BRANCH%"

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Installer failed. See output above.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo  Done! Open Windows Terminal and pick the NixOS profile.
echo ============================================================
pause
