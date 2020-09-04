$ErrorActionPreference = 'Stop'

& wsl.exe --unregister "Ubuntu"
& wsl.exe --list --verbose
