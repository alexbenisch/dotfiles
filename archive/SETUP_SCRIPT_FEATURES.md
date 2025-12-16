# Setup Script Features

## What the Setup Script Does Automatically

The `./setup` script fully automates your development environment setup. Here's everything it handles:

### 🔧 System Tools Installation

- ✅ **chezmoi** - Dotfiles manager (installed system-wide to `/usr/local/bin`)
- ✅ **mise** - Development tool version manager (installed system-wide)
- ✅ **zsh** - Modern shell (via system package manager)
- ✅ **tmux** - Terminal multiplexer (via system package manager)
- ✅ **fzf** - Fuzzy finder (via system package manager or mise)

### 📝 Shell Configuration

- ✅ **Backs up existing configs** with `bkp_` prefix:
  - `.zshrc` → `bkp_.zshrc`
  - `.zprofile` → `bkp_.zprofile`
  - `.bashrc` → `bkp_.bashrc`
  - `.zfunc/` → `bkp_.zfunc/`

- ✅ **Applies new configurations** from dotfiles:
  - `.zshrc` with all customizations
  - `.zprofile` for login shell setup
  - `.bashrc` for bash compatibility
  - `.zfunc/` with shell completions

- ✅ **Installs Antigen** plugin manager for zsh
- ✅ **Installs Pure** prompt theme
- ✅ **Sets zsh as default shell**

### 🛠️ Development Tools via mise

Automatically installs ALL tools from `~/.config/mise/config.toml`:

#### Editors & Runtimes
- ✅ **neovim** - Modern text editor (binary via mise)
- ✅ **LazyVim** - Neovim configuration with plugins (applied automatically)
- ✅ **node** - JavaScript runtime
- ✅ **python** - Programming language

#### CLI Utilities
- ✅ **bat** - Better cat with syntax highlighting
- ✅ **fzf** - Fuzzy file finder
- ✅ **lsd** - Better ls with colors and icons
- ✅ **ripgrep** - Fast grep alternative
- ✅ **uv** - Fast Python package manager

#### Kubernetes Tools
- ✅ **kubectl** - Kubernetes CLI
- ✅ **flux2** - GitOps toolkit
- ✅ **k9s** - Kubernetes TUI

#### Other Tools
- ✅ **commitizen** - Commit message tool

### 🎨 Alacritty & tmux Setup

- ✅ **Alacritty themes** - Downloaded if Alacritty is installed
- ✅ **tmux plugin manager (tpm)** - Installed automatically
- ✅ **tmux plugins** - Auto-installed from config

### 📁 Directory Structure

Creates essential directories:
- ✅ `~/.config/` - Configuration directory
- ✅ `~/.local/bin/` - Local binaries
- ✅ `~/bin/` - User binaries
- ✅ `~/repos/` - Repositories directory
- ✅ `~/.zfunc/` - ZSH completion functions

### 🔍 Verification & Error Handling

- ✅ **Verifies files applied** - Checks all config files exist
- ✅ **Shows clear errors** - No silent failures
- ✅ **Fallback mechanisms** - Direct copy if chezmoi fails
- ✅ **Reports missing tools** - Lists what needs manual attention

## Usage

### First Time Setup on New Server

```bash
# Clone dotfiles
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run setup (handles everything!)
./setup

# Reload shell
exec zsh

# Verify
mise list
nvim --version
```

That's it! No manual steps needed.

### Updating Existing Installation

```bash
cd ~/dotfiles
git pull
./setup  # Re-run to apply updates
```

## What's NOT Applied Automatically

The setup script intentionally does NOT apply these (to avoid overwriting):

- ❌ `~/.config/tmux/` - tmux configuration (apply with `chezmoi apply ~/.config/tmux`)
- ❌ Other `~/.config/*` directories (except mise and nvim which ARE applied)

To apply these:
```bash
# Review changes first
chezmoi diff

# Apply selectively
chezmoi apply ~/.config/tmux

# Or apply everything
chezmoi apply
```

## LazyVim Setup

The setup script follows the official LazyVim installation:
1. ✅ Installs neovim binary via mise
2. ✅ Clones LazyVim starter from GitHub: `git clone https://github.com/LazyVim/starter ~/.config/nvim`
3. ✅ Removes `.git` folder (so you can manage it yourself)
4. ✅ **Pure LazyVim defaults** - No custom configuration applied
5. ✅ Preserves existing nvim config if already present

On first `nvim` launch, LazyVim will automatically:
- Install lazy.nvim plugin manager
- Install all default plugins
- Set up LSP servers
- Download treesitter parsers

Just run `nvim` and LazyVim handles the rest!

### Customizing LazyVim

Your nvim config at `~/.config/nvim` is NOT tracked in dotfiles.
You can customize it locally by editing files in `~/.config/nvim/lua/`:
- `plugins/*.lua` - Add your own plugins
- `config/options.lua` - Custom vim options
- `config/keymaps.lua` - Custom keybindings

See [LazyVim documentation](https://lazyvim.org) for customization guide.

### Reinstalling LazyVim

If you need to reinstall LazyVim:
```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak  # optional
mv ~/.local/state/nvim ~/.local/state/nvim.bak  # optional
mv ~/.cache/nvim ~/.cache/nvim.bak              # optional

# Re-run setup
cd ~/dotfiles
./setup
```

## Troubleshooting

If something goes wrong, see:
- `TROUBLESHOOTING.md` - Common issues and fixes
- `TESTING.md` - How to run tests
- `README_SERVER_SETUP.md` - Post-setup verification

## Design Principles

1. **Automated by default** - No manual steps unless necessary
2. **Safe backups** - Never overwrite without backup
3. **Verify everything** - Check files exist after applying
4. **Clear errors** - Show what went wrong and how to fix
5. **Fallback mechanisms** - Works even if tools fail
6. **Idempotent** - Safe to run multiple times

## Testing

Run automated tests to verify setup works:

```bash
./test_setup_integration.sh  # Test backup and apply
./test_mise_setup.sh          # Test mise configuration
./test_backup.sh              # Test backup functions
```

All tests should pass before deployment to new servers.
