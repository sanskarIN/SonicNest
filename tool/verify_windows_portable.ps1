param(
    [string]$ArchivePath = '',
    [switch]$RequireSignature
)

$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

if ([string]::IsNullOrWhiteSpace($ArchivePath)) {
    $Archive = Get-ChildItem -Path (Join-Path $Root 'build\windows-package') -Filter 'sonicnest-windows-*.zip' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 1
    if (-not $Archive) {
        throw 'No Windows portable package was found under build\windows-package.'
    }
    $ArchivePath = $Archive.FullName
} elseif (-not [System.IO.Path]::IsPathRooted($ArchivePath)) {
    $ArchivePath = Join-Path $Root $ArchivePath
}

if (-not (Test-Path -LiteralPath $ArchivePath -PathType Leaf)) {
    throw "Windows portable package does not exist: $ArchivePath"
}
if ([System.IO.Path]::GetExtension($ArchivePath) -ne '.zip') {
    throw "Windows portable package must be a .zip archive: $ArchivePath"
}

$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("sonicnest-windows-verify-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null

try {
    Expand-Archive -LiteralPath $ArchivePath -DestinationPath $TempRoot -Force

    $RequiredPaths = @(
        'sonic_nest.exe',
        'flutter_windows.dll',
        'data\icudtl.dat',
        'data\flutter_assets'
    )
    foreach ($Relative in $RequiredPaths) {
        $Candidate = Join-Path $TempRoot $Relative
        if (-not (Test-Path -LiteralPath $Candidate)) {
            throw "Portable package is incomplete; required path is missing: $Relative"
        }
    }

    $ForbiddenNames = @(
        '.env',
        'key.properties',
        'google-services.json',
        'GoogleService-Info.plist'
    )
    $ForbiddenExtensions = @(
        '.jks',
        '.keystore',
        '.p12',
        '.pfx',
        '.pem',
        '.mobileprovision'
    )

    $Files = Get-ChildItem -LiteralPath $TempRoot -Recurse -File
    foreach ($File in $Files) {
        if ($ForbiddenNames -contains $File.Name) {
            throw "Portable package contains forbidden sensitive/generated configuration: $($File.FullName.Substring($TempRoot.Length + 1))"
        }
        if ($ForbiddenExtensions -contains $File.Extension.ToLowerInvariant()) {
            throw "Portable package contains forbidden signing/private material: $($File.FullName.Substring($TempRoot.Length + 1))"
        }
    }

    $ExecutablePath = Join-Path $TempRoot 'sonic_nest.exe'
    if ((Get-Item -LiteralPath $ExecutablePath).Length -le 0) {
        throw 'sonic_nest.exe is empty.'
    }

    if ($RequireSignature) {
        $Signature = Get-AuthenticodeSignature -LiteralPath $ExecutablePath
        if ($Signature.Status -ne 'Valid') {
            throw "sonic_nest.exe does not have a valid Authenticode signature. Status: $($Signature.Status)"
        }
        Write-Host "Authenticode signature is valid. Subject: $($Signature.SignerCertificate.Subject)"
    }

    $Hash = (Get-FileHash -LiteralPath $ArchivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    $ChecksumPath = Join-Path (Split-Path -Parent $ArchivePath) 'SHA256SUMS.txt'
    if (Test-Path -LiteralPath $ChecksumPath -PathType Leaf) {
        $ExpectedLine = Get-Content -LiteralPath $ChecksumPath | Where-Object { $_ -match [Regex]::Escape((Split-Path -Leaf $ArchivePath)) } | Select-Object -First 1
        if (-not $ExpectedLine) {
            throw "SHA256SUMS.txt does not contain the package filename: $(Split-Path -Leaf $ArchivePath)"
        }
        $ExpectedHash = ($ExpectedLine -split '\s+', 2)[0].ToLowerInvariant()
        if ($ExpectedHash -ne $Hash) {
            throw "SHA-256 mismatch. Expected $ExpectedHash but calculated $Hash."
        }
    }

    Write-Host "Windows portable package verification passed: $(Split-Path -Leaf $ArchivePath)"
    Write-Host "SHA-256: $Hash"
} finally {
    if (Test-Path -LiteralPath $TempRoot) {
        Remove-Item -LiteralPath $TempRoot -Recurse -Force
    }
}
