@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined CM echo ==^> ERROR: The "CM" variable was not found in the environment & goto exit1

if "%CM%" == "nocm"   goto nocm

if not defined CM_VERSION echo ==^> ERROR: The "CM_VERSION" variable was not found in the environment & set CM_VERSION=latest

if "%CM%" == "chef"   goto chef

echo ==^> ERROR: Unknown value for environment variable CM: "%CM%"

goto exit1

::::::::::::
:chef
::::::::::::

if not defined CHEF_URL if "%CM_VERSION%" == "latest" set CHEF_URL=https://www.getchef.com/chef/install.msi
if not defined CHEF_URL set CHEF_URL=https://opscode-omnibus-packages.s3.amazonaws.com/windows/2008r2/x86_64/chef-windows-%CM_VERSION%.windows.msi

set CHEF_MSI=chef-client-latest.msi
set CHEF_DIR=%TEMP%\chef
set CHEF_PATH=%CHEF_DIR%\%CHEF_MSI%

echo ==^> Creating "%CHEF_DIR%"
mkdir "%CHEF_DIR%"
pushd "%CHEF_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%CHEF_URL%" "%CHEF_PATH%"
) else (
  echo ==^> Downloading %CHEF_URL% to %CHEF_PATH%
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile(\"%CHEF_URL%\", '%CHEF_PATH%')" <NUL
)
if not exist "%CHEF_PATH%" goto exit1

echo ==^> Installing Chef client %CM_VERSION%
msiexec /qb /i "%CHEF_PATH%" /l*v "%CHEF_DIR%\chef.log" %CHEF_OPTIONS%

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: msiexec /qb /i "%CHEF_PATH%" /l*v "%CHEF_DIR%\chef.log" %CHEF_OPTIONS%
ver>nul

goto exit0

::::::::::::
:nocm
::::::::::::

echo ==^> Building box without a configuration management tool

:exit0

@ping 127.0.0.1
@ver>nul

@goto :exit

:exit1

@ping 127.0.0.1
@verify other 2>nul

:exit

@echo ==^> Script exiting with errorlevel %ERRORLEVEL%
@exit /b %ERRORLEVEL%