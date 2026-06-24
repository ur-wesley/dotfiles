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
    # Wesley's starship config — Catppuccin Mocha, dev-friendly.
    # Written by home-manager; do not edit by hand.
    "$schema" = "https://starship.rs/config-schema.json"
    command_timeout = 1000
    continuation_prompt = "[▸▸](bold blue)"

    format = """
    [░▒▓](#a6adc8)[$username](fg:#cdd6f4 bg:#313244)[](fg:#313244 bg:#89b4fa)[ $hostname ](fg:#1e1e2e bg:#89b4fa)[](fg:#89b4fa bg:#1e1e2e)[$directory](fg:#cdd6f4 bg:#1e1e2e)[](fg:#1e1e2e bg:#313244)[$git_branch$git_status ](fg:#cdd6f4 bg:#313244)[](fg:#313244 bg:#45475a)$nodejs$rust$python$java$kotlin$ruby$php$golang [](fg:#f38ba8 bg:#45475a)"""

    # Time goes on the right edge of the terminal, so it stays
    # in the same line as the rest of the prompt.
    right_format = """[$time](fg:#1e1e2e bg:#f38ba8) """

    [username]
    style_user = "bg:#313244 fg:#cdd6f4"
    style_root = "bg:#f38ba8 fg:#1e1e2e"
    format = "[ $user ]($style)"
    show_always = true
    disabled = false

    [hostname]
    ssh_only = false
    style = "bg:#89b4fa fg:#1e1e2e"
    format = "[ $hostname ]($style)"
    disabled = false

    [directory]
    style = "bg:#1e1e2e fg:#cdd6f4"
    format = "[ $path ]($style)"
    truncation_length = 3
    truncation_symbol = "…/"
    home_symbol = "~"
    read_only = " 🔒"

    [git_branch]
    symbol = " "
    style = "bg:#313244"
    format = "[ $symbol $branch (:$remote_branch) ]($style)"

    [git_status]
    style = "bg:#313244"
    format = "[$all_status$ahead_behind ]($style)"
    modified = " !"
    staged = " +"
    renamed = "»"
    deleted = " ✘"
    untracked = " ?"
    ahead = "⇡''${count}"
    behind = "⇣''${count}"
    diverged = "⇕±''${count}"

    [nodejs]
    style = "bg:#45475a"
    format = "[ $symbol ($version) ]($style)"
    symbol = " "

    [rust]
    style = "bg:#45475a"
    format = "[ $symbol ($version) ]($style)"
    symbol = "🦀"

    [golang]
    style = "bg:#45475a"
    format = "[ $symbol ($version) ]($style)"
    symbol = "go"

    [python]
    style = "bg:#45475a"
    format = "[ $symbol ($version) ]($style)"
    symbol = "py"

    [java]
    style = "bg:#45475a"
    format = "[ $symbol ($version) ]($style)"
    symbol = "☕"

    [kotlin]
    style = "bg:#45475a"
    format = "[ $symbol ($version) ]($style)"
    symbol = "🟪"

    [ruby]
    style = "bg:#45475a"
    format = "[ $symbol ($version) ]($style)"
    symbol = "💎"

    [php]
    style = "bg:#45475a"
    format = "[ $symbol ($version) ]($style)"
    symbol = "🐘"

    [time]
    style = "bg:#f38ba8 fg:#1e1e2e"
    format = "[ 󰥔 $time ]($style)"
    time_format = "%R"
    disabled = false

    [memory_usage]
    disabled = true
  '';
}
