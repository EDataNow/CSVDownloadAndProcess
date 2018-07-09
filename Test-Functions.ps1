function Check-PesterPresence {
    if(!(Get-Module -ListAvailable -Name Pester)){
        Write-Host "Pester not found, trying to install"
        Install-Module -Name Pester -Force -SkipPublisherCheck
        if(!(Get-Module -ListAvailable -Name Pester)){
            Write-Host "Pester not found"
        }
    }
}