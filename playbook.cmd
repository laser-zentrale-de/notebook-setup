@echo off
powershell -EP Bypass -NoP -File "%~dp0playbook.ps1" %*
pause