@powershell -NoProfile -ExecutionPolicy ByPass -Command "& './script/chocolatey.ps1'"
REM Issues with Virtualbox that need to be investigated
REM cinst virtualbox --version 5.0.12.104815 -y
REM cinst virtualbox --version 5.0.10.104061 -y
REM cinst vagrant --version 1.8.1 -y
cinst vagrant --version 1.7.4 -y
cinst packer --version 0.8.6 -y
