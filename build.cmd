@echo off
setlocal
set BUIDROOT=%cd%

:getopts
if "%2"=="" (
	set configuration="Release"
) else (
	set configuration=%2%
)

if "%3"=="" (
	echo No target version specified, will determine it from POM
	REM TODO: Apply some MADSKILLZ to do it without the temporary file?
	call mvn -q -Dexec.executable="cmd.exe" -Dexec.args="/c echo ${project.version}" --non-recursive org.codehaus.mojo:exec-maven-plugin:1.3.1:exec > version.txt
	for /f "delims=" %%x in (version.txt) do set version=%%x
) else (
	echo Setting MVN project version to the externally defined %3%
	set version=%3%	
)
echo Target version is %version%

if "%1"=="" (goto :default) else (goto :%1)
goto :exit

:default
goto :cleanbuild

:cleanbuild
echo ### Cleaning the %configuration% build directory
cd %BUIDROOT%\native
call build.cmd cleanbuild %configuration% Win32
if %errorlevel% neq 0 exit /b %errorlevel%
call build.cmd cleanbuild %configuration% x64
if %errorlevel% neq 0 exit /b %errorlevel%
call build.cmd cleanbuild %configuration% arm64
if %errorlevel% neq 0 exit /b %errorlevel%
goto :build

:build
echo ### Building the %configuration% configuration
cd %BUIDROOT%\native
REM /verbosity:minimal

call build.cmd build %configuration% Win32
if %errorlevel% neq 0 exit /b %errorlevel%
call build.cmd build %configuration% x64
if %errorlevel% neq 0 exit /b %errorlevel%
call build.cmd build %configuration% arm64
if %errorlevel% neq 0 exit /b %errorlevel%

echo ### Updating WinP resource files for the %configuration% build
cd %BUIDROOT%
COPY native\win32\%configuration%\winp.dll src\main\resources\winp.dll
if %errorlevel% neq 0 exit /b %errorlevel%
COPY native\x64\%configuration%\winp.dll src\main\resources\winp64.dll
if %errorlevel% neq 0 exit /b %errorlevel%
COPY native\arm64\%configuration%\winp.dll src\main\resources\winp64a.dll
if %errorlevel% neq 0 exit /b %errorlevel%
COPY native\sendctrlc\Win32\%configuration%\sendctrlc.exe src\main\resources\sendctrlc.exe
if %errorlevel% neq 0 exit /b %errorlevel%
COPY native\sendctrlc\x64\%configuration%\sendctrlc.exe src\main\resources\sendctrlc64.exe
if %errorlevel% neq 0 exit /b %errorlevel%
COPY native\sendctrlc\arm64\%configuration%\sendctrlc.exe src\main\resources\sendctrlc64a.exe
if %errorlevel% neq 0 exit /b %errorlevel%

echo ### Build and Test winp.jar for %version%
cd %BUIDROOT%
call mvn -q --batch-mode versions:set -DnewVersion=%version%
if %errorlevel% neq 0 exit /b %errorlevel%
call mvn --batch-mode clean package verify
if %errorlevel% neq 0 exit /b %errorlevel%
goto :exit

:exit
endlocal
