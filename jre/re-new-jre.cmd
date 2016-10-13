@echo off
set http_proxy=
setlocal EnableDelayedExpansion
set path=%path%;%~dp0

del "%~dp0*i586.exe" /Q /F
del "%~dp0*x64.exe" /Q /F

for /f "tokens=*" %%l in ('^
wget --no-cookies --no-check-certificate http://www.java.com/en/download/manual.jsp -qO- ^|
grep BundleId ^|
sed "s/\d034/\n/g" ^|
grep "^http" ^|
gnusort ^|
uniq') do (
echo looking for exe installer under %%l
wget %%l -S --spider -o "%~dp0jretmp.log"
sed "s/http/\nhttp/g;s/exe/exe\n/g" "%~dp0jretmp.log" |^
grep "^http.*x64.exe$\|^http.*i586.exe$" |^
gnusort | uniq | grep "^http.*x64.exe$\|^http.*i586.exe$"
if !errorlevel!==0 (
for /f "tokens=*" %%f in ('^
sed "s/http/\nhttp/g;s/exe/exe\n/g" "%~dp0jretmp.log" ^|
grep "^http.*x64.exe$\|^http.*i586.exe$" ^|
gnusort ^|
uniq ^|
sed "s/^.*\///g"') do (
wget --no-cookies --no-check-certificate %%l -O "%~dp0%%f"
)
)
)

rem https://docs.oracle.com/javase/8/docs/technotes/guides/install/config.html#installing_with_config_file
if not "%ProgramFiles(x86)%"=="" (
for /f "delims=" %%f in ('dir /b "%~dp0jre*x64.exe"') DO (
start /wait "" "%~dp0%%f" /s AUTO_UPDATE=0 WEB_JAVA=1 WEB_JAVA_SECURITY_LEVEL=H WEB_ANALYTICS=0 EULA=1 REBOOT=0 SPONSORS=0
)
)

for /f "delims=" %%f in ('dir /b "%~dp0jre*i586.exe"') DO (
start /wait "" "%~dp0%%f" /s AUTO_UPDATE=0 WEB_JAVA=1 WEB_JAVA_SECURITY_LEVEL=H WEB_ANALYTICS=0 EULA=1 REBOOT=0 SPONSORS=0
)

net stop JavaQuickStarterService > nul 2>&1
sc delete JavaQuickStarterService > nul 2>&1
msiexec /x {4A03706F-666A-4037-7777-5F2748764D10} /qn > nul 2>&1

endlocal