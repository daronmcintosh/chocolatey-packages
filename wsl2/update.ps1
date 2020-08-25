import-module au

$releases = 'https://docs.microsoft.com/en-us/windows/wsl/wsl2-kernel'
function global:au_SearchReplace {
    @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
        }
    }
}

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases

    $url = $download_page.links | Where-Object href -match 'x64.msi$' | ForEach-Object href | Select-Object -First 1
    $nuspecPath = "$PSScriptRoot\wsl2.nuspec"
    $nuspectXML = New-Object -TypeName XML
    $nuspectXML.Load($nuspecPath)
    $nuspectXML.package.metadata.version -match "(?<major>\d+).(?<minor>\d+).(?<patch>\d+)$"

    $updatedPatchVerion = [convert]::ToInt32([int]$Matches.patch, 10) + 1
    $version = "$($Matches.major).$($Matches.minor).$updatedPatchVerion"

    @{
        URL     = $url
        Version = $version
    }
}

update -ChecksumFor 64
