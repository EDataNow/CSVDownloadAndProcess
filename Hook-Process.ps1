#requires -version 3
param([string]$CSVPath, [string]$RemoteServer, [string]$Language)

# Modify the code below to suit your needs
if ( -Not (Test-Path -Path ".\csv\$($Server)\")){
    New-Item .\csv\$($Server)\ -ItemType Directory 
}
&$ProcessPath $CSVPath $RemoteServer $Language