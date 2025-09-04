# Fish configuration for CLI productivity

# Disable greeting message
set -g fish_greeting ""

# Environment variables
set -gx EDITOR vim
set -gx LANG en_US.UTF-8

# PATH configuration
switch (uname)
    case Darwin
        # macOS
        # Intel Mac用Homebrew
        if test -d /usr/local/bin
            set -gx PATH /usr/local/bin $PATH
        end
        # Apple Silicon Mac用Homebrew  
        if test -d /opt/homebrew/bin
            set -gx PATH /opt/homebrew/bin $PATH
        end
    case Linux
        # Linux標準パス
        if test -d /usr/local/bin
            set -gx PATH /usr/local/bin $PATH
        end
        # ユーザーローカル
        if test -d ~/.local/bin
            set -gx PATH ~/.local/bin $PATH
        end
        # Linuxbrew（Linux版Homebrew）
        if test -d /home/linuxbrew/.linuxbrew/bin
            set -gx PATH /home/linuxbrew/.linuxbrew/bin $PATH
        end
        # ユーザー個別Linuxbrew
        if test -d ~/.linuxbrew/bin
            set -gx PATH ~/.linuxbrew/bin $PATH
        end
end
# Starship prompt
starship init fish | source

# Basic abbreviations (fishの推奨方式)
abbr ll "ls -la"
abbr la "ls -a"
abbr l "ls -CF"
abbr .. "cd .."
abbr ... "cd ../.."

# Git abbreviations
abbr gs "git status"
abbr ga "git add"
abbr gc "git commit"
abbr gp "git push"
abbr gl "git log --oneline"
abbr gd "git diff"
abbr gb "git branch"
abbr gco "git checkout"
abbr gpl "git pull"
abbr gcm "git commit -m"

# Directory shortcuts
abbr dt "cd ~/Desktop"
abbr dl "cd ~/Downloads"
abbr docs "cd ~/Documents"

# System abbreviations
abbr reload "source ~/.config/fish/config.fish"
abbr editfish "vim ~/.config/fish/config.fish"

# 一部はaliasの方が適切なもの
alias grep "grep --color=auto"
