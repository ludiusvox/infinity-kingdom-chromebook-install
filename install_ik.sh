#!/usr/bin/env bash
set -euo pipefail

# Infinity Kingdom (GTarcade PC Client) Automated Setup for ChromeOS Crostini (Debian Trixie x86_64)

INSTALLER_DEFAULT="$HOME/InfinityKingdom-gtarcade-6af653af7e22b.exe"
INSTALLER_PATH="${1:-$INSTALLER_DEFAULT}"
GTARCADE_EXE="$HOME/.wine/drive_c/users/$USER/AppData/Local/Gtarcade/app/Gtarcade.exe"

echo "=== [1/6] Verifying Container Architecture ==="
ARCH=$(dpkg --print-architecture)
if [[ "$ARCH" != "amd64" ]]; then
    echo "Error: Detected architecture '$ARCH'. This setup requires an x86_64 (amd64) Chromebook."
    exit 1
fi

echo "=== [2/6] Installing Wine (32/64-bit), Winbind & Mesa OpenGL Drivers ==="
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y wine wine32 wine64 winbind cabextract curl x11-xserver-utils mesa-vulkan-drivers libgl1-mesa-dri:i386

if [[ ! -x /usr/local/bin/winetricks ]]; then
    sudo curl -fsSL [https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks](https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks) -o /usr/local/bin/winetricks
    sudo chmod +x /usr/local/bin/winetricks
fi

echo "=== [3/6] Initializing 64-bit Wine Prefix & Core Fonts ==="
export WINEARCH=win64
export WINEDEBUG=-all
wineboot -u
winetricks -q corefonts

echo "=== [4/6] Configuring Wine Registry (OpenGL Renderer & Mouse/Window Rules) ==="
for dll in d3d9 d3d10core d3d11 dxgi; do
    wine reg delete "HKCU\Software\Wine\DllOverrides" /v "$dll" /f >/dev/null 2>&1 || true
done
wine reg add "HKCU\Software\Wine\X11 Driver" /v GrabFullscreen /t REG_SZ /d "Y" /f >/dev/null
wine reg add "HKCU\Software\Wine\X11 Driver" /v Managed /t REG_SZ /d "N" /f >/dev/null
wine reg add "HKCU\Software\Wine\X11 Driver" /v Decorated /t REG_SZ /d "N" /f >/dev/null

echo "=== [5/6] Running GTarcade / Infinity Kingdom Installer ==="
if [[ -f "$GTARCADE_EXE" ]]; then
    echo "Gtarcade.exe already exists at $GTARCADE_EXE - skipping installer."
else
    if [[ ! -f "$INSTALLER_PATH" ]]; then
        echo "Installer not found at: $INSTALLER_PATH"
        echo "Usage: ./install_ik.sh /path/to/InfinityKingdom-gtarcade-*.exe"
        exit 1
    fi
    WINEDLLOVERRIDES="*d3d9,*d3d10core,*d3d11,*dxgi=b" wine "$INSTALLER_PATH"
    wineserver -k || true
fi

echo "=== [6/6] Adding Full-Screen ik Alias to ~/.bashrc ==="
sed -i "/alias ik=/d" ~/.bashrc
echo 'alias ik="RES=\$(xrandr 2>/dev/null | grep \"\\*\" | awk \"{print \\\$1}\" | head -n 1); RES=\${RES:-1920x1080}; WINEDEBUG=-all WINEDLLOVERRIDES=\"*d3d9,*d3d10core,*d3d11,*dxgi=b\" wine explorer /desktop=IK,\$RES \"\$HOME/.wine/drive_c/users/\$USER/AppData/Local/Gtarcade/app/Gtarcade.exe\" --no-sandbox --disable-gpu --disable-software-rasterizer >/dev/null 2>&1 &"' >> ~/.bashrc
echo "Setup complete! Run: source ~/.bashrc && ik"
