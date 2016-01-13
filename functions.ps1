  
function Check-Incoming {
    Get-ChildItem .\servers\$($server)\Incoming\ | ForEach {
        if (Test-Path -Path ".\servers\$($server)\Incoming\$($_.Name)\*"){
            Write-Warning "Unrecognized File in Incoming folder."
            Remove-Item ".\servers\$($server)\Incoming\$($_.Name)\*"     
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
		    Copy-S3Object -BucketName $bucket -Key $object.Key -LocalFile $localFilePath -AccessKey $user.'Access Key Id' -SecretKey $user.'Secret Access Key' -Region $region
	    }
        else{
            Write-Verbose "File already downloaded: $($object.Key | Split-Path -leaf)" #-ForegroundColor Cyan
        }
    }
} # download missing files from remoteCollection

function Process-NewFiles {
    ForEach ($file in (Get-ChildItem ".\servers\$($server)\Incoming\*" -Recurse) ){
        $currentFilePath = (($file.DirectoryName, "\", $file.Name) -join '')
        $newFilePath = (".\servers\$($server)\Processed\", ($file.DirectoryName | Split-Path -leaf), "\") -join ''
        Invoke-Expression (".\custom_processor.ps1 -csvpath {0} -language {1} -remoteServer {2}" -f $currentFilePath,$language,$server)
        Move-Item $file $newFilePath -Force 
    }
} # Process files, move to new location