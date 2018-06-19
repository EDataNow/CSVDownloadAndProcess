$BaseDirectory = $PSScriptRoot
$task = "GetDataFromBucket"
$description = "Hourly CSV bucket pull and database update."
$server= $env:computername
$user= "derek"
$pass= "nevermind"
$filePath = "$($BaseDirectory)\Scheduled-Task.ps1"

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
   Write-Host "Created new file and text content added"
}

$option = New-ScheduledJobOption -RunElevated -RequireNetwork
$nextHour = (Get-Date).AddHours(1).AddMinutes(-(Get-Date -UFormat "%M")+15).AddSeconds(-(Get-Date -UFormat "%S"))
$argument = "-NoProfile -WindowStyle Hidden -command `"& '$($filePath)'`""
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $argument
$trigger =  New-ScheduledTaskTrigger -Once -At $nextHour -RepetitionInterval (New-TimeSpan -Hours 1)

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $task -Description $description -User $user -Password $pass -RunLevel Highest 

function WaitOnScheduledTask($server = $(throw "Server is required."), $task = $(throw "Task is required."), $maxSeconds = 5000)
{
    $startTime = get-date
    $initialDelay = 3
    $intervalDelay = 10
     
    Write-Output "Starting task '$task' on '$server'. Please wait..."
    schtasks /run /s $server /TN $task
 
    # wait a tick before checking the first time, otherwise it may still be at ready, never transitioned to running
    Write-Output "One moment..."
    start-sleep -s $initialDelay
    $timeout = $false
 
    while ($true)
    {
        $ts = New-TimeSpan $startTime $(get-date)
         
        # this whole csv thing is hacky but one workaround I found for server 2003
        $tempFile = Join-Path $env:temp "SchTasksTemp.csv"
        schtasks /Query /FO CSV /s $server /TN $task /v > $tempFile
 
        $taskData = Import-Csv $tempFile
        $status = $taskData.Status
         
        if($status.tostring() -eq "Running")
        {
            $status = ((get-date).ToString("hh:MM:ss tt") + " Still running '$task' on '$server'...")
            Write-Progress -activity $task -status $status -percentComplete -1 #-currentOperation "Waiting for completion status"
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
        "Scheduled task '{0}' on '{1}' complete in {2:###} seconds" -f $task, $server, $ts.TotalSeconds
    }
}
WaitOnScheduledTask $server $task

$msg = "GetDataFromBucket ScheduledTask Job added at $(Get-Date): First backup sync's at $($nextHour)"
$msg | Out-File -filepath $log -Append
Write-Output $msg

<#Remove
Unregister-ScheduledTask $task
#>