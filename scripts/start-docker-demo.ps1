param(
    [switch]$Build,
    [switch]$Detached,
    [switch]$LegacyPython
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker CLI was not found. Install Docker Desktop, restart PowerShell, then run this script again."
}

try {
    docker info *> $null
} catch {
    Write-Error "Docker CLI is installed, but Docker Desktop/daemon is not running. Start Docker Desktop and try again."
}

$composeArgs = @(
    "compose",
    "-f", "docker/docker-compose.yml",
    "-f", "docker/docker-compose.local.yml"
)

if ($LegacyPython) {
    $composeArgs += @("--profile", "legacy-python")
}

$composeArgs += "up"

if ($Build) {
    $composeArgs += "--build"
}

if ($Detached) {
    $composeArgs += "-d"
}

$composeArgs += "sensing-server"

Write-Host "Starting RuView Docker demo with simulated data..."
Write-Host "UI:  http://localhost:3300/ui/index.html"
Write-Host "API: http://localhost:3300/health"
Write-Host ""

& docker @composeArgs
