@echo off
setlocal

:: Check for admin privileges
if not "%1"=="admin" (
    powershell start -verb runas '%0' admin & exit /b
)
if not "%2"=="system" (
    powershell . '%~dp0\PsExec.exe' /accepteula -i -s -d '%0' admin system & exit /b
)

:: Define services to stop and disable
set services=wuauserv UsoSvc uhssvc WaaSMedicSvc

:: Stop and disable services
for %%i in (%services%) do (
    net stop %%i
    sc config %%i start= disabled
    sc failure %%i reset= 0 actions= ""
)

:: Define DLL path
set dll_path=C:\Windows\System32

:: Rename WaaSMedicSvc DLL
set dll_name=WaaSMedicSvc
takeown /f %dll_path%\%dll_name%.dll
icacls %dll_path%\%dll_name%.dll /grant *S-1-1-0:F
rename %dll_path%\%dll_name%.dll %dll_name%_BAK.dll
icacls %dll_path%\%dll_name%_BAK.dll /setowner "NT SERVICE\TrustedInstaller"
icacls %dll_path%\%dll_name%_BAK.dll /remove *S-1-1-0

:: Update registry settings
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v FailureActions /t REG_BINARY /d 000000000000000000000000030000001400000000000000c0d4010000000000e09304000000000000000000 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f

:: Delete software distribution folder
erase /f /s /q c:\windows\softwaredistribution\*.*
rmdir /s /q c:\windows\softwaredistribution

echo Finished
pause
endlocal