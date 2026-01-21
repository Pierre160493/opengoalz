# Setup Instructions for OpenGoalz

This guide will help you set up your development environment for contributing to or building the OpenGoalz Flutter app. OpenGoalz is a cross-platform application supporting Android, iOS, Windows, and web.

## Automated Package Installation

Most dependencies can be installed automatically with a single Chocolatey command. This includes tools like VS Code, Git, Flutter Version Manager (FVM), OpenJDK 17, and Android Debug Bridge (ADB).

Run the following command:

```powershell
choco install vscode vscode.install git git.install fvm openjdk17 adb -y
```

This will install:

- VS Code (editor)
- Git (version control)
- FVM (Flutter version management)
- OpenJDK 17 (Java for Android development)
- ADB (Android debugging)

## Manual Installations

Some tools require custom parameters and cannot be automated via the config file:

### Visual Studio 2022 Community with Native Desktop Workload

Required for building native components (e.g., Windows desktop apps) and certain Flutter plugins.

Run this command in an elevated PowerShell:

```powershell
choco install visualstudio2022community --package-parameters "--add Microsoft.VisualStudio.Workload.NativeDesktop"
```

See [docs/USEFUL_COMMANDS.md](USEFUL_COMMANDS.md) for more build and run commands.
