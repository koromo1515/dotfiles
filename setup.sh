#!/bin/bash
# dotfiles setup script
# Reproduces tmux environment on a fresh machine

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS_TYPE=$(uname)
ARCH=$(uname -m)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()      { echo -e "${GREEN}[ OK ]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()     { echo -e "${RED}[ERR ]${NC} $1"; }
has()     { command -v "$1" &>/dev/null; }

# --- PATH ---
setup_path() {
    mkdir -p "$HOME/.local/bin"
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

# --- zsh ---
setup_zsh() {
    info "Setting up zsh..."

    if ! has zsh; then
        warn "zsh is not installed. Install it first:"
        echo "  Ubuntu/Debian: sudo apt install zsh"
        echo "  macOS:         brew install zsh"
        return
    fi

    # Backup existing zshrc
    if [[ -f "$HOME/.zshrc" ]] && [[ ! -L "$HOME/.zshrc" ]]; then
        local backup="$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)"
        cp "$HOME/.zshrc" "$backup"
        warn "Existing .zshrc backed up to $backup"
    fi

    ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
    ok ".zshrc symlinked"

    # Install starship if missing
    if ! has starship; then
        info "Installing starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -b "$HOME/.local/bin" -y > /dev/null
        ok "starship installed"
    else
        ok "starship already installed"
    fi
}

# --- tmux config ---
setup_tmux_config() {
    info "Setting up tmux config..."
    mkdir -p "$HOME/.config/tmux"

    # Backup existing config if it's not already a symlink
    if [[ -f "$HOME/.config/tmux/tmux.conf" ]] && [[ ! -L "$HOME/.config/tmux/tmux.conf" ]]; then
        local backup="$HOME/.config/tmux/tmux.conf.bak.$(date +%Y%m%d%H%M%S)"
        cp "$HOME/.config/tmux/tmux.conf" "$backup"
        warn "Existing config backed up to $backup"
    fi

    ln -sf "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
    ok "tmux.conf symlinked"
}

# --- TPM ---
setup_tpm() {
    if [[ -d "$HOME/.config/tmux/plugins/tpm" ]]; then
        ok "TPM already installed"
        return
    fi
    info "Installing TPM..."
    git clone --depth 1 https://github.com/tmux-plugins/tpm \
        "$HOME/.config/tmux/plugins/tpm"
    ok "TPM installed"
}

# --- gitmux ---
setup_gitmux() {
    if has gitmux; then
        ok "gitmux already installed"
        return
    fi
    info "Installing gitmux..."
    local url
    if [[ "$OS_TYPE" == "Linux" ]]; then
        url="https://github.com/arl/gitmux/releases/download/v0.11.5/gitmux_v0.11.5_linux_amd64.tar.gz"
    elif [[ "$OS_TYPE" == "Darwin" ]]; then
        if [[ "$ARCH" == "arm64" ]]; then
            url="https://github.com/arl/gitmux/releases/download/v0.11.5/gitmux_v0.11.5_darwin_arm64.tar.gz"
        else
            url="https://github.com/arl/gitmux/releases/download/v0.11.5/gitmux_v0.11.5_darwin_amd64.tar.gz"
        fi
    fi
    local tmp; tmp=$(mktemp -d)
    curl -sL "$url" | tar xz -C "$tmp" gitmux
    mv "$tmp/gitmux" "$HOME/.local/bin/"
    rm -rf "$tmp"
    ok "gitmux installed"
}

# --- tmux-mem-cpu-load ---
setup_mem_cpu_load() {
    if has tmux-mem-cpu-load; then
        ok "tmux-mem-cpu-load already installed"
        return
    fi
    if ! has cmake || ! has g++; then
        warn "cmake/g++ not found. Skipping tmux-mem-cpu-load."
        warn "  Install with: sudo apt install cmake g++"
        return
    fi
    info "Building tmux-mem-cpu-load..."
    local tmp; tmp=$(mktemp -d)
    git clone --depth 1 https://github.com/thewtex/tmux-mem-cpu-load.git "$tmp/src"
    cd "$tmp/src"
    cmake . -DCMAKE_INSTALL_PREFIX="$HOME/.local" -DCMAKE_BUILD_TYPE=MinSizeRel > /dev/null
    make -j"$(nproc)" > /dev/null
    make install > /dev/null
    cd - &>/dev/null
    rm -rf "$tmp"
    ok "tmux-mem-cpu-load installed"
}

# --- bottom (btm) ---
setup_bottom() {
    if has btm; then
        ok "bottom (btm) already installed"
        return
    fi
    info "Installing bottom (btm)..."
    if [[ "$OS_TYPE" == "Linux" ]]; then
        local tmp; tmp=$(mktemp -d)
        curl -sLO --output-dir "$tmp" \
            "https://github.com/ClementTsang/bottom/releases/download/0.12.3/bottom_0.12.3-1_amd64.deb"
        dpkg -x "$tmp"/*.deb "$tmp/extracted"
        mv "$tmp/extracted/usr/bin/btm" "$HOME/.local/bin/"
        rm -rf "$tmp"
    elif [[ "$OS_TYPE" == "Darwin" ]]; then
        brew install bottom
    fi
    ok "bottom (btm) installed"
}

# --- Install tmux plugins ---
setup_tmux_plugins() {
    info "Installing tmux plugins via TPM..."
    "$HOME/.config/tmux/plugins/tpm/bin/install_plugins" 2>&1 \
        | grep -E "(Installing|Already|success)" || true
    ok "Tmux plugins installed"
}

# --- Main ---
main() {
    echo ""
    echo "=== dotfiles setup ==="
    info "OS: $OS_TYPE / Arch: $ARCH"
    echo ""

    if ! has tmux; then
        err "tmux is not installed. Install it first:"
        echo "  Ubuntu/Debian: sudo apt install tmux"
        echo "  macOS:         brew install tmux"
        exit 1
    fi

    setup_path
    setup_zsh
    setup_tmux_config
    setup_tpm
    setup_gitmux
    setup_mem_cpu_load
    setup_bottom
    setup_tmux_plugins

    echo ""
    echo "=== Setup complete! ==="
    echo "Start tmux and enjoy."
}

main "$@"
