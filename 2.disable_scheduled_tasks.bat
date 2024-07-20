if not "%1"=="admin" (powershell start -verb runas '%0' admin & exit /b)
if not "%2"=="system" (powershell . '%~dp0\PsExec.exe' /accepteula -i -s -d '%0' admin system & exit /b)

powershell -command "Get-ScheduledTask -TaskPath '\Microsoft\Windows\InstallService\*' | Disable-ScheduledTask; 
powershell -command "Get-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\*' | Disable-ScheduledTask;"
powershell -command "Get-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateAssistant\*' | Disable-ScheduledTask;"
powershell -command "Get-ScheduledTask -TaskPath '\Microsoft\Windows\WaaSMedic\*' | Disable-ScheduledTask;"
powershell -command "Get-ScheduledTask -TaskPath '\Microsoft\Windows\WindowsUpdate\*' | Disable-ScheduledTask;"
powershell -command "Get-ScheduledTask -TaskPath '\Microsoft\WindowsUpdate\*' | Disable-ScheduledTask"