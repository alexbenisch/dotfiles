# Chezmoi Configuration

Your dotfiles are configured to use chezmoi with `~/.local/share/dotfiles` as the source directory.

## Automatic Configuration

The setup script automatically configures chezmoi by creating `~/.config/chezmoi/chezmoi.toml`:

```toml
sourceDir = "~/.local/share/dotfiles"
```

This is done automatically when you run `./setup` on any machine.

## Verify Configuration

```bash
# Check source directory
chezmoi source-path
# Should output: /home/youruser/.local/share/dotfiles

# Check what chezmoi is managing
chezmoi status

# Navigate to source directory
chezmoi cd
# Takes you to ~/.local/share/dotfiles
```

## Using Chezmoi Commands

All chezmoi commands now work with your dotfiles directory:

### Add Files to Dotfiles

```bash
# Add a single file
chezmoi add ~/.zshrc

# Add a directory
chezmoi add ~/.config/nvim

# Re-add to update existing files
chezmoi re-add ~/.config/nvim
```

### Apply Files from Dotfiles

```bash
# Apply specific file
chezmoi apply ~/.zshrc

# Apply specific directory
chezmoi apply ~/.config/nvim

# Apply everything
chezmoi apply
```

### Check Differences

```bash
# See what would change
chezmoi diff

# See what would change for specific file
chezmoi diff ~/.zshrc

# Check status of all managed files
chezmoi status
```

### Manage Changes

```bash
# Go to dotfiles source directory
chezmoi cd

# Make changes, then commit
git add .
git commit -m "Update dotfiles"
git push

# Exit source directory
exit
```

## Directory Structure

```
~/.local/share/dotfiles/           # Source directory (git repo)
├── dot_zshrc                      # Becomes ~/.zshrc
├── dot_config/
│   ├── nvim/                     # Becomes ~/.config/nvim/
│   │   ├── init.lua
│   │   └── lua/
│   └── chezmoi/
│       └── chezmoi.toml.tmpl     # Chezmoi config template
├── setup                         # Setup script
└── ...

~/.config/chezmoi/                # Chezmoi runtime config
└── chezmoi.toml                  # Created by setup script
```

## Key Benefits

1. **Consistent Source**: All machines use same source directory path
2. **Simple Commands**: `chezmoi add/apply` work directly with dotfiles
3. **Version Control**: Changes committed to git in dotfiles repo
4. **Templates**: Can use chezmoi templates for per-machine config
5. **Automatic Setup**: Setup script configures everything

## Example Workflow

### Update Your Neovim Config

```bash
# 1. Edit locally
nvim ~/.config/nvim/lua/plugins/new.lua

# 2. Add to dotfiles
chezmoi re-add ~/.config/nvim

# 3. Commit changes
chezmoi cd
git add .
git commit -m "Add new neovim plugin"
git push
exit
```

### Apply Updates on Another Machine

```bash
# 1. Pull dotfiles
cd ~/.local/share/dotfiles  # or: chezmoi cd
git pull
exit  # if you used chezmoi cd

# 2. Apply changes
chezmoi apply ~/.config/nvim

# 3. Restart nvim
nvim
```

## Troubleshooting

### Wrong Source Directory

If chezmoi is using wrong source:

```bash
# Check current source
chezmoi source-path

# If it's wrong, run setup again
cd ~/dotfiles
./setup
```

### Config Not Found

If `~/.config/chezmoi/chezmoi.toml` is missing:

```bash
# Run setup to recreate it
cd ~/dotfiles
./setup
```

### Manual Configuration

If you need to manually configure:

```bash
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml <<EOF
sourceDir = "~/.local/share/dotfiles"
EOF
```

## Resources

- Chezmoi documentation: https://www.chezmoi.io/
- Your dotfiles: `~/.local/share/dotfiles`
- Chezmoi config: `~/.config/chezmoi/chezmoi.toml`
