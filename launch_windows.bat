@echo off
REM Spider Solitaire - Windows launcher
REM Double-click this file to launch the game without a terminal window.
REM Make sure you have built the Windows release first:
REM   flutter build windows --release

set EXE="%~dp0build\windows\x64\runner\Release\spider_solitaire.exe"

if not exist %EXE% (
  echo Build not found. Please run:
  echo   flutter build windows --release
  pause
  exit /b 1
)

start "" %EXE%
