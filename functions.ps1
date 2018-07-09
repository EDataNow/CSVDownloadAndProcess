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
    Get-ChildItem $BaseDirectory\servers\$($Server)\Incoming\ | ForEach {
        if (Test-Path -Path "$($BaseDirectory)\servers\$($Server)\Incoming\$($_.Name)\*"){
            Write-Warning "Incoming\$($_.Name)\ contains unprocessed or unrecognized files."
            #Remove-Item "$($BaseDirectory)\servers\$($Server)\Incoming\$($_.Name)\*"     
        }
    } 
}# check Incoming folder for old files, raise warning

function Recreate-Folders {
    ForEach ($folder in (Split-Path (Split-Path $remoteCollection.Key -Parent) -Leaf | Sort-Object | Get-Unique)){
        if ( -Not (Test-Path -Path "$($BaseDirectory)\servers\$($Server)\Processed\$($folder)\")){
            New-Item $BaseDirectory\servers\$($Server)\Processed\$($folder) -ItemType Directory 
        }
        if ( -Not (Test-Path -Path "$($BaseDirectory)\servers\$($Server)\Incoming\$($folder)\")){
            New-Item $BaseDirectory\servers\$($Server)\Incoming\$($folder) -ItemType Directory 
        }
    }
} # recreate  folders if absent

function Download-NewFiles {
    param([string]$Bucket)
    $fileList = $LocalCollection | Split-Path -leaf -ErrorAction SilentlyContinue
    ForEach ($object in $RemoteCollection) {
	    $localFileName = $object.Key -replace $keyPrefix, ''
	    if ( ($localFileName -ne '') -and ($fileList -notcontains ($object.Key | Split-Path -leaf) ) ) {
            $localFilePath = Join-Path "$($BaseDirectory)\servers\$($Server)\Incoming\" $localFileName
		    Copy-S3Object -BucketName $Bucket -Key $object.Key -LocalFile $localFilePath `
            -AccessKey $user.'Access Key Id' -SecretKey $user.'Secret Access Key' -Region $region
	    }
        else{
            Write-Verbose "File already downloaded: $($object.Key | Split-Path -leaf)" #-ForegroundColor Cyan
        }
    }
} # download missing files from remoteCollection


function Process-NewFiles {
    $processHook = "$($BaseDirectory)\Hook-Process.ps1"
    $failureHook = "$($BaseDirectory)\Hook-Failure.ps1"
    $finishHook = "$($BaseDirectory)\Hook-Finish.ps1"
    $rollUp = Get-ChildItem "$($BaseDirectory)\servers\$($Server)\Incoming\*" -Recurse | Sort-Object Name
    ForEach ($file in $rollUp){
        $currentFilePath = (($file.DirectoryName, "\", $file.Name) -join '')
        $newFilePath = ("$($BaseDirectory)\servers\$($Server)\Processed\", ($file.DirectoryName | Split-Path -leaf), "\") -join ''
        try {
            $applicationResult = &$processHook $currentFilePath $Server $Language 2>&1
            if ($LASTEXITCODE -ne 0) {throw $err}
        }
        catch [System.Management.Automation.MethodInvocationException] {
            $Error[0].Exception.Message.Split(':')[1] | Write-Host -ForegroundColor Yellow 
            Write-Error "Error while processing file $($file.Name)" -ErrorAction Continue
            &$failureHook $currentFilePath $err (Get-Date)
            Break
        }
        catch {
            $Error[0] | Write-Host -ForegroundColor Yellow 
            #$Error[0].exception.GetType().fullname | Write-Host -ForegroundColor Yellow 
            Write-Error "Error while processing file $($file.Name)" -ErrorAction Continue
            &$failureHook $currentFilePath $err (Get-Date)
            Break
        }
        $applicationResult
        Move-Item $file $newFilePath -Force 
    }
    &$finishHook (Get-Date)
} # Process files, move to new location
