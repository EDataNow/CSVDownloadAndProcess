#requires -version 3
. ./config/Config.ps1
. ./Functions.ps1

Check-AWSPresence
Set-AWSCredentials -AccessKey $User."Access Key Id" -SecretKey $User."Secret Access Key" -StoreAs $User."User Name"

foreach ($Server in $ServerList){
    $KeyPrefix = "{0}/{1}/csv/{2}/" -f $User."User Name",$Server,$Language 
    $RemoteCollection = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -ProfileName $User."User Name" -Region $Region
    Recreate-Folders
    $LocalCollection = Get-ChildItem ".\servers\$($Server)\*" -Recurse
    Check-Incoming

    Download-NewFiles
    Process-NewFiles
    
}

Write-Host "Operation completed at $(Get-Date)." -ForegroundColor Cyan  