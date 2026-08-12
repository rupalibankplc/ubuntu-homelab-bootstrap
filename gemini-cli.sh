#!/bin/bash

# Install Google Gemini CLI
set -e

echo "=== Updating system ==="
sudo apt update && sudo apt upgrade -y

echo "=== Installing Python and dependencies ==="
sudo apt install -y python3 python3-pip python3-venv curl wget

echo "=== Installing Gemini CLI ==="
# Install via pip
pip3 install --upgrade pip
pip3 install google-generativeai

# Install gemini-cli tool (if available)
pip3 install gemini-cli

echo "=== Verifying installation ==="
echo "Python version:"
python3 --version

echo -e "\nPip packages installed:"
pip3 list | grep -i gemini

echo "=== Configuration ==="
echo "To use Gemini CLI, you need to set your API key:"
echo ""
echo "Option 1: Export as environment variable"
echo "  export GOOGLE_API_KEY='your-api-key-here'"
echo ""
echo "Option 2: Store in ~/.gemini/config"
mkdir -p ~/.gemini
cat > ~/.gemini/config.example << 'EOF'
# Gemini CLI Configuration
GOOGLE_API_KEY=your-api-key-here
EOF

echo "  Edit: nano ~/.gemini/config"
echo ""
echo "Get your API key from: https://ai.google.dev"
echo ""

echo "=== Testing Gemini CLI ==="
echo "Run: gemini --help"
echo ""

echo "✅ Gemini CLI installation complete!"