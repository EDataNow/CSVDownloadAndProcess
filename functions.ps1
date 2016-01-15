function Check-AWSPresence {
    try {
        Get-AWSRegion *>$null
    }
    catch {
        $status = (new-object -com wscript.shell).run("https://aws.amazon.com/powershell/",3)
        Write-Host "These scripts require AWSPowerShell." -ForegroundColor Red
        Write-Host "Please visit https://aws.amazon.com/powershell/ to download the latest version. Install, reboot, and try again." -ForegroundColor Red
        Break
    }
}# ensure AWS is installed

function Check-Incoming {
    Get-ChildItem .\servers\$($server)\Incoming\ | ForEach {
        if (Test-Path -Path ".\servers\$($server)\Incoming\$($_.Name)\*"){
            Write-Warning "Incoming\$($_.Name)\ contains unprocessed or unrecognized files."
            #Remove-Item ".\servers\$($server)\Incoming\$($_.Name)\*"     
        }
    } 
}# check Incoming folder for old files, raise warning

function Recreate-Folders {
    ForEach ($folder in (Split-Path (Split-Path $remoteCollection.Key -Parent) -Leaf | Sort-Object | Get-Unique)){
        if ( -Not (Test-Path -Path ".\servers\$($server)\Processed\$($folder)\")){
            New-Item .\servers\$($server)\Processed\$($folder) -ItemType Directory 
        }
        if ( -Not (Test-Path -Path ".\servers\$($server)\Incoming\$($folder)\")){
            New-Item .\servers\$($server)\Incoming\$($folder) -ItemType Directory 
        }
    }
} # recreate  folders if absent

function Download-NewFiles {
    ForEach ($object in $remoteCollection) {
	    $localFileName = $object.Key -replace $keyPrefix, ''
	    if ( ($localFileName -ne '') -and (($localCollection | Split-Path -leaf) -notcontains ($object.Key | Split-Path -leaf) ) ) {
            $localFilePath = Join-Path ".\servers\$($server)\Incoming\" $localFileName
		    Copy-S3Object -BucketName $bucket -Key $object.Key -LocalFile $localFilePath `
            -AccessKey $user.'Access Key Id' -SecretKey $user.'Secret Access Key' -Region $region
	    }
        else{
            Write-Verbose "File already downloaded: $($object.Key | Split-Path -leaf)" #-ForegroundColor Cyan
        }
    }
} # download missing files from remoteCollection


function Process-NewFiles {
    $processHook = ".\processor_hook.ps1"
    $failureHook = ".\failure_hook.ps1"
    $finishHook = ".\finish_hook.ps1"
    $rollUp = Get-ChildItem ".\servers\$($server)\Incoming\*" -Recurse | Sort-Object $file.Name
    ForEach ($file in $rollUp){
        $currentFilePath = (($file.DirectoryName, "\", $file.Name) -join '')
        $newFilePath = (".\servers\$($server)\Processed\", ($file.DirectoryName | Split-Path -leaf), "\") -join ''
        try {
            $err = &$processHook $currentFilePath $server $language 2>&1
            if ($LASTEXITCODE -ne 0) {throw $err}
        }
        catch {
            &$failureHook $currentFilePath $err (Get-Date)
            Break
        }
        Move-Item $file $newFilePath -Force 
    }
    &$finishHook (Get-Date)
} # Process files, move to new location
