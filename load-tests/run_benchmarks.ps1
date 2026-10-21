param(
    [string]$BaseUrl = "http://127.0.0.1:8000",
    [string]$ResultDir = "results/docker"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

$OutDir = Join-Path $Root ($ResultDir -replace "/", "\")
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$env:BASE_URL = $BaseUrl
$failed = $false
$relative = ($ResultDir -replace "\\", "/").TrimEnd("/")

for ($run = 1; $run -le 3; $run++) {
    $env:RESULT_PATH = "$relative/results_run$run.json"
    & k6 run (Join-Path $Root "test-script.js")
    if ($LASTEXITCODE -ne 0) {
        $failed = $true
    }
    if ($run -lt 3) {
        Start-Sleep -Seconds 15
    }
}

if ($failed) {
    exit 1
}
