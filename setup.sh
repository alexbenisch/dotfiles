#!/bin/bash
set -e # Beende das Skript bei Fehlern

echo "🔧 Symlinking Dotfiles mit Stow..."
stow -t $HOME zsh tmux nvim # Passe das je nach Struktur an

echo "📦 Plugins und Abhängigkeiten installieren..."
# LazyVim Plugins installieren
nvim --headless "+Lazy sync" +qa

echo "✅ Setup abgeschlossen!"3. **Füge folgenden Inhalt hinzu:**

### **📌 Was macht das Skript?**
# - **Symlinkt Dotfiles** mit `stow`, sodass deine Konfiguration immer einheitlich ist
# - **Installiert LazyVim-Plugins**, damit deine Neovim-Umgebung sofort einsatzbereit ist
# - **Gibt Statusmeldungen aus**, damit du siehst, was passiert

# Sobald du dieses Skript in deinem Repo hast, wird es automatisch von Terraform auf deinem Server ausgeführt. Du kannst es auch manuell auf deinem Laptop oder Desktop ausführen. 🚀
