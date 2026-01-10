# Useful Commands

## Flutter Commands

Instead of running Flutter directly, use the provided PowerShell script to handle environment variables and device selection:

```powershell
./run_flutter.ps1 -d windows   # Launches the app on Windows
./run_flutter.ps1 -d chrome    # Launches the app on Chrome (web)
```

You can still use `fvm flutter pub get` for dependency management:

```bash
fvm flutter pub get
```

## Powershell Scripts

```plaintext
sql/dump/pg_dump.ps1
