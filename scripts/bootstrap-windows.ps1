$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$env:UV_CACHE_DIR = Join-Path $projectRoot '.cache/uv'
$env:UV_PYTHON_INSTALL_DIR = Join-Path $projectRoot '.local/python'
$bootstrap = Join-Path $projectRoot '.local/bootstrap'
$uv = Join-Path $bootstrap 'Scripts/uv.exe'
if (-not (Test-Path $uv)) {
    & python -m venv --without-pip $bootstrap
    if ($LASTEXITCODE -ne 0) { throw 'Cannot create bootstrap environment' }
    & python -m pip --python "$bootstrap/Scripts/python.exe" install uv==0.13.6
    if ($LASTEXITCODE -ne 0) { throw 'Cannot install uv' }
}
& $uv sync --project $projectRoot --locked --python 3.13
if ($LASTEXITCODE -ne 0) { throw 'Environment sync failed' }
& "$PSScriptRoot/cs336.ps1" doctor a1 --device cuda
exit $LASTEXITCODE
