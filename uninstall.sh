#!/usr/bin/env bash
# ============================================================
# AUR-SENTRY Customization Uninstaller / Restorer
# ============================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] Please run this script with sudo:${NC}"
    echo "  sudo $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/uninstall.sh"
    exit 1
fi

echo -e "${CYAN}Restoring default pacman configuration...${NC}"

# Remove custom XferCommand and ILoveCandy if present
sed -i '\|/usr/local/bin/aur-sentry|d' /etc/pacman.conf
sed -i '\|/usr/local/bin/arcxos-dl|d' /etc/pacman.conf
sed -i '\|/usr/local/bin/hyperdl|d' /etc/pacman.conf
sed -i '/^ILoveCandy/d' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

# Remove installed binaries
rm -f /usr/local/bin/aur-sentry /usr/local/bin/arcxos-dl /usr/local/bin/arcxos-hyper-dl /usr/local/bin/hyperdl.sh
rm -f /var/lib/pacman/sync/*.sig 2>/dev/null || true
rm -f /tmp/.*sentry*session* /tmp/.*arcxos*session* /tmp/.*hyperdl*session* /dev/shm/.* 2>/dev/null || true

echo -e "${GREEN}[ OK ] Restored default pacman settings and cleaned up binaries.${NC}"
