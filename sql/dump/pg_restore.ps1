# Script to dump and restore PostgreSQL schema and data

Write-Output "Starting the dump process by calling pg_dump.ps1..."

# Call the pg_dump.ps1 script
& "$(git rev-parse --show-toplevel)\sql\dump\pg_dump.ps1"

# PostgreSQL Connection Details
$DBName = "postgres"
$DBPort = "5432"
$DBUser_PROD = "postgres.ogsvrmrxnfqlasrxzeyw"
$DBHost_PROD = "aws-0-eu-west-3.pooler.supabase.com"

Write-Output "Restoring schema for database '$DBName' from host '$DBHost_PROD' on port '$DBPort' as user '$DBUser_PROD'"

Set-Location "$(git rev-parse --show-toplevel)"

# Set the PGPASSFILE environment variable
$Env:PGPASSFILE = "C:\users\pgranger\OGZ_PROD.pgpass"

# Restore Schema
# pg_restore -U $DBUser_PROD -h $DBHost_PROD -p $DBPort -d $DBName --no-owner --no-privileges "$(git rev-parse --show-toplevel)\sql\dump\dump.tar"
pg_restore -U $DBUser_PROD -h $DBHost_PROD -p $DBPort -d $DBName --no-owner --no-privileges "$(git rev-parse --show-toplevel)\sql\dump\dump.sql"

Write-Output "Restore completed successfully."