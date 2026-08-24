$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

foreach ($Command in @('flutter', 'dart', 'python')) {
    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        throw "$Command is required for SonicNest release preflight."
    }
}

python tool/verify_project_state_dependencies.py
if ($LASTEXITCODE -ne 0) {
    throw "Dependency-state verification failed with exit code $LASTEXITCODE."
}

python tool/verify_release_version.py
if ($LASTEXITCODE -ne 0) {
    throw "Release-version verification failed with exit code $LASTEXITCODE."
}

./tool/bootstrap_platforms.ps1
if ($LASTEXITCODE -ne 0) {
    throw "Platform bootstrap failed with exit code $LASTEXITCODE."
}

flutter pub get
if ($LASTEXITCODE -ne 0) {
    throw "Dependency resolution failed with exit code $LASTEXITCODE."
}

./tool/apply_branding.ps1
if ($LASTEXITCODE -ne 0) {
    throw "Native branding failed with exit code $LASTEXITCODE."
}

dart format --output=none --set-exit-if-changed lib test tool/generate_brand_assets_v2.dart
if ($LASTEXITCODE -ne 0) {
    throw "Dart formatting validation failed with exit code $LASTEXITCODE."
}

flutter analyze --no-fatal-infos
if ($LASTEXITCODE -ne 0) {
    throw "Flutter analysis failed with exit code $LASTEXITCODE."
}

flutter test
if ($LASTEXITCODE -ne 0) {
    throw "Flutter tests failed with exit code $LASTEXITCODE."
}

Write-Host 'SonicNest release-candidate source preflight passed.'
