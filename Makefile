.PHONY: help install update sync clean test

# Default target
help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'

install: ## Install dotfiles using setup script
	./setup

update: ## Update dotfiles from remote repository
	@if command -v chezmoi >/dev/null 2>&1; then \
		echo "🔄 Updating dotfiles with chezmoi..."; \
		chezmoi update; \
	else \
		echo "📦 Chezmoi not found, pulling with git..."; \
		git pull origin main; \
		./setup; \
	fi

sync: ## Sync local changes back to repository
	@if command -v chezmoi >/dev/null 2>&1; then \
		echo "🔄 Syncing changes with chezmoi..."; \
		chezmoi re-add; \
	else \
		echo "⚠️  Chezmoi not found, manual git operations required"; \
	fi

clean: ## Clean up temporary files
	@echo "🧹 Cleaning up temporary files..."
	@find . -name "*.tmp" -delete
	@find . -name "*.log" -delete
	@find . -name "*~" -delete
	@echo "✅ Cleanup complete"

test: ## Test dotfiles configuration
	@echo "🧪 Testing dotfiles configuration..."
	@bash -n dot_bashrc && echo "✅ bashrc syntax OK" || echo "❌ bashrc syntax error"
	@zsh -n dot_zshrc && echo "✅ zshrc syntax OK" || echo "❌ zshrc syntax error"
	@echo "🔍 Checking for required tools..."
	@command -v git >/dev/null && echo "✅ git found" || echo "⚠️  git not found"
	@command -v zsh >/dev/null && echo "✅ zsh found" || echo "⚠️  zsh not found"
	@command -v tmux >/dev/null && echo "✅ tmux found" || echo "⚠️  tmux not found"
	@command -v nvim >/dev/null && echo "✅ neovim found" || echo "⚠️  neovim not found"

backup: ## Create backup of current dotfiles
	@echo "💾 Creating dotfiles backup..."
	@mkdir -p backups
	@tar -czf "backups/dotfiles-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz" \
		--exclude='.git' --exclude='backups' .
	@echo "✅ Backup created in backups/ directory"

check: ## Check dotfiles for common issues
	@echo "🔍 Checking dotfiles for common issues..."
	@if grep -r "<<<<<<< HEAD" . --exclude-dir=.git >/dev/null 2>&1; then \
		echo "❌ Merge conflicts found:"; \
		grep -r "<<<<<<< HEAD" . --exclude-dir=.git; \
	else \
		echo "✅ No merge conflicts found"; \
	fi
	@if grep -r "TODO\|FIXME\|XXX" . --exclude-dir=.git --exclude="Makefile" >/dev/null 2>&1; then \
		echo "📋 TODOs found:"; \
		grep -r "TODO\|FIXME\|XXX" . --exclude-dir=.git --exclude="Makefile"; \
	else \
		echo "✅ No outstanding TODOs"; \
	fi