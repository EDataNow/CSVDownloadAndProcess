param([string]$CSVPath, [string]$RemoteServer, [string]$Language)
. "$BaseDirectory\SQL-Functions.ps1"
Import-Module $BaseDirectory\lib\Out-DataTable.psm1
$Global:LASTEXITCODE = $null

$DBConn.Open();

#"Starting {0} @ {1}" -f "GetHeaders", (Get-Date) | Write-Host -ForegroundColor Cyan
$Columns = Get-Content $CSVPath -TotalCount 1
$Columns += ", source_file, date_time_inserted"
$FileName = $CSVPath | Split-Path -leaf 
$Table = $FileName -replace( '(?:[^-]*-){3}|\.csv','') -replace('-','_')

#"Starting {0} @ {1}" -f "CreateTempTable", (Get-Date) | Write-Host -ForegroundColor Cyan
$TempCopier='TEMP'
Create-Temp-Table  $TempCopier $Columns

##"Starting {0} @ {1}" -f "AddToTempTable", (Get-Date) | Write-Host -ForegroundColor Cyan
Temp-Table-Dump $TempCopier $CSVPath $DBConn $FileName

##"Starting {0} @ {1}" -f "MergeWithTable", (Get-Date) | Write-Host -ForegroundColor Cyan
Merge-Tables $Table $TempCopier $DBConn $Columns

#"Starting {0} @ {1}" -f "DropTempTable", (Get-Date) | Write-Host -ForegroundColor Cyan
Drop-Table $TempCopier

$DBConn.Close();
"Stored {0} in {1} @ {2}" -f $FileName, $Table, (Get-Date) | Write-Host -ForegroundColor Cyan
$Global:LASTEXITCODE = 0