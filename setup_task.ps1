# PowerShell script to set up Task Scheduler to update sunrise/sunset times on logon and unlock

$taskName = "UpdateSunsetSchedule"
$scriptPath = "update_scheduler.ps1"

# Define the trigger for logon (runs when the user logs in)
$logonTrigger = New-ScheduledTaskTrigger -AtLogOn

# Define the trigger for unlocking the workstation (runs when the user unlocks the laptop)
$unlockTrigger = New-ScheduledTaskTrigger -AtWorkStationUnlock

# Create the action to run the PowerShell script
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

# Create the scheduled task for the current user (no admin needed)
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Limited

# Register the task
Register-ScheduledTask -TaskName $taskName -Trigger $logonTrigger, $unlockTrigger -Action $action -Principal $principal -Description "Updates sunrise/sunset schedule on logon and unlock." -Force

Write-Output "Scheduled task '$taskName' has been created successfully!"