$ErrorActionPreference = "Stop"
$User= Import-CSV .\credentials\*.csv
$Region="us-east-1"

if (-Not (Test-Path -Path ".\credentials\ReportingEmail.txt")){
    Write-Host "Please enter a password for the reporting email." -ForegroundColor Cyan
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File ".\credentials\ReportingEmail.txt"
}

# replace the sample fields in the below information with the correct values
$ServerList="service.edatanow.com" #separate desired servers with a comma
$Language="en"
#$ProcessPath=".\Store-CSV.ps1"
$ProcessPath=".\bin\Win32ConsoleApplication.exe"
$FailurePath=".\bin\Failure.exe"
$UseFailureHook=0
$FailureEmail=0
$FinishPath=".\Upload-CSV.ps1"
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
$EmailPassword = Get-Content ".\credentials\ReportingEmail.txt" | ConvertTo-SecureString
$EmailSender= New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $From, $EmailPassword
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"

# DB Connections and OneDrive
$DBServer='127.0.0.1'
$Port=5432
$DB='S_CSV'
$UID='Whapow'
if (-Not (Test-Path -Path ".\credentials\DatabaseCredentials.txt")){
    Write-Host "Please enter a password for the database." -ForegroundColor Cyan
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File ".\credentials\DatabaseCredentials.txt"
}
$DBPassword = Get-Content ".\credentials\DatabaseCredentials.txt" | ConvertTo-SecureString
$DBPassword = '5cal3sl337'
$DBConnectionString = "Server=$DBServer;Port=$Port;Database=$DB;Uid=$UID;Pwd=$DBPassword;Driver={PostgreSQL UNICODE(x64)}"
$DBConn = New-Object System.Data.Odbc.OdbcConnection;
$DBConn.ConnectionString = $DBConnectionString;

$OneDriveLocation = 'C:\Users\Whapow\Desktop\PowerShell\DAPr_CSV\OneDrive\Documents'
    #if ( -Not (Test-Path -Path "$($OneDriveLocation)\$($Server)\")){
    #    New-Item "$($OneDriveLocation)\$($Server)" -ItemType Directory 
    #}