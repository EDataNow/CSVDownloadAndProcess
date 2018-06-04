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
- Run the script with `powershell.exe .\DAPr-CSV.ps1`

### config.ps1
```powershell
$ErrorActionPreference = "Stop"
$User= Import-CSV $BaseDirectory\credentials\*.csv
$Region="us-east-1"

if (-Not (Test-Path -Path "$($BaseDirectory)\credentials\ReportingEmail.txt")){
    Write-Host "Please enter a password for the reporting email." -ForegroundColor Cyan
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File "$($BaseDirectory)\credentials\ReportingEmail.txt"
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
$EmailPassword= Get-Content "$($BaseDirectory)\credentials\ReportingEmail.txt" | ConvertTo-SecureString
$EmailSender= New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $From, $EmailPassword
$SMTPServer="smtp.gmail.com"
$SMTPPort="587"
```

To use the included `Store-CSV_SQLServer.ps1` script to process the files into a local database, the `$ProcessPath` variable can be set to `$ProcessPath="$($BaseDirectory)\Store-CSV_SQLServer.ps1"`
The following must also be added to the config.ps1 file:

```
#Windows Authentication Database Connection
$DBServer="SERVER_NAME"
$Database="S_CSV"

$DBConn = New-Object System.Data.SqlClient.SqlConnection
$DBConn.ConnectionString = "Server=$DBServer;Database=$Database;Integrated Security=True"
```
or
```
#Database Connection
$DBServer="SERVER_NAME"
$Database="S_CSV"
$DBUserID="username"
$DBPassword="password"

$DBConn = New-Object System.Data.SqlClient.SqlConnection
$DBConn.ConnectionString = "Server=$DBServer;Database=$Database;User ID=$DBUserID;Password=$DBPassword"
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

`./Win32ConsoleApplication/` contains a sample custom application that will build itself into the `$(BaseDirectory)/bin/` folder when run. This directory is never touched during updates, and so the script can be freely modified or replaced. 
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

