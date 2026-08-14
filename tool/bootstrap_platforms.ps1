$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Flutter is required. Install the stable Flutter SDK and place flutter on PATH.'
}

$RequiredHosts = @('android', 'ios', 'macos', 'linux', 'windows')
$MissingHost = $false
foreach ($HostDirectory in $RequiredHosts) {
    if (-not (Test-Path (Join-Path $Root $HostDirectory))) {
        $MissingHost = $true
        break
    }
}

if ($MissingHost) {
    flutter create . `
        --project-name sonic_nest `
        --org io.github.sanskarin `
        --platforms=android,ios,macos,linux,windows `
        --no-pub
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter platform generation failed with exit code $LASTEXITCODE."
    }
}

$GeneratedWidgetTest = Join-Path $Root 'test/widget_test.dart'
if (Test-Path $GeneratedWidgetTest) {
    Remove-Item $GeneratedWidgetTest -Force
}

$AndroidOverrideRoot = Join-Path $Root 'tool/platform_overrides/android/app/src/main'
$AndroidMainRoot = Join-Path $Root 'android/app/src/main'
Copy-Item (Join-Path $AndroidOverrideRoot 'AndroidManifest.xml') `
    (Join-Path $AndroidMainRoot 'AndroidManifest.xml') -Force

$KotlinDestination = Join-Path $AndroidMainRoot 'kotlin/io/github/sanskarin/sonic_nest'
New-Item -ItemType Directory -Force -Path $KotlinDestination | Out-Null
Copy-Item (Join-Path $AndroidOverrideRoot 'kotlin/io/github/sanskarin/sonic_nest/MainActivity.kt') `
    (Join-Path $KotlinDestination 'MainActivity.kt') -Force
Copy-Item (Join-Path $AndroidOverrideRoot 'kotlin/io/github/sanskarin/sonic_nest/RecordingForegroundService.kt') `
    (Join-Path $KotlinDestination 'RecordingForegroundService.kt') -Force

$Python = Get-Command python -ErrorAction SilentlyContinue
if (-not $Python) {
    $Python = Get-Command python3 -ErrorAction SilentlyContinue
}
if (-not $Python) {
    throw 'Python 3 is required to apply generated platform patches.'
}
& $Python.Source 'tool/patch_generated_platforms.py'
if ($LASTEXITCODE -ne 0) {
    throw "Platform patching failed with exit code $LASTEXITCODE."
}

Write-Host 'SonicNest platform scaffolding is ready.'
