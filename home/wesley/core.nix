{ config, pkgs, lib, ... }:

{
  # Shell prompt + history
  home.packages = with pkgs; [
    starship
    atuin
    mcfly
    zoxide
  ];

  # fzf shell integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    tmux = {
      enableShellIntegration = true;
      shellIntegrationOptions = [ "-p 60%" ];
    };
  };

  # zoxide — smart cd. `cd` is replaced with `z` and we also
  # override `cd` itself so it just works transparently.
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # direnv with nix-direnv integration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Atuin shell history
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      auto_sync = false;
      search_mode = "fuzzy";
      style = "auto";
    };
  };

  # mcfly shell history
  programs.mcfly = {
    enable = true;
    enableFishIntegration = true;
    keyScheme = "vim";
  };

  # Starship prompt: write the TOML file directly so we have full
  # control over the literal $ characters in format strings.
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    # Intentionally do not set `settings` — full config is in
    # xdg.configFile."starship.toml" below. This avoids the conflict
    # with the home-manager generated file at the same path.
  };

  # Author the full starship TOML config ourselves so we can use
  # literal $ freely without fighting Nix string interpolation.
  xdg.configFile."starship.toml".text = ''
    # Wesley's starship config — Catppuccin Mocha, rounded pills.
    # Written by home-manager; do not edit by hand.
    "$schema" = "https://starship.rs/config-schema.json"
    command_timeout = 1000
    scan_timeout = 5000
    continuation_prompt = "[▸▸](bold blue)"

    # Top-level: just concatenate modules; each module styles itself.
    # The `(`/`)` and `·` characters inside each module's `format`
    # give the prompt its rounded, pill-like look.
    format = """$character$username$hostname$directory$git_branch$git_status$nodejs$rust$python$java$kotlin$ruby$php$golang"""

    # Time on the right edge of the terminal, kept on the same line
    # as the rest of the prompt.
    right_format = """ [$time]($style) """

    # --- Prompt arrow ----------------------------------------------
    # NOTE: starship 1.25 removed the bare `symbol` and `style` keys
    # from [character]. The arrow is now `success_symbol` /
    # `error_symbol` / `vimcmd_*_symbol`, and color is applied via
    # starship's own `[...](style)` syntax in `format`.
    [character]
    success_symbol = "❯"
    error_symbol = "❯"
    vimcmd_symbol = "❮"
    vimcmd_visual_symbol = "❮"
    vimcmd_replace_symbol = "❮"
    vimcmd_replace_one_symbol = "❮"
    format = "[$symbol](bold #cba6f7) "
    disabled = false

    # --- Identity --------------------------------------------------
    # Note: starship's style system only kicks in on `[text](style)`,
    # so the parentheses are baked into the content (as literal chars)
    # and the brackets carry the style group.
    [username]
    style_user = "bold #f5c2e7"
    style_root = "bold #f38ba8"
    format = "[($user)]($style) "
    show_always = true
    disabled = false

    [hostname]
    ssh_only = false
    style = "bold #94e2d5"
    format = "·[@($hostname)]($style) "
    disabled = false

    # --- Location --------------------------------------------------
    [directory]
    style = "bold #89b4fa"
    format = "·[($path)]($style) "
    truncation_length = 3
    truncation_symbol = "…/"
    home_symbol = "~"
    read_only = " 🔒"

    # --- Git --------------------------------------------------------
    [git_branch]
    symbol = " "
    style = "bold #fab387"
    format = "·[git:($symbol$branch(:$remote_branch))]($style) "

    [git_status]
    style = "bold #f38ba8"
    format = "[($all_status$ahead_behind)]($style) "
    modified = "!"
    staged = "+"
    renamed = "»"
    deleted = "✘"
    untracked = "?"
    ahead = "⇡''${count}"
    behind = "⇣''${count}"
    diverged = "⇕±''${count}"

    # --- Languages --------------------------------------------------
    [nodejs]
    symbol = "⬢"
    style = "bold #a6e3a1"
    format = "·[($symbol $version)]($style) "

    [rust]
    symbol = "🦀"
    style = "bold #fab387"
    format = "·[($symbol $version)]($style) "

    [golang]
    symbol = "go"
    style = "bold #94e2d5"
    format = "·[($symbol $version)]($style) "

    [python]
    symbol = "py"
    style = "bold #f9e2af"
    format = "·[($symbol $version)]($style) "

    [java]
    symbol = "☕"
    style = "bold #f38ba8"
    format = "·[($symbol $version)]($style) "

    [kotlin]
    symbol = "🟪"
    style = "bold #b4befe"
    format = "·[($symbol $version)]($style) "

    [ruby]
    symbol = "💎"
    style = "bold #f38ba8"
    format = "·[($symbol $version)]($style) "

    [php]
    symbol = "🐘"
    style = "bold #b4befe"
    format = "·[($symbol $version)]($style) "

    # --- Time (right edge) -----------------------------------------
    [time]
    style = "bold #f38ba8"
    format = "[$time]($style)"
    time_format = "%R"
    disabled = false

    # --- Disabled (kept off to stay minimal) -----------------------
    [memory_usage]
    disabled = true
  '';
}
