function Test-Database
{ 
  param([string]$DBName = 'S_CSV')

  Write-Verbose "Test-Database..: Testing for database $DBName"

  $dbcmd = @"
    SELECT COUNT(*) AS DbExists
      FROM [master].[sys].[databases]
     WHERE [name] = '$($DBName)'  
"@

  $result = Invoke-Sqlcmd -Query $dbcmd `
                          -ServerInstance $env:COMPUTERNAME `
                          -Database 'master' `
                          -SuppressProviderContextWarning 
 
  if ($($result.DbExists) -eq 0)
  { $return = $false }
  else
  { $return = $true }

   
  # Let user know
  Write-Verbose "Test-Database..: Database $DBName exists: $return"

  # Return the result of the test
  return $return

} # function Test-Database
function Test-Table
{
  param([string]$DBName = 'S_CSV', [string]$TableName = 'test' )

    # Check to see if they included a schema, if not use dbo
    if ($TableName.Contains('.'))
    { $tbl = $TableName }
    else
    { $tbl = "dbo.$TableName" }
    
    $dbcmd = @"
    SELECT COUNT(*) AS TableExists
        FROM [INFORMATION_SCHEMA].[TABLES]
        WHERE [TABLE_SCHEMA] + '.' + [TABLE_NAME] = '$tbl'
"@
    
    $result = Invoke-Sqlcmd -Query $dbcmd `
                            -ServerInstance $env:COMPUTERNAME `
                            -Database $DBName `
                            -SuppressProviderContextWarning 
     
    if ($($result.TableExists) -eq 0)
    { $return = $false }
    else
    { $return = $true }
      
    return $return

}
function Count-Number-Columns
{
  param ([string]$DBName = 'S_CSV', [string]$TableName = 'test')

    # Check to see if they included a schema, if not use dbo
    if ($TableName.Contains('.'))
    { $tbl = $TableName }
    else
    { $tbl = "dbo.$TableName" }
    
    $dbcmd = @"
    SELECT COUNT(*) AS ColumnCount
        FROM information_schema.columns 
        WHERE [TABLE_SCHEMA] + '.' + [TABLE_NAME] = '$tbl'
"@
    
    $result = Invoke-Sqlcmd -Query $dbcmd `
                            -ServerInstance $env:COMPUTERNAME `
                            -Database $DBName `
                            -SuppressProviderContextWarning 
    return $result.ColumnCount

}
function Count-Number-Rows
{
  param
  (
    [string]$DBName = 'S_CSV',
    [string]$TableName = 'test'
  )

    # Check to see if they included a schema, if not use dbo
    if ($TableName.Contains('.'))
    { $tbl = $TableName }
    else
    { $tbl = "dbo.$TableName" }
    
    $dbcmd = @"
      SELECT COUNT(*) AS RowsCount 
        FROM $TableName    
"@
    
    $result = Invoke-Sqlcmd -Query $dbcmd `
                            -ServerInstance $env:COMPUTERNAME `
                            -Database $DBName `
                            -SuppressProviderContextWarning 
    return $result.RowsCount

}

$BaseDirectory = $PSScriptRoot
Set-Location -Path $PSScriptRoot
. $BaseDirectory\config\config.ps1
. $BaseDirectory\SQL-Functions.ps1
Import-Module $BaseDirectory\lib\Out-DataTable.psm1

$DBName = 'S_CSV'
$DBConn.Open();
Describe 'Database Testing' {

    $TestFiles= @(
            ("testing.csv"),
            ("testing2.csv"),
            ("testing3.csv")
        )
    $TableName = 'testing'
    $CSVPath = "$BaseDirectory\Tests\$($TestFiles[0])"
    $Columns = Get-Content "$CSVPath" -TotalCount 1

    $TempCopier='TEMP'
    $CSVPath2 = "$BaseDirectory\Tests\$($TestFiles[1])"
    $Columns2 = Get-Content "$CSVPath2" -TotalCount 1
        
    $Columns3 = Get-Content "$BaseDirectory\Tests\$($TestFiles[2])" -TotalCount 1
    
    Context "'$DBName' database" {
        It "exists" {
            Test-Database $DBName | Should Be $true
        }
    }

    Context "'$TableName' Table" {
        It "created" {
            $Columns = Get-Content $CSVPath -TotalCount 1
            Create-Table $TableName $Columns
            Test-Table $DBName $TableName | Should Be $true
        }

        It "required test files exist" {
            foreach($TestFile in $TestFiles) {
                "$BaseDirectory\Tests\$TestFile" | Should Exist
            }
        }

        It 'rows added' {
            $(Count-Number-Rows $DBName $TableName) | Should be 0

            Temp-Table-Dump $TableName $CSVPath $DBConn

            $(Count-Number-Rows $DBName $TableName) | Should Be 1
        }

        It 'rows updated' {
            #todo: testing that the row data is diffferent
            Count-Number-Rows $DBName $TableName | Should be 1

            Create-Temp-Table $TempCopier $Columns2
            Temp-Table-Dump $TempCopier $CSVPath2 $DBConn

            Merge-Tables $TableName $TempCopier $DBConn $Columns2

            Count-Number-Rows $DBName $TempCopier | Should Be 2
            Count-Number-Rows $DBName $TableName | Should Be 2
        }

        It "added columns" {
            Count-Number-Columns $DBName $TableName | Should Be 5
            Update-Columns $TableName $Columns3
            Count-Number-Columns $DBName $TableName | Should Be 6
        }


        It "removed $TableName" {
            Drop-Table $TableName
            Test-Table $DBName $TableName | Should Be $false
        }
        It "removed $TempCopier" {
            Drop-Table $TempCopier
            Test-Table $DBName $TempCopier | Should Be $false
        }
    }
    
}
$DBConn.Close();