﻿$ErrorActionPreference = "Stop"
$user= Import-CSV .\credentials\*.csv
$bucket="edn-production"
$region="us-east-1"

# replace the sample fields in the below information with the correct values
$serverList="service.edatanow.com" #separate desired servers with a comma
$language="en"
$processPath=".\bin\Process.exe"
$failurePath=".\bin\Failure.exe"
$useFailureHook="False" 
$finishPath=".\bin\Finish.exe"
$useFinishHook="False"

#Email for failure_hook
$From = "user@domain.com"
$To = "dapr.noreply@gmail.com"
$Cc = "YourBoss@YourDomain.com"
$Subject = "Email Subject"
$Body = "Insert body text here"
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"