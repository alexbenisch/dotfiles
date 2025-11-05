# Updating Neovim Configuration in Dotfiles

Your LazyVim configuration is now tracked in the dotfiles repository.

## How It Works

- **Local config**: `~/.config/nvim/` (your working config)
- **Dotfiles**: `~/.local/share/dotfiles/dot_config/nvim/` (tracked in git)
- **Setup script**: Applies config from dotfiles to local

## Update Dotfiles with Local Changes

When you make changes to your local neovim config and want to save them to dotfiles:

### Method 1: Using Chezmoi (Recommended)

```bash
# Re-add the nvim config to chezmoi (updates tracked files)
chezmoi re-add ~/.config/nvim

# Or add specific changed files
chezmoi add ~/.config/nvim/lua/plugins/myplugin.lua

# Check what changed
chezmoi cd
git status
git diff

# Commit changes
git add .
git commit -m "Update nvim config: <describe your changes>"
git push
exit  # exit chezmoi source directory
```

### Method 2: Manual (for reference)

```bash
cd ~/.local/share/dotfiles

# Copy changed files (including hidden files)
cp -r ~/.config/nvim/. dot_config/nvim/

git add dot_config/nvim/
git commit -m "Update nvim config: <describe your changes>"
git push
```

## Update Local Config from Dotfiles

If you've pulled dotfiles updates and want to apply them locally:

### Using Chezmoi (Recommended)

```bash
# Pull latest dotfiles
cd ~/.local/share/dotfiles
git pull

# Apply nvim config from dotfiles to local
chezmoi apply ~/.config/nvim

# Or just run setup script which does this
./setup
```

### Manual Method

```bash
cd ~/.local/share/dotfiles
git pull

# Copy including hidden files
cp -r dot_config/nvim/. ~/.config/nvim/
```

## What Gets Tracked

Your dotfiles track:
- ✅ `init.lua` - Main neovim entry point
- ✅ `lua/config/*.lua` - Config files (options, keymaps, autocmds, lazy.lua)
- ✅ `lua/plugins/*.lua` - Plugin configurations
- ✅ `lazy-lock.json` - Plugin versions (locked versions)
- ✅ `lazyvim.json` - LazyVim metadata
- ✅ `stylua.toml` - Lua formatter config

## Common Workflows

### Add a New Plugin

1. Edit `~/.config/nvim/lua/plugins/myplugins.lua` (or create new file)
2. Add plugin, e.g.:
   ```lua
   return {
     { "github/copilot.vim" },
   }
   ```
3. Restart nvim - LazyVim will install it
4. Update dotfiles:
   ```bash
   cd ~/.local/share/dotfiles
   cp -r ~/.config/nvim/lua/plugins/* dot_config/nvim/lua/plugins/
   git add dot_config/nvim/lua/plugins/
   git commit -m "Add copilot plugin"
   git push
   ```

### Update Plugin Versions

Your `lazy-lock.json` locks plugin versions for reproducibility.

To update plugins:
```bash
# In nvim
:Lazy sync

# This updates lazy-lock.json with new versions
```

To save updated versions to dotfiles:
```bash
cd ~/.local/share/dotfiles
cp ~/.config/nvim/lazy-lock.json dot_config/nvim/
git add dot_config/nvim/lazy-lock.json
git commit -m "Update plugin versions"
git push
```

### Change Vim Options

1. Edit `~/.config/nvim/lua/config/options.lua`
2. Add your options:
   ```lua
   vim.opt.relativenumber = false
   vim.opt.wrap = true
   ```
3. Save and update dotfiles

### Add Custom Keymaps

1. Edit `~/.config/nvim/lua/config/keymaps.lua`
2. Add keymaps:
   ```lua
   vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save" })
   ```
3. Save and update dotfiles

## Setup Script Behavior

When running `./setup` on a new machine:

1. **If `~/.config/nvim` exists**: Updates it from dotfiles
2. **If `~/.config/nvim` missing**: Installs from dotfiles
3. Uses `chezmoi apply` first, falls back to direct copy

This ensures all your machines have the same LazyVim configuration!

## Important Files

- `dot_config/nvim/lazy-lock.json` - Plugin versions (important for consistency)
- `dot_config/nvim/lazyvim.json` - LazyVim extras and settings
- `dot_config/nvim/lua/plugins/` - All your plugin customizations

## Tips

- Commit `lazy-lock.json` to ensure consistent plugin versions across machines
- Use descriptive commit messages for config changes
- Test changes locally before pushing to dotfiles
- On new machines, run `./setup` to get your full config
