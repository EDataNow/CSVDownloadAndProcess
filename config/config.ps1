$ErrorActionPreference = "Stop"
$User= Import-CSV .\credentials\*.csv
$Region="us-east-1"

if (-Not (Test-Path -Path ".\credentials\ReportingEmail.txt")){
    Write-Host "Please enter a password for the reporting email." -ForegroundColor Cyan
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File ".\credentials\ReportingEmail.txt"
}

# replace the sample fields in the below information with the correct values
$ServerList="service-uat.edatanow.com" #separate desired servers with a comma
$Language="en"
$ProcessPath=".\bin\Win32ConsoleApplication.exe"
$FailurePath=".\bin\Failure.exe"
$UseFailureHook=0
$FailureEmail=0
$FinishPath=".\bin\Finish.exe"
$UseFinishHook=0
$FinishEmail=0

#Email for failure_hook and finish_hook
$To = "recipient@email.com"
$From="reportsource@email.com"
$Cc = "CCTarget@email.com"
$FailSubject = "Email Subject"
$FinishSubject = "Email Subject"
$FailBody = "Insert Failure body text here"
$FinishBody = "Insert Finish body text here"
$Password= Get-Content ".\credentials\ReportingEmail.txt" | ConvertTo-SecureString
$EmailSender=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $From, $Password
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"