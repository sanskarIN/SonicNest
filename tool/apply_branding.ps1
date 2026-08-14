$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
    throw 'Dart is required. Install Flutter and place its bin directory on PATH.'
}

$RequiredHosts = @('android', 'ios', 'macos', 'windows')
foreach ($HostDirectory in $RequiredHosts) {
    if (-not (Test-Path (Join-Path $Root $HostDirectory))) {
        throw 'Platform hosts are missing. Run tool/bootstrap_platforms.ps1 first.'
    }
}

dart tool/generate_brand_assets_v2.dart
if ($LASTEXITCODE -ne 0) {
    throw "Brand asset generation failed with exit code $LASTEXITCODE."
}

dart run flutter_launcher_icons
if ($LASTEXITCODE -ne 0) {
    throw "Launcher icon generation failed with exit code $LASTEXITCODE."
}

dart run flutter_native_splash:create
if ($LASTEXITCODE -ne 0) {
    throw "Native splash generation failed with exit code $LASTEXITCODE."
}

Write-Host 'SonicNest native launcher icons and splash assets are applied.'
