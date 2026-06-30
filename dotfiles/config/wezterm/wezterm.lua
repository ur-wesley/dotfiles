-- Wesley's WezTerm config — Catppuccin Mocha, JetBrainsMono Nerd Font,
-- transparent + blurred background, mirrors dotfiles/config/rio/config.toml.
-- Runs on Windows; default shell drops into WSL → fish (same as Rio).
-- Docs: https://wezfurlong.org/wezterm/config/

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ---- Catppuccin Mocha palette -----------------------------------------
-- Identical hex values to dotfiles/config/rio/config.toml so the two
-- terminals render the same colors.
local mocha = {
  base      = '#1e1e2e',
  mantle    = '#181825',
  crust     = '#11111b',
  text      = '#cdd6f4',
  subtext1  = '#bac2de',
  subtext0  = '#a6adc8',
  overlay2  = '#7f849c',
  overlay1  = '#6c7086',
  overlay0  = '#585b70',
  surface2  = '#45475a',
  surface1  = '#313244',
  surface0  = '#1e1e2e',
  rosewater = '#f5e0dc',
  pink      = '#f5c2e7',
  mauve     = '#cba6f7',
  red       = '#f38ba8',
  maroon    = '#eba0ac',
  peach     = '#fab387',
  yellow    = '#f9e2af',
  green     = '#a6e3a1',
  teal      = '#94e2d5',
  sky       = '#89dceb',
  sapphire  = '#74c7ec',
  blue      = '#89b4fa',
  lavender  = '#b4befe',
}

-- ---- Window -----------------------------------------------------------
-- Match Rio: 1280x820 area, transparent w/ blur. On Windows 11 the OS
-- (DWM) applies acrylic blur automatically when window_background_opacity
-- is < 1.0; window_background_blur is a no-op there but kept for parity
-- with macOS / Linux blur. opacity=0.78 + blur=35 = strong frosted-glass.
config.window_decorations = 'RESIZE'        -- clean borderless title bar
config.window_background_opacity = 0.78     -- stronger frost: more desktop
config.window_background_blur = 35          -- visible through the panel
config.window_corner_radius = 12            -- Win11 rounded corners
                                              -- (matches Rio's rounded bg)

-- Padding — mirrors Rio's [24, 12, 8, 12].
config.window_padding = {
  left   = 12,
  right  = 12,
  top    = 24,
  bottom = 8,
}

-- ---- Fonts ------------------------------------------------------------
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 14.0
config.harfbuzz_features = { 'calt', 'liga', 'clig' }  -- ligatures
config.font_shaper = 'HarfBuzz'             -- better ligature/emoji shaping
config.freetype_load_target = 'Normal'      -- GPU glyph rendering

-- ---- Colors ------------------------------------------------------------
config.colors = {
  foreground = mocha.text,
  background = mocha.base,
  cursor_bg  = mocha.rosewater,
  cursor_border = mocha.rosewater,
  cursor_fg  = mocha.base,
  selection_fg = mocha.base,
  selection_bg = mocha.pink,
  scrollbar_thumb = mocha.overlay0,
  scrollbar_track = mocha.surface2,
  split = mocha.surface2,
  ansi = {
    mocha.base, mocha.red,  mocha.green, mocha.yellow,
    mocha.blue,  mocha.pink, mocha.teal,  mocha.subtext1,
  },
  brights = {
    mocha.surface2, mocha.red,    mocha.green,   mocha.yellow,
    mocha.blue,     mocha.pink,   mocha.teal,    mocha.subtext0,
  },
  tab_bar = {
    background = mocha.mantle,
    inactive_tab = {
      bg_color = mocha.mantle,
      fg_color = mocha.subtext0,
    },
    active_tab = {
      bg_color = mocha.mauve,
      fg_color = mocha.base,
    },
    new_tab = {
      bg_color = mocha.mantle,
      fg_color = mocha.subtext0,
    },
    inactive_tab_hover = {
      bg_color = mocha.surface0,
      fg_color = mocha.subtext1,
    },
    new_tab_hover = {
      bg_color = mocha.surface0,
      fg_color = mocha.subtext1,
    },
  },
}

-- ---- Tabs --------------------------------------------------------------
config.hide_tab_bar_if_only_one_tab = true   -- matches Rio's hide-if-single
config.use_fancy_tab_bar = false             -- flat tab strip, like Rio
config.show_new_tab_button_in_tab_bar = false
config.show_close_button_in_tab_bar = false
config.tab_bar_at_bottom = false
config.enable_scroll_bar = true

-- ---- Mouse / Selection ------------------------------------------------
-- Right-click paste is the default; left-click drag selects, and selecting
-- automatically puts text on the clipboard (matches Rio's copy-on-select).
-- Ctrl+Click opens hyperlinks.
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

-- ---- Cursor ------------------------------------------------------------
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 800               -- ms; matches Rio
config.force_reverse_video_cursor = false

-- ---- Scroll ------------------------------------------------------------
config.scrollback_lines = 10000
config.mouse_scroll_multiplier = 3           -- matches Rio's [scroll] multiplier

-- ---- Bell --------------------------------------------------------------
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_delay_ms = 100,
  fade_out_duration_ms = 100,
  text = 'BEL ',
  background = mocha.red,
  foreground = mocha.base,
}

-- ---- Shell -------------------------------------------------------------
-- Drop into WSL → fish, same as Rio. Change "NixOS" if you rename the distro.
config.default_prog = { 'wsl.exe', '-d', 'NixOS', '--', 'fish', '-l' }
config.launch_menu = {
  { label = 'WSL → fish',     args = { 'wsl.exe', '-d', 'NixOS', '--', 'fish', '-l' } },
  { label = 'PowerShell',     args = { 'powershell.exe', '-NoLogo' } },
  { label = 'Windows CMD',    args = { 'cmd.exe' } },
}

-- ---- Key bindings ------------------------------------------------------
-- Readline-ish; line up with Rio's [key_bindings] notes.
config.key_bindings = {
  -- Ctrl+Shift+C / Ctrl+Shift+V for copy/paste.
  { key = 'c', mods = 'SHIFT|CTRL', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'SHIFT|CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
  -- Reload config after edits.
  { key = 'r', mods = 'SHIFT|CTRL', action = wezterm.action.ReloadConfiguration },
  -- New tab at WSL.
  { key = 't', mods = 'SHIFT|CTRL', action = wezterm.action.SpawnCommandInNewTab {
      args = { 'wsl.exe', '-d', 'NixOS', '--', 'fish', '-l' },
    } },
  -- Open editor in current directory.
  { key = 'e', mods = 'SHIFT|CTRL', action = wezterm.action.SpawnCommandInNewTab {
      args = { 'code', '.' },
    } },
  -- Fuzzy search scrollback.
  { key = 'f', mods = 'CTRL', action = wezterm.action.Search { CaseInSensitiveString = '' } },
  -- Zoom in/out/reset (Ctrl+- / Ctrl+= / Ctrl+0).
  { key = '-', mods = 'CTRL', action = wezterm.action.DecreaseFontSize },
  { key = '=', mods = 'CTRL', action = wezterm.action.IncreaseFontSize },
  { key = '0', mods = 'CTRL', action = wezterm.action.ResetFontSize },
}

-- ---- Misc --------------------------------------------------------------
config.exit_behavior = 'CloseOnCleanExit'
config.automatically_reload_config = true    -- pick up config edits live
config.check_for_updates = true              -- notify on new WezTerm releases
config.term = 'xterm-256color'
config.enable_wayland = false
config.prefer_egl = true                    -- GPU-accelerated rendering
config.max_fps = 60                          -- cap for blur perf on Win10

return config
