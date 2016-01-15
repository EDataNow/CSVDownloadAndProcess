# CSV-DownloadAndProcess
This is a simple PowerShell script designed to download and process .csv files from Amazon S3. Downloaded files can be passed through a custom processing tool.

Requirements:
- PowerShell v5 or higher
- AWS Tool for Windows PowerShell [(download)](http://aws.amazon.com/powershell/)

Once you have downloaded this package, there are a few steps to get set up. 
Navigate to config/config.ps1 and replace the sample fields with your information.  
- serverList - servers you wish to pull .scv files from, separated by a comma
- language - language to display .csv files in
- reportEmail - email to receive failure notifications
- processPath - see below
- failurePath - see below
- finishPath - see below

There are three points of interaction available: process, failure, and finish. Each has a corresponding *_hook.ps1 script which can invoke an external application provided by you. Paths to custom applications are set in /config/config.ps1.
- Process: Occurs once for each downloaded file, in roll-up order. Takes a .csv path, server, and language as arguments.
- Failure: Occurs only when an application invoked by Process throws an exception. Takes a .csv path, date/time, and error information as arguments. 
- Finish: Occurs once all downloaded .csv files have been passed to the Process application. Takes date/time as an argument.