@@ -23,9 +23,16 @@ $ErrorActionPreference = "Stop"
$User= Import-CSV $BaseDirectory\credentials\*.csv
$Region="us-east-1"

if (-Not (Test-Path -Path "$($BaseDirectory)\credentials\ReportingEmail.txt")){
$UserDirectory = "$($env:UserDomain)_$($env:UserName)" -replace '[<>:"/\\|?*]','-'
$UserDirectory = "$($BaseDirectory)\credentials\$($UserDirectory)\"

if(!(Test-Path -Path "$($UserDirectory )")){
    New-Item -ItemType directory -Path "$($UserDirectory)"
}

if (!(Test-Path -Path "$($UserDirectory)ReportingEmail.txt")){
    Write-Host "Please enter a password for the reporting email." -ForegroundColor Cyan
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File "$($BaseDirectory)\credentials\ReportingEmail.txt"
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File "$($UserDirectory)ReportingEmail.txt"
}

# replace the sample fields in the below information with the correct values
@ -47,7 +54,7 @@ $FailSubject="Email Subject"
$FinishSubject="Email Subject"
$FailBody="Insert Failure body text here"
$FinishBody="Insert Finish body text here"
$EmailPassword= Get-Content "$($BaseDirectory)\credentials\ReportingEmail.txt" | ConvertTo-SecureString
$EmailPassword= Get-Content "$($UserDirectory)ReportingEmail.txt" | ConvertTo-SecureString
$EmailSender= New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $From, $EmailPassword
$SMTPServer="smtp.gmail.com"
$SMTPPort="587"
@ -67,13 +74,19 @@ $DBConn.ConnectionString = "Server=$DBServer;Database=$Database;Integrated Secur
or
```
#Database Connection
if (!(Test-Path -Path "$($UserDirectory)SQLServer.txt")){
    Write-Host "Please enter a password for the sql Server." -ForegroundColor Cyan
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File "$($UserDirectory)SQLServer.txt"
}
$DBServer="SERVER_NAME"
$Database="S_CSV"
$DBUserID="username"
$DBPassword="password"
$DBPassword= Get-Content "$($UserDirectory)SQLServer.txt" | ConvertTo-SecureString
$DBPassword.MakeReadOnly()

$DBConn = New-Object System.Data.SqlClient.SqlConnection
$DBConn.ConnectionString = "Server=$DBServer;Database=$Database;User ID=$DBUserID;Password=$DBPassword"
$DBConn.Credential = New-Object System.Data.SqlClient.SqlCredential($DBUserID,$DBPassword)
$DBConn.ConnectionString = "Server=$DBServer;Database=$Database"
```

### Hook-Process.ps1