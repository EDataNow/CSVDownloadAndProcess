#requires -version 5
. ./config/config.ps1
. ./functions.ps1

Check-AWSPresence
Set-AWSCredentials -AccessKey $user."Access Key Id" -SecretKey $user."Secret Access Key" -StoreAs $user."User Name"

foreach ($server in $serverList){
    $keyPrefix = "{0}/{1}/csv/{2}/" -f $user."User Name",$server,$language 
    $remoteCollection = Get-S3Object -BucketName $bucket -KeyPrefix $keyPrefix -ProfileName $user."User Name" -Region $region
    Recreate-Folders
    $localCollection = Get-ChildItem ".\servers\$($server)\Processed\*" -Recurse
    $localCollection += Get-ChildItem ".\servers\$($server)\Incoming\*" -Recurse
    Check-Incoming

    Download-NewFiles
    Process-NewFiles
    
}

Write-Host "Operation completed at $(Get-Date)." -ForegroundColor Cyan  