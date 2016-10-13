@echo off
setlocal EnableDelayedExpansion

date /t
time /t

rem Java remove do not happen on computernames listed in whitelist
if exist "%~dp0whitelist\%computername%.txt" goto exit

echo.
rem detect if this is 32-bit operaing system
if "%ProgramFiles(x86)%"=="" goto FIND_NATIVE_JAVA_UNINSTALL_KEYS

:FIND_32_BIT_JAVA_UNINSTALL_KEYS_UNDER_64_BIT_SYSTEM
echo FINDING 32-BIT JAVA UNINSTALL KEYS UNDER 64-BIT SYSTEM:
echo.
rem list all 32-bit uninstall keys on 64-bit system
for /f "tokens=8 delims=\" %%a in ('reg query "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"') do (

rem work only with keys which have DisplayName
reg query "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\%%a" /v DisplayName > nul 2>&1
if !errorlevel!==0 (

rem if the uninstall key has "Java" inside then remember the uninstall key 
reg query "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\%%a" /v DisplayName | find "Java" > nul 2>&1
if !errorlevel!==0 (

rem show the key which included word "Java"
echo %%a;

rem show which exact Java version is under this key
reg query "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\%%a" /v DisplayName | find "Java"

rem delete uninstall key
if "%1"=="remove" reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\%%a" /f
echo.
)
)
)
echo.


:FIND_32_BIT_JAVA_CONTROL_PANEL_UNDER_64_BIT_SYSTEM
echo FINDING 32-BIT JAVA CONTROL PANEL ICON UNDER 64-BIT SYSTEM:
echo.
for /f "tokens=4 delims=\" %%a in ('reg query "HKCR\Wow6432Node\CLSID"') do (

rem look for keys which inlude InfoTip
reg query "HKCR\Wow6432Node\CLSID\%%a" /v InfoTip > nul 2>&1
if !errorlevel!==0 (

rem check inf InfoTip key included javacpl
reg query "HKCR\Wow6432Node\CLSID\%%a" /v InfoTip  | find "javacpl" > nul 2>&1

rem if found javacpl then this key is responsible for Java control panel icon
if !errorlevel!==0 (
echo %%a;
reg query "HKCR\Wow6432Node\CLSID\%%a" /v InfoTip  | find "javacpl"

if "%1"=="remove" reg delete "HKCR\Wow6432Node\CLSID\%%a" /f
echo.
)
)
)
echo.


:FIND_NATIVE_JAVA_UNINSTALL_KEYS
echo FINDING NATIVE JAVA UNINSTALL KEYS:
echo.
rem list all native uninstall keys
for /f "tokens=7 delims=\" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"') do (

rem work only with keys which have DisplayName
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%a" /v DisplayName > nul 2>&1
if !errorlevel!==0 (

rem if the uninstall key has "Java" inside then remeber the uninstall key 
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%a" /v DisplayName | find "Java" > nul 2>&1
if !errorlevel!==0 (

rem show the key which included word "Java"
echo %%a;

rem show which exact Java version is under this key
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%a" /v DisplayName | find "Java"

rem delete the key
if "%1"=="remove" reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%a" /f
echo.
)
)
)
echo.

:REMOVE_NATIVE_JAVA_ICON_FROM_CONTROL_PANEL
echo FINDING NATIVE JAVA CONTROL PANEL ICON:
echo.
for /f "tokens=3 delims=\" %%a in ('reg query "HKCR\CLSID"') do (

rem look for keys which inlude InfoTip
reg query "HKCR\CLSID\%%a" /v InfoTip > nul 2>&1
if !errorlevel!==0 (

rem check inf InfoTip key included javacpl
reg query "HKCR\CLSID\%%a" /v InfoTip  | find "javacpl" > nul 2>&1

rem if found javacpl then this key is responsible for Java control panel icon
if !errorlevel!==0 (
echo %%a;
reg query "HKCR\CLSID\%%a" /v InfoTip  | find "javacpl"

if "%1"=="remove" reg delete "HKCR\CLSID\%%a" /f
echo.
)
)
)
echo.


:FIND_ALL_JAVA_UNINSTALL_KEYS
echo FINDING JAVA PRODUCT CODES:
echo.
rem list all keys under "HKLM\SOFTWARE\Classes\Installer\Products"
for /f "tokens=6 delims=\" %%a in ('reg query "HKLM\SOFTWARE\Classes\Installer\Products"') do (

rem look which keys have name "Java"
reg query "HKLM\SOFTWARE\Classes\Installer\Products\%%a" /v ProductName | find "Java" > nul 2>&1

rem if there is "Java" keyword in ProductName then put the product code into the file
if !errorlevel!==0 (

echo %%a;
reg query "HKLM\SOFTWARE\Classes\Installer\Products\%%a" /v "ProductName" | find "ProductName"

rem removing this key
if "%1"=="remove" reg delete "HKLM\SOFTWARE\Classes\Installer\Products\%%a" /f
echo.
)
)
echo.

:KILL_JAVA_PROCESSES
"%~dp0sleep.exe" 1
rem kill existing java instances
tasklist | find "javaw.exe"
if !errorlevel!==0 if "%1"=="remove" "%~dp0nircmd.exe" killprocess "javaw.exe"
"%~dp0sleep.exe" 1
tasklist | find "javaws.exe"
if !errorlevel!==0 if "%1"=="remove" "%~dp0nircmd.exe" killprocess "javaws.exe"
"%~dp0sleep.exe" 1
tasklist | find "java.exe"
if !errorlevel!==0 if "%1"=="remove" "%~dp0nircmd.exe" killprocess "java.exe"


:REMOVE_JAVA_SERVICES
sc query JavaQuickStarterService > nul 2>&1
if !errorlevel!==0 (
if "%1"=="remove" (
net stop JavaQuickStarterService
"%~dp0sleep.exe" 2
sc delete JavaQuickStarterService
) else sc query JavaQuickStarterService
echo.
)

rem double check if service do not exist
sc query JavaQuickStarterService > nul 2>&1
if not !errorlevel!==1060 goto REMOVE_JAVA_SERVICES


:REMOVE_JAVA_REGISTRY_BASE
rem removing java master keys under registry
reg query "HKLM\SOFTWARE\JavaSoft" > nul 2>&1
if !errorlevel!==0 (
if "%1"=="remove" (
echo Found HKLM\SOFTWARE\JavaSoft key, deleting now..
reg delete "HKLM\SOFTWARE\JavaSoft" /f
) else echo Found "HKLM\SOFTWARE\JavaSoft" registry key!
echo.
)

reg query "HKLM\SOFTWARE\Wow6432Node\JavaSoft" > nul 2>&1
if !errorlevel!==0 (
if "%1"=="remove" (
echo Found HKLM\SOFTWARE\Wow6432Node\JavaSoft key, deleting now..
reg delete "HKLM\SOFTWARE\Wow6432Node\JavaSoft" /f
) else echo Found "HKLM\SOFTWARE\Wow6432Node\JavaSoft" registry key!
echo.
)


:REMOVE_JAVA_DIRECTORIES
rem removing Java catalog from native system
if exist "%programfiles%\Java" (
if "%1"=="remove" (
echo "%programfiles%\Java" found, removing now..
rd "%programfiles%\Java" /Q /S
) else echo Found "%programfiles%\Java" directory!
echo.
)

if exist "%programfiles(x86)%\Java" (
if "%1"=="remove" (
echo "%programfiles(x86)%\Java" found, removing now..
rd "%programfiles(x86)%\Java" /Q /S
) else echo Found "%programfiles(x86)%\Java" directory!
echo.
)

if exist "%programdata%\Oracle\Java" (
if "%1"=="remove" (
echo "%programdata%\Oracle\Java" found, removing now..
rd "%programdata%\Oracle\Java" /Q /S
) else echo Found "%programdata%\Oracle\Java" directory!
echo.
)


rem final check 
if "%1"=="remove" if exist "%programfiles%\Java" goto KILL_JAVA_PROCESSES
if "%1"=="remove" if exist "%programfiles(x86)%\Java" goto KILL_JAVA_PROCESSES

if "%1" NEQ "remove" goto exit

if not "%ProgramFiles(x86)%"=="" (
for /f "delims=" %%f in ('dir /b "%~dp0jre*x64.exe"') DO (
echo JRE install starts
time /t
start /wait "" "%~dp0%%f" /s AUTO_UPDATE=0 WEB_JAVA=1 WEB_JAVA_SECURITY_LEVEL=H WEB_ANALYTICS=0 EULA=1 REBOOT=0 SPONSORS=0
if !errorlevel!==0 echo sent email here
echo installation ends with code !errorlevel!
time /t
)
)

for /f "delims=" %%f in ('dir /b "%~dp0jre*i586.exe"') DO (
echo JRE install starts
time /t
start /wait "" "%~dp0%%f" /s AUTO_UPDATE=0 WEB_JAVA=1 WEB_JAVA_SECURITY_LEVEL=H WEB_ANALYTICS=0 EULA=1 REBOOT=0 SPONSORS=0
if !errorlevel!==0 echo sent email here
echo installation ends with code !errorlevel!
time /t
)

net stop JavaQuickStarterService > nul 2>&1
sc delete JavaQuickStarterService > nul 2>&1
echo Uninstall JRE updater
time /t
msiexec /x {4A03706F-666A-4037-7777-5F2748764D10} /qn > nul 2>&1
echo installation ends with code !errorlevel!
time /t


:exit
if exist "%~dp0whitelist\%computername%.txt" echo this computer is listed in whitelist

date /t
time /t

endlocal

