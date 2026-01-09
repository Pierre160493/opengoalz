# PowerShell script to read .env and run Flutter with --dart-define
# Usage: powershell -ExecutionPolicy Bypass -File run_flutter.ps1 [-Device windows|chrome] [-- <extra flutter args>]

param(
    [string]$Device = "windows",
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs
)

# Path to your .env file
$envFile = ".env"

# Read .env file and extract variables
$envVars = Get-Content $envFile | Where-Object { $_ -match "^\s*\w+=" } | ForEach-Object {
    $parts = $_ -split '=', 2
    @{ Key = $parts[0].Trim(); Value = $parts[1].Trim() }
}

# Build --dart-define arguments
$dartDefines = ($envVars | ForEach-Object { "--dart-define=$($_.Key)=$($_.Value)" }) -join ' '

# Build the flutter run command
$cmd = "flutter run -d $Device $dartDefines $($ExtraArgs -join ' ')"
Write-Host "Running: flutter run -d $Device with --dart-define arguments from .env (values hidden)"
Invoke-Expression $cmd
