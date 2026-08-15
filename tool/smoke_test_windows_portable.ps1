param(
    [string]$ArchivePath = '',
    [int]$StartupSeconds = 8
)

$ErrorActionPreference = 'Stop'

if ($StartupSeconds -lt 2 -or $StartupSeconds -gt 30) {
    throw 'StartupSeconds must be between 2 and 30 seconds.'
}

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

$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("sonicnest-windows-smoke-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null

$Process = $null
try {
    Expand-Archive -LiteralPath $ArchivePath -DestinationPath $TempRoot -Force
    $ExecutablePath = Join-Path $TempRoot 'sonic_nest.exe'
    if (-not (Test-Path -LiteralPath $ExecutablePath -PathType Leaf)) {
        throw 'Portable package does not contain sonic_nest.exe at its root.'
    }

    $Process = Start-Process -FilePath $ExecutablePath -WorkingDirectory $TempRoot -PassThru
    Start-Sleep -Seconds $StartupSeconds
    $Process.Refresh()

    if ($Process.HasExited) {
        throw "SonicNest exited during the $StartupSeconds-second startup smoke. Exit code: $($Process.ExitCode)"
    }

    Write-Host "SonicNest remained running for the $StartupSeconds-second portable-package startup smoke."
} finally {
    if ($null -ne $Process) {
        try {
            $Process.Refresh()
            if (-not $Process.HasExited) {
                Stop-Process -Id $Process.Id -Force -ErrorAction SilentlyContinue
                $Process.WaitForExit(5000) | Out-Null
            }
        } catch {
            Write-Warning "Could not fully clean up smoke-test process: $($_.Exception.Message)"
        }
    }

    if (Test-Path -LiteralPath $TempRoot) {
        $Removed = $false
        for ($Attempt = 1; $Attempt -le 5; $Attempt++) {
            try {
                Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction Stop
                $Removed = $true
                break
            } catch {
                Start-Sleep -Milliseconds (250 * $Attempt)
            }
        }
        if (-not $Removed) {
            Write-Warning "Could not remove portable smoke-test directory: $TempRoot"
        }
    }
}
