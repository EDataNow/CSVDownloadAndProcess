# CSV-DownloadAndProcess
This is a simple PowerShell script designed to download and process .csv files from Amazon S3. Downloaded files can be passed through a custom processing tool.

Requirements:
- PowerShell v3 or higher
- AWS Tool for Windows PowerShell [(download)](http://aws.amazon.com/powershell/)

Once you have downloaded this package, there are a few steps to get set up:
1. Run PowerShell as an administrator and navigate to the CSVDownloadAndProcess folder
1. Set the execution policy with the **Set-ExecutionPolicy AllSigned** command
    - Restricted - This is the default value, and prevents all scripts from being run. CSVDownloadAndProcess will not run with this setting.
    - RemoteSigned - Prevents unsigned scripts from being run unless they were created locally.
    - AllSigned (Recommended) - Prevents all unsigned scripts from being run.
    - Unrestricted - Allows any script to be run regardless of source, including potentially malicious code.
1. Use makecert.exe to sign all scripts to be run [(guide)](http://www.hanselman.com/blog/SigningPowerShellScripts.aspx).
    - I have provided a pre-signed script titled sign-script.ps1 that you can run to easily sign your scripts, using the command **powershell.exe -file ./sign-scripts.ps1** followed by the path to the script to be signed. Use this script on *sign-defaults.ps1* and then run it with powershell
1. Open config/config.ps1 and replace the sample fields with your information.  
    - serverList - servers you wish to pull .scv files from, separated by a comma
    - language - language to display .csv files in
    - reportEmail - email to receive failure notifications
    - processPath / failurePath / finishPath - see below
    - useFailureHook / useFinishHook - leave this false to bypass the corresponding hook

There are three points of interaction available: process, failure, and finish. Each has a corresponding *_hook.ps1 script which can invoke an external application provided by you. Paths to custom applications are set in /config/config.ps1.
- Process: Occurs once for each downloaded file, in roll-up order. Takes a .csv path, server, and language as arguments.
- Failure: Occurs only when an application invoked by Process throws an exception. Takes a .csv path, date/time, and error information as arguments. 
- Finish: Occurs once all downloaded .csv files have been passed to the Process application. Takes date/time as an argument.