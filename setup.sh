#!/bin/bash
set -e # Beende das Skript bei Fehlern
sudo dnf install -y $(
  cat <<EOF
	git 
	curl 
	unzip 
	wget 
	ripgrep 
	fd-find 
  neovim 
	lua 
	make 
	gcc 
	zsh 
	tmux
EOF
)
HOME=/home/$USER
mkdir -p "$HOME/.config/zsh"
git clone https://github.com/sindresorhus/pure.git "$HOME/.config/zsh/pure"
git clone https://github.com/LazyVim/starter $HOME/.config/nvim

echo "🔧 Symlinking Dotfiles mit Stow..."
stow -t $HOME zsh tmux nvim # Passe das je nach Struktur an

echo "📦 Plugins und Abhängigkeiten installieren..."
# LazyVim Plugins installieren
nvim --headless "+Lazy sync" +qa

exec zsh

echo "✅ Setup abgeschlossen!"3. **Füge folgenden Inhalt hinzu:**

### **📌 Was macht das Skript?**
# - **Symlinkt Dotfiles** mit `stow`, sodass deine Konfiguration immer einheitlich ist
# - **Installiert LazyVim-Plugins**, damit deine Neovim-Umgebung sofort einsatzbereit ist
# - **Gibt Statusmeldungen aus**, damit du siehst, was passiert

# Sobald du dieses Skript in deinem Repo hast, wird es automatisch von Terraform auf deinem Server ausgeführt. Du kannst es auch manuell auf deinem Laptop oder Desktop ausführen. 🚀
