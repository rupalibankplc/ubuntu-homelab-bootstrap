#!/bin/bash

set -e

echo "=================================================="
echo "Installing Zsh + Arch Linux Terminal + Server Stats"
echo "=================================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

# Step 2: Install Zsh and dependencies
print_info "Step 2: Installing Zsh and dependencies..."
sudo apt install -y zsh curl git wget htop net-tools lsb-release neofetch
print_status "Zsh and dependencies installed"

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

# Step 8: Create server stats functions
print_info "Step 8: Creating server statistics functions..."
mkdir -p ~/.local/bin

# Create the system_stats function
cat > ~/.local/bin/system_stats << 'EOF'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${CYAN}              🖥️  SERVER INFORMATION & STATISTICS${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_section() {
    echo -e "\n${YELLOW}📌 $1${NC}"
    echo -e "${CYAN}─────────────────────────────────────${NC}"
}

# Header
print_header

# System Information
print_section "SYSTEM INFORMATION"
echo -e "${GREEN}Hostname:${NC}         $(hostname)"
echo -e "${GREEN}OS:${NC}               $(lsb_release -d | cut -f2)"
echo -e "${GREEN}Kernel:${NC}           $(uname -r)"
echo -e "${GREEN}Architecture:${NC}     $(uname -m)"
echo -e "${GREEN}Uptime:${NC}           $(uptime -p)"

# CPU Information
print_section "CPU INFORMATION"
echo -e "${GREEN}CPU Model:${NC}        $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
echo -e "${GREEN}CPU Cores:${NC}        $(nproc) cores"
echo -e "${GREEN}CPU Sockets:${NC}      $(lscpu | grep '^Socket' | cut -d: -f2 | xargs)"
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')
echo -e "${GREEN}CPU Usage:${NC}        ${RED}${CPU_USAGE}${NC}"

# Memory Information
print_section "MEMORY INFORMATION"
TOTAL_MEM=$(free -h | awk '/^Mem:/ {print $2}')
USED_MEM=$(free -h | awk '/^Mem:/ {print $3}')
AVAILABLE_MEM=$(free -h | awk '/^Mem:/ {print $7}')
MEM_PERCENT=$(free | awk '/^Mem:/ {printf("%.1f", ($3/$2)*100)}')

echo -e "${GREEN}Total Memory:${NC}     ${TOTAL_MEM}"
echo -e "${GREEN}Used Memory:${NC}      ${USED_MEM} (${RED}${MEM_PERCENT}%${NC})"
echo -e "${GREEN}Available Memory:${NC} ${AVAILABLE_MEM}"

# Swap Information
TOTAL_SWAP=$(free -h | awk '/^Swap:/ {print $2}')
USED_SWAP=$(free -h | awk '/^Swap:/ {print $3}')
echo -e "${GREEN}Total Swap:${NC}       ${TOTAL_SWAP}"
echo -e "${GREEN}Used Swap:${NC}        ${USED_SWAP}"

# Disk Information
print_section "DISK INFORMATION"
echo -e "${GREEN}Filesystems:${NC}"
df -h | grep -E "^/dev/" | awk '{
    total = $2;
    used = $3;
    percent = $5;
    device = $1;
    mount = $6;
    
    # Color coding based on usage percentage
    num = substr(percent, 1, length(percent)-1);
    if (num > 80) color = "\033[0;31m";
    else if (num > 60) color = "\033[1;33m";
    else color = "\033[0;32m";
    
    printf "  %-15s %8s / %8s [%s%5s\033[0m] → %s\n", device, used, total, color, percent, mount
}'

# Network Information
print_section "NETWORK INFORMATION"
echo -e "${GREEN}Interfaces:${NC}"
hostname -I | tr ' ' '\n' | while read ip; do
    echo "  └─ $ip"
done

echo -e "\n${GREEN}DNS Servers:${NC}"
cat /etc/resolv.conf 2>/dev/null | grep nameserver | head -3 | awk '{print "  └─ " $2}'

# Process Information
print_section "PROCESS INFORMATION"
TOTAL_PROCS=$(ps aux | wc -l)
echo -e "${GREEN}Total Processes:${NC}  ${TOTAL_PROCS}"

# Top Processes by CPU
echo -e "\n${YELLOW}Top 5 Processes by CPU:${NC}"
ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  %-30s %6s%% CPU\n", $11, $3}'

# Top Processes by Memory
echo -e "\n${YELLOW}Top 5 Processes by Memory:${NC}"
ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "  %-30s %6s%% MEM\n", $11, $4}'

# Services Status
print_section "SERVICES STATUS"
for service in ssh nginx apache2 mysql postgresql docker; do
    if systemctl list-unit-files | grep -q "^$service"; then
        status=$(systemctl is-active $service 2>/dev/null)
        if [ "$status" = "active" ]; then
            echo -e "${GREEN}✓${NC} $service: ${GREEN}${status}${NC}"
        else
            echo -e "${RED}✗${NC} $service: ${RED}${status}${NC}"
        fi
    fi
done

# Last Login
print_section "LAST LOGIN"
lastlog -t 1 | tail -1 | awk '{print "  " $0}' || echo "  No recent logins"

# Footer
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Generated at: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
EOF

chmod +x ~/.local/bin/system_stats
print_status "Server statistics functions created"

# Step 9: Configure .zshrc
print_info "Step 9: Configuring .zshrc..."

# Backup original .zshrc
cp ~/.zshrc ~/.zshrc.backup

# Replace theme
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Update plugins
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting archlinux)/' ~/.zshrc

# Add PATH for local bin if not present
if ! grep -q "~/.local/bin" ~/.zshrc; then
    sed -i '/^export PATH=/d' ~/.zshrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
fi

# Add custom functions and aliases
if ! grep -q "# Server Stats Aliases" ~/.zshrc; then
    cat >> ~/.zshrc << 'EOF'

# Server Stats Aliases
alias stats='system_stats'
alias sysinfo='system_stats'
alias info='neofetch'
alias top-cpu='ps aux --sort=-%cpu | head -11'
alias top-mem='ps aux --sort=-%mem | head -11'
alias diskspace='df -h'
alias meminfo='free -h'
alias netstat-listen='ss -tlnp'
alias ports='ss -tlnp'
alias load='cat /proc/loadavg'
alias users='who'

# Arch-like aliases
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias search='apt-cache search'
alias show='apt-cache show'
alias pacman='sudo apt'

# System monitoring
alias monitor='watch -n 1 "clear && system_stats"'
alias watch-cpu='watch -n 1 "top -b -n 1 | head -20"'
alias watch-mem='watch -n 1 "free -h"'

# Useful shortcuts
alias ll='ls -lah'
alias la='ls -la'
alias clear-cache='sudo sync && sudo echo 3 > /proc/sys/vm/drop_caches'
alias ssh-keygen='ssh-keygen -t rsa -b 4096'

EOF
fi

print_status ".zshrc configured with server stats"

# Step 10: Set Zsh as default shell
print_info "Step 10: Setting Zsh as default shell..."
sudo chsh -s /usr/bin/zsh $USER
print_status "Zsh set as default shell"

echo ""
echo "=================================================="
echo -e "${GREEN}✓ Installation Complete!${NC}"
echo "=================================================="
echo ""
echo "📝 AVAILABLE COMMANDS:"
echo ""
echo -e "  ${CYAN}Server Statistics:${NC}"
echo "    • ${YELLOW}stats${NC} or ${YELLOW}sysinfo${NC}     - Display comprehensive server info"
echo "    • ${YELLOW}info${NC}                - Display system info with neofetch"
echo "    • ${YELLOW}monitor${NC}              - Live server stats updates (every 1s)"
echo ""
echo -e "  ${CYAN}Performance Monitoring:${NC}"
echo "    • ${YELLOW}top-cpu${NC}               - Top 10 CPU consuming processes"
echo "    • ${YELLOW}top-mem${NC}               - Top 10 memory consuming processes"
echo "    • ${YELLOW}watch-cpu${NC}             - Watch CPU usage (updates every 1s)"
echo "    • ${YELLOW}watch-mem${NC}             - Watch memory usage (updates every 1s)"
echo "    • ${YELLOW}load${NC}                 - Display system load average"
echo ""
echo -e "  ${CYAN}System Information:${NC}"
echo "    • ${YELLOW}diskspace${NC}             - Disk usage for all filesystems"
echo "    • ${YELLOW}meminfo${NC}               - Memory and swap information"
echo "    • ${YELLOW}ports${NC} or ${YELLOW}netstat-listen${NC} - Open listening ports"
echo "    • ${YELLOW}users${NC}                 - Currently logged in users"
echo ""
echo -e "  ${CYAN}System Administration:${NC}"
echo "    • ${YELLOW}update${NC}                - Update system (apt update + upgrade)"
echo "    • ${YELLOW}install${NC}               - Install packages (apt install)"
echo "    • ${YELLOW}remove${NC}                - Remove packages (apt remove)"
echo "    • ${YELLOW}search${NC}                - Search packages"
echo "    • ${YELLOW}clear-cache${NC}           - Clear system cache"
echo ""
echo -e "  ${CYAN}Other:${NC}"
echo "    • ${YELLOW}ll${NC}                   - Long format listing (ls -lah)"
echo "    • ${YELLOW}la${NC}                   - List all files (ls -la)"
echo ""
echo "⚙️  NEXT STEPS:"
echo ""
echo "1. Apply shell changes:"
echo -e "   ${CYAN}exec zsh${NC}"
echo ""
echo "2. Configure Powerlevel10k theme:"
echo -e "   ${CYAN}p10k configure${NC}"
echo ""
echo "3. View server stats immediately:"
echo -e "   ${CYAN}stats${NC}"
echo ""
echo "4. Set terminal font to: ${YELLOW}MesloLGS NF${NC}"
echo "   (Settings → Preferences → Appearance → Font)"
echo ""
echo "5. Backup of original .zshrc: ${YELLOW}~/.zshrc.backup${NC}"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
echo ""
