# DAPr-CSV
**EDataNow** pushes csv reports hourly to S3.  This powershell script downloads all of the new CSV's from S3 and allows the end user to process each new csv file individually.

## Setup
- PowerShell v3 or higher
- AWS Tool for Windows PowerShell [(download)](http://aws.amazon.com/powershell/)
- git clone https://github.com/EDataNow/DaPr-CSVDownloadAndProcessForPowerShell
- Copy Credentials(IE: **3.csv**) into `./credentials`

## Developers Quick Start Setup
This is **dangerous** for Production Machines as any Powershell script can run
- Run `PowerShell` as Administrator
- `Set-ExecutionPolicy Unrestricted`
- Navigate to `CSVDownloadAndProcess`
- Create a `./config/config.ps1` with the information below.
  - Change `$ProcessPath="$($BaseDirectory)\bin\Win32ConsoleApplication.exe"` to your custom executable
  - Do the same for `$FinishPath` and `$FailurePath`, if necessary.
- Run the script with `powershell.exe .\DAPr-CSV.ps1 -EmailPassword "your password" -DBPassword "your password"` params are optional.
	- Optional Credentials params `-UserName "YOUR_USER_NAME" -AccessKeyId "YOUR_ACCESS_KEY_ID" -SecretAccessKey "YOUR_SECRET_ACCESS_KEY" -ConsoleLoginLink "YOUR_CONSOLE_LOGIN_LINK"`. If you use one Credentials variable, you must include them all.
		- Additional Optional Credential params `-Region "us-east-1" -Server "service.edatanow.com" -Language "en" -Processor "./db_store.rb"` If not included uses defaults.

### config.ps1
```powershell
$ErrorActionPreference = "Stop"
$User= Import-CSV $BaseDirectory\credentials\*.csv
$Region="us-east-1"

$UserDirectory = "$($env:UserDomain)_$($env:UserName)" -replace '[<>:"/\\|?*]','-'
$UserDirectory = "$($BaseDirectory)\credentials\$($UserDirectory)\"

if(!(Test-Path -Path "$($UserDirectory )")){
    New-Item -ItemType directory -Path "$($UserDirectory)"
}

if (!(Test-Path -Path "$($UserDirectory)ReportingEmail.txt")){
    Write-Host "Please enter a password for the reporting email." -ForegroundColor Cyan
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File "$($UserDirectory)ReportingEmail.txt"
}

# replace the sample fields in the below information with the correct values
$ServerList="service.edatanow.com" #separate desired servers with a comma
$Language="en"
$ProcessPath="$($BaseDirectory)\Bin\Win32ConsoleApplication.exe"
$FailurePath="$($BaseDirectory)\Bin\Failure.exe"
$UseFailureHook=0
$FailureEmail=0
$FinishPath="$($BaseDirectory)\Upload-CSV.ps1"
$UseFinishHook=0
$FinishEmail=0

#Email for failure_hook
$To="recipient@email.com"
$From="reportsource@email.com"
$Cc="YourBoss@YourDomain.com"
$FailSubject="Email Subject"
$FinishSubject="Email Subject"
$FailBody="Insert Failure body text here"
$FinishBody="Insert Finish body text here"
$EmailPassword= Get-Content "$($UserDirectory)ReportingEmail.txt" | ConvertTo-SecureString
$EmailSender= New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $From, $EmailPassword
$SMTPServer="smtp.gmail.com"
$SMTPPort="587"
```

To use the included `Store-CSV_SQLServer.ps1` script to process the files into a local database, the `$ProcessPath` variable can be set to `$ProcessPath="$($BaseDirectory)\Store-CSV_SQLServer.ps1"`
The following must also be added and configured in the config.ps1 file:

```
#Windows Authentication Database Connection
$DBServer="SERVER_NAME"
$Database="S_CSV"

$DBConn = New-Object System.Data.SqlClient.SqlConnection
$DBConn.ConnectionString = "Server=$DBServer;Database=$Database;Integrated Security=True"
```
or
```
#SQLServer Authentication Database Connection
if (!(Test-Path -Path "$($UserDirectory)SQLServer.txt")){
    Write-Host "Please enter a password for the sql Server." -ForegroundColor Cyan
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File "$($UserDirectory)SQLServer.txt"
}
$DBServer="SERVER_NAME"
$Database="S_CSV"
$DBUserID="username"
$DBPassword= Get-Content "$($UserDirectory)SQLServer.txt" | ConvertTo-SecureString
$DBPassword.MakeReadOnly()

$DBConn = New-Object System.Data.SqlClient.SqlConnection
$DBConn.Credential = New-Object System.Data.SqlClient.SqlCredential($DBUserID,$DBPassword)
$DBConn.ConnectionString = "Server=$DBServer;Database=$Database"
```

### Create-Scheduled-Task

To use the included `Create-Scheduled-Task.ps1` script to process the files into a local database with a hourly task.
The following must be added to the bottom of `config.ps1` file, before running `Create-Scheduled-Task.ps1`.
```
#Task Information
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
```
### Hook-Process.ps1

```powershell
#requires -version 3
param([string]$CSVPath, [string]$RemoteServer, [string]$Language)

# Modify the code below to suit your needs

&$ProcessPath $CSVPath $RemoteServer $Language
```
## Custom Executable
The PowerShell script will pass 3 arguments to the executable that you may find useful.
- Full Path of the CSV
- Server Name, ``service.edatanow.com``
- Language

`./Win32ConsoleApplication/` contains a sample custom application that will build itself into the `$(BaseDirectory)/Bin/` folder when run. This directory is never touched during updates, and so the script can be freely modified or replaced. 
**NOTE:** The powershell script will halt at the Processing stage if no application is defined.

## Resetting the Script
- Delete anything from `$($BaseDirectory)/servers/{server-name}/Processed` and it will be redownloaded.
- Deleting all of `$($BaseDirectory)/servers/` content will force the script to redownload everything.

## config/Config.ps1
- `ServerList` - servers you wish to pull .scv files from, separated by a comma
- `Language` - language to display .csv files in
- `ReportEmail` - email to receive failure notifications
- `ProcessPath` / `FailurePath` / `FinishPath` - see below
- `UseFailureHook` / `UseFinishHook` - leave this false to bypass the corresponding hook

## Hooks for Developers to Extend
There are three points of interaction available: process, failure, and finish. Each has a corresponding Hook-*.ps1 script which can invoke an external application provided by you.
- Process: Occurs once for each downloaded file, in roll-up order. Takes a .csv path, server, and language as arguments.
- Failure: Occurs only when an application invoked by Process throws an exception. Takes a .csv path, date/time, and error information as arguments. 
- Finish: Occurs once all downloaded .csv files have been passed to the Process application. Takes date/time as an argument.

## Admin/Production Setup
- Run `PowerShell` as Administrator
- `Set-ExecutionPolicy AllSigned`
- Navigate to `CSVDownloadAndProcess`
- Use makecert.exe to sign all scripts to be run     [(guide)](http://www.hanselman.com/blog/SigningPowerShellScripts.aspx).
    -  Pre-signed script titled *Sign-Script.ps1* can be used to sign your scripts, using the command **powershell.exe -file .\Sign-Scripts.ps1** followed by the path to the script to be signed. Use this script on *Sign-DefaultScripts.ps1* and then run *Sign-DefaultScripts.ps1* with **powershell.exe -file .\Sign-DefaultScripts**

## Changelog
- 13.Apr.2016: **S3 Folder Structure Changes**
	- Bucket is now customer specific; determined by credentials file
	- Paths modified to match new structure
	- No functional changes to any scripts/config

