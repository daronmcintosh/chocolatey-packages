$ErrorActionPreference = 'Stop'

$wslVersion = 2
$retryInstall = $false

$pp = Get-PackageParameters
if ([int]$pp.Version -in (1, 2)) { $wslVersion = $pp.Version }
if ($pp.Retry -eq $true) { $retryInstall = $true }

$packageArgs = @{
    packageName    = 'wsl2'
    softwareName   = 'Windows Subsystem for Linux'
    Version        = $wslVersion
    Retry          = $retryInstall
    checksum       = 'd872c2ef8f86798daedc295c49a31fb75fb7ba7e46f0660036ff16e55f0926fd'
    checksumType   = 'sha256'
    url            = 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi'
    fileType       = 'msi'
    silentArgs     = '/quiet /qn /norestart'
    validExitCodes = @(0, 3010, 1641)
}

# https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-operatingsystem?redirectedfrom=MSDN
enum OSType {
    WorkStation = 1
    DomainController = 2
    Server = 3
}

$OSVersionInfo = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion")
$OSMajorVersion = $OSVersionInfo.CurrentMajorVersionNumber
$OSMajorBuildNumber = $OSVersionInfo.CurrentBuildNumber
$OSMinorBuildNumber = $OSVersionInfo.UBR
$OSReleaseId = $OSVersionInfo.ReleaseId
$OSProductType = (Get-CimInstance -Class Win32_OperatingSystem).ProductType

function Enable-WSL() {
    & dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null
}

function Write-NotSupportedError() {
    Write-Error "WSL is not supported on windows $OSMajorVersion release $OSReleaseId build $OSMajorBuildNumber.$OSMinorBuildNumber.
See https://docs.microsoft.com/en-us/windows/wsl/ for more info."
    exit 1
}

if ($OSMajorVersion -ne 10) { Write-NotSupportedError }

# https://docs.microsoft.com/en-us/windows/wsl/install-win10
if ($packageArgs.Version -eq 1 ) {
    if (($OSProductType -eq [OSType]::WorkStation -and $OSMajorBuildNumber -ge 14393) -or
        ($OSProductType -eq [OSType]::Server -and $OSMajorBuildNumber -ge 16299)) {

        Enable-WSL
        Write-Host 'Reboot to finish installing WSL'
    }
    else {
        Write-NotSupportedError
    }
}
# https://docs.microsoft.com/en-us/windows/wsl/install-win10#update-to-wsl-2
# https://devblogs.microsoft.com/commandline/wsl-2-support-is-coming-to-windows-10-versions-1903-and-1909/
elseif ($packageArgs.Version -eq 2 -and
    $OSProductType -eq [OSType]::WorkStation -and
    (($OSMajorBuildNumber -in (18362, 18363) -and $OSMinorBuildNumber -ge 1049) -or
        ($OSMajorBuildNumber -ge 19041))) {

    Enable-WSL
    & dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Out-Null

    $wslIntalled = $false
    if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
        $wslIntalled = $true
    }

    if (!$wslIntalled) {
        if ($packageArgs.Retry) {
            & schtasks.exe /create /f /tn WSL2RestartTask /sc ONLOGON /rl HIGHEST /tr "powershell.exe -NoExit -Command 'choco install wsl2 -y -f; schtasks.exe /delete /f /tn WSL2RestartTask'"
            return
        }
        else {
            Write-Warning 'WSL not detected! Reboot PC then install this package again to enable WSL 2'
            return
        }
    }

    Install-ChocolateyPackage @packageArgs
    & wsl.exe --set-default-version 2
}
# https://www.appveyor.com/docs/environment-variables/
elseif ($env:APPVEYOR -eq 'True') {
    Write-Output 'Building package on AppVeyor'
}
else {
    Write-NotSupportedError
}
