@echo off
setlocal
set PATH=%PATH%;%ProgramFiles(x86)%\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\bin\amd64
set VCTargetsPath=C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V140
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

:clean
echo ### Cleaning the %configuration% build directory
call build-native.cmd clean %configuration%
goto :exit

:cleanbuild
echo ### Cleaning the %configuration% build directory
call build-native.cmd clean %configuration%
goto :build

:build
:build_native
echo ### Building the %configuration% configuration
call build-native.cmd build %configuration%
if "%1"=="" goto :copy_native
goto :exit

:copy_native
echo ### Updating WinP resource files for the %configuration% build
cd %BUIDROOT%
COPY native\Win32\%configuration%\winp.dll src\main\resources\
if %errorlevel% neq 0 exit /b %errorlevel%
COPY native\x64\%configuration%\winp.x64.dll src\main\resources\
if %errorlevel% neq 0 exit /b %errorlevel%
COPY native\arm64\%configuration%\winp.arm64.dll src\main\resources\
if %errorlevel% neq 0 exit /b %errorlevel%
COPY native\Win32\%configuration%\sendctrlc.exe src\main\resources\
if %errorlevel% neq 0 exit /b %errorlevel%
COPY native\x64\%configuration%\sendctrlc.x64.exe src\main\resources\
if %errorlevel% neq 0 exit /b %errorlevel%
COPY native\arm64\%configuration%\sendctrlc.arm64.exe src\main\resources\
if %errorlevel% neq 0 exit /b %errorlevel%
if "%1"=="" goto :maven
goto :exit

:maven
echo ### Build and Test winp.jar for %version%
cd %BUIDROOT%
call mvn -q --batch-mode versions:set -DnewVersion=%version%
if %errorlevel% neq 0 exit /b %errorlevel%
call mvn --batch-mode clean package verify 
if %errorlevel% neq 0 exit /b %errorlevel%
goto :exit

:exit
endlocal
