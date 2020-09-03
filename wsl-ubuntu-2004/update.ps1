import-module au

$releases = 'https://docs.microsoft.com/en-us/windows/wsl/install-manual'
function global:au_SearchReplace {
    @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
        }
    }
}

# https://github.com/majkinetor/au-packages/blob/master/cpu-z.install/update.ps1#L18-L46
function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases

    $url = $download_page.links | Where-Object href -match 'https://aka.ms/wslubuntu2004$' | ForEach-Object href | Select-Object -First 1

    $current_checksum = (Get-Item $PSScriptRoot\tools\chocolateyInstall.ps1 | Select-String '\bchecksum\b') -split "=|'" | Select-Object -Last 1 -Skip 1
    if ($current_checksum.Length -ne 64) { throw "Can't find current checksum" }
    $remote_checksum  = Get-RemoteChecksum $url
    if ($current_checksum -ne $remote_checksum) {
        Write-Host 'Remote checksum is different then the current one, forcing update'
        $global:au_old_force = $global:au_force
        $global:au_force = $true
    }

    @{
        URL     = $url
        Version = '20.4.0'
        Checksum64 = $remote_checksum
    }
}

if ($MyInvocation.InvocationName -ne '.') { # run the update only if script is not sourced
    update -ChecksumFor none
    if ($global:au_old_force -is [bool]) { $global:au_force = $global:au_old_force }
}

