# NeonClipping launcher (Windows). Creates .venv on first run, starts the app, opens the browser.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (-not (Test-Path .venv/Scripts/python.exe)) {
    python -m venv .venv
    .venv/Scripts/python.exe -m pip install -r requirements.txt
}

# Keep large model downloads inside this app folder.
$env:HF_HOME = Join-Path $PSScriptRoot 'data\huggingface'
$env:FACECAM_ASR_MODEL = Join-Path $PSScriptRoot 'data\models\large-v3'
$ollamaData = Join-Path $PSScriptRoot 'data\ollama'
$env:OLLAMA_ID = Join-Path $ollamaData 'id_ed25519'
$env:OLLAMA_MODELS = Join-Path $ollamaData 'models'
New-Item -ItemType Directory -Path $env:HF_HOME, $env:OLLAMA_MODELS -Force | Out-Null

# Start the optional local AI service if Ollama is installed and not already running.
$ollamaExe = Join-Path $env:LOCALAPPDATA 'Programs\Ollama\ollama.exe'
if (Test-Path $ollamaExe) {
    $ollamaReady = $false
    try {
        Invoke-RestMethod 'http://127.0.0.1:11434/api/tags' -TimeoutSec 2 | Out-Null
        $ollamaReady = $true
    } catch {}
    if (-not $ollamaReady) {
        Start-Process -FilePath $ollamaExe -ArgumentList 'serve' -WindowStyle Hidden
    }
}

Start-Process 'http://127.0.0.1:8770'
.venv/Scripts/python.exe app.py
