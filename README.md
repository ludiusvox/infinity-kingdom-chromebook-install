# Infinity Kingdom on ChromeOS (Crostini)

Automated setup script to install and run the Windows PC version of **Infinity Kingdom** (GTarcade Desktop client) inside ChromeOS Crostini (Debian Trixie `x86_64`), bypassing Android ARCVM scoped-storage crashes and memory limits.

## Key Fixes Included
- **OpenGL (`wined3d`) Backend:** Explicitly overrides `d3d9`, `d3d10core`, `d3d11`, and `dxgi` to Wine builtins (`=b`) to prevent DXVK `llvmpipe` `VK_ERROR_OUT_OF_HOST_MEMORY` swapchain crashes under Crostini VirtIO GPU.
- **CEF Launcher Stability:** Passes `--no-sandbox --disable-gpu --disable-software-rasterizer` to `Gtarcade.exe` so the embedded Chromium login screen renders cleanly and supports Google account sign-in.
- **Virtual Desktop & Pointer Alignment:** Wraps the client in `wine explorer /desktop=IK,$RES` dynamically matched via `xrandr`, and sets `Managed=N`, `Decorated=N`, and `GrabFullscreen=Y` in the Wine registry so mouse clicks register accurately.

## Usage
1. Download the Windows GTarcade installer (`InfinityKingdom-gtarcade-*.exe`) into your ChromeOS **Linux files** (`~`) directory.
2. Run `./install_ik.sh` (or `./install_ik.sh /path/to/installer.exe`).
3. Run `source ~/.bashrc && ik` to launch full screen.
