param(
    [string]$EmailPassword = $null,
    [string]$DBPassword = $null,
    [string]$UserName = $null,
    [string]$AccessKeyId = $null,
    [string]$SecretAccessKey = $null,
    [string]$ConsoleLoginLink = $null,
    [string]$Region = $null,
    [string]$Server = $null,
    [string]$Language = $null,
    [string]$Processor = $null)
#requires -version 3
$BaseDirectory = $PSScriptRoot
Set-Location -Path $PSScriptRoot

if ($DBPassword) {
    ConvertTo-SecureString -String $DBPassword -AsPlainText -Force | ConvertFrom-SecureString | Out-File "$($UserDirectory)SQLServer.txt"
}
if ($EmailPassword) {
    ConvertTo-SecureString -String $EmailPassword -AsPlainText -Force | ConvertFrom-SecureString | Out-File "$($UserDirectory)ReportingEmail.txt"
}

if ($UserName -and $AccessKeyId -and $SecretAccessKey -and $ConsoleLoginLink) {
    if (!$Region) { $Region = "us-east-1" }
    if (!$Server) { $Server = "service.edatanow.com" }
    if (!$Language) { $Language = "en" }
    if (!$Processor) { $Processor = "./db_store.rb" }
    "User Name,Access Key Id,Secret Access Key,Console Login Link,Region,Server,Language,Processor" | Out-File "$($BaseDirectory)\credentials\config.csv"
    "$UserName,$AccessKeyId,$SecretAccessKey,$ConsoleLoginLink,$Region,$Server,$Language,$Processor" | Out-File "$($BaseDirectory)\credentials\config.csv" -Append
}
elseif ($UserName -or $AccessKeyId -or $SecretAccessKey -or $ConsoleLoginLink) {
    Write-Error 'UserName, AccessKeyId, SecretAccessKey, and ConsoleLoginLink are Required Together.' -ErrorAction Continue
    Break
}

Remove-Variable EmailPassword, DBPassword, UserName, AccessKeyId, SecretAccessKey, ConsoleLoginLink, Region, Server, Language, Processor

. $BaseDirectory\Functions.ps1
. $BaseDirectory\config\config.ps1

Check-AWSPresence
Set-AWSCredentials -AccessKey $User."Access Key Id" -SecretKey $User."Secret Access Key" -StoreAs $User."User Name"

foreach ($Server in $ServerList){
    $Bucket="private-{1}-{0}" -f $User."User Name",$Server.replace('.edatanow.com','-edatanow-com')
    $KeyPrefix = "csv-export/v1/$Language/" 
    $RemoteCollection = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -ProfileName $User."User Name" -Region $Region | Where-Object { $_.size –ne 0 }
    Recreate-Folders
    $LocalCollection = Get-ChildItem "$($BaseDirectory)\servers\$($Server)\*" -Recurse
    Check-Incoming

    Download-NewFiles -Bucket $Bucket
    Process-NewFiles
}

Write-Host "Operation completed at $(Get-Date)." -ForegroundColor Cyan