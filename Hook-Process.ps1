#requires -version 3
param([string]$CSVPath, [string]$RemoteServer, [string]$Language)

# Modify the code below to suit your needs
if ( -Not (Test-Path -Path "$($BaseDirectory)\csv\$($Server)\")){
    New-Item $BaseDirectory\csv\$($Server)\ -ItemType Directory 
}
&$ProcessPath $CSVPath $RemoteServer $Language