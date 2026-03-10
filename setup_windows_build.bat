@echo off
REM =====================================================================
REM Spider Solitaire - Windows Build Setup
REM Run this script AFTER restarting Windows to install the C++ workload
REM and build the Windows release.
REM =====================================================================

echo Spider Solitaire - Windows Build Setup
echo ========================================
echo.

REM Step 1: Install VS C++ workload (if not already installed)
echo Step 1: Checking Visual Studio C++ workload...
IF EXIST "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC" (
    echo   C++ toolchain already installed. Skipping.
) ELSE (
    echo   Installing Desktop development with C++ workload...
    "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" modify ^
        --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" ^
        --add Microsoft.VisualStudio.Workload.VCTools ^
        --includeRecommended ^
        --quiet --norestart
    echo   VS modification complete. You may need to restart again.
)

REM Step 2: Accept Android licenses
echo.
echo Step 2: Accepting Android SDK licenses...
set ANDROID_HOME=D:\Android\sdk
echo y | "%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager.bat" --licenses

REM Step 3: Build Flutter Windows release
echo.
echo Step 3: Building Flutter Windows release...
set PATH=D:\flutter\bin;%PATH%
set ANDROID_HOME=D:\Android\sdk
cd /d "%~dp0"
flutter build windows --release
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter Windows build failed.
    echo Run: flutter doctor
    pause
    exit /b 1
)

echo.
echo =====================================================================
echo BUILD COMPLETE!
echo Windows exe: build\windows\x64\runner\Release\spider_solitaire.exe
echo.
echo To create a desktop shortcut:
echo   Right-click spider_solitaire.exe -^> Send to -^> Desktop (shortcut)
echo.
echo Or double-click launch_windows.bat to run the game.
echo =====================================================================
pause
