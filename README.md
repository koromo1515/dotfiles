# dotfiles

zsh + tmux + WezTerm environment with one-command setup.

## Quick Start

```bash
git clone https://github.com/koromo1515/dotfiles.git ~/dotfiles
cd ~/dotfiles && chmod +x setup.sh && ./setup.sh
```

Requires: `tmux`, `mpv` (sudo apt install tmux mpv)

## What's Included

### zsh
- Zinit plugin manager (fast-syntax-highlighting, autosuggestions, completions)
- Starship prompt
- History search with arrow keys

### tmux (`Ctrl+a` prefix)
| Key | Action |
|-----|--------|
| `Ctrl+a \` | Split left/right |
| `Ctrl+a -` | Split top/bottom |
| `Ctrl+a h/j/k/l` | Navigate panes (vim-style) |
| `Ctrl+a H/J/K/L` | Resize panes |
| `Ctrl+a b` | System monitor (bottom) |
| `Ctrl+a W` | Weather forecast |
| `Ctrl+a y` | YouTube (yewtube) |
| `Ctrl+a w` | Window/pane list |
| `Ctrl+a p` | Pomodoro timer |
| `Ctrl+a r` | Reload config |

### Status Bar
Session / Git status / CPU+RAM graph / Battery / Weather / Uptime / DateTime

### WezTerm
- Catppuccin Mocha theme
- Background opacity 0.85 (transparent for anime viewing)
- Auto-start tmux session
- Japanese IME support

### Tools (auto-installed)
- [gitmux](https://github.com/arl/gitmux) - Git info in status bar
- [tmux-mem-cpu-load](https://github.com/thewtex/tmux-mem-cpu-load) - CPU/RAM graph
- [bottom (btm)](https://github.com/ClementTsang/bottom) - System monitor
- [yewtube](https://github.com/mps-youtube/yewtube) - YouTube in terminal
- [Starship](https://starship.rs/) - Cross-shell prompt

### Theme
[Catppuccin Mocha](https://github.com/catppuccin/tmux) with rounded window style
