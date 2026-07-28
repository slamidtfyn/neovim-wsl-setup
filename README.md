# My Neovim Setup

An automated, modern Neovim configuration script for Linux (Ubuntu / Debian). It installs system dependencies, bootstraps Neovim (v0.10+), and configures a fast, feature-rich development environment powered by [`lazy.nvim`](https://github.com/folke/lazy.nvim).

---

## 🚀 Quick Install

Run the setup directly from your terminal using `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/slamidtfyn/my-neovim-setup/main/setup.sh | bash
```

### Alternative: Download & Run

```bash
wget https://raw.githubusercontent.com/slamidtfyn/my-neovim-setup/main/setup.sh
chmod +x setup.sh
./setup.sh
```

### Alternative: Git Clone

```bash
git clone https://github.com/slamidtfyn/my-neovim-setup.git
cd my-neovim-setup
./setup.sh
```

> **Note:** The setup script requires `sudo` privileges to install system packages (`ripgrep`, `fd-find`, `wl-clipboard`, etc.) and to upgrade Neovim to v0.10+ if the system package manager offers an older version.

---

## ✨ Features Included

- **Neovim v0.10+ Upgrade:** Automatically installs or upgrades Neovim to the latest stable binary if system version is outdated.
- **System Dependencies:** Installs `curl`, `git`, `build-essential`, `unzip`, `ripgrep`, `fd-find`, `xclip`, and `wl-clipboard` (Wayland support).
- **Plugin Management:** Powered by [lazy.nvim](https://github.com/folke/lazy.nvim) for fast lazy-loading.
- **Theme & UI:** 
  - Colorscheme: `tokyonight-night`
  - Statusline: `lualine.nvim`
  - File Explorer: `neo-tree.nvim`
  - Floating Terminal: `toggleterm.nvim`
- **Syntax & Search:**
  - `nvim-treesitter` for syntax highlighting and indentation.
  - `telescope.nvim` for fuzzy searching files and live grep.
- **LSP & Autocompletion:**
  - `mason.nvim` & `mason-lspconfig.nvim` for automated LSP server management.
  - Pre-configured LSP servers: `ts_ls` (TypeScript/JS), `pyright` (Python), `html`, `cssls`.
  - `nvim-cmp` & `LuaSnip` for completion popups.
- **Git Tools:**
  - `gitsigns.nvim` for inline git status and line blame.
  - `diffview.nvim` for side-by-side git diff inspection and history.

---

## ⌨️ Keybindings

| Keybinding | Action |
| --- | --- |
| `<Space>` | **Leader Key** |
| `Ctrl + b` | Toggle Neo-tree file explorer |
| `Ctrl + p` | Telescope: Find files |
| `Ctrl + f` | Telescope: Live grep (text search) |
| `Ctrl + \`` | Toggle floating terminal |
| `<leader>dv` | Open Diffview |
| `<leader>dc` | Close Diffview |
| `<leader>dh` | Open Diffview file history for current file |
| `Enter` / `Tab` / `Shift+Tab` | Confirm / Navigate autocompletion suggestions |

---

## 📋 Requirements

- **OS:** Ubuntu / Debian (tested on Ubuntu 22.04 LTS through 26.04)
- **Privileges:** `sudo` access for package management
