#!/usr/bin/env bash
set -e

echo "=== 1. Checking / Installing System Dependencies ==="
sudo apt-get update
sudo apt-get install -y curl git build-essential unzip tar ripgrep fd-find xclip

# Ensure standard binary symlink for fd-find if needed
if ! command -v fd &> /dev/null && command -v fdfind &> /dev/null; then
  sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
fi

echo "=== 2. Checking Neovim Version ==="
MIN_VERSION="0.10.0"
NEEDS_INSTALL=true

if command -v nvim &> /dev/null; then
  CURRENT_VERSION=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  echo "Current Neovim version: $CURRENT_VERSION"
  
  if [ "$(printf '%s\n' "$MIN_VERSION" "$CURRENT_VERSION" | sort -V | head -n1)" = "$MIN_VERSION" ]; then
    echo "Neovim version is sufficient (>= $MIN_VERSION)."
    NEEDS_INSTALL=false
  else
    echo "Neovim version is below $MIN_VERSION. Upgrading..."
  fi
fi

if [ "$NEEDS_INSTALL" = true ]; then
  echo "Downloading Neovim stable binary (v0.10+)..."
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  rm nvim-linux-x86_64.tar.gz
  
  sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
  echo "Neovim successfully upgraded to: $(nvim --version | head -n1)"
fi

echo "=== 3. Cleaning Up Previous Neovim Cache/State ==="
rm -rf ~/.local/share/nvim ~/.cache/nvim ~/.config/nvim

echo "=== 4. Creating ~/.config/nvim Directory Structure ==="
mkdir -p ~/.config/nvim

echo "=== 5. Writing ~/.config/nvim/init.lua ==="
cat << 'EOF' > ~/.config/nvim/init.lua
-- ============================================================================
-- 1. BASIC OPTIONS & KEYMAPS
-- ============================================================================
vim.g.mapleader = " "              -- Space key as Leader
vim.opt.number = true              -- Line numbers
vim.opt.relativenumber = true      -- Relative line numbers
vim.opt.tabstop = 4                -- 4 spaces per tab
vim.opt.shiftwidth = 4
vim.opt.expandtab = true           -- Tabs -> spaces
vim.opt.smartindent = true
vim.opt.termguicolors = true       -- True color support
vim.opt.mouse = "a"                -- Mouse support
vim.opt.clipboard = "unnamedplus"  -- Sync with system/Windows clipboard

-- Keymaps (VS Code style)
vim.keymap.set("n", "<C-b>", ":Neotree toggle<CR>", { silent = true })      -- Ctrl+B: Toggle File Explorer
vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>", { silent = true }) -- Ctrl+P: File Search
vim.keymap.set("n", "<C-f>", ":Telescope live_grep<CR>", { silent = true })  -- Ctrl+F: Text Search

-- Diffview Keymaps
vim.keymap.set("n", "<leader>dv", ":DiffviewOpen<CR>", { silent = true, desc = "Open Git Diff View" })
vim.keymap.set("n", "<leader>dc", ":DiffviewClose<CR>", { silent = true, desc = "Close Git Diff View" })
vim.keymap.set("n", "<leader>dh", ":DiffviewFileHistory %<CR>", { silent = true, desc = "Current File History" })

-- ============================================================================
-- 2. BOOTSTRAP LAZY.NVIM
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 3. PLUGINS
-- ============================================================================
require("lazy").setup({
  -- Theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },

  -- File Explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "javascript", "typescript", "python", "html", "css", "json", "bash", "diff" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Fuzzy Finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Git Integration: Gutter Signs & Line Blame
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 300,
        },
      })
    end,
  },

  -- Git Integration: Full Diff & Branch Review Tool
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory" },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "tokyonight" } })
    end,
  },

  -- Floating Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<C-`>]],
        direction = "float",
      })
    end,
  },

  -- LSP & Autocompletion
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      require("mason").setup()

      local mason_lspconfig = require("mason-lspconfig")
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = { "ts_ls", "pyright", "html", "cssls" }

      mason_lspconfig.setup({
        ensure_installed = servers,
      })

      for _, server in ipairs(servers) do
        lspconfig[server].setup({
          capabilities = capabilities,
        })
      end

      -- Autocompletion setup
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
})
EOF

echo "=== 6. Pre-fetching & Syncing Plugins ==="
nvim --headless "+Lazy! sync" +qa

echo ""
echo "=========================================================================="
echo " Setup complete! Neovim and all plugins are configured and synced."
echo " Launch Neovim with: nvim"
echo "=========================================================================="
