#!/bin/bash

# Logging konfigurieren
exec > >(tee /var/log/user-data.log) 2>&1

echo "Starting setup: $(date)"

# Minimalpakete installieren
apt-get update && apt-get upgrade -y
apt-get install -y git curl zsh sudo locales

# Setze Locale-Einstellungen auf C.UTF-8
echo "🌐 Konfiguriere Locale-Einstellungen..."
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
locale-gen C.UTF-8
update-locale LANG=C.UTF-8 LC_ALL=C.UTF-8

# Docker-Gruppe erstellen falls nicht vorhanden
groupadd -f docker

# Benutzer erstellen (falls nicht durch cloud-init gemacht)
if ! id -u alex >/dev/null 2>&1; then
	useradd -m -s /bin/zsh -G sudo,docker alex
	echo 'alex ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/alex
	chmod 0440 /etc/sudoers.d/alex
fi

# SSH-Key einrichten
mkdir -p /home/alex/.ssh
echo '${var.ssh_key}' >>/home/alex/.ssh/authorized_keys
chmod 700 /home/alex/.ssh
chmod 600 /home/alex/.ssh/authorized_keys
chown -R alex:alex /home/alex/.ssh

# Dotfiles klonen und Setup vorbereiten
sudo -u alex mkdir -p /home/alex/.local/share
sudo -u alex git clone https://github.com/alexbenisch/dotfiles.git /home/alex/.local/share/dotfiles
chsh -s $(which zsh) alex

# .zshrc vorbereiten für sauberen Zsh-Start
sudo -u alex touch /home/alex/.zshrc
chown alex:alex /home/alex/.zshrc

EOF
