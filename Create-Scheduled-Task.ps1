#requires -version 3
$BaseDirectory = $PSScriptRoot
Set-Location -Path $PSScriptRoot
. $BaseDirectory\config\config.ps1

$TaskName = "EDataNow_CSV_Sync"
$TaskDescription = "Hourly CSV bucket pull and update."
$TaskAuthor = "E-Data Now"
$TaskServer = $env:computername
$TaskUsername = "Admin"
$TaskFilePath = "$($BaseDirectory)\Scheduled-Task.ps1"

if (!(Test-Path -Path "$($UserDirectory)ScheduledTask.txt")){
    Write-Host "Please enter `"$($TaskUsername)'s`" password for the task setup." -ForegroundColor Cyan
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File "$($UserDirectory)ScheduledTask.txt"
}
$TaskPassword= Get-Content "$($UserDirectory)ScheduledTask.txt" | ConvertTo-SecureString
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $TaskUsername, $TaskPassword
$Password = $Credentials.GetNetworkCredential().Password 

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
$trigger =  New-ScheduledTaskTrigger -Once -At $nextHour -RepetitionInterval (New-TimeSpan -Hours 1)

Register-ScheduledTask -Action $action -Trigger $trigger -Settings $setting -TaskName $TaskName -Description $TaskDescription -User $TaskUsername -Password $Password -RunLevel Highest

function WaitOnScheduledTask($TaskServer = $(throw "Server is required."), $TaskName = $(throw "Task is required."), $maxSeconds = 5000)
{
    $startTime = get-date
    $initialDelay = 3
    $intervalDelay = 10

    Write-Output "Starting task '$TaskName' on '$TaskServer'. Please wait..."
    schtasks /run /s $TaskServer /TN $TaskName
 
    # wait a tick before checking the first time, otherwise it may still be at ready, never transitioned to running
    Write-Output "One moment..."
    start-sleep -s $initialDelay
    $timeout = $false
 
    while ($true)
    {
        $ts = New-TimeSpan $startTime $(get-date)
         
        # this whole csv thing is hacky but one workaround I found for server 2003
        $tempFile = Join-Path $env:temp "SchTasksTemp.csv"
        schtasks /Query /FO CSV /s $TaskServer /TN $TaskName /v > $tempFile
 
        $taskData = Import-Csv $tempFile
        $status = $taskData.Status
         
        if($status.tostring() -eq "Running")
        {
            $status = ((get-date).ToString("hh:MM:ss tt") + " Still running '$TaskName' on '$TaskServer'...")
            Write-Progress -activity $TaskName -status $status -percentComplete -1 #-currentOperation "Waiting for completion status"
            Write-Output $status
        }
        else
        {
            break
        }
 
        start-sleep -s $intervalDelay  
         
        if ($ts.TotalSeconds -gt $maxSeconds)
        {
            $timeout = $true
            Write-Output "Taking longer than max wait time of $maxSeconds seconds, giving up all hope. Task execution continues but I'm peacing out."
            break
        }
    }
 
    if (-not $timeout)
    {
        $ts = New-TimeSpan $startTime $(get-date)
        "Scheduled task '{0}' on '{1}' complete in {2:###} seconds" -f $TaskName, $TaskServer, $ts.TotalSeconds
    }
}
WaitOnScheduledTask $TaskServer $TaskName

$msg = "$($TaskName) ScheduledTask added at $(Get-Date) - First backup sync's at $($nextHour)"
$msg | Out-File -filepath $log -Append
Write-Output $msg

<#Remove
Unregister-ScheduledTask $task
#>