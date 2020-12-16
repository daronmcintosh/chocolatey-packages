$ErrorActionPreference = 'Stop'

$package = Get-AppxProvisionedPackage -online | where-object {$_.PackageName -Like "*Ubuntu20.04*"}

if (-not ([string]::IsNullOrEmpty($package.PackageName))) {
    Remove-AppxProvisionedPackage -Online -PackageName $package.PackageName
}

if (Get-Command ubuntu2004.exe -ErrorAction SilentlyContinue) {
    & wsl.exe --unregister "Ubuntu-20.04"
}
else {
    & wsl.exe --unregister "Ubuntu"
}
& wsl.exe --list --verbose
