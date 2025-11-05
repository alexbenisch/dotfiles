# Testing Documentation

## Overview

This directory contains automated tests to validate the dotfiles setup and backup functionality.

## Test Files

### `test_setup_integration.sh`

**Purpose**: Integration test that validates the complete backup and apply workflow for ZSH configuration files.

### `test_mise_setup.sh`

**Purpose**: Test that validates mise configuration is applied correctly before tools are installed.

**What it tests**:
- ✅ Mise config directory is created
- ✅ Mise config.toml is copied correctly
- ✅ Config contains neovim
- ✅ Config contains node
- ✅ Config contains python

**How to run**:
```bash
./test_mise_setup.sh
```

**Expected output**: All 5 tests should pass.

**What it tests** (test_setup_integration.sh):
- ✅ Backs up existing `.zshrc` to `bkp_.zshrc`
- ✅ Backs up existing `.zprofile` to `bkp_.zprofile`
- ✅ Backs up existing `.zfunc` directory to `bkp_.zfunc`
- ✅ Applies new configuration from dotfiles
- ✅ Preserves original content in backups
- ✅ Correctly replaces old files with new ones

**How to run**:
```bash
./test_setup_integration.sh
```

**Expected output**: All 7 tests should pass with a success message.

### `test_backup.sh`

**Purpose**: Unit tests for the backup functions in isolation.

**What it tests**:
- Backup function for individual files
- Backup function for directories
- Idempotency (handles non-existent files gracefully)

**How to run**:
```bash
./test_backup.sh
```

## Running Tests Before Changes

Before modifying the `setup` script, run the tests to ensure current functionality works:

```bash
./test_setup_integration.sh
```

If all tests pass, you can safely make changes. After modifying the script, run the tests again to ensure your changes didn't break existing functionality.

## What the Tests Validate

The integration test creates an isolated test environment with:
1. Mock home directory with existing ZSH configs
2. Mock dotfiles directory with new configs
3. Executes the backup functions
4. Validates that:
   - Original files are backed up with `bkp_` prefix
   - New files are applied correctly
   - Original content is preserved in backups
   - Directory structures are maintained

## Backup Naming Convention

The setup script uses the `bkp_` prefix for all backups:
- `.zshrc` → `bkp_.zshrc`
- `.zprofile` → `bkp_.zprofile`
- `.zfunc/` → `bkp_.zfunc/`

This makes backups easy to identify and restore if needed.

## Restoring from Backup

If you need to restore your original configuration:

```bash
# Restore .zshrc
mv ~/bkp_.zshrc ~/.zshrc

# Restore .zprofile
mv ~/bkp_.zprofile ~/.zprofile

# Restore .zfunc
rm -rf ~/.zfunc
mv ~/bkp_.zfunc ~/.zfunc
```
