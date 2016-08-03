$DBConn.Open();
$TableList = $DBConn.GetSchema('Tables')
ForEach ($Table in $TableList){
    if ($Table.TABLE_TYPE -eq 'TABLE'){
        #"Starting {0} @ {1}" -f "ExportToCSV", (Get-Date) | Write-Host -ForegroundColor Cyan
        $ExportToCSV = $DBConn.CreateCommand()
        $ExportToCSV.CommandText = "COPY {0} TO '{1}\csv\{2}\{0}.csv' WITH (FORMAT CSV, HEADER);" -f $Table.TABLE_NAME, (Get-Location), $Server
        #$ExportToCSV.CommandText += "COPY {0} TO '{1}\{2}\{0}.csv' WITH (FORMAT CSV, HEADER);" -f $Table.TABLE_NAME, $OneDriveLocation, $Server
        $ExportToCSV.ExecuteNonQuery() | Out-Null
    }
}
$DBConn.Close();