@echo off
if not exist %systemroot%\system32\psexec.exe xcopy /y "%~dp0psexec.exe" "%systemroot%\system32"
for /f "tokens=*" %%m in ('dir /b "%~dp0todo"') do (
echo processing %%~nm
if not exist "%~dp0skip\%%~nm.txt" (
if exist "\\%%~nm\c$" (
if not exist "\\%%~nm\c$\install" md "\\%%~nm\c$\install"
if exist "\\%%~nm\c$\install\jre" rd "\\%%~nm\c$\install\jre" /Q /S
if not exist "\\%%~nm\c$\install\jre" md "\\%%~nm\c$\install\jre"
xcopy /Y "%~dp0jre\*.*" "\\%%~nm\c$\install\jre"
%systemroot%\system32\psexec.exe /accepteula \\%%~nm c:\install\jre\force.cmd remove
) else echo %%~nm is offline
) else echo %%~nm is in whitelist
)
