@echo on
powershell -NoProfile -ExecutionPolicy bypass -Command "%~dp0hypervBuild.ps1 %*"
