# DAPr-CSV
**EDataNow** pushes csv reports hourly to S3.  This powershell script downloads all of the new CSV's from S3 and allows the end user to process each new csv file individually.

## Setup
- PowerShell v3 or higher
- AWS Tool for Windows PowerShell [(download)](http://aws.amazon.com/powershell/)
- git clone git@github.com:EDataNow/CSVDownloadAndProcess.git
- Copy Credentials(IE: **50.csv**) into `./credentials`

## Developers Quick Start Setup
This is **dangerous** for Production Machines as any Powershell script can run
- Run `PowerShell` as Administrator
- `Set-ExecutionPolicy Unrestricted`
- Navigate to `CSVDownloadAndProcess`
- Edit `./config/config.ps1` change `$ProcessPath=".\bin\Win32ConsoleApplication.exe"` to your custom executable.
- Run the script, `powershell -file .\DAPr-CSV.ps1`

### config.ps1
```powershell
$ErrorActionPreference = "Stop"
$User= Import-CSV .\credentials\*.csv
$Bucket="edn-production"
$Region="us-east-1"

# replace the sample fields in the below information with the correct values
$ServerList="service.edatanow.com" #separate desired servers with a comma
$Language="en"
$ProcessPath=".\bin\Win32ConsoleApplication.exe"
$FailurePath=".\bin\Failure.exe"
$UseFailureHook=0
$FinishPath=".\bin\Finish.exe"
$UseFinishHook=0

#Email for failure_hook
$From = "user@domain.com"
$To = "dapr.noreply@gmail.com"
$Cc = "YourBoss@YourDomain.com"
$Subject = "Email Subject"
$Body = "Insert body text here"
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"
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

`./Win32ConsoleApplication/` contains a sample custom application.

## Resetting the Script
- Delete anything from `./servers/{server-name}/Processed` and it will be redownloaded.
- Deleting all of `./servers/` content will force the script to redownload everything.

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

