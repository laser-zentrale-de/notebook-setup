@echo off
powershell -EP Bypass -NoP -File "%~dp0Set-StaticIP.ps1" %*
pause