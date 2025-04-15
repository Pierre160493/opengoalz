# PostgreSQL Connection Details
$DBName = "postgres"
$DBPort = "5432"
$DBUser_DEV = "postgres.kaderxuszmqjknsoyjpi"
$DBHost_DEV = "aws-0-eu-central-1.pooler.supabase.com"

Write-Output "Dumping schema for database '$DBName' from host '$DBHost_DEV' on port '$DBPort' as user '$DBUser_DEV'"

Set-Location "$(git rev-parse --show-toplevel)"

# Set the PGPASSFILE environment variable
$Env:PGPASSFILE = "C:\users\pgranger\OGZ_DEV.pgpass"

# Dump Schema
pg_dump -U $DBUser_DEV -h $DBHost_DEV -p $DBPort $DBName -f "$(git rev-parse --show-toplevel)\sql\dump\dump.sql"
pg_dump -U $DBUser_DEV -h $DBHost_DEV -p $DBPort $DBName -Ft -f "$(git rev-parse --show-toplevel)\sql\dump\dump.tar"

Write-Output "Dump completed successfully."