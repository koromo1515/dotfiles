-- NoMouseLife - WezTerm config (tmux delegate mode)
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- === Font ===
config.font = wezterm.font_with_fallback {
  'Noto Sans Mono',
  'Noto Serif CJK JP',
}
config.font_size = 12.0

-- === Theme: Catppuccin Mocha ===
config.color_scheme = 'Catppuccin Mocha'

-- === Window ===
config.window_decorations = 'NONE'
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20
config.text_background_opacity = 0.9
config.window_padding = { left = 2, right = 2, top = 2, bottom = 2 }
config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = 'NeverPrompt'

-- === Cursor ===
config.default_cursor_style = 'SteadyBar'

-- === Scrollback (tmux handles this, but keep as fallback) ===
config.scrollback_lines = 50000

-- === IME (Japanese input) ===
config.use_ime = true
config.xim_im_name = 'ibus'

-- === Keys: minimal, delegate everything to tmux ===
config.keys = {
  { key = 'C', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'V', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },
}

-- === tmux auto-start ===
-- Attach to existing session, or create new one if none exists
-- Uses grouped sessions to avoid mirroring
config.default_prog = { '/usr/bin/zsh', '-l', '-c',
  'tmux attach 2>/dev/null || tmux new-session -s main'
}

return config
