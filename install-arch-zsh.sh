#!/bin/bash

set -e

echo "=================================================="
echo "Installing Zsh + Arch Linux Terminal on Ubuntu"
echo "=================================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[*]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Step 1: Update system
print_info "Step 1: Updating system packages..."
sudo apt update
sudo apt upgrade -y
print_status "System updated"

# Step 2: Install Zsh
print_info "Step 2: Installing Zsh..."
sudo apt install -y zsh curl git wget
print_status "Zsh installed"

# Step 3: Install Oh-My-Zsh
print_info "Step 3: Installing Oh-My-Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
print_status "Oh-My-Zsh installed"

# Step 4: Install Powerline Fonts
print_info "Step 4: Installing Powerline fonts..."
git clone https://github.com/powerline/fonts.git --depth=1 /tmp/powerline-fonts
cd /tmp/powerline-fonts
./install.sh
cd -
rm -rf /tmp/powerline-fonts
print_status "Powerline fonts installed"

# Step 5: Install Nerd Fonts
print_info "Step 5: Installing Nerd Fonts (Meslo)..."
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

# Download Meslo Nerd Font
wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/Meslo.zip" -O meslo.zip
unzip -q meslo.zip
rm meslo.zip

fc-cache -fvf ~/.local/share/fonts/ > /dev/null 2>&1
cd -
print_status "Nerd Fonts installed"

# Step 6: Install Powerlevel10k Theme
print_info "Step 6: Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
print_status "Powerlevel10k installed"

# Step 7: Install Zsh Plugins
print_info "Step 7: Installing Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
print_status "Zsh plugins installed"

# Step 8: Configure .zshrc
print_info "Step 8: Configuring .zshrc..."

# Backup original .zshrc
cp ~/.zshrc ~/.zshrc.backup

# Replace theme
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Update plugins
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting archlinux)/' ~/.zshrc

# Add aliases at the end if not already present
if ! grep -q "# Arch-like aliases" ~/.zshrc; then
    cat >> ~/.zshrc << 'EOF'

# Arch-like aliases
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias search='apt-cache search'
alias info='apt-cache show'
alias pacman='sudo apt'
EOF
fi

print_status ".zshrc configured"

# Step 9: Set Zsh as default shell
print_info "Step 9: Setting Zsh as default shell..."
sudo chsh -s /usr/bin/zsh $USER
print_status "Zsh set as default shell"

echo ""
echo "=================================================="
echo -e "${GREEN}Installation Complete!${NC}"
echo "=================================================="
echo ""
echo "Next steps:"
echo "1. Log out and log back in for changes to take effect"
echo "   Or run: exec zsh"
echo ""
echo "2. First time setup:"
echo "   Run 'p10k configure' to customize Powerlevel10k theme"
echo ""
echo "3. Terminal settings for best experience:"
echo "   - Font: MesloLGS NF or Meslo Nerd Font"
echo "   - Color scheme: Dracula or Nord"
echo "   - Opacity: 95-98%"
echo ""
echo "4. Useful aliases configured:"
echo "   - update (apt update + upgrade)"
echo "   - install (apt install)"
echo "   - remove (apt remove)"
echo "   - search (apt-cache search)"
echo "   - info (apt-cache show)"
echo "   - pacman (sudo apt)"
echo ""
echo "Backup of original .zshrc saved as: ~/.zshrc.backup"
echo ""
