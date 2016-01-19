#requires -version 3
param([string]$CSVPath, [string]$RemoteServer, [string]$Language)

# Modify the code below to suit your needs

&$ProcessPath $CSVPath $RemoteServer $Language
