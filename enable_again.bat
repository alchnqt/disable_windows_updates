@echo off
setlocal

:: Check for admin privileges
if not "%1"=="admin" (
    powershell start -verb runas '%0' admin & exit /b
)
if not "%2"=="system" (
    powershell . '%~dp0\PsExec.exe' /accepteula -i -s -d '%0' admin system & exit /b
)

:: Configure services to start automatically
set services=wuauserv UsoSvc uhssvc
for %%s in (%services%) do (
    sc config %%s start= auto
)

:: Configure WaaSMedicSvc to start with delay
sc config WaaSMedicSvc start= delayed-auto

:: Restore WaaSMedicSvc DLL
set dll_path=C:\Windows\System32
set dll_name=WaaSMedicSvc
takeown /f %dll_path%\%dll_name%_BAK.dll
icacls %dll_path%\%dll_name%_BAK.dll /grant *S-1-1-0:F
rename %dll_path%\%dll_name%_BAK.dll %dll_name%.dll
icacls %dll_path%\%dll_name%.dll /setowner "NT SERVICE\TrustedInstaller"
icacls %dll_path%\%dll_name%.dll /remove *S-1-1-0

:: Update registry settings
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v FailureActions /t REG_BINARY /d 840300000000000000000000030000001400000001000000c0d4010001000000e09304000000000000000000 /f
reg delete "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /f

:: Enable scheduled tasks
set task_paths=\
    \Microsoft\Windows\InstallService\* \
    \Microsoft\Windows\UpdateOrchestrator\* \
    \Microsoft\Windows\UpdateAssistant\* \
    \Microsoft\Windows\WaaSMedic\* \
    \Microsoft\Windows\WindowsUpdate\* \
    \Microsoft\WindowsUpdate\*

for %%t in (%task_paths%) do (
    powershell -command "Get-ScheduledTask -TaskPath '%%t' | Enable-ScheduledTask"
)

echo Finished
pause
endlocal