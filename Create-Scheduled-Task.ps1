#requires -version 3
$BaseDirectory = $PSScriptRoot
Set-Location -Path $PSScriptRoot
. $BaseDirectory\config\config.ps1

#Create folder
$ScheduledTaskLogsDir = "$($BaseDirectory)\ScheduledTaskLogs"
if(!(Test-Path -Path $ScheduledTaskLogsDir )){
    New-Item -ItemType directory -Path $ScheduledTaskLogsDir
}

#Create task
$log =  "$($ScheduledTaskLogsDir)\log.log"
if (!(Test-Path "$log"))
{
   New-Item -path $ScheduledTaskLogsDir -name log.log -type "file"
   Write-Host "Created new log file."
}

$nextHour = (Get-Date).AddHours(1).AddMinutes(-(Get-Date -UFormat "%M")+15).AddSeconds(-(Get-Date -UFormat "%S"))
$argument = "-NoProfile -WindowStyle Hidden -command `"& '$($filePath)'`""
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $argument
$setting = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -StartWhenAvailable
$trigger = New-ScheduledTaskTrigger -Once -At $nextHour -RepetitionInterval (New-TimeSpan -Hours 1)

Register-ScheduledTask -Action $action -Trigger $trigger -Settings $setting -TaskName $TaskName -Description $TaskDescription -User $TaskUsername -Password $Password -RunLevel Highest

$msg = "$($TaskName) ScheduledTask added at $(Get-Date) - First backup sync's at $($nextHour)"
$msg | Out-File -filepath $log -Append
Write-Output $msg

<# Remove
Unregister-ScheduledTask $task
#>