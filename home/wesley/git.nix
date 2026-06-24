{ config, pkgs, lib, ... }:

{
  # Git + delta + gh + git-cliff + pre-commit
  home.packages = with pkgs; [
    git
    gh
    glab
    lazygit
    git-cliff
    pre-commit
    commitlint
  ];

  programs.git = {
    enable = true;
    package = pkgs.git;

    settings = {
      # Identity
      user = {
        name = "Wesley";
        email = "wesley@local";
      };

      # Core
      init.defaultBranch = "main";
      core = {
        pager = "delta";
        editor = "nvim";
        whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
        autocrlf = "input";
        safecrlf = "warn";
        excludesfile = "~/.config/git/ignore";
        attributesfile = "~/.config/git/attributes";
        hooksPath = "~/.config/git/hooks";
      };

      # Pull / push
      pull = {
        rebase = true;
        ff = "only";
      };
      push = {
        autoSetupRemote = true;
        default = "current";
      };

      # Diff / merge
      diff = {
        algorithm = "histogram";
        renames = true;
        colorMoved = "zebra";
        mnemonicPrefix = true;
      };
      merge = {
        tool = "nvim";
        conflictstyle = "zdiff3";
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };

      # Branch
      branch = {
        sort = "-committerdate";
      };

      # Log
      log = {
        date = "iso";
      };

      # Delta
      add = {
        interactive = {
          diffFilter = "delta --color-only --color-moved";
        };
      };

      # Aliases (in addition to shell aliases)
      alias = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "!gitk";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        lgp = "log --stat --patch";
        type = "cat-file -t";
        cleanup = "!git clean -dfx && git reset --hard";
        amend = "commit --amend --no-edit";
        undo = "reset --soft HEAD~1";
        wip = "commit -am \"WIP\"";
        unwip = "reset --soft HEAD~1";
        contribute = "shortlog -s -n --all --no-merges";
        ranked = "shortlog -s -n --all";
      };

      # URL rewrites
      # The `url` attrset key is the LHS of `[url "..."]`, and the
      # value is an attrset of sub-keys like `insteadOf` /
      # `pushInsteadOf`. So this becomes:
      #   [url "git@github.com:"]
      #       insteadOf = "https://github.com/"
      url = {
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
      };
    };

    # Global gitignore
    ignores = [
      "*.swp"
      "*.swo"
      "*~"
      ".DS_Store"
      "Thumbs.db"
      "*.tmp"
      "*.bak"
      "*.orig"
      ".idea/"
      ".vscode/"
      "node_modules/"
      "dist/"
      "build/"
      "target/"
      ".next/"
      ".nuxt/"
      ".svelte-kit/"
      ".cache/"
      ".parcel-cache/"
      "coverage/"
      "*.log"
      ".env"
      ".env.local"
      ".env.*.local"
      ".DS_Store"
      "*.pyc"
      "__pycache__/"
      ".mypy_cache/"
      ".pytest_cache/"
      ".ruff_cache/"
    ];
  };

  # Delta pager config
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "diff-highlight line-numbers decorations";
      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-style = "bold yellow";
        file-decoration-style = "none";
      };
      line-numbers = {
        line-numbers-left-format = "  ";
        line-numbers-right-format = "  ›";
        line-numbers-minus-style = "red";
        line-numbers-plus-style = "green";
      };
      navigate = {
        n = "true";
      };
      side-by-side = true;
      syntax-theme = "Catppuccin Mocha";
      pager = "less --mouse --wheel-lines=3 --quit-on-intr";
      # Catppuccin Mocha for dark, OneHalfLight for light
      dark = "Catppuccin Mocha";
      light = "Catppuccin Latte";
    };
  };

  # gh CLI config
  programs.gh = {
    enable = true;
    settings = {
      editor = "nvim";
      prompt = "enabled";
      pager = "delta";
      alias = {
        co = "pr checkout";
        rs = "pr review:approve";
      };
    };
  };
}
