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
$TempCopier = 'temp'
$CreateTempTable = $DBConn.CreateCommand();
$CreateTempTable.CommandText = "CREATE TEMP TABLE {0} AS SELECT * FROM {1} LIMIT 0; ALTER TABLE {0} ADD PRIMARY KEY (id);" -f $TempCopier, $Table
$CreateTempTable.ExecuteNonQuery() | Out-Null

#"Starting {0} @ {1}" -f "AddToTempTable", (Get-Date) | Write-Host -ForegroundColor Cyan
$AddToTempTable = $DBConn.CreateCommand();
$AddToTempTable.CommandText = "COPY {0} from '{1}' DELIMITERS ',' CSV HEADER;" -f $TempCopier, $CSVPath
$AddToTempTable.ExecuteNonQuery() | Out-Null

# Possible move out to finish-hook
#"Starting {0} @ {1}" -f "MergeWithTable", (Get-Date) | Write-Host -ForegroundColor Cyan
$MergeWithTable  = $DBConn.CreateCommand();
$MergeWithTable.CommandText = "INSERT INTO {0} ({2}) (SELECT * FROM {1}) ON CONFLICT (id) DO UPDATE SET ({2}) = (SELECT * FROM {1} WHERE {0}.id = {1}.id);" -f $Table, $TempCopier, $Columns
$MergeWithTable.ExecuteNonQuery() | Out-Null

#"Starting {0} @ {1}" -f "DropTempTable", (Get-Date) | Write-Host -ForegroundColor Cyan
$DropTempTable = $DBConn.CreateCommand();
$DropTempTable.CommandText = "DROP TABLE {0};" -f $TempCopier
$DropTempTable.ExecuteNonQuery() | Out-Null

$DBConn.Close();
"Stored {0} @ {1}" -f $FileName, (Get-Date) | Write-Host -ForegroundColor Cyan
$Global:LASTEXITCODE = 0