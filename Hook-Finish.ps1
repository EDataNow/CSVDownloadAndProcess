#requires -version 3
param([DateTime]$TimeFinished)

# Modify the code below to suit your needs

if ($FinishEmail){
    Send-MailMessage -From $From -to $To -Cc $Cc -Subject $FinishSubject `
        -Body $FinishBody -SmtpServer $SMTPServer  `
        -port $SMTPPort -UseSsl -Credential $EmailSender 
}

if ($UseFinishHook){
    &$FinishPath $TimeFinished
}