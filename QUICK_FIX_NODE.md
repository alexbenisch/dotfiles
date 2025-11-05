# Quick Fix: Node.js Installation on wrkr1

## Problem
Node.js installation failed with:
```
error while loading shared libraries: libatomic.so.1: cannot open shared object file
```

## Solution

### Option 1: Re-run Updated Setup Script (Recommended)

```bash
cd ~/dotfiles
git pull
./setup
```

The updated setup script now:
- ✅ Installs `libatomic1` before installing tools
- ✅ Installs `build-essential` for compilation
- ✅ Continues even if individual tools fail
- ✅ Shows clear warnings for failed installations

### Option 2: Manual Fix (If Already Completed Setup)

```bash
# Install missing system dependency
sudo apt update && sudo apt install -y libatomic1

# Retry node installation
mise use -g node@latest

# Verify installation
node --version
```

## Verification

After fixing, verify all tools:

```bash
# Check what's installed
mise list

# Test individual tools
nvim --version     # Should work ✅
node --version     # Should work after fix ✅
python --version   # Should work ✅
```

## What Happened on wrkr1

Your current run installed:
- ✅ neovim - Successfully installed
- ❌ node - Failed due to missing libatomic1
- ⏸️ Other tools - Installation stopped

After re-running with the updated script, all tools should install successfully.

## Prevention

The updated setup script now installs these system dependencies automatically:
- `libatomic1` - Atomic operations library (needed by Node.js)
- `build-essential` - GCC, make, and build tools
- Plus distro-specific equivalents for RHEL, Fedora, Arch

This prevents the error on fresh Ubuntu/Debian installations.
