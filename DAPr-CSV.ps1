#requires -version 3
. .\config\config.ps1
. .\Functions.ps1

Check-AWSPresence
Set-AWSCredentials -AccessKey $User."Access Key Id" -SecretKey $User."Secret Access Key" -StoreAs $User."User Name"

foreach ($Server in $ServerList){
    $Bucket="{0}-{1}" -f $User."User Name",$Server.replace('.edatanow.com','-edatanow-com')
    $KeyPrefix = "v1/csv/$Language/" 
    $RemoteCollection = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -ProfileName $User."User Name" -Region $Region | Where-Object { $_.size –ne 0 }
    Recreate-Folders
    $LocalCollection = Get-ChildItem ".\servers\$($Server)\*" -Recurse
    Check-Incoming

    Download-NewFiles -Bucket $Bucket
    Process-NewFiles
}

Write-Host "Operation completed at $(Get-Date)." -ForegroundColor Cyan