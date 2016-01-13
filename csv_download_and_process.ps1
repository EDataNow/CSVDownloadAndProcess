#requires -version 5
. ./config/config.ps1
. ./functions.ps1

$keyPrefix = "{0}/{1}/csv/{2}/" -f $user."User Name",$server,$language 
 
try {
  $remoteCollection = Get-S3Object -BucketName $bucket -KeyPrefix $keyPrefix -AccessKey $user."Access Key Id" -SecretKey $user."Secret Access Key" -Region $region | Sort-Object ("Key" | Split-Path -leaf)
}
catch {
  $status = (new-object -com wscript.shell).run("https://aws.amazon.com/powershell/",3); Write-Host "These scripts require AWSPowerShell. Please visit https://aws.amazon.com/powershell/ to download the latest version.  Please install, reboot, and try again." -ForegroundColor Red; Exit
}
Recreate-Folders
$localCollection = Get-ChildItem ".\servers\$($server)\Processed\*" -Recurse 
Check-Incoming

Download-NewFiles
Process-NewFiles
Write-Host "Operation completed at $(Get-Date)." -ForegroundColor Cyan  