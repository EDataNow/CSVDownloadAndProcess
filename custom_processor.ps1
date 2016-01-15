#requires -version 5
param([string]$csvpath, [string]$remoteServer, [string]$language)

# Modify the code below to suit your needs

$processor = ".\bin\Win32ConsoleApplication.exe"

&$processor $csvpath $remoteServer $language
