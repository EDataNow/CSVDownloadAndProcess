#requires -version 3
param([string]$CSVPath, [string]$ErrorInfo, [DateTime]$FailTime)

$fileName = $CSVPath | Split-Path -leaf
$errorInfo | Out-File "$($BaseDirectory)\logs\$($fileName).log"

# Modify the code below to suit your needs

if ($FailureEmail){
    $attachment = "$($BaseDirectory)\logs\$($fileName).log"
    Send-MailMessage -From $From -to $To -Cc $Cc -Subject $FailSubject `
        -Body $FailBody -Attachments $attachment -SmtpServer $SMTPServer  `
        -port $SMTPPort -UseSsl -Credential $EmailSender 
}

if ($UseFailureHook){
 
    &$FailurePath $CSVPath $errorInfo $FailTime
}

