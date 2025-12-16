# Server Setup Guide

## Quick Start for New Servers

After running the setup script successfully, your shell configuration will be ready and **all development tools should be automatically installed**.

### 1. Verify Shell Configuration

Check that your shell configs are present:
```bash
ls -la ~/ | grep -E "\.zshrc|\.zprofile|\.bashrc|\.zfunc"
```

You should see:
- `.zshrc` ✅
- `.zprofile` ✅
- `.bashrc` ✅
- `.zfunc/` ✅

### 2. Verify Development Tools

The setup script automatically installs all tools from your mise config:

```bash
# Check installed tools
mise list

# Verify specific tools
nvim --version
node --version
python --version
kubectl version --client
```

**If any tools are missing**, run:
```bash
# Install all tools from mise config
mise install
```

### 3. Apply Additional Configs (Optional)

The setup script only applies shell configs. For other configurations:

```bash
# Review what will change
chezmoi diff

# Apply specific configs
chezmoi apply ~/.config/mise
chezmoi apply ~/.config/tmux
chezmoi apply ~/.config/nvim

# Or apply everything
chezmoi apply
```

## Common Post-Setup Tasks

### Install Neovim
```bash
# Via mise (recommended - gets latest version)
mise use -g neovim@latest

# Or via system package manager
sudo snap install nvim --classic
# or
sudo apt install neovim
```

### Set Up Git
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Install Docker (if needed)
```bash
# Follow official Docker installation for Ubuntu
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### Install Additional CLI Tools
```bash
# Example: Install useful CLI tools via mise
mise use -g bat@latest        # Better cat
mise use -g lsd@latest        # Better ls
mise use -g ripgrep@latest    # Fast grep
mise use -g fd@latest         # Better find
mise use -g delta@latest      # Better git diff
```

## Troubleshooting

### Shell Not Loading Config
```bash
# Manually source the config
source ~/.zshrc

# Or restart shell
exec zsh
```

### mise Commands Not Found
```bash
# Check if mise is in PATH
which mise

# If not found, add to PATH manually
export PATH="$HOME/.local/bin:$PATH"

# Or reinstall mise
curl https://mise.run | sh
```

### Neovim Not Found
```bash
# Install via mise
mise use -g neovim@latest

# Verify installation
which nvim
nvim --version
```

### Tool Versions Not Updating
```bash
# Update mise itself
mise self-update

# Update all tools
mise upgrade

# Reinstall specific tool
mise uninstall neovim
mise use -g neovim@latest
```

## Server-Specific Notes

### wrkr1
- Initial setup completed ✅
- Shell configuration working ✅
- Next steps: Install neovim and other tools via mise

## Regular Maintenance

```bash
# Update dotfiles
cd ~/dotfiles
git pull
chezmoi apply

# Update mise and tools
mise self-update
mise upgrade

# Update system packages
sudo apt update && sudo apt upgrade -y
```
