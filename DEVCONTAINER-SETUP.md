# DevContainer Setup Analysis

## Summary
Your Dockerfile and devcontainer.json already handle most of the setup work. The main `setup` script has significant duplication with your container configuration.

## What's Already in Dockerfile (~/repos/ide/.devcontainer/Dockerfile)

### System Tools (pre-installed)
- **zsh** (line 6) - setup script lines 109-128 can be skipped
- **git, curl** (lines 7-8) - assumed in setup script
- **tmux** (line 18) - setup script lines 203-221 can be skipped
- **fzf** (line 21) - setup script lines 174-191 can be skipped
- **neovim** (line 17) - setup script lines 288-291 can be skipped
- **bat** (line 22) - setup script line 273 can be skipped
- **ripgrep** (line 19) - setup script line 276 can be skipped
- **nodejs/npm** (line 35) - setup script lines 293-296 can be skipped

### Development Tools (pre-installed)
- **mise** (lines 51-52) - setup script line 85 can be skipped
- **chezmoi** (line 76) - setup script line 72 can be skipped
- **LazyVim** (lines 79-80) - setup script lines 327-371 can be skipped

### Build Dependencies (pre-installed)
- **build-base** (line 30 - Alpine equivalent of build-essential) - setup script lines 88-106 can be skipped

### Other Tools
- kubectl, helm, docker-cli, aws-cli, azure-cli (lines 38-48)
- Python tools via pip (lines 83-88)

## What's Already in devcontainer.json

### Automated Setup Commands
- **postCreateCommand** (line 22):
  - Runs `chezmoi init --apply` - duplicates setup script lines 403-407, 421-435
  - Sets up SSH config
  - Runs `mise trust` - duplicates part of new setup-devcontainer

- **postStartCommand** (line 23):
  - Runs `chezmoi apply` - duplicates setup script lines 468-473

### Mounts
- SSH keys, kubeconfig, docker socket already mounted

## What You Still Need (setup-devcontainer)

The new minimal script **only** handles:

1. **ssh-agent setup** - Runtime configuration (can't be in Dockerfile)
2. **Antigen** - Zsh plugin manager (not in Dockerfile)
3. **Pure prompt** - Zsh theme (not in Dockerfile)
4. **tpm** - Tmux plugin manager (needs config files first)
5. **mise trust** - Runtime trust settings
6. **Directory creation** - Quick directory setup

Total: ~90 lines vs 542 lines in original setup script

## Recommended Approach

### For DevContainer Use:
1. Update `devcontainer.json` postCreateCommand to call `setup-devcontainer`:
   ```json
   "postCreateCommand": "~/.local/share/dotfiles/setup-devcontainer"
   ```

2. Keep the full `setup` script for:
   - Bare metal installations
   - Non-containerized environments
   - Fresh system setup

### What Can Be Optimized in devcontainer.json

Your current postCreateCommand is quite complex. Consider simplifying:

**Current:**
```bash
(sh -c \"$(curl -fsLS get.chezmoi.io)\" -- init --apply --source ~/.local/share/dotfiles alexbenisch/dotfiles || true) && ...
```

**Suggested:**
```bash
~/.local/share/dotfiles/setup-devcontainer
```

This is cleaner because:
- Chezmoi is already installed in Dockerfile (line 76)
- The setup-devcontainer script handles runtime config
- Easier to maintain and debug

## Size Comparison

| Script | Lines | Purpose |
|--------|-------|---------|
| `setup` | 542 | Full system setup (bare metal) |
| `setup-devcontainer` | ~90 | Minimal runtime config (containers) |
| **Savings** | **83%** | When using devcontainers |

## Migration Path

1. ✅ Created `setup-devcontainer` (minimal script for containers)
2. ⏭️  Update devcontainer.json postCreateCommand (optional)
3. ⏭️  Keep full `setup` script for non-container environments
4. ⏭️  Document which script to use when

## Files Modified

- **Created:** `~/.local/share/dotfiles/setup-devcontainer` (90 lines)
- **Created:** `~/.local/share/dotfiles/DEVCONTAINER-SETUP.md` (this file)
- **Original:** `~/.local/share/dotfiles/setup` (kept unchanged, 542 lines)
