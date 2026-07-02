{ config, pkgs, ... }:

let
  configDir = ../../dotfiles;
in
{
  programs.helix = {
    enable = true;
    defaultEditor = false; # nvim is primary
    settings = {
      theme = "catppuccin_mocha_transparent";
      editor = {
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        true-color = true;
        bufferline = "multiple";
        scrolloff = 8;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides = {
          render = true;
        };
        statusline = {
          left = [ "mode" "spinner" "file-name" "file-modification-indicator" ];
          right = [ "diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type" ];
          separator = "│";
        };
        lsp = {
          display-messages = true;
        };
      };
      keys.normal = {
        space.space = "file_picker";
        space.w = ":w";
        space.q = ":q";
      };
    };
  };

  xdg.configFile."helix/themes/catppuccin_mocha_transparent.toml".source =
    "${configDir}/config/helix/themes/catppuccin_mocha_transparent.toml";
}
