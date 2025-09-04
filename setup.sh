#!/bin/bash
# Complete setup script for CLI environment dotfiles
# Supports both macOS and Linux with automatic Homebrew installation

set -e

DOTFILES_DIR="$HOME/dotfiles"
OS_TYPE=$(uname)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running with proper permissions
check_permissions() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
}

# Install Homebrew if not present
install_homebrew() {
    if command -v brew &> /dev/null; then
        print_success "Homebrew already installed"
        return
    fi
    
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        # macOS
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    elif [[ "$OS_TYPE" == "Linux" ]]; then
        # Linux
        if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi
    
    print_success "Homebrew installed successfully"
}

# Install required packages
install_packages() {
    print_status "Installing required packages..."
    
    local packages=(
        "fish"
        "tmux" 
        "starship"
    )
    
    # Optional packages (install if available)
    local optional_packages=(
        "alacritty"
    )
    
    # Install required packages
    for package in "${packages[@]}"; do
        print_status "Installing $package..."
        if brew install "$package"; then
            print_success "$package installed"
        else
            print_error "Failed to install $package"
            exit 1
        fi
    done
    
    # Install optional packages
    for package in "${optional_packages[@]}"; do
        print_status "Installing optional package: $package..."
        if brew install "$package" 2>/dev/null; then
            print_success "$package installed"
        else
            print_warning "$package installation skipped (not available or failed)"
        fi
    done
}

# Install Nerd Font for terminal
install_font() {
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        print_status "Installing Nerd Font for macOS..."
        if brew tap homebrew/cask-fonts && brew install --cask font-meslo-lg-nerd-font; then
            print_success "Nerd Font installed"
        else
            print_warning "Font installation failed, continuing..."
        fi
    else
        print_warning "Font installation for Linux requires manual setup"
        print_status "Please install a Nerd Font manually: https://www.nerdfonts.com/"
    fi
}

# Create configuration directories
create_config_dirs() {
    print_status "Creating configuration directories..."
    
    mkdir -p ~/.config/fish
    mkdir -p ~/.config/alacritty 2>/dev/null || true
    
    print_success "Configuration directories created"
}

# Backup existing configurations
backup_existing_configs() {
    print_status "Backing up existing configurations..."
    
    local backup_dir="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
    
    if [[ -f ~/.config/fish/config.fish ]]; then
        mkdir -p "$backup_dir"
        cp ~/.config/fish/config.fish "$backup_dir/config.fish.backup"
        print_success "Fish config backed up to $backup_dir"
    fi
    
    if [[ -f ~/.tmux.conf ]]; then
        mkdir -p "$backup_dir"
        cp ~/.tmux.conf "$backup_dir/tmux.conf.backup"  
        print_success "Tmux config backed up to $backup_dir"
    fi
    
    if [[ -f ~/.config/alacritty/alacritty.yml ]]; then
        mkdir -p "$backup_dir"
        cp ~/.config/alacritty/alacritty.yml "$backup_dir/alacritty.yml.backup"
        print_success "Alacritty config backed up to $backup_dir"
    fi
}

# Create symlinks
create_symlinks() {
    print_status "Creating symlinks..."
    
    # Fish configuration
    if [[ -f "$DOTFILES_DIR/config.fish" ]]; then
        ln -sf "$DOTFILES_DIR/config.fish" ~/.config/fish/config.fish
        print_success "Fish config linked"
    else
        print_error "config.fish not found in $DOTFILES_DIR"
        exit 1
    fi
    
    # Tmux configuration (if exists)
    if [[ -f "$DOTFILES_DIR/tmux.conf" ]]; then
        ln -sf "$DOTFILES_DIR/tmux.conf" ~/.tmux.conf
        print_success "Tmux config linked"
    else
        print_warning "tmux.conf not found, skipping"
    fi
    
    # Alacritty configuration (if exists)
    if [[ -f "$DOTFILES_DIR/alacritty.yml" ]]; then
        ln -sf "$DOTFILES_DIR/alacritty.yml" ~/.config/alacritty/alacritty.yml
        print_success "Alacritty config linked"
    else
        print_warning "alacritty.yml not found, skipping"
    fi
}

# Set fish as default shell
set_fish_shell() {
    print_status "Setting fish as default shell..."
    
    local fish_path
    fish_path=$(command -v fish)
    
    if [[ -z "$fish_path" ]]; then
        print_error "Fish not found in PATH"
        exit 1
    fi
    
    # Add fish to /etc/shells if not already there
    if ! grep -q "$fish_path" /etc/shells 2>/dev/null; then
        print_status "Adding fish to /etc/shells (requires sudo)"
        echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
    fi
    
    # Change default shell
    if [[ "$SHELL" != "$fish_path" ]]; then
        print_status "Changing default shell to fish"
        chsh -s "$fish_path"
        print_success "Default shell changed to fish"
    else
        print_success "Fish is already the default shell"
    fi
}

# Main setup function
main() {
    echo "🚀 Starting CLI Environment Setup"
    echo "=================================="
    echo ""
    
    print_status "Detected OS: $OS_TYPE"
    echo ""
    
    # Run setup steps
    check_permissions
    check_prerequisites
    install_homebrew
    install_packages
    install_font
    create_config_dirs
    backup_existing_configs
    create_symlinks
    set_fish_shell
    
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Restart your terminal or run: exec fish"
    echo "2. If using Alacritty, restart it to load the new configuration"
    echo "3. Run 'tmux' to test tmux setup"
    echo ""
    print_success "Your CLI environment is ready!"
}

# Run main function
main "$@"
