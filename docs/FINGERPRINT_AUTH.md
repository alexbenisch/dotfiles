---
title: "Fingerprint Authentication — ThinkPad T14 Gen 3"
author: "Alex Benisch"
date: 2026-09-13
geometry: "margin=1.5cm"
papersize: a4
---

# Hardware

| | |
|---|---|
| Laptop | ThinkPad T14 Gen 3 (`21AHCTO1WW`) |
| Reader | Goodix `27c6:6594` |
| Driver | Goodix MOC (match-on-chip), in libfprint since 1.94.9 |
| Arch ships | libfprint 1.94.100 |

Confirmed present in the [libfprint supported device
list](https://fprint.freedesktop.org/supported-devices.html) under the Goodix
MOC driver. Note `lsusb` returns nothing on this machine — `usbutils` is not
installed. Enumerate from sysfs instead:

```bash
for d in /sys/bus/usb/devices/*/; do
  [ -f "$d/idVendor" ] || continue
  printf "%s:%s  %s %s\n" "$(cat $d/idVendor)" "$(cat $d/idProduct)" \
    "$(cat $d/manufacturer 2>/dev/null)" "$(cat $d/product 2>/dev/null)"
done | sort -u
```

# Local setup

GNOME already ships the PAM plumbing — `/etc/pam.d/gdm-fingerprint` contains
`pam_fprintd.so` out of the box. The only missing piece is the daemon.

```bash
sudo pacman -S fprintd      # pulls in libfprint
```

No service to enable; `fprintd` is D-Bus activated on demand.

## Enrolment

GUI (preferred — GNOME wires up PAM itself, no file editing needed for login
or lock screen):

> Settings → System → Users → Fingerprint Login

CLI equivalent:

```bash
fprintd-enroll -f right-index-finger
fprintd-verify
```

Templates are stored **on the sensor chip**, not as files on disk. Log out and
back in after enrolling — GDM reads fingerprint availability at session start.

## sudo

GNOME covers login and unlock only. For `sudo`, add this as the **first**
`auth` line in `/etc/pam.d/sudo`, above the `include`:

```
auth		sufficient	pam_fprintd.so
```

`sufficient` means success is enough, but failure falls through to the
password — a bad read never locks you out.

> **Before editing, open a second terminal and run `sudo -i` to hold a live
> root shell.** If the edit is wrong, every `sudo` in a fresh shell fails, and
> that root shell is the way back in. Close it only after confirming `sudo`
> works in a new terminal.

## Caveats

- **gnome-keyring will not auto-unlock** on a fingerprint login. The keyring is
  encrypted with the account password and a fingerprint cannot derive it, so a
  keyring prompt after login is expected, not a misconfiguration.
- **SDDM is installed but unused** — GDM is the running display manager.
  Editing `/etc/pam.d/sddm` has no effect.

# Remote sudo over SSH

**Fingerprint authentication cannot be forwarded over SSH.** This is a design
limit, not a missing feature.

`pam_fprintd` talks to `fprintd` over D-Bus on the same machine, and `fprintd`
needs the USB device. Even forwarding the D-Bus socket (`ssh -R`) only gets the
remote a **single boolean** — "did it match?" — that is bound to nothing: not
the session, not the command, not a nonce. Anything able to observe or replay
it could authorise itself.

| | fingerprint via fprintd | SSH agent |
|---|---|---|
| What crosses the wire | "yes, it matched" | signature over a session-specific challenge |
| Replayable | yes | no |
| Secret leaves client | n/a | never |

The Goodix reader is match-on-chip, so its only output is match/no-match. It
holds no signing key and is not a FIDO2 authenticator — there is nothing
cryptographic to relay even in principle.

## Working alternative: `pam_ssh_agent_auth`

The agent signs a challenge issued by the remote PAM stack.

```bash
yay -S pam_ssh_agent_auth      # AUR; not in the official repos
```

On the **remote**, in `/etc/pam.d/sudo`, above the `include`:

```
auth  sufficient  pam_ssh_agent_auth.so file=/etc/security/authorized_keys
```

In `sudoers` (via `visudo`):

```
Defaults env_keep += "SSH_AUTH_SOCK"
```

Connect with `ssh -A`.

> Point `file=` at a **root-owned** path, never `~/.ssh/authorized_keys`. If a
> user can edit the file listing who may sudo, they can grant themselves root
> by appending a key.

## Genuine biometric remote sudo

This requires an authenticator that can *sign* — a FIDO2 token with a sensor
(e.g. YubiKey Bio). `libfido2` is already installed, so OpenSSH is ready:

```bash
ssh-keygen -t ed25519-sk -O resident -O verify-required
```

`verify-required` forces biometric verification for every signature. Combined
with `pam_ssh_agent_auth`, remote sudo then requires a fingerprint touch on the
token. The laptop's built-in reader cannot substitute; there is no supported
path to bind a Goodix MOC sensor to a signing key on Linux.

## Agent-forwarding risk

While connected with `-A`, root on the remote can use the forwarded agent
socket to authenticate as you anywhere your keys are accepted. Forward
selectively per-host in `~/.ssh/config` rather than globally, and consider
`ssh-add -c` so each use prompts locally for confirmation.

# References

- <https://fprint.freedesktop.org/supported-devices.html>
- <https://github.com/jbeverly/pam_ssh_agent_auth>
- <https://jpmens.net/2021/11/21/pam-ssh-agent-authentication-with-ansible/>
