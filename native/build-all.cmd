@echo off
setlocal

call build.cmd %1 %2 Win32
if %errorlevel% neq 0 exit /b %errorlevel%
call build.cmd %1 %2 x64
if %errorlevel% neq 0 exit /b %errorlevel%
call build.cmd %1 %2 arm64
if %errorlevel% neq 0 exit /b %errorlevel%

:exit
endlocal