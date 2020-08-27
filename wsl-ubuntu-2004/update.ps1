import-module au

$releases = 'https://docs.microsoft.com/en-us/windows/wsl/install-manual'
function global:au_SearchReplace {
    @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
        }
    }
}

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases

    $url = $download_page.links | Where-Object href -match 'https://aka.ms/wslubuntu2004$' | ForEach-Object href | Select-Object -First 1
    $version = "20.04.0.$(Get-Date -Format yyyyMMdd)"

    @{
        URL     = $url
        Version = $version
    }
}

update -ChecksumFor 64 -Force
