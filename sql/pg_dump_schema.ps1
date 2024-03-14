# PostgreSQL Connection Details
$DBName = "postgres"
$DBUser = "postgres.kaderxuszmqjknsoyjpi"
$DBHost = "aws-0-eu-central-1.pooler.supabase.com"
$DBPort = "5432"

Write-Output "Dumping schema for database '$DBName' from host '$DBHost' on port '$DBPort' as user '$DBUser'"
cd "C:\Users\pierr\git\opengoalz\sql"
pwd
# Directory to save dump
$DumpDir = "C:\Users\pierr\git\opengoalz\sql\dump"

# Dump Schema
pg_dump -U $DBUser -h $DBHost -p $DBPort -s $DBName | Out-File -FilePath "$DumpDir\schema_dump.sql"