# DAPr-CSV
This is a simple PowerShell script designed to download and process .csv files from Amazon S3. Downloaded files can be passed through a custom processing tool.

Requirements:
- PowerShell v3 or higher
- AWS Tool for Windows PowerShell [(download)](http://aws.amazon.com/powershell/)

Once you have downloaded this package, there are a few steps to get set up:   
1. Run PowerShell as an administrator and navigate to the DAPr-CSV folder     
2. Set the execution policy with the **Set-ExecutionPolicy AllSigned** command   
    - Restricted - This is the default value, and prevents all scripts from being run. DAPr-CSV will not run with this setting.   
    - RemoteSigned - Prevents unsigned scripts from being run unless they were created locally.
    - AllSigned (Recommended) - Prevents all unsigned scripts from being run.   
    - Unrestricted - Allows any script to be run regardless of source, including potentially malicious code. 
3. Use makecert.exe to sign all scripts to be run     [(guide)](http://www.hanselman.com/blog/SigningPowerShellScripts.aspx).
    - I have provided a pre-signed script titled *Sign-Script.ps1* that you can run to easily sign your scripts, using the command **powershell.exe -file .\Sign-Scripts.ps1** followed by the path to the script to be signed. Use this script on *Sign-DefaultScripts.ps1* and then run *Sign-DefaultScripts.ps1* with **powershell.exe -file .\Sign-DefaultScripts**   
4. Open config/Config.ps1 and replace the sample fields with your information.  
    - ServerList - servers you wish to pull .scv files from, separated by a comma
    - Language - language to display .csv files in
    - ReportEmail - email to receive failure notifications
    - ProcessPath / FailurePath / FinishPath - see below
    - UseFailureHook / UseFinishHook - leave this false to bypass the corresponding hook  

There are three points of interaction available: process, failure, and finish. Each has a corresponding Hook-*.ps1 script which can invoke an external application provided by you. Paths to custom applications are set in /config/Config.ps1.
- Process: Occurs once for each downloaded file, in roll-up order. Takes a .csv path, server, and language as arguments.
- Failure: Occurs only when an application invoked by Process throws an exception. Takes a .csv path, date/time, and error information as arguments. 
- Finish: Occurs once all downloaded .csv files have been passed to the Process application. Takes date/time as an argument.