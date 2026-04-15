# Cloud Storage Strategy

## Overview

A three-tier storage architecture using rclone to consolidate data from multiple cloud providers into a self-hosted backup chain.

```
Google Drive  ──┐
Dropbox       ──┼──► Nextcloud (Backup 1) ──► Hetzner Storagebox (Backup 2)
Google Photos ──┘
```

- **Sources** (primary working storage): Google Drive, Dropbox, Google Photos
- **Backup 1 — Nextcloud**: self-hosted, first backup target, local/LAN accessible
- **Backup 2 — Hetzner Storagebox**: off-site 1TB HDD, second backup target, SFTP access

---

## Phase 1: Initial Migration (One-Time)

Move all existing data from Google Drive, Dropbox, and Google Photos into Nextcloud.

### 1.1 Configure rclone remotes

```bash
rclone config
```

Add the following remotes:

| Remote name      | Type         | Notes                                 |
|------------------|--------------|---------------------------------------|
| `gdrive`         | Google Drive | OAuth via browser                     |
| `dropbox`        | Dropbox      | OAuth via browser                     |
| `gphotos`        | Google Photos| OAuth via browser, read-only option   |
| `nextcloud`      | WebDAV       | URL: https://<your-nc>/remote.php/dav/files/<user>/ |
| `storagebox`     | SFTP         | Host: <user>.your-storagebox.de       |

### 1.2 Dry-run first (always)

```bash
rclone copy --dry-run --progress gdrive: nextcloud:GoogleDrive/
rclone copy --dry-run --progress dropbox: nextcloud:Dropbox/
rclone copy --dry-run --progress gphotos:media/by-year nextcloud:GooglePhotos/
```

### 1.3 Execute initial copy

```bash
# Google Drive → Nextcloud
rclone copy --progress --transfers 4 --checkers 8 \
  gdrive: nextcloud:GoogleDrive/

# Dropbox → Nextcloud
rclone copy --progress --transfers 4 --checkers 8 \
  dropbox: nextcloud:Dropbox/

# Google Photos → Nextcloud (media only, preserves year/month structure)
rclone copy --progress --transfers 4 --checkers 8 \
  gphotos:media/by-year nextcloud:GooglePhotos/
```

### 1.4 Initial Nextcloud → Storagebox copy

```bash
rclone copy --progress --transfers 4 storagebox: nextcloud:
```

> Note: This will take a long time for large datasets. Run inside a tmux session.

---

## Phase 2: Ongoing Sync (Automated, Hourly)

After migration, rclone checks each source hourly for new files and propagates them down the chain.

### Sync flow

```
Sources → Nextcloud  (rclone copy, one-way, new files only)
Nextcloud → Storagebox  (rclone sync, one-way mirror)
```

- `rclone copy` — copies new/updated files, never deletes
- `rclone sync` — makes destination mirror source, deletes orphans on destination

### Systemd timer (per machine)

See `~/.config/systemd/user/rclone-backup.service` and `rclone-backup.timer`.

---

## Phase 3: Verification

Run periodically to confirm backup integrity:

```bash
# Check that Nextcloud matches sources
rclone check gdrive: nextcloud:GoogleDrive/
rclone check dropbox: nextcloud:Dropbox/

# Check that Storagebox matches Nextcloud
rclone check nextcloud: storagebox: --size-only
```

---

## rclone Remote Configuration Details

### Nextcloud (WebDAV)

```
[nextcloud]
type = webdav
url = https://<your-nextcloud-domain>/remote.php/dav/files/<username>/
vendor = nextcloud
user = <username>
pass = <app-password>  # generate in Nextcloud Settings → Security
```

### Hetzner Storagebox (SFTP)

```
[storagebox]
type = sftp
host = <username>.your-storagebox.de
user = <username>
port = 23
key_file = ~/.ssh/id_storagebox
```

> Hetzner Storagebox uses port **23**, not 22.

### SSH key for Storagebox

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_storagebox -C "storagebox"
ssh-copy-id -i ~/.ssh/id_storagebox.pub -p 23 <user>@<user>.your-storagebox.de
```

---

## Systemd Units

### `~/.config/systemd/user/rclone-backup.service`

```ini
[Unit]
Description=rclone cloud backup sync
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/rclone copy --transfers 4 --checkers 8 --log-level INFO gdrive: nextcloud:GoogleDrive/
ExecStart=/usr/bin/rclone copy --transfers 4 --checkers 8 --log-level INFO dropbox: nextcloud:Dropbox/
ExecStart=/usr/bin/rclone copy --transfers 4 --checkers 8 --log-level INFO gphotos:media/by-year nextcloud:GooglePhotos/
ExecStart=/usr/bin/rclone sync --transfers 4 --checkers 8 --log-level INFO nextcloud: storagebox:
```

### `~/.config/systemd/user/rclone-backup.timer`

```ini
[Unit]
Description=Run rclone cloud backup hourly

[Timer]
OnBootSec=5min
OnUnitActiveSec=1h
Persistent=true

[Install]
WantedBy=timers.target
```

### Enable the timer

```bash
systemctl --user daemon-reload
systemctl --user enable --now rclone-backup.timer
systemctl --user list-timers rclone-backup.timer
```

### Check logs

```bash
journalctl --user -u rclone-backup.service -f
```

---

## Notes & Decisions

- **Google Photos**: rclone's `gphotos` backend is read-only by design (Google API limitation for uploads). Downloads preserve the year/month folder structure.
- **Dropbox conflict with system package**: The AUR `dropbox` package and Dropbox's self-updater (`~/.dropbox-dist`) can conflict after system updates. Always remove `~/.dropbox-dist` after a `yay -S dropbox` upgrade.
- **Storagebox port**: Hetzner Storagebox SFTP runs on port **23**, not the standard 22.
- **App passwords**: Use Nextcloud app-specific passwords (not your main password) for rclone — revokable per-device.
- **Bandwidth**: `--transfers 4 --checkers 8` is conservative. On fast connections increase to `--transfers 8 --checkers 16`.
- **Multi-machine**: Each machine (laptop, desktop) runs its own systemd timer. The Storagebox sync step is idempotent — running it from multiple machines is safe since `rclone sync` is deterministic.
