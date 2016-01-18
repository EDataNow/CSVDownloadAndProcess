#requires -version 3
param([string]$csvpath, [string]$errorInfo, [DateTime]$failTime)

$fileName = $csvpath | Split-Path -leaf

# Modify the code below to suit your needs

$errorInfo | Out-File ".\logs\$($fileName).log"
$Attachment = ".\logs\$($fileName).log"

Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject `
-Body $Body -Attachments $Attachment -SmtpServer $SMTPServer  `
-port $SMTPPort -UseSsl -Credential (Get-Credential) 

if ($useFailureHook){ 
    &$failurePath $csvpath $errorInfo $failTime
}