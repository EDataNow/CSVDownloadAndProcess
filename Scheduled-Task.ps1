$BaseDirectory = $PSScriptRoot
$filePath = "$($BaseDirectory)\DAPr-CSV.ps1"
$log = "$($BaseDirectory)\ScheduledTaskLogs\log.log"
$nextHour = (Get-Date).AddHours(1).AddMinutes(-(Get-Date -UFormat "%M")+15).AddSeconds(-(Get-Date -UFormat "%S"))

"EDataNow_CSV_Sync ScheduledTask Started at $(Get-Date)" | Out-File -filepath $log -Append
& $filePath
"EDataNow_CSV_Sync ScheduledTask Ended at $(Get-Date): Next backup sync's at $($nextHour)" | Out-File -filepath $log -Append
