@echo on
powershell -NoProfile -ExecutionPolicy bypass -Command "%~dp0build\buildBox.ps1 %*"
