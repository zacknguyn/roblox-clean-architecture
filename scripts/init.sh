#!/usr/bin/env bash
# init.sh — Run once after cloning template
# Usage: ./scripts/init.sh

set -e

echo "🚀  Bootstrapping Roblox Clean Architecture project..."

# 1. Install toolchain via Rokit
echo "📦  Installing rokit tools (rojo, wally, selene, stylua)..."
rokit install

# 2. Install Wally packages
echo "📚  Installing Wally packages..."
wally install

# 3. Build place file
echo "🔨  Building place.rbxlx..."
rojo build -o place.rbxlx

# 4. Verify architecture
echo "🔍  Running architecture validation..."
selene src
stylua src

echo "
✅  Project ready!

Next steps:
  rojo serve              # Live sync to Studio
  # or open place.rbxlx in Studio

Useful commands:
  phong-rojo lint         # Check architecture (if CLI installed)
  phong-rojo validate     # Run selene plugin rules
"

# 5. Optional: Install skill into AI agents
if command -v phong-rojo &> /dev/null; then
    echo "💡  Run 'phong-rojo install --with-skill' to install skill into AI agents"
fi