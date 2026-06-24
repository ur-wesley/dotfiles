-- Wesley's WezTerm config — Catppuccin Mocha
-- WezTerm IS the multiplexer. No tmux/zellij needed.
-- Documentation: https://wezterm.org/config/

local wezterm = require "wezterm"
local config = wezterm.config_builder and wezterm.config_builder() or {}

local act = wezterm.action
local mux = wezterm.mux

-- ============================================================
-- Appearance
-- ============================================================
config.color_scheme = "Catppuccin Mocha"
config.font_size = 12.0
config.line_height = 1.2
config.cell_width = 1.0
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.freetype_load_target = "Normal"

config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }

-- ============================================================
-- WSL: NixOS distro is the default
-- ============================================================
config.default_domain = "WSL:NixOS"
config.wsl_domains = {
  ["NixOS"] = {
    default_user = "wesley",
    default_cwd = "/home/wesley",
  },
}

-- Fish on Linux, pwsh on Windows
config.default_prog = { "wsl.exe", "-d", "NixOS", "--", "fish", "-l" }

-- ============================================================
-- Tabs + Workspaces
-- ============================================================
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.show_tabs_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = true
config.tab_max_width = 30
config.tab_fade_when_close = true

-- Pre-defined workspaces
config.workspaces = {
  { name = "Dev",  spawn = { "wsl.exe", "-d", "NixOS", "--", "fish", "-l" } },
  { name = "Dev2", spawn = { "wsl.exe", "-d", "NixOS", "--", "fish", "-l" } },
  { name = "Win",  spawn = { "pwsh.exe" } },
}

-- ============================================================
-- Leader key (C-a) — every multiplexer binding is a prefix
-- ============================================================
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.disable_default_key_bindings = false

config.keys = {
  -- ----------------------------------------------------------------
  -- Splits (LEADER + SHIFT + key)
  -- ----------------------------------------------------------------
  { key = "|", mods = "LEADER | SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "-", mods = "LEADER | SHIFT", action = act.SplitVertical({   domain = "CurrentPaneDomain" }) },

  -- Pane navigation (LEADER + h/j/k/l)
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left")  },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up")    },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down")  },

  -- Pane resize (LEADER + SHIFT + h/j/k/l)
  { key = "h", mods = "LEADER | SHIFT", action = act.AdjustPaneSize({ "Left",  3 }) },
  { key = "l", mods = "LEADER | SHIFT", action = act.AdjustPaneSize({ "Right", 3 }) },
  { key = "k", mods = "LEADER | SHIFT", action = act.AdjustPaneSize({ "Up",    3 }) },
  { key = "j", mods = "LEADER | SHIFT", action = act.AdjustPaneSize({ "Down",  3 }) },

  -- Zoom / unzoom pane
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

  -- Close pane (LEADER + x) and close pane in tab if last (LEADER + X)
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

  -- ----------------------------------------------------------------
  -- Workspaces (LEADER + 1..9)
  -- ----------------------------------------------------------------
  { key = "1", mods = "LEADER", action = act.SwitchToWorkspace { name = "Dev"  } },
  { key = "2", mods = "LEADER", action = act.SwitchToWorkspace { name = "Dev2" } },
  { key = "3", mods = "LEADER", action = act.SwitchToWorkspace { name = "Win"  } },

  -- ----------------------------------------------------------------
  -- Tabs (LEADER + t/c/n/p)
  -- ----------------------------------------------------------------
  { key = "t", mods = "LEADER",         action = act.SpawnTab "CurrentPaneDomain" },
  { key = "n", mods = "LEADER",         action = act.ActivateTabRelative( 1) },
  { key = "p", mods = "LEADER",         action = act.ActivateTabRelative(-1) },
  { key = "c", mods = "LEADER | SHIFT", action = act.CloseCurrentTab({ confirm = true }) },

  -- Rename tab
  { key = "r", mods = "LEADER",         action = act.PromptInputLine {
      description = "Enter new tab title:",
      action = act_callback,
    },
  },

  -- ----------------------------------------------------------------
  -- Misc
  -- ----------------------------------------------------------------
  { key = "r", mods = "LEADER | SHIFT", action = act.ReloadConfiguration },
  { key = "p", mods = "LEADER | SHIFT", action = act.ActivateCommandPalette },
  { key = "/", mods = "LEADER",         action = act.Search({ CaseInSensitiveString = "" }) },
  { key = "f", mods = "LEADER",         action = act.ActivateCopyMode },

  -- Copy/paste
  { key = "c", mods = "CTRL | SHIFT",   action = act.CopyTo "Clipboard" },
  { key = "v", mods = "CTRL | SHIFT",   action = act.PasteFrom "Clipboard" },
}

-- Tab title callback
function act_callback(window, pane, line)
  if line then
    window:active_tab():set_title(line)
  end
end

-- ============================================================
-- Status bar (Catppuccin Mocha)
-- ============================================================
wezterm.on("update-right-status", function(window, _pane)
  local date = wezterm.strftime("%Y-%m-%d %H:%M")
  local dist = "NixOS"
  local pane = window:active_pane()
  if pane and pane.domain_name then
    if pane.domain_name:match("WSL:NixOS") then dist = "NixOS" end
  end
  local cwd = pane and pane.current_working_dir or wezterm.home_dir
  local cwd_disp = cwd and cwd.path:gsub("^" .. wezterm.home_dir, "~") or "~"
  local left = " " .. dist .. "  " .. cwd_disp .. " "
  local right = " " .. date .. " "
  window:set_left_status(wezterm.format({
    { Attribute = { Intensity = "Bold" } },
    { Background = { Color = "#89b4fa" } },
    { Foreground = { Color = "#1e1e2e" } },
    { Text = left },
  }))
  window:set_right_status(wezterm.format({
    { Background = { Color = "#313244" } },
    { Foreground = { Color = "#cdd6f4" } },
    { Text = right },
  }))
end)

-- ============================================================
-- Mouse + UX
-- ============================================================
config.mouse_bindings = {
  { event = { Down = { streak = 1, button = "Left", mods = "CTRL" } },
    mods = "CTRL", action = act.OpenUrlAtMouseCursor },
}
config.hide_mouse_cursor_when_typing = true
config.max_fps = 60
config.scrollback_lines = 10000
config.enable_scroll_bar = true
config.scrollback_in_mouse_selection = true
config.audible_bell = "Disabled"
config.visual_bell = { fade_in_function = "easeIn", fade_out_function = "easeOut",
                       fade_in_duration_ms = 30, fade_out_duration_ms = 30 }
config.ssh_backend = "LibSsh"

-- Selection colors (Catppuccin Mocha selection)
config.selection_bg = "#45475a"
config.selection_fg = "#cdd6f4"
config.selection_word_boundary = " \t\n{}[]()\"'`,;:"

return config
