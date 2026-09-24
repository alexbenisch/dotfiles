# Omarchy Clipboard Manager on Caps Lock

How the Omarchy clipboard manager works, and how Caps Lock (disabled as a modifier) is bound to open it.

## Omarchy's Clipboard Manager

Omarchy does not ship a third-party clipboard manager (no cliphist, clipse or CopyQ). Clipboard history is built into the Omarchy shell (Quickshell) as the **`omarchy.clipboard`** plugin.

| Part | Location / Detail |
|------|-------------------|
| Plugin | `/usr/share/omarchy/shell/plugins/clipboard/` (`Clipboard.qml`, `ClipboardHistory.js`, `capture.sh`, `manifest.json`) |
| Capture | Two `wl-paste --watch` processes (text and `image/png`) pipe each copy into `capture.sh` |
| Images | Stored deduplicated by SHA-256 in `~/.local/state/omarchy/clipboard-images/` |
| Sensitive data | Skipped when `CLIPBOARD_STATE=sensitive` or the `x-kde-passwordManagerHint` mime type is set (password managers) |
| Backend | `wl-clipboard` |

### Default Keybindings

From `/usr/share/omarchy/default/hypr/bindings/clipboard.lua`:

| Keys | Action |
|------|--------|
| `SUPER + C` | Universal copy (sends `Ctrl+Insert` in terminals) |
| `SUPER + V` | Universal paste (sends `Shift+Insert` in terminals) |
| `SUPER + CTRL + V` | Clipboard manager (`omarchy-shell shell toggle omarchy.clipboard`) |

### Related Commands

```bash
omarchy-menu-clipboard          # Toggle the clipboard manager (= omarchy menu clipboard)
omarchy-clipboard-open
omarchy-clipboard-paste-text
omarchy-clipboard-paste-file
```

## Caps Lock → Clipboard Manager

### Starting Point

Caps Lock is disabled in `~/.config/hypr/input.lua`:

```lua
hl.config({
  input = {
    kb_layout = "us,de",
    kb_options = "caps:none",
  },
})
```

(Omarchy's default is `compose:caps,shift:both_capslock_cancel`, i.e. Caps Lock is the Compose key.)

With `caps:none` the key produces no keysym (`VoidSymbol`), so it cannot be bound by name. The kernel still delivers the physical keycode, so it can be bound by **keycode 66**.

### Binding

Appended to `~/.config/hypr/bindings.lua`:

```lua
-- Caps Lock (disabled via kb_options = "caps:none" in input.lua) opens the
-- clipboard manager. Bound by keycode since the key produces no keysym.
o.bind("code:66", "Clipboard manager", "omarchy-menu-clipboard")
```

- `o.bind` is Omarchy's helper (`/usr/share/omarchy/default/hypr/helpers.lua`); it wraps `hl.bind` and turns a string into `exec_cmd`.
- `code:N` syntax is also used by Omarchy's own defaults (e.g. `SUPER + SHIFT + code:201`).
- `SUPER + CTRL + V` keeps working as well.

### Apply and Verify

```bash
hyprctl reload && hyprctl configerrors      # should print "ok"
hyprctl binds | grep -B6 -A3 'description: Clipboard manager'
```

Expected entry:

```
bindd
	modmask: 0
	key: code:66
	description: Clipboard manager
```

Then press Caps Lock — the clipboard manager should toggle.

### Finding a Keycode

If a different key is wanted, find its keycode with:

```bash
wev          # press the key, read "key: <n>" and add 8 → XKB keycode
# or
xev          # under XWayland, prints "keycode <n>" directly
```

Caps Lock is evdev `58` → XKB `66`.

### Revert

Delete the `o.bind("code:66", ...)` lines from `~/.config/hypr/bindings.lua` (a backup exists as `bindings.lua.bak.<timestamp>`) and run `hyprctl reload`.
