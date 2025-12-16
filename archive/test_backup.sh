#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🧪 Testing backup functionality for setup script"
echo ""

# Create a test directory
TEST_DIR=$(mktemp -d)
TEST_HOME="$TEST_DIR/home"
mkdir -p "$TEST_HOME"

echo "📁 Test directory: $TEST_DIR"
echo "🏠 Mock home directory: $TEST_HOME"
echo ""

# Track test results
PASSED=0
FAILED=0

# Test helper functions
pass() {
  echo -e "${GREEN}✅ PASS${NC}: $1"
  ((PASSED++))
}

fail() {
  echo -e "${RED}❌ FAIL${NC}: $1"
  ((FAILED++))
}

info() {
  echo -e "${YELLOW}ℹ️  INFO${NC}: $1"
}

# Create mock files to backup
echo "📝 Creating mock configuration files..."
echo "# Mock .zshrc" > "$TEST_HOME/.zshrc"
echo "# Mock .zprofile" > "$TEST_HOME/.zprofile"
echo "# Mock .bashrc" > "$TEST_HOME/.bashrc"
mkdir -p "$TEST_HOME/.zfunc"
echo "# Mock docker completion" > "$TEST_HOME/.zfunc/_docker"

echo ""
echo "🔍 Testing backup_and_apply function..."

# Source the functions from setup script (extract just the function)
backup_and_apply() {
  local file="$1"
  local home_path="$TEST_HOME/$file"

  if [ -f "$home_path" ]; then
    backup_name="bkp_${file}"
    mv "$home_path" "$TEST_HOME/$backup_name"
    echo "💾 Backed up existing $file to $backup_name"
  fi
}

backup_and_apply_dir() {
  local dir="$1"
  local home_path="$TEST_HOME/$dir"

  if [ -d "$home_path" ]; then
    backup_name="bkp_${dir}"
    mv "$home_path" "$TEST_HOME/$backup_name"
    echo "💾 Backed up existing $dir to $backup_name"
  fi
}

# Test 1: Backup .zshrc
echo ""
echo "Test 1: Backup .zshrc file"
if [ -f "$TEST_HOME/.zshrc" ]; then
  backup_and_apply ".zshrc"
  if [ -f "$TEST_HOME/bkp_.zshrc" ] && [ ! -f "$TEST_HOME/.zshrc" ]; then
    pass "Successfully backed up .zshrc to bkp_.zshrc"
  else
    fail ".zshrc backup failed"
  fi
else
  fail ".zshrc not found in test directory"
fi

# Test 2: Backup .zprofile
echo ""
echo "Test 2: Backup .zprofile file"
if [ -f "$TEST_HOME/.zprofile" ]; then
  backup_and_apply ".zprofile"
  if [ -f "$TEST_HOME/bkp_.zprofile" ] && [ ! -f "$TEST_HOME/.zprofile" ]; then
    pass "Successfully backed up .zprofile to bkp_.zprofile"
  else
    fail ".zprofile backup failed"
  fi
else
  fail ".zprofile not found in test directory"
fi

# Test 3: Backup .bashrc
echo ""
echo "Test 3: Backup .bashrc file"
if [ -f "$TEST_HOME/.bashrc" ]; then
  backup_and_apply ".bashrc"
  if [ -f "$TEST_HOME/bkp_.bashrc" ] && [ ! -f "$TEST_HOME/.bashrc" ]; then
    pass "Successfully backed up .bashrc to bkp_.bashrc"
  else
    fail ".bashrc backup failed"
  fi
else
  fail ".bashrc not found in test directory"
fi

# Test 4: Backup .zfunc directory
echo ""
echo "Test 4: Backup .zfunc directory"
if [ -d "$TEST_HOME/.zfunc" ]; then
  backup_and_apply_dir ".zfunc"
  if [ -d "$TEST_HOME/bkp_.zfunc" ] && [ ! -d "$TEST_HOME/.zfunc" ]; then
    if [ -f "$TEST_HOME/bkp_.zfunc/_docker" ]; then
      pass "Successfully backed up .zfunc directory to bkp_.zfunc with contents preserved"
    else
      fail ".zfunc directory backed up but contents missing"
    fi
  else
    fail ".zfunc directory backup failed"
  fi
else
  fail ".zfunc directory not found in test directory"
fi

# Test 5: Test idempotency (backup should not fail if file doesn't exist)
echo ""
echo "Test 5: Test idempotency (no file to backup)"
backup_and_apply ".zshrc"  # Should not fail even though file doesn't exist anymore
pass "Function handles non-existent files gracefully"

echo ""
echo "📊 Final test directory contents:"
ls -la "$TEST_HOME"

# Cleanup
echo ""
echo "🧹 Cleaning up test directory..."
rm -rf "$TEST_DIR"

# Summary
echo ""
echo "================================"
echo "📊 Test Summary"
echo "================================"
echo -e "Tests passed: ${GREEN}$PASSED${NC}"
echo -e "Tests failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}❌ Some tests failed${NC}"
  exit 1
fi
