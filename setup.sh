#!/bin/bash
set -e # Beende das Skript bei Fehlern

# Definiere Dotfiles-Quellverzeichnis
DOTFILES_SOURCE="$HOME/.local/share/dotfiles"

# Paketmanager und Systeminformationen ermitteln
if [ -f /etc/debian_version ]; then
	echo "🐧 Debian-basiertes System erkannt"
	PACKAGE_MANAGER="apt"
	INSTALL_CMD="sudo apt update && sudo apt install -y"
elif [ -f /etc/fedora-release ]; then
	echo "🎩 Fedora-basiertes System erkannt"
	PACKAGE_MANAGER="dnf"
	INSTALL_CMD="sudo dnf install -y"
elif command -v nix-env &>/dev/null; then
	echo "❄️ Nix Package Manager erkannt"
	PACKAGE_MANAGER="nix"
	INSTALL_CMD="nix-env -iA nixpkgs."
else
	echo "⚠️ Unterstützter Paketmanager nicht gefunden."
	echo "Möchten Sie Nix Package Manager installieren? (y/n)"
	read -r install_nix
	if [[ $install_nix =~ ^[Yy]$ ]]; then
		echo "🔄 Installiere Nix Package Manager..."
		curl -L https://nixos.org/nix/install | sh
		source ~/.nix-profile/etc/profile.d/nix.sh
		PACKAGE_MANAGER="nix"
		INSTALL_CMD="nix-env -iA nixpkgs."
	else
		echo "❌ Kein unterstützter Paketmanager gefunden. Installation abgebrochen."
		exit 1
	fi
fi

echo "📦 Installiere benötigte Pakete mit $PACKAGE_MANAGER..."

# Paketliste
packages="git curl unzip wget ripgrep lua make gcc zsh tmux neovim"

if [ "$PACKAGE_MANAGER" = "apt" ]; then
	$INSTALL_CMD $packages fd-find
elif [ "$PACKAGE_MANAGER" = "dnf" ]; then
	$INSTALL_CMD $packages fd-find
elif [ "$PACKAGE_MANAGER" = "nix" ]; then
	# Bei Nix müssen wir die Pakete einzeln installieren
	for pkg in $packages fd; do
		$INSTALL_CMD$pkg
	done
fi

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

# Prüfe, ob stow installiert ist
if ! command -v stow &>/dev/null; then
	echo "📥 Stow nicht gefunden, installiere..."
	if [ "$PACKAGE_MANAGER" = "apt" ]; then
		sudo apt install -y stow
	elif [ "$PACKAGE_MANAGER" = "dnf" ]; then
		sudo dnf install -y stow
	elif [ "$PACKAGE_MANAGER" = "nix" ]; then
		nix-env -iA nixpkgs.stow
	fi
fi

# Überprüfe, ob Dotfiles-Verzeichnis existiert
if [ ! -d "$DOTFILES_SOURCE" ]; then
	echo "❌ Dotfiles-Verzeichnis $DOTFILES_SOURCE nicht gefunden"
	echo "Bitte klone dein Dotfiles-Repository nach $DOTFILES_SOURCE"
	exit 1
fi

# Wechsle ins Dotfiles-Verzeichnis
echo "🔧 Symlinking Dotfiles mit Stow..."
cd "$DOTFILES_SOURCE"
stow -t "$HOME" zsh tmux nvim

echo "📦 Installiere Plugins und Abhängigkeiten..."
# LazyVim Plugins installieren
nvim --headless "+Lazy sync" +qa

echo "✅ Setup abgeschlossen!"
echo "🐚 Starte eine neue ZSH-Shell..."
exec zsh
