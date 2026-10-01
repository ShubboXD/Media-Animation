# ==============================================================================
# Fluid Volume & Media OSD - Windows PowerShell Installer
# ==============================================================================

Write-Host "Installing Fluid Volume & Media OSD..." -ForegroundColor Cyan

# 1. Check Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Python 3 is required. Please install Python from https://www.python.org/" -ForegroundColor Red
    exit 1
}

# 2. Check / Install PyQt5
Write-Host "Checking PyQt5 dependency..." -ForegroundColor Yellow
python -c "import PyQt5" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installing PyQt5 via pip..." -ForegroundColor Yellow
    pip install PyQt5
}

# 3. Target Paths
$InstallDir = "$env:LOCALAPPDATA\Programs\volume-osd"
$ConfigDir = "$env:APPDATA\volume-osd"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

Copy-Item -Recurse -Force "$PSScriptRoot\volume_osd" "$InstallDir\"
Copy-Item -Force "$PSScriptRoot\setup.py" "$InstallDir\"
Copy-Item -Force "$PSScriptRoot\pyproject.toml" "$InstallDir\"

pip install -e "$InstallDir"

Write-Host "Installed successfully to $InstallDir!" -ForegroundColor Green
Write-Host "To run the OSD:" -ForegroundColor Cyan
Write-Host "  python -m volume_osd.cli --daemon"
Write-Host "  python -m volume_osd.cli up 5"
Write-Host "  python -m volume_osd.cli play-pause"
