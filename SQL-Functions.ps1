function Create-Table {
param([string]$TableName, [string[]]$Columns)
    $CreateTable = $DBConn.CreateCommand();
    $CreateTable.CommandText = "CREATE TABLE {0} ("-f $TableName
    $NewColumns = foreach ($Column in ($Columns -split ',')) {
        if ($Column -eq 'id'){"{0} integer" -f $Column}
        else{"{0} varchar(max)" -f $Column}
    }
    $CreateTable.CommandText += "{0}, PRIMARY KEY(id));" -f ($NewColumns -join ', ')
    $CreateTable.ExecuteNonQuery() | Out-Null
}
function Create-Temp-Table {
param([string]$TableName, $Columns)
    try {Create-Table $TableName $Columns}
    catch {
        Drop-Table $TableName
        Create-Table $TableName $Columns
    }
}
function Temp-Table-Dump {
param([string]$TempCopier, [string]$CSVPath, $DBConn)
    $sqlBulkCopy = New-Object (“Data.SqlClient.SqlBulkCopy”) -ArgumentList $DBConn
    $sqlBulkCopy.DestinationTableName = $TempCopier
    $CSV = Import-Csv -Path $CSVPath | Out-DataTable
    $sqlBulkCopy.WriteToServer($CSV) | Out-Null
}
function Update-Columns {
param([string]$TableName, [string[]]$Columns)
    foreach ($Column in ($Columns -split ',')) {
        $AddColumn = $DBConn.CreateCommand();
        $AddColumn.CommandText = "ALTER TABLE {0} ADD {1} varchar(max)" -f $TableName, $Column
        try {$AddColumn.ExecuteNonQuery()
        write-host "'$Column' column has been added to the '$TableName' table."}
        catch { } 
    }
}
function Merge-Tables {
param([string]$Table, [string]$TempCopier, $DBConn, $Columns)

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

    try { $MergeWithTable.ExecuteNonQuery() | Out-Null }
    catch { 
        #$Error[0] | Write-Host -ForegroundColor Yellow 
        try {Create-Table $Table  $Columns}
        catch {
        #$Error[0] | Write-Host -ForegroundColor Yellow 
        Update-Columns $Table  $Columns}
        $MergeWithTable.ExecuteNonQuery() | Out-Null
    }
}
function Drop-Table {
param([string]$TableName)
    $DropTempTable = $DBConn.CreateCommand();
    $DropTempTable.CommandText = "DROP TABLE {0};" -f $TableName
    $DropTempTable.ExecuteNonQuery() | Out-Null
}