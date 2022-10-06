@echo off
setlocal
set BROOT=%cd%

set CONF=%2%
set PLATFORM=%3%

if "%1"=="" (goto :default) else (goto :%1)
goto :exit

:default
goto :build

:cleanbuild
echo ### Cleaning the %PLATFORM% build directory
SET BUILD_DIR=build-%PLATFORM%
IF EXIST "%BUILD_DIR%" RMDIR /S /Q "%BUILD_DIR%"
goto :build

:build
echo ### Building the %CONF% configuration
REM /verbosity:minimal

SET BUILD_DIR=build-%PLATFORM%
IF EXIST "%BUILD_DIR%" RMDIR /S /Q "%BUILD_DIR%"
MKDIR "%BUILD_DIR%" & CD "%BUILD_DIR%"

cmake -G "Visual Studio 15 2017" -T v141 -A "%PLATFORM%" ..
IF ERRORLEVEL 1 EXIT /b 1

cmake --build . --config %CONF%
IF ERRORLEVEL 1 EXIT /b 2

:exit
endlocal
