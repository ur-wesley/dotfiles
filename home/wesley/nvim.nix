{ config, pkgs, lib, ... }:

{
  programs.nixvim = {

    # Editor options
    opts = {
      number = true;
      relativenumber = true;
      cursorline = true;
      signcolumn = "yes";
      showmode = false;
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
      smartindent = true;
      wrap = false;
      linebreak = true;
      breakindent = true;
      scrolloff = 8;
      sidescrolloff = 16;
      termguicolors = true;
      background = "dark";
      mouse = "a";
      clipboard = "unnamedplus";
      completeopt = [ "menu" "menuone" "noselect" ];
      timeoutlen = 400;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      inccommand = "split";
      splitright = true;
      splitbelow = true;
      updatetime = 250;
    };

    globals = {
      mapleader = " ";
      maplocalleader = ",";
    };

    # Colorscheme
    colorschemes = {
      catppuccin = {
        enable = true;
        settings = {
          flavour = "mocha";
        };
      };
    };

    colorscheme = "catppuccin-mocha";

    # Keymaps
    keymaps = [
      # Clear search highlight
      { key = "<Esc>"; mode = [ "n" ]; action = "<cmd>nohlsearch<cr>"; }
      # Quit
      { key = "q"; mode = [ "n" ]; action = "<cmd>q<cr>"; }
      # Center screen
      { key = "<C-d>"; mode = [ "n" ]; action = "<C-d>zz"; }
      { key = "<C-u>"; mode = [ "n" ]; action = "<C-u>zz"; }
      # Move lines
      { key = "<A-j>"; mode = [ "v" "n" ]; action = ":m .+1<CR>=="; }
      { key = "<A-k>"; mode = [ "v" "n" ]; action = ":m .-2<CR>=="; }
      # Better indenting
      { key = ">"; mode = [ "v" ]; action = ">gv"; }
      { key = "<"; mode = [ "v" ]; action = "<gv"; }
      # Move to start/end of line
      { key = "H"; mode = [ "n" ]; action = "^"; }
      { key = "L"; mode = [ "n" ]; action = "$"; }
      # Diagnostics nav
      { key = "<C-j>"; mode = [ "n" ]; action.__raw = "vim.diagnostic.goto_next"; }
      { key = "<C-k>"; mode = [ "n" ]; action.__raw = "vim.diagnostic.goto_prev"; }
      { key = "<leader>e"; mode = [ "n" ]; action.__raw = "vim.diagnostic.open_float"; }
      # LSP
      { key = "gd"; mode = [ "n" ]; action.__raw = "vim.lsp.buf.definition"; }
      { key = "gD"; mode = [ "n" ]; action.__raw = "vim.lsp.buf.declaration"; }
      { key = "gi"; mode = [ "n" ]; action.__raw = "vim.lsp.buf.implementation"; }
      { key = "gr"; mode = [ "n" ]; action.__raw = "vim.lsp.buf.references"; }
      { key = "K"; mode = [ "n" ]; action.__raw = "vim.lsp.buf.hover"; }
      { key = "<leader>rn"; mode = [ "n" ]; action.__raw = "vim.lsp.buf.rename"; }
      { key = "<leader>ca"; mode = [ "n" ]; action.__raw = "vim.lsp.buf.code_action"; }
      { key = "[d"; mode = [ "n" ]; action.__raw = "vim.diagnostic.goto_prev"; }
      { key = "]d"; mode = [ "n" ]; action.__raw = "vim.diagnostic.goto_next"; }
    ];

    # Plugins as attribute set (nixvim modules)
    plugins = {
      lualine = {
        enable = true;
        settings = {
          options = {
            theme = "catppuccin-mocha";
            component_separators = "|";
            section_separators = "";
          };
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [ "branch" "diff" "diagnostics" ];
            lualine_c = [ "filename" ];
            lualine_x = [ "filetype" "encoding" "fileformat" "location" ];
            lualine_y = [ "progress" ];
            lualine_z = [ "time" ];
          };
        };
      };

      bufferline = {
        enable = true;
        settings = {
          highlights = {
            buffer_selected = {
              guifg = "#cdd6f4";
              guibg = "#1e1e2e";
            };
          };
        };
      };

      indent-blankline = {
        enable = true;
      };

      # Hotkey help: modern replacement for which-key.
      # mini.clue shows pending keybindings inline in the cmdline
      # area (no full-screen popup), with a short delay so
      # single-key presses don't trigger it. Press <leader>? to
      # open a Telescope keymap search for on-demand lookup.
      mini-clue = {
        enable = true;
      };

      neo-tree = {
        enable = true;
        settings = {
          filesystem = {
            follow_current_file = {
              enabled = true;
            };
            use_libuv_file_watcher = true;
          };
          window = {
            width = 32;
          };
        };
      };

      telescope = {
        enable = true;
        settings = {
          defaults = {
            prompt_prefix = "  ";
            selection_caret = "  ";
            path_display = { truncate = 40; };
            sorting_strategy = "ascending";
            layout_strategy = "horizontal";
            layout_config = {
              preview_cutoff = 120;
              horizontal = {
                preview_width = 0.55;
                width = 0.87;
                height = 0.85;
              };
            };
            file_ignore_patterns = [
              "%.git/"
              "node_modules/"
              "%.cache/"
              "dist/"
              "build/"
            ];
          };
          pickers = {
            buffers = { sort_lastused = true; sort_usage = true; };
          };
        };
      };

      treesitter = {
        enable = true;
        settings = {
          ensure_installed = [
            "lua" "vim" "vimdoc" "query" "bash" "fish" "zsh"
            "c" "cpp" "python" "rust" "go" "java" "javascript" "typescript"
            "tsx" "jsx" "html" "css" "scss" "json" "yaml" "toml" "xml"
            "markdown" "markdown_inline" "dockerfile" "dockerfile_highlights"
            "php" "ruby" "gleam" "dart" "kotlin" "swift" "haskell" "elm"
            "hcl" "terraform" "graphql" "vue" "svelte" "astro" "regex"
            "diff" "gitcommit" "gitignore" "gitattributes" "ini"
          ];
          highlight = { enable = true; };
          indent = { enable = true; };
          fold = { enable = false; };
          incremental_selection = {
            enable = true;
            keymaps = {
              init_selection = "<C-space>";
              node_incremental = "<C-space>";
              scope_incremental = "<C-s>";
              node_decremental = "<C-x>";
            };
          };
        };
      };

      lspconfig = {
        enable = true;
      };

      gitsigns = {
        enable = true;
        settings = {
          current_line_blame = true;
          current_line_blame_opts = {
            virt_text = true;
            virt_text_pos = "eol";
            delay = 500;
          };
        };
      };

      neogit = {
        enable = true;
      };

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            lua = [ "stylua" ];
            python = [ "black" "isort" ];
            javascript = [ "prettierd" "prettier" ];
            typescript = [ "prettierd" "prettier" ];
            json = [ "prettierd" "prettier" ];
            yaml = [ "prettierd" "prettier" ];
            markdown = [ "prettierd" "prettier" ];
            go = [ "gofmt" "goimports" ];
            rust = [ "rustfmt" ];
            sh = [ "shfmt" ];
          };
          format_on_save = "function(bufnr) local conform = require('conform'); conform.format({ lsp_format = 'fallback' }) end";
          notify_on_error = false;
        };
      };

      trouble = {
        enable = true;
        settings = {
          use_diagnostic_signs = true;
        };
      };

      toggleterm = {
        enable = true;
        settings = {
          size = 15;
          shade_filetypes = [ ];
        };
      };

      nvim-autopairs = {
        enable = true;
      };

      nvim-surround = {
        enable = true;
      };

      auto-session = {
        enable = true;
        settings = {
          auto_session_enable_last_session = true;
          auto_session_root_dir = "~/.local/share/nvim/sessions";
        };
      };
    };

    # Extra plugins (those without dedicated nixvim modules)
    extraPlugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-emoji
      luasnip
      friendly-snippets
      mason-nvim
      mason-lspconfig-nvim
      plenary-nvim
    ];

    # Extra raw Lua config (LSP setup that depends on cmp-nvim-lsp, mason, etc.)
    extraConfigLua = ''
      -- Mason setup (installs LSP servers but doesn't enable them)
      require("mason").setup()

      -- LSP servers to enable (using the new vim.lsp.config API in nvim 0.11+)
      local servers = {
        "ts_ls", "pyright", "rust_analyzer", "gopls", "clangd",
        "jdtls", "lua_ls", "gleam", "dartls",
        "phpactor", "terraformls", "yamlls", "jsonls",
        "html", "cssls", "tailwindcss",
        "bashls", "zls", "denols"
      }

      -- LSP keymaps
      local on_attach = function(client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
      end

      -- Use the new vim.lsp API (nvim 0.11+). The legacy
      -- require('lspconfig') framework is deprecated and will be
      -- removed in nvim-lspconfig v3.0.0.
      for _, server in ipairs(servers) do
        vim.lsp.config(server, {
          on_attach = on_attach,
          capabilities = vim.lsp.protocol.make_client_capabilities(),
        })
        vim.lsp.enable(server)
      end

      -- nvim-cmp
      local cmp = require("cmp")
      local has_luasnip, snip = pcall(require, "luasnip")
      local snip = has_luasnip and snip or nil
      cmp.setup({
        snippet = {
          expand = function(args)
            if snip and snip.jumpable(-1) then
              snip.jump(-1)
            end
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Insert }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif snip and snip.jumpable(1) then
              snip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif snip and snip.jumpable(-1) then
              snip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "buffer" },
        }),
      })

      -- Telescope keybindings
      local telescope = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", telescope.find_files, {})
      vim.keymap.set("n", "<leader>fg", telescope.live_grep, {})
      vim.keymap.set("n", "<leader>fb", telescope.buffers, {})
      vim.keymap.set("n", "<leader>fh", telescope.help_tags, {})
      vim.keymap.set("n", "<leader>fr", telescope.oldfiles, {})
      vim.keymap.set("n", "<leader>fc", telescope.commands, {})
      -- Hotkey help: search all current keymaps via Telescope.
      vim.keymap.set("n", "<leader>?", telescope.keymaps, {})
      vim.keymap.set("n", "<leader>fd", telescope.diagnostics, {})
      vim.keymap.set("n", "<leader>fs", function() telescope.lsp_document_symbols({ symbols = "document" }) end, {})
      vim.keymap.set("n", "<leader>fS", telescope.lsp_workspace_symbols, {})
      vim.keymap.set("n", "<leader>/", telescope.live_grep, {})

      -- File tree
      vim.keymap.set("n", "<leader>t", "<cmd>Neotree toggle<cr>")

      -- Toggleterm keymap
      vim.keymap.set("n", "<C-\\>", "<cmd>ToggleTerm<cr>")

      -- mini.clue: pending-keymap hints. Modern replacement for
      -- which-key's full-screen popup — shows a small, delay-
      -- triggered hint at the bottom of the screen. <leader>?
      -- opens a Telescope picker for on-demand lookup.
      require("mini.clue").setup({
        triggers = {
          -- auto-show after typing <leader>, g, or [ in normal/visual
          { mode = { "n", "v" }, keys = "<leader>" },
          { mode = { "n", "v" }, keys = "g" },
          { mode = { "n" }, keys = "[" },
        },
        clues = {
          enable_mark = true,
          enable_register = true,
          enable_spell_suggestions = true,
        },
        delay = 200,
        window = {
          config = function() return { anchor = "C", border = "none", width = 60, height = 10 } end,
        },
      })

      -- Autocmds
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "json", "jsonc", "json5" },
        callback = function() vim.opt_local.expandtab = false; vim.opt_local.tabstop = 2 end,
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function() vim.opt_local.tabstop = 4; vim.opt_local.shiftwidth = 4 end,
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "go", "rust" },
        callback = function() vim.opt_local.tabstop = 4; vim.opt_local.shiftwidth = 4 end,
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "make",
        callback = function() vim.opt_local.expandtab = false; vim.opt_local.tabstop = 4 end,
      })

      -- Highlight yanked region
      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function() vim.highlight.yank({ higroup = "IncSearch", timeout = 200 }) end,
      })

      -- Resize splits when window resizes
      vim.api.nvim_create_autocmd("VimResized", {
        group = vim.api.nvim_create_augroup("resize_splits", { clear = true }),
        callback = function() vim.cmd("tabdo wincmd =") end,
      })
    '';
  };
}
