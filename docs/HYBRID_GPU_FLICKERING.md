# Hybrid GPU Flickering (Hyprland + Chrome)

Fix for screen flickering/freezing in Chrome (and Electron apps) on the Intel + NVIDIA laptop running Omarchy/Hyprland, especially while video is playing and a window is moved.

## System

| Component | Value |
|-----------|-------|
| iGPU | Intel Raptor Lake-P Iris Xe (`i915`) — `card2` / `renderD129` |
| dGPU | NVIDIA RTX A500 Laptop (`nvidia-open-dkms` 610.57.04) — `card1` / `renderD128` |
| Displays | `eDP-1` 1920x1200 and `DP-3` 3840x2160 — **both wired to the Intel iGPU** |
| Hyprland | 0.56.2 |

Check which GPU drives each output:

```bash
for c in /sys/class/drm/card*-*; do echo "$(basename $c): $(cat $c/status)"; done
```

## Root Cause

- Hyprland (Aquamarine) correctly selects the Intel GPU as primary: `gpu /dev/dri/card2 becomes primary drm`.
- Omarchy's `/usr/share/omarchy/default/hypr/nvidia.lua` detects the NVIDIA card and sets session-wide:
  ```
  LIBVA_DRIVER_NAME=nvidia
  __GLX_VENDOR_LIBRARY_NAME=nvidia
  NVD_BACKEND=direct
  ```
- Chrome's GPU process renders on Intel (`--render-node-override=/dev/dri/renderD129`) but loads `nvidia_drv_video.so` for VA-API. Video is decoded on NVIDIA and every frame is shipped as a dmabuf across GPUs to the Intel compositor/scanout → flicker, freezes, transparent windows.

Diagnose it on a running system:

```bash
# Does Chrome's GPU process load the NVIDIA VA-API driver? (should print 0 after the fix)
pgrep -f type=gpu-process | xargs -I{} grep -c nvidia_drv_video /proc/{}/maps

# Session env seen by apps
systemctl --user show-environment | grep -E 'LIBVA|GLX|NVD'
```

## Upstream References

- [hyprwm/Hyprland#16228](https://github.com/hyprwm/Hyprland/issues/16228) — *Screen freezes/flickers/goes transparent when moving a window playing video, on hybrid Intel+NVIDIA laptops*. Same Hyprland version and GPU layout. Auto-closed by the bot (Hyprland only accepts Discussions now), no upstream fix. The reporter noted that mismatched GPU vendor env vars made it worse.
- [hyprwm/Hyprland discussion #11141](https://github.com/hyprwm/Hyprland/discussions/11141) — multi-GPU flicker when the monitor is on the non-primary dGPU (different topology).
- [#7252](https://github.com/hyprwm/Hyprland/issues/7252), [#6701](https://github.com/hyprwm/Hyprland/issues/6701) — older NVIDIA-only Chromium/Electron flicker.

Note: use `gh issue list -R hyprwm/Hyprland --state all --search "..."` — `gh search issues` returned nothing for this repo.

## Fix

Appended to `~/.config/hypr/hyprland.lua` (loaded after Omarchy's defaults, so it overrides them; never edit `/usr/share/omarchy/`):

```lua
-- Hybrid Intel + NVIDIA laptop: every display is wired to the Intel iGPU, so
-- keep apps' GL and VA-API on Intel too. Omarchy's NVIDIA defaults point them at
-- the dGPU, which makes Chrome decode video on NVIDIA and hand the frames across
-- GPUs to the Intel compositor, and that flickers (hyprwm/Hyprland#16228).
-- Run a single app on the dGPU with:
--   __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only <app>
hl.env("LIBVA_DRIVER_NAME", "iHD")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "mesa")
hl.env("NVD_BACKEND", "")
```

Then validate and **log out / back in** (env changes only reach the systemd user environment and new apps at login):

```bash
hyprctl reload && hyprctl configerrors
```

Side benefit: the dGPU can stay runtime-suspended more often → better battery life.

## Running an App on the NVIDIA GPU

```bash
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only <app>
```

## Verify

1. Log out and back in.
2. Play a YouTube video in Chrome and drag the window around both monitors.
3. `pgrep -f type=gpu-process | xargs -I{} grep -c nvidia_drv_video /proc/{}/maps` → `0`.

## If Flicker Remains

- Add `--disable-features=Vulkan` to `~/.config/chrome-flags.conf` (and `chromium-flags.conf`).
- Install `libva-utils` and check `LIBVA_DRIVER_NAME=iHD vainfo` for working Intel decode.
- Revert: restore `~/.config/hypr/hyprland.lua.bak.<timestamp>` or delete the three `hl.env` lines.
