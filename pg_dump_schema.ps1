# PostgreSQL Connection Details
$DBName = "postgres"
$DBUser = "postgres.kaderxuszmqjknsoyjpi"
$DBHost = "aws-0-eu-central-1.pooler.supabase.com"
$DBPort = "5432"

Write-Output "Dumping schema for database '$DBName' from host '$DBHost' on port '$DBPort' as user '$DBUser'"

Set-Location "$(git rev-parse --show-toplevel)"

# Set the PGPASSFILE environment variable
$Env:PGPASSFILE = "C:\users\pgranger\.pgpass"

Get-Location

# Dump Schema
pg_dump -U $DBUser -h $DBHost -p $DBPort -s $DBName | Out-File -FilePath "$(git rev-parse --show-toplevel)\sql\schema_dump.sql"