#!/usr/bin/env bash
# ============================================================
# AUR-SENTRY Animated Pacman Customization Installer
# ============================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
GOLD='\033[38;5;220m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${GOLD}     AUR-SENTRY AI Security Agent & Theme Installer         ${NC}"
echo -e "${CYAN}============================================================${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] Please run this script with sudo:${NC}"
    echo "  sudo $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install.sh"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Install visualizer and security binaries to /usr/local/bin
echo -e "${CYAN}[1/5] Installing aur-sentry binaries to /usr/local/bin...${NC}"
cp -f "$SCRIPT_DIR/aur-sentry" /usr/local/bin/aur-sentry
cp -f "$SCRIPT_DIR/arcxos-dl" /usr/local/bin/arcxos-dl
cp -f "$SCRIPT_DIR/arcxos-hyper-dl" /usr/local/bin/arcxos-hyper-dl 2>/dev/null || true
cp -f "$SCRIPT_DIR/hyperdl.sh" /usr/local/bin/hyperdl.sh 2>/dev/null || true
chmod 755 /usr/local/bin/aur-sentry /usr/local/bin/arcxos-dl /usr/local/bin/arcxos-hyper-dl /usr/local/bin/hyperdl.sh 2>/dev/null || true
echo -e "${GREEN}[ OK ] Installed /usr/local/bin/aur-sentry and visualizer utilities${NC}"

# 2. Backup existing /etc/pacman.conf
BACKUP_PATH="/etc/pacman.conf.bak.$(date +%s)"
echo -e "${CYAN}[2/5] Backing up /etc/pacman.conf -> ${BACKUP_PATH}...${NC}"
cp -f /etc/pacman.conf "$BACKUP_PATH"
echo -e "${GREEN}[ OK ] Backup created successfully.${NC}"

# 3. Configure /etc/pacman.conf
echo -e "${CYAN}[3/5] Updating /etc/pacman.conf with ILoveCandy & XferCommand...${NC}"

# Ensure Color is enabled
if grep -q "^#Color" /etc/pacman.conf; then
    sed -i 's/^#Color/Color/' /etc/pacman.conf
elif ! grep -q "^Color" /etc/pacman.conf; then
    sed -i '/^\[options\]/a Color' /etc/pacman.conf
fi

# Ensure ILoveCandy is present under [options]
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
    sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
fi

# Configure XferCommand to use arcxos-dl / aur-sentry
if grep -q "^XferCommand" /etc/pacman.conf; then
    sed -i 's|^XferCommand.*|XferCommand = /usr/local/bin/arcxos-dl %u -o %o|' /etc/pacman.conf
else
    sed -i '/^\[options\]/a XferCommand = /usr/local/bin/arcxos-dl %u -o %o' /etc/pacman.conf
fi

# Ensure ParallelDownloads is disabled/commented out for single interactive download visualizer
if grep -q "^ParallelDownloads" /etc/pacman.conf; then
    sed -i 's/^ParallelDownloads.*/#ParallelDownloads = 5/' /etc/pacman.conf
fi

echo -e "${GREEN}[ OK ] /etc/pacman.conf customized (sequential downloads active).${NC}"

# 4. Clean up any stale or corrupted signature files from previous failed runs
echo -e "${CYAN}[4/5] Cleaning up corrupted signature caches and session locks...${NC}"
rm -f /var/lib/pacman/sync/*.sig 2>/dev/null || true
rm -f /tmp/.*sentry*session* /tmp/.*arcxos*session* /tmp/.*hyperdl*session* /dev/shm/.* 2>/dev/null || true
echo -e "${GREEN}[ OK ] Signature cache and session reset.${NC}"

# 5. Verification
echo -e "${CYAN}[5/5] Installation complete!${NC}"
echo -e "${GOLD}AUR-Sentry and animated Pacman tools are now active!${NC}"
echo -e "Try running: ${CYAN}sudo pacman -Syu${NC} or ${CYAN}aur-sentry <pkg>${NC}"
