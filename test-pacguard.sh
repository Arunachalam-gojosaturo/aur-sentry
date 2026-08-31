#!/usr/bin/env bash
# ============================================================
#  PacGuard-AI Test Suite & Interactive Security Evaluator
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACGUARD="$SCRIPT_DIR/pacguard-ai"

chmod +x "$PACGUARD"

echo -e "\033[38;5;51m============================================================\033[0m"
echo -e "\033[38;5;220m     PacGuard-AI Security Agent & Visualizer Test Suite     \033[0m"
echo -e "\033[38;5;51m============================================================\033[0m"
echo

# Reset session so we see the full boot matrix for test 1
rm -f /tmp/.*pacguard*session* /dev/shm/.*pacguard*session* 2>/dev/null || true

echo -e "\033[1;38;5;51m[TEST 1/4] Scanning Safe Official Package: 'gum'\033[0m"
"$PACGUARD" "gum" --scan-only
echo

echo -e "\033[1;38;5;196m[TEST 2/4] Scanning Malicious Typosquatted Package: 'firefox-patch-bin'\033[0m"
set +e
"$PACGUARD" "firefox-patch-bin" --scan-only
set -e
echo

echo -e "\033[1;38;5;196m[TEST 3/4] Scanning Supply-Chain Campaign Vector: 'atomic-arch-helper'\033[0m"
set +e
"$PACGUARD" "atomic-arch-helper" --scan-only
set -e
echo

echo -e "\033[1;38;5;46m[TEST 4/4] End-to-End Test: Verified Security Clearance + Animated Downloader\033[0m"
TEST_URL="https://raw.githubusercontent.com/Arunachalam-gojosaturo/ArcXos/master/README.md"
TARGET="/tmp/pacguard_verified_download.tmp"
rm -f "$TARGET"
"$PACGUARD" "$TEST_URL" -o "$TARGET"
rm -f "$TARGET"

echo
echo -e "\033[38;5;220m[✓] All PacGuard-AI security checks and visualizer tests completed!\033[0m"
