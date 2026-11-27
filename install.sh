#!/usr/bin/env bash
# =====================================================================
#  THEAM-X installer  |  VPS + Termux
#  https://github.com/Its2Pawan/Theam-x
#  Copyright (c) 2026 Its2Pawan. All Rights Reserved.
#
#  Install :  curl -fsSL https://raw.githubusercontent.com/Its2Pawan/Theam-x/main/install.sh | bash
#  Remove  :  bash install.sh uninstall
#
#  Installs into  ~/.sino   (VPS: /root/.sino  |  Termux: ~/.sino)
# =====================================================================

REPO="Its2Pawan/Theam-x"
BRANCH="${TX_BRANCH:-main}"
RAW_BASE="${TX_RAW_BASE:-https://raw.githubusercontent.com}"
DEST="${TX_HOME:-$HOME/.sino}"
RC="$HOME/.bashrc"

G=$'\e[1;92m'; R=$'\e[1;91m'; Y=$'\e[1;93m'; D=$'\e[0;32m'; X=$'\e[0m'
say()  { printf '%s\n' "${G}[+]${X} $*"; }
warn() { printf '%s\n' "${Y}[!]${X} $*"; }
die()  { printf '%s\n' "${R}[x]${X} $*"; exit 1; }

if [[ -n "${TERMUX_VERSION:-}" || "${PREFIX:-}" == *com.termux* ]]; then DEVICE=termux; else DEVICE=vps; fi

fetch() { # url
  if command -v curl >/dev/null 2>&1; then curl -fsSL --max-time 20 "$1"
  elif command -v wget >/dev/null 2>&1; then wget -qO- -T 20 "$1"
  else return 127; fi
}

need_downloader() {
  command -v curl >/dev/null 2>&1 && return 0
  command -v wget >/dev/null 2>&1 && return 0
  warn "curl/wget not found - installing curl"
  local SUDO=""
  if [[ $DEVICE != termux && $EUID -ne 0 ]] && command -v sudo >/dev/null 2>&1; then SUDO=sudo; fi
  if   [[ $DEVICE == termux ]];            then pkg install -y curl
  elif command -v apt-get >/dev/null 2>&1; then $SUDO apt-get update -y && $SUDO apt-get install -y curl
  elif command -v dnf     >/dev/null 2>&1; then $SUDO dnf install -y curl
  elif command -v yum     >/dev/null 2>&1; then $SUDO yum install -y curl
  elif command -v apk     >/dev/null 2>&1; then $SUDO apk add curl
  elif command -v pacman  >/dev/null 2>&1; then $SUDO pacman -Sy --noconfirm curl
  fi
  command -v curl >/dev/null 2>&1 || die "could not install curl - install curl or wget and re-run"
}

do_uninstall() {
  [[ -f "$RC" ]] && sed -i '/\.sino\/theam-x\.sh/d;/^# Theam-X$/d' "$RC"
  rm -rf "$DEST"
  say "Theam-X removed. Open a new shell to get your old prompt back."
  exit 0
}

do_install() {
  printf '%s\n' "${G}"
  cat <<'BANNER'
  _____ __  __
 |_   _|\ \/ /     THEAM-X installer
   | |   \  /      by Its2Pawan
   | |   /  \
   |_|  /_/\_\
BANNER
  printf '%s\n' "${X}"
  say "device detected: ${DEVICE}"
  say "install folder : ${DEST}"

  mkdir -p "$DEST" || die "can't create $DEST"
  local tmp="$DEST/.tmp.$$"; mkdir -p "$tmp"

  # offline / repo-checkout install: use files sitting next to this script
  local src="" d
  if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    d=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
    [[ -f "$d/theam-x.sh" && -f "$d/ver.txt" ]] && src=$d
  fi

  if [[ -n $src ]]; then
    cp "$src/theam-x.sh" "$src/ver.txt" "$tmp/"
    say "using local files from $src"
  else
    need_downloader
    local b ok=0
    for b in "$BRANCH" master; do
      if fetch "$RAW_BASE/$REPO/$b/theam-x.sh" > "$tmp/theam-x.sh" 2>/dev/null \
         && fetch "$RAW_BASE/$REPO/$b/ver.txt"  > "$tmp/ver.txt"  2>/dev/null \
         && [[ -s "$tmp/theam-x.sh" && -s "$tmp/ver.txt" ]]; then
        ok=1; say "downloaded from GitHub ($b)"; break
      fi
    done
    (( ok )) || { rm -rf "$tmp"; die "download failed - check internet and that theam-x.sh + ver.txt exist in the repo"; }
  fi

  # verify before touching anything
  bash -n "$tmp/theam-x.sh" 2>/dev/null || { rm -rf "$tmp"; die "downloaded theam-x.sh is not valid bash"; }
  grep -q 'THEAM-X' "$tmp/theam-x.sh"    || { rm -rf "$tmp"; die "downloaded file doesn't look like Theam-X"; }
  [[ "$(head -n1 "$tmp/ver.txt" | tr -d '[:space:]')" =~ ^[0-9]+(\.[0-9]+)*$ ]] \
    || { rm -rf "$tmp"; die "ver.txt is not a valid version"; }

  mv -f "$tmp/theam-x.sh" "$DEST/theam-x.sh"
  mv -f "$tmp/ver.txt"    "$DEST/ver.txt"
  rm -rf "$tmp"
  chmod +x "$DEST/theam-x.sh"

  # config (kept if it already exists)
  if [[ ! -f "$DEST/config" ]]; then
    {
      echo "# Theam-X config  (edit, then open a new shell)"
      echo "TX_AUTOUPDATE=1            # 0 = never auto update"
      echo "TX_CHECK_INTERVAL=86400    # seconds between update checks"
      echo "HV_COOLDOWN=300            # seconds before the boot animation can replay"
      if [[ $DEVICE == vps ]]; then echo 'HV_SERVICES_STR="ssh nginx docker wings"   # services shown in hv'; fi
    } > "$DEST/config"
  fi

  # migrate the old hacker-vps theme if present (avoid double theme)
  if [[ -f "$RC" ]] && grep -q 'hacker-vps' "$RC"; then
    sed -i '/hacker-vps/d' "$RC"; rm -f "$HOME/.hacker-vps.sh"
    say "old hacker-vps theme replaced"
  fi

  # load it from ~/.bashrc
  touch "$RC"
  if ! grep -qF '.sino/theam-x.sh' "$RC"; then
    printf '\n# Theam-X\n[ -f "$HOME/.sino/theam-x.sh" ] && . "$HOME/.sino/theam-x.sh"\n' >> "$RC"
  fi
  # login shells must read ~/.bashrc
  if [[ -f "$HOME/.bash_profile" ]] && ! grep -q 'bashrc' "$HOME/.bash_profile"; then
    printf '\n[ -f ~/.bashrc ] && . ~/.bashrc\n' >> "$HOME/.bash_profile"
  fi

  say "installed Theam-X v$(head -n1 "$DEST/ver.txt" | tr -d '[:space:]')"
  echo
  printf '%s\n' "${D}  Run now :${X}  source ~/.bashrc"
  printf '%s\n' "${D}  Commands:${X}  sfetch | dev | hv | matrix | hvboot | txver | txupdate"
  printf '%s\n' "${D}  Auto-update is ON (checks GitHub once a day). Turn off: TX_AUTOUPDATE=0 in $DEST/config${X}"
  echo
}

case "${1:-install}" in
  uninstall|remove) do_uninstall ;;
  install|"")       do_install ;;
  *) echo "usage: bash install.sh [install|uninstall]"; exit 1 ;;
esac
