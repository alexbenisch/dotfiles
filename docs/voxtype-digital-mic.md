# Voxtype with the Built-in Digital Microphone

Voxtype (push-to-talk dictation on Omarchy) is configured to record from the ThinkPad's built-in digital microphone array instead of the system default mic.

## System

| Component | Value |
|-----------|-------|
| Laptop | Lenovo ThinkPad P14s Gen 4 (21HF000SGE) |
| Audio | Intel Raptor Lake cAVS / SOF (`sof-hda-dsp`, card 1), codec Realtek ALC257 |
| Voxtype | `voxtype-bin` 1.0.1, runs as `voxtype.service` (systemd user unit) |
| Default source | JBL Quantum 360P Console (USB headset) |

## Available Microphones

```bash
wpctl status              # Audio → Sources
pactl list sources short  # node names
```

| wpctl name | PipeWire node name | What it is |
|------------|--------------------|------------|
| JBL Quantum 360P Console Mono | `alsa_input.usb-JBL_JBL_Quantum_360P_Console-00.mono-fallback` | USB headset (system default) |
| Raptor Lake-P/U/H cAVS **Digital Microphone** | `alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source` | Built-in DMIC array |
| Raptor Lake-P/U/H cAVS Stereo Microphone | `alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic2__source` | 3.5 mm combo jack |

Note: on this machine **Mic1 = digital mic**, **Mic2 = headphone jack**.

## Configuration

**Voxtype takes ALSA device names, not PipeWire node names** — despite the comment in its config pointing at `pactl list sources short`. Setting `device` to the PipeWire node name fails on every recording:

```
ERROR Failed to start audio: Audio device not found: 'alsa_input...HiFi__Mic1__source'.
Available devices: sysdefault, pipewire, default, sysdefault:CARD=Console, sysdefault:CARD=sofhdadsp
```

So a named ALSA device routes to the PipeWire node. `~/.asoundrc`:

```
# Named ALSA capture device for the built-in digital microphone, routed through
# PipeWire. Used by voxtype, which takes ALSA device names, not PipeWire nodes.
pcm.dmic {
    type pipewire
    capture_node "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source"
    hint {
        show on
        description "Built-in Digital Microphone (PipeWire)"
    }
}
```

`~/.config/voxtype/config.toml`:

```toml
[audio]
device = "dmic"
```

Apply and verify:

```bash
arecord -L | grep -A1 '^dmic'            # device is listed
systemctl --user restart voxtype
voxtype record start; sleep 2; voxtype record stop
journalctl --user -u voxtype --since -30s -o cat | grep -E 'ERROR|Recording'
# expect "Recording started" / "Recording stopped (2.0s)" and no audio error
```

While recording, `pactl list source-outputs | grep Source:` should show the Mic1 source index (`pactl list sources short`).

Using a dedicated device (instead of `wpctl set-default`) keeps the JBL headset as the default for calls and every other app, and doesn't get overridden when the headset is replugged.

## Usage

Keybindings from `/usr/share/omarchy/default/hypr/bindings/voxtype.lua`:

| Keys | Action |
|------|--------|
| `F9` (hold) | Push-to-talk: record while held, transcribe on release |
| `SUPER + CTRL + X` | Toggle dictation |

## Testing a Microphone

Record 3 seconds and measure the level:

```bash
timeout 3 pw-record --target <node-name> --rate 16000 --channels 1 test.wav
python3 - <<'EOF'
import wave, array, math
w = wave.open("test.wav"); d = array.array('h', w.readframes(w.getnframes()))
m = max(abs(x) for x in d); rms = math.sqrt(sum(x*x for x in d) / len(d))
print(f"peak={20*math.log10(max(m,1)/32768):.1f}dBFS rms={20*math.log10(max(rms,1)/32768):.1f}dBFS")
EOF
```

Results measured on 2026-09-24:

| Source | Peak | RMS | Verdict |
|--------|------|-----|---------|
| Digital mic (Mic1) | −7.8 dBFS | −20.8 dBFS | Works well |
| Jack (Mic2), as detected | −90.3 dBFS | −90.3 dBFS | Silence |
| Jack (Mic2), capture forced on + boost | −42.1 dBFS | −58.2 dBFS | Only noise/very faint |

## Why the Jack Mic Doesn't Work

The external mic has a **3-pole TRS plug (two rings)**. The P14s has a 4-pole **TRRS combo jack** (CTIA headset standard) that only detects a mic on a 4-pole plug. With a TRS plug the mic contact lands on ground, so the jack reports headphones only:

```bash
amixer -c1 contents | grep -A2 -E "Headphone Jack|Mic Jack"
# Headphone Jack: on
# Mic Jack: off        ← no microphone detected
```

PipeWire then marks the Mic2 port `not available` and ALSA `Capture Switch` stays `off`.

Options if the jack mic is needed later:

1. **TRRS headset splitter** (CTIA, ~€5): 4-pole male plug → separate pink mic / green headphone sockets. Plug the mic into pink; `Mic Jack` should turn `on`, then use the `...HiFi__Mic2__source` node.
2. **USB audio adapter or USB mic**: avoids the combo jack entirely and is usually cleaner.

## Known Harmless Log Error

```
ERROR Hotkey listener error: No keyboard device found in /dev/input/
```

This comes from voxtype's built-in evdev hotkey listener (`key = "PAUSE"` in `config.toml`), which needs the user in the `input` group. It predates this change and doesn't matter: Omarchy's Hyprland keybindings drive recording via `voxtype record start|stop|toggle`. To silence it, set `enabled = false` in the hotkey section of `config.toml`.

## Revert

Restore `~/.config/voxtype/config.toml.bak.<timestamp>` (or set `device = "default"`), optionally delete `~/.asoundrc`, and run `systemctl --user restart voxtype`.

## Foot Pedal (voxtype-pedal.service)

A Grundig Digta Foot Control 540 USB (`15d8:0024`) drives voxtype through `~/.local/bin/voxtype-pedal` (systemd user unit `voxtype-pedal.service`). The pedal is a vendor HID device with no evdev node; a udev rule (`/etc/udev/rules.d/`) grants `uaccess` and creates `/dev/grundig-pedal → hidrawN`.

| Byte 0 bit | Action |
|------------|--------|
| `0x02` | `record start` on press, `record stop` on release (push-to-talk) |
| `0x01` | `record cancel` |
| `0x04` | `record toggle` (hands-free) |

Test layer by layer:

```bash
systemctl --user status voxtype-pedal     # "reading /dev/grundig-pedal"
# raw reports (works alongside the service; hidraw fans out to all readers)
python3 -c 'import os; fd=os.open("/dev/grundig-pedal", os.O_RDONLY)
while True: r=os.read(fd,64); print(r.hex())'
voxtype status --follow                   # watch state while pressing pedals
journalctl --user -u voxtype -f           # "Recording started (external trigger)"
```

The pedal does not answer HID GET_REPORT/GET_FEATURE (`Broken pipe`) — that's normal, only the interrupt input reports matter. The bridge ignores `voxtype` exit codes, so audio errors only show up in the `voxtype` journal, not the pedal's.
