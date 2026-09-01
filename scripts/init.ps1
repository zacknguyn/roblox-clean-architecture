# init.ps1 — Windows native alternative to init.sh
# Usage: powershell -ExecutionPolicy Bypass -File scripts\init.ps1

$ErrorActionPreference = "Stop"

Write-Host "🚀  Bootstrapping Roblox Clean Architecture project..." -ForegroundColor Cyan

# 1. Install toolchain via Rokit
Write-Host "📦  Installing rokit tools (rojo, wally, selene, stylua)..." -ForegroundColor Yellow
rokit install

# 2. Install Wally packages
Write-Host "📚  Installing Wally packages..." -ForegroundColor Yellow
wally install

# 3. Build place file
Write-Host "🔨  Building place.rbxlx..." -ForegroundColor Yellow
rojo build -o place.rbxlx

# 4. Verify architecture
Write-Host "🔍  Running architecture validation..." -ForegroundColor Yellow
selene src
stylua src

Write-Host @"
✅  Project ready!

Next steps:
  rojo serve              # Live sync to Studio
  # or open place.rbxlx in Studio

Useful commands:
  phong-rojo lint         # Check architecture (if CLI installed)
  phong-rojo validate     # Run selene plugin rules
"@ -ForegroundColor Green

# 5. Optional: Install skill into AI agents
if (Get-Command phong-rojo -ErrorAction SilentlyContinue) {
    Write-Host "💡  Run 'phong-rojo install --with-skill' to install skill into AI agents" -ForegroundColor Magenta
}