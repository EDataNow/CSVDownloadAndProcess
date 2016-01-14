#requires -version 5
param([string]$csvpath, [string]$remoteServer, [string]$language)

# Modify the code below to suit your needs

Invoke-Expression (".\bin\Win32ConsoleApplication.exe {0} {1} {2}"-f $csvpath, $remoteServer, $language)