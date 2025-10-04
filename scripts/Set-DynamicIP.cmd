@echo off
powershell -EP Bypass -NoP -File "%~dp0Set-DynamicIP.ps1" %*
pause