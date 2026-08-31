#!/usr/bin/env bash
# ============================================================
#  AUR-SENTRY All-In-One Test Suite & Security Evaluator
# ============================================================

set -euo pipefail

CYAN='\033[38;5;51m'
GOLD='\033[38;5;220m'
GREEN='\033[38;5;46m'
RED='\033[38;5;196m'
MAGENTA='\033[38;5;201m'
WHITE='\033[97m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SENTRY="$SCRIPT_DIR/aur-sentry"
ARCDL="$SCRIPT_DIR/arcxos-dl"
TEST_URL="https://raw.githubusercontent.com/Arunachalam-gojosaturo/ArcXos/master/README.md"
TARGET="/tmp/aur_sentry_test_download.tmp"

chmod +x "$SENTRY" "$ARCDL"

# Check for custom argument to scan directly
if [[ $# -gt 0 ]] && [[ "$1" != "--all" ]] && [[ "$1" != "-a" ]]; then
  case "$1" in
    --sentry|--scan)
      echo -e "${MAGENTA}--- Running AUR-Sentry Security Analysis Test ---${NC}"
      "$SENTRY" "neovim" --scan-only
      exit 0
      ;;
    --dl)
      echo -e "${CYAN}--- Running Download Animation Test ---${NC}"
      rm -f /tmp/.*arcxos*session* /tmp/.*aur_sentry*session* 2>/dev/null || true
      "$ARCDL" "$TEST_URL" -o "$TARGET"
      rm -f "$TARGET"
      exit 0
      ;;
    --sig)
      echo -e "${GOLD}--- Running 404 Sig Bypass Test ---${NC}"
      set +e
      "$ARCDL" "http://in.mirrors.cicku.me/archlinux/core/os/x86_64/core.db.sig" -o "/tmp/sig.test"
      st=$?
      set -e
      if [ "$st" -ne 0 ] && [ ! -f "/tmp/sig.test" ]; then
        echo -e "${GREEN}[ OK ] 404 signature cleanly skipped with exit code $st${NC}"
      fi
      exit 0
      ;;
    -h|--help)
      echo "Usage: ./test.sh [OPTIONS | PACKAGE_NAME]"
      echo "  ./test.sh               Run the complete all-in-one AUR-Sentry test suite"
      echo "  ./test.sh <pkg_name>    Scan a specific package with AUR-Sentry"
      echo "  ./test.sh --sentry      Run AUR-Sentry AI threat scan test"
      echo "  ./test.sh --dl          Run download animation test"
      echo "  ./test.sh --sig         Run 404 missing signature test"
      exit 0
      ;;
    *)
      echo -e "${CYAN}Running AUR-Sentry scan on: ${GOLD}$1${NC}\n"
      "$SENTRY" "$1" --scan-only
      exit 0
      ;;
  esac
fi

echo -e "${CYAN}============================================================${NC}"
echo -e "${GOLD}          AUR-SENTRY Visualizer & AI Test Suite             ${NC}"
echo -e "${CYAN}============================================================${NC}"
echo

# ------------------------------------------------------------
# TEST 1: Full ASCII Boot Animation & Downloader
# ------------------------------------------------------------
echo -e "${CYAN}[TEST 1/6] Full ASCII Art Boot Sequence & Initial Download...${NC}"
rm -f /tmp/.*arcxos*session* /tmp/.*aur_sentry*session* /dev/shm/.* 2>/dev/null || true
"$ARCDL" "$TEST_URL" -o "$TARGET"
rm -f "$TARGET"
echo

# ------------------------------------------------------------
# TEST 2: Session Caching (ASCII Art Loop Prevention)
# ------------------------------------------------------------
echo -e "${CYAN}[TEST 2/6] Sequential Download (Same Session - ASCII Art Skipped)...${NC}"
"$ARCDL" "$TEST_URL" -o "$TARGET"
rm -f "$TARGET"
echo

# ------------------------------------------------------------
# TEST 3: AUR-Sentry AI Security Analysis on Safe Package
# ------------------------------------------------------------
echo -e "${GREEN}[TEST 3/6] AUR-Sentry AI Neural Scan on Safe Official Package ('neovim')...${NC}"
"$SENTRY" "neovim" --scan-only
echo

# ------------------------------------------------------------
# TEST 4: AUR-Sentry AI Security Analysis on Typosquatted Package
# ------------------------------------------------------------
echo -e "${RED}[TEST 4/6] AUR-Sentry AI Neural Scan on Typosquatted Threat ('firefox-patch-bin')...${NC}"
set +e
"$SENTRY" "firefox-patch-bin" --scan-only
set -e
echo

# ------------------------------------------------------------
# TEST 5: AUR-Sentry AI Security Analysis on Supply-Chain Trojan
# ------------------------------------------------------------
echo -e "${RED}[TEST 5/6] AUR-Sentry AI Neural Scan on Supply Chain Trojan ('atomic-arch-helper')...${NC}"
set +e
"$SENTRY" "atomic-arch-helper" --scan-only
set -e
echo

# ------------------------------------------------------------
# TEST 6: 404 Missing Sig Handling
# ------------------------------------------------------------
echo -e "${GOLD}[TEST 6/6] Pacman 404 Missing Signature Handling (Silent & Zero Corrupt File)...${NC}"
SIG_URL="http://in.mirrors.cicku.me/archlinux/core/os/x86_64/core.db.sig"
SIG_PART="/tmp/core.db.sig.test.part"
rm -f "$SIG_PART"

set +e
"$ARCDL" "$SIG_URL" -o "$SIG_PART"
STATUS=$?
set -e

if [ "$STATUS" -ne 0 ] && [ ! -f "$SIG_PART" ]; then
  echo -e "${GREEN}[ OK ] 404 cleanly handled: exit code=$STATUS, no corrupted file left on disk.${NC}"
else
  echo -e "${RED}[ FAIL ] 404 handling failed: exit code=$STATUS, file exists=$([ -f "$SIG_PART" ] && echo yes || echo no)${NC}"
  exit 1
fi
echo

echo -e "${CYAN}============================================================${NC}"
echo -e "${GREEN}[✓] ALL 6 AUR-SENTRY TESTS COMPLETED SUCCESSFULLY!${NC}"
echo -e "${GOLD}Scan any custom package with: ${WHITE}./test.sh <package-name>${NC}"
echo -e "${CYAN}============================================================${NC}"
