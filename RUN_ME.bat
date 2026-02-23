@echo off
chcp 65001 > nul
powershell.exe -ExecutionPolicy Bypass -File "%~dp0MASTER_MENU.ps1"
pause
