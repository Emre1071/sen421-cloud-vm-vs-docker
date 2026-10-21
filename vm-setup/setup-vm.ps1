$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

if (-not (Get-Command vagrant -ErrorAction SilentlyContinue)) {
    throw "vagrant is not on PATH"
}
if (-not (Get-Command VBoxManage -ErrorAction SilentlyContinue)) {
    throw "VBoxManage is not on PATH"
}

& vagrant up --provider virtualbox
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
