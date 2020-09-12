$ErrorActionPreference = 'Stop'

if (Get-Command ubuntu2004.exe -ErrorAction SilentlyContinue) {
    & wsl.exe --unregister "Ubuntu-20.04"
}
else {
    & wsl.exe --unregister "Ubuntu"
}
& wsl.exe --list --verbose
