# Update Local Neovim Configuration

## Quick Update

To update your local neovim config with the latest changes from dotfiles:

```bash
# Pull latest dotfiles
cd ~/.local/share/dotfiles
git pull

# Copy updated config to local nvim
cp -r dot_config/nvim/lua/plugins/* ~/.config/nvim/lua/plugins/

# Launch nvim to install/update plugins
nvim
```

When you open nvim, LazyVim will automatically:
- Detect new plugins (like noice.nvim)
- Update existing plugins
- Install any missing dependencies

## What's New: noice.nvim

The config now includes **noice.nvim** which provides:

### ✨ Features
- **Fancy Command Line** - Command line appears at the top with nice UI
- **Better Notifications** - Pretty notification popups with nvim-notify
- **Command Palette** - Modern command interface
- **LSP Documentation** - Better borders and formatting for LSP hover docs
- **Message History** - Use `:Noice` to see message history

### 🎨 Visual Changes
- Command line moves from bottom to a floating window at top
- Notifications appear in top-right corner with animations
- Search appears at the bottom with better highlighting
- Messages use a cleaner, more modern interface

## Manual Plugin Update

If you just want to update plugins without copying config:

```bash
# Open nvim
nvim

# Inside nvim, run:
:Lazy sync
```

This updates all plugins to their latest versions.

## Troubleshooting

### Noice not working
If noice.nvim doesn't load:
1. Make sure the config file exists: `~/.config/nvim/lua/plugins/noice.lua`
2. Open nvim and run `:Lazy` to check plugin status
3. Run `:Lazy sync` to install/update plugins

### Want to disable noice
If you don't like noice.nvim:
```bash
# Remove or rename the config file
mv ~/.config/nvim/lua/plugins/noice.lua ~/.config/nvim/lua/plugins/noice.lua.disabled

# Restart nvim
```

### Reset to clean state
If something breaks:
```bash
# Backup current config
mv ~/.config/nvim ~/.config/nvim.bak

# Reinstall from dotfiles
cd ~/dotfiles
./setup

# This will clone LazyVim starter and apply your custom config
```

## Checking What Changed

To see what's different between dotfiles and your local config:

```bash
# Compare plugins directory
diff -r ~/.local/share/dotfiles/dot_config/nvim/lua/plugins/ ~/.config/nvim/lua/plugins/
```

## After Update

Once you've updated and launched nvim:
1. LazyVim will show a popup with changes
2. It will install noice.nvim and its dependencies
3. Restart nvim to see the full noice.nvim UI
4. Try commands like `:Noice` to see the message history

Enjoy your enhanced LazyVim experience! 🚀
