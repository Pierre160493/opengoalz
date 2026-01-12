# PowerShell script to read .env and run Flutter with --dart-define
# Usage: .\run_flutter.ps1 [-Device windows|chrome] [-- <extra flutter args>]

param(
    [string]$Device = "windows"
)


# Map short input to full device name or detect Android device
switch ($Device.ToLower()) {
    'w' { $Device = 'windows' }
    'c' { $Device = 'chrome' }
    'p' { $Device = 'android' }
    'phone' { $Device = 'android' }
}

# If device is 'android', try to detect the first connected Android device
if ($Device -eq 'android') {
    $adbOutput = & adb devices | Select-Object -Skip 1 | Where-Object { $_ -match 'device$' -and $_ -notmatch 'List of devices' }
    if ($adbOutput) {
        $firstDevice = ($adbOutput -split '\s+')[0]
        if ($firstDevice) {
            $Device = $firstDevice
        }
    }
}


# Path to your .env file
$envFile = ".env"
if (-not (Test-Path $envFile)) {
    Write-Error ".env file not found. Please create a .env file in the project root containing key=value pairs.\nRequired variables:\nSUPABASE_URL=\nSUPABASE_KEY="
    exit 1
}

# Read .env file and extract variables
$envVars = Get-Content $envFile | Where-Object { $_ -match "^\s*\w+=" } | ForEach-Object {
    $parts = $_ -split '=', 2
    @{ Key = $parts[0].Trim(); Value = $parts[1].Trim() }
}

# Build --dart-define arguments
$dartDefines = ($envVars | ForEach-Object { "--dart-define=$($_.Key)=$($_.Value)" }) -join ' '

# Build the flutter run command
$cmd = "flutter run -d $Device $dartDefines"
Write-Host "Running: flutter run -d $Device with --dart-define arguments from .env (values hidden)"
Invoke-Expression $cmd
