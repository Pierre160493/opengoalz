
# Load DB connection variables from .env file in repo root
$envFile = Join-Path (git rev-parse --show-toplevel) ".env"
if (-not (Test-Path $envFile)) {
    Write-Error ".env file not found in repo root."
    exit 1
}

# Function to get environment variable value from .env file
function Get-EnvValue {
    param(
        [string]$Key
    )
    $lines = @(Get-Content $envFile | Where-Object { $_ -match "^$Key=" })
    if ($lines.Count -eq 1) {
        $val = ($lines[0] -split '=',2)[1].Trim()
        if ($val) {
            return $val
        } else {
            Write-Error ".env entry for $Key is empty."
            exit 1
        }
    } elseif ($lines.Count -eq 0) {
        Write-Error ".env file found but no $Key entry."
        exit 1
    } else {
        Write-Error ".env file found but multiple $Key entries."
        exit 1
    }
}

$DBName = Get-EnvValue "SUPABASE_DB_NAME"
$DBPort = Get-EnvValue "SUPABASE_DB_PORT"
$DBUser_DEV = Get-EnvValue "SUPABASE_DB_USER"
$DBHost_DEV = Get-EnvValue "SUPABASE_DB_HOST"
$Env:PGPASSWORD = Get-EnvValue "SUPABASE_DB_PASSWORD"

Write-Output "Dumping schema for database '$DBName' from host '$DBHost_DEV' on port '$DBPort' as user '$DBUser_DEV'"

# Change to repo root
Set-Location "$(git rev-parse --show-toplevel)"

# Dump Schema and handle errors
$output = & pg_dump -U $DBUser_DEV -h $DBHost_DEV -p $DBPort $DBName --schema-only -f "$(git rev-parse --show-toplevel)\sql\dump\dump.sql" 2>&1
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    Write-Error $output
    exit 1
}

$output = & pg_dump -U $DBUser_DEV -h $DBHost_DEV -p $DBPort $DBName --schema-only -Ft -f "$(git rev-parse --show-toplevel)\sql\dump\dump.tar" 2>&1
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    Write-Error $output
    exit 1
}

Write-Output "Dump completed successfully."