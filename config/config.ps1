$ErrorActionPreference = "Stop"
$User= Import-CSV .\credentials\*.csv
$Bucket="edn-production"
$Region="us-east-1"

# replace the sample fields in the below information with the correct values
$ServerList="service.edatanow.com" #separate desired servers with a comma
$Language="en"
$ProcessPath=".\bin\Win32ConsoleApplication.exe"
$FailurePath=".\bin\Failure.exe"
$UseFailureHook=0
$FinishPath=".\bin\Finish.exe"
$UseFinishHook=0

#Email for failure_hook
$From = "user@domain.com"
$To = "dapr.noreply@gmail.com"
$Cc = "YourBoss@YourDomain.com"
$Subject = "Email Subject"
$Body = "Insert body text here"
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"