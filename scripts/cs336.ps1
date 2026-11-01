param(
    [Parameter(Mandatory, Position=0)]
    [ValidateSet('sync','doctor','collect','test','fixtures','run')][string]$Action,
    [Parameter(Position=1)][ValidateSet('a1')][string]$Assignment = 'a1',
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$ExtraArgs
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$env:UV_CACHE_DIR = Join-Path $projectRoot '.cache/uv'
$env:UV_PYTHON_INSTALL_DIR = Join-Path $projectRoot '.local/python'
$env:HF_HOME = Join-Path $projectRoot '.cache/huggingface'
$env:TORCH_HOME = Join-Path $projectRoot '.cache/torch'
$env:TEMP = Join-Path $projectRoot '.cache/tmp'
$env:TMP = $env:TEMP
New-Item -ItemType Directory -Path $env:TEMP -Force | Out-Null
$env:PYTHONUTF8 = '1'
$env:PYTEST_DISABLE_PLUGIN_AUTOLOAD = '1'
if (-not $env:WANDB_MODE) { $env:WANDB_MODE = 'offline' }
$uv = Join-Path $projectRoot '.venv/Scripts/uv.exe'
if (-not (Test-Path $uv)) {
    $uv = (Get-Command uv -ErrorAction Stop).Source
}
$workDir = Join-Path $projectRoot 'assignments/assignment1-basics'
Push-Location $workDir
try {
    switch ($Action) {
        'sync' { & $uv sync --project $projectRoot --locked --python 3.13 @ExtraArgs }
        'doctor' { & $uv run --project $projectRoot --locked python "$PSScriptRoot/doctor.py" --assignment a1 @ExtraArgs }
        'collect' { & $uv run --project $projectRoot --locked python "$PSScriptRoot/windows-pytest.py" --collect-only -q tests @ExtraArgs }
        'test' { & $uv run --project $projectRoot --locked python "$PSScriptRoot/windows-pytest.py" @ExtraArgs }
        'fixtures' { & $uv run --project $projectRoot --locked python "$PSScriptRoot/fetch-assets.py" a1 @ExtraArgs }
        'run' { & $uv run --project $projectRoot --locked @ExtraArgs }
    }
    $result = $LASTEXITCODE
} finally { Pop-Location }
exit $result
