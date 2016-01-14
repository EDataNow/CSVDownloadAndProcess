$ErrorActionPreference = "Stop"
$user= Import-CSV .\credentials\*.csv
$bucket="edn-production"
$serverList="service.edatanow.com"
$language="en"
$region="us-east-1"
