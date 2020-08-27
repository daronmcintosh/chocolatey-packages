$ErrorActionPreference = 'Stop'

$wslIntalled = $false
if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
    $wslIntalled = $true
}

if (!$wslIntalled) {
    Write-Error "WSL not detected! WSL is needed to install $($packageArgs.softwareName)"
    exit 1
}

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$installAsRoot = $false

$pp = Get-PackageParameters
if ($pp.RootInstall -eq $true) { $installAsRoot = $true }

$packageArgs = @{
    packageName    = 'wsl-ubuntu-2004'
    softwareName   = 'Ubuntu 20.04 LTS for WSL'
    checksum       = 'd40aa183993d110a93d386a547ee0165328082f0ef05e1da56c48a1a0e94e99a'
    checksumType   = 'sha256'
    url            = 'https://aka.ms/wslubuntu2004'
    unzipLocation  = "$toolsDir\ubuntu2004"
    validExitCodes = @(0)
}

New-Item -Path $packageArgs.unzipLocation -ItemType Directory -Force | Out-Null
Install-ChocolateyZipPackage @packageArgs

$packageArgs.silentArgs = if ($installAsRoot) { "install --root" } else { "install" }
$packageArgs.fileType = 'exe'
$packageArgs.file = "$($packageArgs.unzipLocation)\ubuntu2004.exe"

Install-ChocolateyInstallPackage @packageArgs

Remove-Item -Path $packageArgs.unzipLocation -Force -Recurse | Out-Null
wslconfig /list
