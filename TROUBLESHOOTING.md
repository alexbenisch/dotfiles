# Troubleshooting Guide

## Missing .zshrc and .zprofile after setup

### Problem
After running the setup script on a new server, you have backup files (`bkp_.zshrc`, `bkp_.bashrc`, `bkp_.zfunc`) but the actual configuration files (`.zshrc`, `.zprofile`, `.bashrc`) are missing from your home directory.

### Root Cause
The setup script was backing up existing files but `chezmoi apply` was failing silently. The error suppression (`2>/dev/null`) hid the actual problem, and there was no fallback mechanism.

### Quick Fix (for wrkr1)

If you're currently on wrkr1 with missing config files:

```bash
# Option 1: Use chezmoi to apply (if initialized correctly)
cd ~/dotfiles
chezmoi apply

# Option 2: Copy directly from dotfiles source
cp ~/dotfiles/dot_zshrc ~/.zshrc
cp ~/dotfiles/dot_zprofile ~/.zprofile
cp ~/dotfiles/dot_bashrc ~/.bashrc
cp -r ~/dotfiles/dot_zfunc ~/.zfunc

# Restart your shell
exec zsh
```

### Restore from Backup (if needed)

If you want to restore your original configs instead:

```bash
# Restore original files
mv ~/bkp_.bashrc ~/.bashrc
mv ~/bkp_.zfunc ~/.zfunc

# If zshrc and zprofile backups exist:
mv ~/bkp_.zshrc ~/.zshrc
mv ~/bkp_.zprofile ~/.zprofile
```

### Solution in Updated Script

The setup script has been updated (commit 3243bb7) to:

1. **Show errors** - Removed `2>/dev/null` so you can see what's failing
2. **Add fallback** - If `chezmoi apply` fails, automatically copies from source
3. **Verify** - Checks that files exist after applying and warns if missing
4. **Better feedback** - Shows "🔄 Applying..." messages and clear error states

### Running Updated Setup

Pull the latest changes and re-run setup:

```bash
cd ~/dotfiles
git pull
./setup
```

The new version will:
- Try `chezmoi apply` first
- Fall back to direct copy if chezmoi fails
- Verify all files exist after applying
- Show clear error messages if something goes wrong

### Common Issues

#### Issue: chezmoi not initialized
**Symptom**: `chezmoi apply` fails with "source directory not found"

**Fix**:
```bash
chezmoi init --source=/path/to/dotfiles
```

#### Issue: Wrong working directory
**Symptom**: `DOTFILES_SOURCE` points to wrong directory

**Fix**: Always run setup from the dotfiles directory:
```bash
cd ~/dotfiles  # or wherever you cloned it
./setup
```

#### Issue: Files don't have execute permission
**Symptom**: `bash: ./setup: Permission denied`

**Fix**:
```bash
chmod +x setup
./setup
```

### Verification After Setup

Check that all files are in place:

```bash
ls -la ~/ | grep -E "\.zshrc|\.zprofile|\.bashrc|\.zfunc"
```

You should see:
- `.zshrc` (configuration file, not backup)
- `.zprofile` (configuration file, not backup)
- `.bashrc` (configuration file, not backup)
- `.zfunc/` (directory with completions)
- `bkp_*` files (backups of original files, if they existed)

### Getting Help

If problems persist:

1. Check the output of `./setup` for error messages
2. Try manual copy method shown above
3. Verify chezmoi is working: `chezmoi doctor`
4. Check file locations: `chezmoi source-path`
