param([string]$CSVPath, [string]$RemoteServer, [string]$Language)

$Global:LASTEXITCODE = $null

function Create-Table {
param([string]$TableName)
    $CreateTable = $DBConn.CreateCommand();
    $CreateTable.CommandText = "CREATE TABLE {0} ("-f $TableName
    $NewColumns = foreach ($Column in ($Columns -split ',')) {
        if ($Column -eq 'id'){"{0} integer" -f $Column}
        else{"{0} varchar(255)" -f $Column}
    }
    $CreateTable.CommandText += "{0}, PRIMARY KEY(id));" -f ($NewColumns -join ', ')
    $CreateTable.ExecuteNonQuery() | Out-Null
}

$DBConn.Open();

#"Starting {0} @ {1}" -f "GetHeaders", (Get-Date) | Write-Host -ForegroundColor Cyan
$Columns = Get-Content $CSVPath -TotalCount 1
$FileName = $CSVPath | Split-Path -leaf 
$Table = $FileName -replace( '(?:[^-]*-){3}|\.csv','') -replace('-','_')

#"Starting {0} @ {1}" -f "CreateTable", (Get-Date) | Write-Host -ForegroundColor Cyan
try {Create-Table $Table}
catch {}

#"Starting {0} @ {1}" -f "CreateTempTable", (Get-Date) | Write-Host -ForegroundColor Cyan
$TempCopier = '#temp'
try {Create-Table $TempCopier}
catch {}

#"Starting {0} @ {1}" -f "AddToTempTable", (Get-Date) | Write-Host -ForegroundColor Cyan
$AddToTempTable = $DBConn.CreateCommand();
$AddToTempTable.CommandText = "BULK INSERT {0} FROM '{1}' WITH (FIRSTROW=2,FIELDTERMINATOR = ',', ROWTERMINATOR = '\n')" -f $TempCopier, $CSVPath
$AddToTempTable.ExecuteNonQuery() | Out-Null

# Possible move out to finish-hook
#"Starting {0} @ {1}" -f "MergeWithTable", (Get-Date) | Write-Host -ForegroundColor Cyan
$MergeWithTable  = $DBConn.CreateCommand();

$InsertString = foreach ($Column in ($Columns -split ',')) {"S.$Column"}
$InsertString = $InsertString -join ','
$UpdateString = foreach ($Column in ($Columns -split ',')) {"T.$Column = S.$Column"}
$UpdateString = $UpdateString -join ','

$MergeWithTable.CommandText = "MERGE {0} AS T  
USING {1} AS S 
ON T.id = S.id
WHEN MATCHED THEN  
  UPDATE SET {3}
WHEN NOT MATCHED THEN  
  INSERT ({2}) VALUES ({4});" -f $Table, $TempCopier, $Columns, $UpdateString, $InsertString
$MergeWithTable.ExecuteNonQuery() | Out-Null

#"Starting {0} @ {1}" -f "DropTempTable", (Get-Date) | Write-Host -ForegroundColor Cyan
$DropTempTable = $DBConn.CreateCommand();
$DropTempTable.CommandText = "DROP TABLE {0};" -f $TempCopier
$DropTempTable.ExecuteNonQuery() | Out-Null

$DBConn.Close();
"Stored {0} @ {1}" -f $FileName, (Get-Date) | Write-Host -ForegroundColor Cyan
$Global:LASTEXITCODE = 0