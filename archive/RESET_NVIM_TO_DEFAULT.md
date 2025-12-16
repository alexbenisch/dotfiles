# Reset Neovim to Pure LazyVim Defaults

All custom neovim configurations have been removed from the dotfiles.
Your nvim setup will now use **100% pure LazyVim defaults** with no custom modifications.

## Reset Your Local Neovim

To get a clean LazyVim installation on your local machine:

### Step 1: Backup Current Config

```bash
# Backup your current neovim config
mv ~/.config/nvim ~/.config/nvim.bak

# Optionally backup data/state/cache
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

### Step 2: Install Fresh LazyVim

```bash
# Clone LazyVim starter (pure defaults)
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

### Step 3: Launch Neovim

```bash
nvim
```

LazyVim will automatically:
- Install lazy.nvim plugin manager
- Install all default plugins
- Set up LSP servers
- Configure everything with defaults

## What You Get

### Default LazyVim Features ✨

- **Command line at bottom** - Default vim command line (not noice.nvim)
- **Default colorscheme** - TokyoNight theme
- **File explorer** - Neo-tree on the left
- **Fuzzy finder** - Telescope for finding files
- **LSP** - Language servers for code intelligence
- **Treesitter** - Better syntax highlighting
- **Git integration** - Git signs, diff view, lazygit
- **Terminal** - Built-in terminal toggles

### Default Keybindings

LazyVim uses `<space>` as the leader key:
- `<space>ff` - Find files
- `<space>fg` - Find in files (grep)
- `<space>e` - Toggle file explorer
- `<space>gg` - Open lazygit
- `<space>l` - Open lazy plugin manager
- `<space>?` - Show all keybindings

## Customizing Locally

Your nvim config is **NOT tracked in dotfiles**.

Customize it locally by creating files in `~/.config/nvim/lua/`:

### Add Custom Plugins

Create `~/.config/nvim/lua/plugins/myplugins.lua`:
```lua
return {
  -- Add your plugins here
  { "github/copilot.vim" },
}
```

### Custom Options

Create `~/.config/nvim/lua/config/options.lua`:
```lua
-- Your custom vim options
vim.opt.relativenumber = false
vim.opt.wrap = true
```

### Custom Keymaps

Create `~/.config/nvim/lua/config/keymaps.lua`:
```lua
-- Your custom keybindings
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
```

## Enable LazyVim Extras

LazyVim comes with optional extras you can enable.

Open nvim and run:
```
:LazyExtras
```

This shows available extras like:
- UI enhancements (noice.nvim, edgy.nvim, etc.)
- Language support (Python, Go, Rust, etc.)
- Formatting tools
- Linting tools

## Documentation

- Official LazyVim docs: https://lazyvim.org
- Keybindings: https://lazyvim.org/keymaps
- Plugins: https://lazyvim.org/plugins
- Extras: https://lazyvim.org/extras

## No Tracking in Dotfiles

Your `~/.config/nvim` is **NOT** and **WILL NOT** be tracked in dotfiles.
This gives you complete freedom to customize LazyVim locally without
affecting the dotfiles setup for other machines.

Each machine can have its own nvim customizations!
