@echo off
setlocal

:: Check for admin privileges
if not "%1"=="admin" (
    powershell start -verb runas '%0' admin & exit /b
)
if not "%2"=="system" (
    powershell . '%~dp0\PsExec.exe' /accepteula -i -s -d '%0' admin system & exit /b
)

:: Define task paths
set task_paths=\
    \Microsoft\Windows\InstallService\* \
    \Microsoft\Windows\UpdateOrchestrator\* \
    \Microsoft\Windows\UpdateAssistant\* \
    \Microsoft\Windows\WaaSMedic\* \
    \Microsoft\Windows\WindowsUpdate\* \
    \Microsoft\WindowsUpdate\*

:: Disable scheduled tasks
for %%t in (%task_paths%) do (
    powershell -command "Get-ScheduledTask -TaskPath '%%t' | Disable-ScheduledTask"
)

echo Finished
pause
endlocal