#!/bin/bash
set -e # Beende das Skript bei Fehlern

# Definiere Dotfiles-Quellverzeichnis
DOTFILES_SOURCE="$HOME/.local/share/dotfiles"

echo "❄️ Überprüfe Nix Package Manager..."

# Prüfe, ob Nix bereits installiert ist, andernfalls installiere ihn
if ! command -v nix-env &>/dev/null; then
	echo "🔄 Installiere Nix Package Manager..."
	curl -L https://nixos.org/nix/install | sh

	# Lade Nix-Umgebung in die aktuelle Shell
	if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
		source "$HOME/.nix-profile/etc/profile.d/nix.sh"
	else
		echo "⚠️ Konnte Nix-Umgebung nicht laden. Starte eine neue Shell und versuche es erneut."
		exit 1
	fi
fi

echo "📦 Installiere benötigte Pakete mit Nix..."

# Installiere Pakete mit Nix
nix-env -iA \
	nixpkgs.git \
	nixpkgs.curl \
	nixpkgs.unzip \
	nixpkgs.wget \
	nixpkgs.ripgrep \
	nixpkgs.fd \
	nixpkgs.neovim \
	nixpkgs.lua \
	nixpkgs.gnumake \
	nixpkgs.gcc \
	nixpkgs.zsh \
	nixpkgs.tmux \
	nixpkgs.stow

# Erstelle benötigte Verzeichnisse
mkdir -p "$HOME/.config/zsh"

# Richte ZSH-Theme ein
if [ ! -d "$HOME/.config/zsh/pure" ]; then
	echo "🎨 Installiere Pure ZSH-Theme..."
	git clone https://github.com/sindresorhus/pure.git "$HOME/.config/zsh/pure"
fi

# Richte LazyVim ein
if [ ! -d "$HOME/.config/nvim" ]; then
	echo "🚀 Installiere LazyVim..."
	git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
	rm -rf "$HOME/.config/nvim/.git"
fi

# Überprüfe, ob Dotfiles-Verzeichnis existiert
if [ ! -d "$DOTFILES_SOURCE" ]; then
	echo "❌ Dotfiles-Verzeichnis $DOTFILES_SOURCE nicht gefunden"
	echo "Bitte klone dein Dotfiles-Repository nach $DOTFILES_SOURCE"
	exit 1
fi

# Wechsle ins Dotfiles-Verzeichnis und verlinke Dateien
echo "🔧 Symlinking Dotfiles mit Stow..."
cd "$DOTFILES_SOURCE"
stow -t "$HOME" zsh tmux nvim

echo "📦 Installiere Plugins und Abhängigkeiten..."
# LazyVim Plugins installieren
nvim --headless "+Lazy sync" +qa

echo "✅ Setup abgeschlossen!"
echo "🐚 Starte eine neue ZSH-Shell..."
exec zsh
