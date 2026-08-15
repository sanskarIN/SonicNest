param(
    [ValidateSet('debug', 'profile', 'release')]
    [string]$Configuration = 'release',
    [string]$ArtifactSuffix = 'unsigned',
    [string]$OutputDirectory = 'build\windows-package'
)

$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$ConfigDirectory = switch ($Configuration) {
    'debug' { 'Debug' }
    'profile' { 'Profile' }
    'release' { 'Release' }
}

$BundleDirectory = Join-Path $Root "build\windows\x64\runner\$ConfigDirectory"
if (-not (Test-Path -LiteralPath $BundleDirectory -PathType Container)) {
    throw "Windows $Configuration bundle was not found at $BundleDirectory. Build it with 'flutter build windows --$Configuration' first."
}

$RequiredBundlePaths = @(
    'sonic_nest.exe',
    'flutter_windows.dll',
    'data\icudtl.dat',
    'data\flutter_assets'
)
foreach ($Relative in $RequiredBundlePaths) {
    $Candidate = Join-Path $BundleDirectory $Relative
    if (-not (Test-Path -LiteralPath $Candidate)) {
        throw "Windows bundle is incomplete; required path is missing: $Relative"
    }
}

$VersionLine = Select-String -Path (Join-Path $Root 'pubspec.yaml') -Pattern '^version:\s*(?<version>[^\s]+)\s*$' | Select-Object -First 1
if (-not $VersionLine) {
    throw 'Could not read the SonicNest version from pubspec.yaml.'
}
$FullVersion = $VersionLine.Matches[0].Groups['version'].Value
$PublicVersion = ($FullVersion -split '\+', 2)[0]
if ([string]::IsNullOrWhiteSpace($PublicVersion)) {
    throw 'pubspec.yaml contains an empty version.'
}

$SafeSuffix = ($ArtifactSuffix -replace '[^A-Za-z0-9._-]', '-').Trim('-')
if ([string]::IsNullOrWhiteSpace($SafeSuffix)) {
    throw 'ArtifactSuffix must contain at least one safe filename character.'
}

$OutputRoot = if ([System.IO.Path]::IsPathRooted($OutputDirectory)) {
    $OutputDirectory
} else {
    Join-Path $Root $OutputDirectory
}
New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null

$ArtifactName = "sonicnest-windows-x64-v$PublicVersion-portable-$SafeSuffix.zip"
$ArtifactPath = Join-Path $OutputRoot $ArtifactName
$ChecksumPath = Join-Path $OutputRoot 'SHA256SUMS.txt'
$ManifestPath = Join-Path $OutputRoot 'PACKAGE_INFO.txt'

if (Test-Path -LiteralPath $ArtifactPath) {
    Remove-Item -LiteralPath $ArtifactPath -Force
}

Compress-Archive -Path (Join-Path $BundleDirectory '*') -DestinationPath $ArtifactPath -CompressionLevel Optimal -Force

if (-not (Test-Path -LiteralPath $ArtifactPath -PathType Leaf)) {
    throw "Windows portable archive was not created: $ArtifactPath"
}

$Hash = (Get-FileHash -LiteralPath $ArtifactPath -Algorithm SHA256).Hash.ToLowerInvariant()
"$Hash  $ArtifactName" | Set-Content -LiteralPath $ChecksumPath -Encoding ASCII

@"
SonicNest Windows portable package
Version: $PublicVersion
Flutter build configuration: $Configuration
Architecture: x64
Artifact: $ArtifactName
SHA-256: $Hash

The archive contains the complete Flutter Windows runner bundle. It is portable: extract the whole archive before launching sonic_nest.exe.
The artifact suffix is a packaging label only. Public stable Windows releases must satisfy docs/WINDOWS_SIGNING_POLICY.md and must not be represented as signed unless Authenticode verification succeeds on the exact packaged binaries.
"@ | Set-Content -LiteralPath $ManifestPath -Encoding UTF8

Write-Host "Created Windows portable package: $ArtifactPath"
Write-Host "Checksum: $Hash"
