@echo off
powershell -EP Bypass -NoP -File "%~dp0Switch-Adapter.ps1" %*
pause