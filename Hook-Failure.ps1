#requires -version 3
param([string]$CSVPath, [string]$ErrorInfo, [DateTime]$FailTime)

$fileName = $CSVPath | Split-Path -leaf

# Modify the code below to suit your needs

if ($UseFailureHook){
$errorInfo | Out-File ".\logs\$($fileName).log"
$attachment = ".\logs\$($fileName).log"

Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject `
-Body $Body -Attachments $attachment -SmtpServer $SMTPServer  `
-port $SMTPPort -UseSsl -Credential (Get-Credential) 

 
    &$FailurePath $CSVPath $errorInfo $FailTime
}