param(
    [string]$EmailPassword = $null,
    [string]$DBPassword = $null,
    [string]$UserName = $null,
    [string]$AccessKeyId = $null,
    [string]$SecretAccessKey = $null,
    [string]$Region = $null,
    [string]$Server = $null,
    [string]$Language = $null)
#requires -version 3
$BaseDirectory = $PSScriptRoot
Set-Location -Path $PSScriptRoot
. $BaseDirectory\Functions.ps1

$UserDirectory = "$($env:UserDomain)_$($env:UserName)" -replace '[<>:"/\\|?*]','-'
$UserDirectory = "$($BaseDirectory)\credentials\$($UserDirectory)\"

Create-Directory-If-Doesnt-Exist -Directory $UserDirectory

if ($DBPassword) {
    ConvertTo-SecureString -String $DBPassword -AsPlainText -Force | ConvertFrom-SecureString | Out-File "$($UserDirectory)SQLServer.txt"
}
if ($EmailPassword) {
    ConvertTo-SecureString -String $EmailPassword -AsPlainText -Force | ConvertFrom-SecureString | Out-File "$($UserDirectory)ReportingEmail.txt"
}

if ($UserName -and $AccessKeyId -and $SecretAccessKey) {
    if (!$Region) { $Region = "us-east-1" }
    if (!$Server) { $Server = "service.edatanow.com" }
    if (!$Language) { $Language = "en" }

    Clean-Credentials

    "User Name,Access Key Id,Secret Access Key,Region,Server,Language" | Out-File "$($BaseDirectory)\credentials\config.csv"
    "$UserName,$AccessKeyId,$SecretAccessKey,$Region,$Server,$Language" | Out-File "$($BaseDirectory)\credentials\config.csv" -Append

}
elseif ($UserName -or $AccessKeyId -or $SecretAccessKey) {
    'UserName, AccessKeyId, and SecretAccessKey are Required Together.' | Write-Host -ForegroundColor Yellow -ErrorAction Continue
    Break
}

Remove-Variable EmailPassword, DBPassword, UserName, AccessKeyId, SecretAccessKey, Region, Server, Language

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