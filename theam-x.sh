#!/usr/bin/env bash
# =====================================================================
#  THEAM-X  |  hacker terminal theme & toolkit for VPS + Termux
#  by Its2Pawan  -  https://github.com/Its2Pawan/Theam-x
#  Site: https://its2pawan.us.ci
#  Copyright (c) 2026 Its2Pawan. All Rights Reserved.
# =====================================================================

[ -n "$BASH_VERSION" ] || exec bash "$0" "$@"

HV_SELF="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")"
TX_HOME="${TX_HOME:-$HOME/.sino}"
[[ -f "$TX_HOME/config" ]] && . "$TX_HOME/config"

TX_REPO="Its2Pawan/Theam-x"
TX_BRANCH="${TX_BRANCH:-main}"
TX_RAW_BASE="${TX_RAW_BASE:-https://raw.githubusercontent.com}"

TX_THEME="${TX_THEME:-matrix}"
TX_PROMPT="${TX_PROMPT:-hacker}"
TX_RAIN="${TX_RAIN:-binary}"
TX_BOOT="${TX_BOOT:-1}"
TX_BANNER="${TX_BANNER:-1}"
TX_AUTOUPDATE="${TX_AUTOUPDATE:-1}"
TX_CHECK_INTERVAL="${TX_CHECK_INTERVAL:-86400}"
HV_COOLDOWN="${HV_COOLDOWN:-300}"

TX_DEV_NAME="${TX_DEV_NAME:-Its2Pawan}"
TX_DEV_ROLE="${TX_DEV_ROLE:-Developer}"
TX_DEV_TAG="${TX_DEV_TAG:-Discord Bots | Minecraft Plugins | Game Servers}"
TX_DEV_GITHUB="${TX_DEV_GITHUB:-https://github.com/Its2Pawan}"
TX_DEV_REPO="${TX_DEV_REPO:-https://github.com/Its2Pawan/Theam-x}"
TX_DEV_DISCORD="${TX_DEV_DISCORD:-}"
TX_DEV_SITE="${TX_DEV_SITE:-https://its2pawan.us.ci}"

if [[ -n "${TERMUX_VERSION:-}" || "${PREFIX:-}" == *com.termux* ]]; then
  TX_DEVICE=termux
  HV_DISK_PATH="$HOME"
  : "${HV_SERVICES_STR:=}"
else
  TX_DEVICE=vps
  HV_DISK_PATH="/"
  : "${HV_SERVICES_STR:=ssh nginx docker wings}"
fi
read -ra HV_SERVICES <<< "$HV_SERVICES_STR"

# ---------------------------------------------------------------------
#  theme palette & helpers
# ---------------------------------------------------------------------
TX_THEMES=(matrix cyber crimson amber ice purple neon)
TX_PROMPTS=(hacker minimal power compact)
TX_RAINS=(binary hex glyph)

_tx_is_utf8() {
  local loc="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
  [[ "$loc" == *[Uu][Tt][Ff]*8* || "$loc" == *[Uu][Tt][Ff]8* || -n "${TERMUX_VERSION:-}" ]]
}

_tx_strip_ctrl() {
  local s="$1"
  s="${s//$'\r'/}"
  s="${s//$'\n'/ }"
  s="${s//$'\t'/ }"
  printf '%s' "$s"
}

_tx_is_int() { [[ "$1" =~ ^[0-9]+$ ]]; }

_tx_in_list() {
  local needle="$1"; shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

tx_apply_palette() {
  local t="${1:-$TX_THEME}"
  _tx_in_list "$t" "${TX_THEMES[@]}" || t="matrix"
  TX_THEME="$t"

  E=$'\033'
  X="${E}[0m"
  TX_CX="${E}[0m"
  TX_CW="${E}[1;97m"
  TX_CY="${E}[1;93m"
  TX_CR="${E}[1;91m"

  # Panel / animation colors (40m black background)
  W="${E}[1;40;97m"
  Y="${E}[1;40;93m"
  R="${E}[1;40;91m"

  case "$t" in
    matrix)
      G="${E}[0;40;32m"; DIM="${E}[2;40;32m"; BR="${E}[1;40;92m"; C="${E}[1;40;96m"
      TX_C1="${E}[0;32m"; TX_C2="${E}[1;92m"; TX_CD="${E}[2;32m"; TX_CA="${E}[1;96m"
      ;;
    cyber)
      G="${E}[0;40;36m"; DIM="${E}[2;40;36m"; BR="${E}[1;40;96m"; C="${E}[1;40;95m"
      TX_C1="${E}[0;36m"; TX_C2="${E}[1;96m"; TX_CD="${E}[2;36m"; TX_CA="${E}[1;95m"
      ;;
    crimson)
      G="${E}[0;40;31m"; DIM="${E}[2;40;31m"; BR="${E}[1;40;91m"; C="${E}[1;40;97m"; R="${E}[1;40;95m"
      TX_C1="${E}[0;31m"; TX_C2="${E}[1;91m"; TX_CD="${E}[2;31m"; TX_CA="${E}[1;97m"
      ;;
    amber)
      G="${E}[0;40;33m"; DIM="${E}[2;40;33m"; BR="${E}[1;40;93m"; C="${E}[1;40;97m"; Y="${E}[1;40;92m"
      TX_C1="${E}[0;33m"; TX_C2="${E}[1;93m"; TX_CD="${E}[2;33m"; TX_CA="${E}[1;97m"
      ;;
    ice)
      G="${E}[0;40;34m"; DIM="${E}[2;40;36m"; BR="${E}[1;40;94m"; C="${E}[1;40;96m"
      TX_C1="${E}[0;34m"; TX_C2="${E}[1;94m"; TX_CD="${E}[2;36m"; TX_CA="${E}[1;96m"
      ;;
    purple)
      G="${E}[0;40;35m"; DIM="${E}[2;40;35m"; BR="${E}[1;40;95m"; C="${E}[1;40;96m"
      TX_C1="${E}[0;35m"; TX_C2="${E}[1;95m"; TX_CD="${E}[2;35m"; TX_CA="${E}[1;96m"
      ;;
    neon)
      G="${E}[0;40;92m"; DIM="${E}[2;40;32m"; BR="${E}[1;40;95m"; C="${E}[1;40;93m"
      TX_C1="${E}[0;92m"; TX_C2="${E}[1;95m"; TX_CD="${E}[2;32m"; TX_CA="${E}[1;93m"
      ;;
  esac
}
tx_apply_palette "$TX_THEME"

_tx_cycle_theme() {
  local i n=${#TX_THEMES[@]}
  for ((i=0; i<n; i++)); do
    if [[ "${TX_THEMES[i]}" == "$TX_THEME" ]]; then
      tx_apply_palette "${TX_THEMES[(i + 1) % n]}"
      return
    fi
  done
  tx_apply_palette "matrix"
}

_tx_cycle_rain() {
  local i n=${#TX_RAINS[@]}
  for ((i=0; i<n; i++)); do
    if [[ "${TX_RAINS[i]}" == "$TX_RAIN" ]]; then
      TX_RAIN="${TX_RAINS[(i + 1) % n]}"
      return
    fi
  done
  TX_RAIN="binary"
}

_tx_say()  { printf '%s[+]%s %s\n' "$TX_C2" "$TX_CX" "$*"; }
_tx_warn() { printf '%s[!]%s %s\n' "$TX_CY" "$TX_CX" "$*"; }
_tx_err()  { printf '%s[x]%s %s\n' "$TX_CR" "$TX_CX" "$*" >&2; }

# ---------------------------------------------------------------------
#  basics (terminal UI engine)
# ---------------------------------------------------------------------
hv_init() {
  tx_apply_palette "$TX_THEME"
  IN_ALT=0
  trap 'hv_cleanup' EXIT
  trap 'exit 130' INT TERM HUP
  RESIZED=0
  trap 'RESIZED=1' WINCH
}

hv_cleanup() {
  printf '%s' "${X}${E}[?7h${E}[?25h"
  (( IN_ALT )) && printf '%s' "${E}[?1049l"
  stty sane </dev/tty 2>/dev/null || stty sane 2>/dev/null || true
}

hv_enter() { printf '%s' "${E}[?1049h${E}[?7l${E}[?25l${E}[40m${E}[2J"; IN_ALT=1; }
hv_leave() { printf '%s' "${E}[?1049l${E}[?7h${E}[?25h${X}"; IN_ALT=0; }

hv_size() {
  local r="" c=""
  if [[ -r /dev/tty ]]; then
    read -r r c < <(stty size </dev/tty 2>/dev/null) || true
  fi
  if ! _tx_is_int "$r" || ! _tx_is_int "$c"; then
    read -r r c < <(stty size 2>/dev/null) || true
  fi
  _tx_is_int "$r" && (( r > 0 )) || r=$(tput lines 2>/dev/null || echo "${LINES:-24}")
  _tx_is_int "$c" && (( c > 0 )) || c=$(tput cols  2>/dev/null || echo "${COLUMNS:-80}")
  _tx_is_int "$r" && (( r > 0 )) || r=24
  _tx_is_int "$c" && (( c > 0 )) || c=80
  ROWS=$r
  COLS=$c
}

hv_layout() {
  local maxw="${HV_WIDTH:-66}"
  _tx_is_int "$maxw" || maxw=66
  PW=$(( COLS - 2 ))
  (( PW > maxw )) && PW=$maxw
  (( PW < 20 )) && PW=20
  INNER=$(( PW - 2 ))
  (( INNER < 1 )) && INNER=1
  printf -v HL '%*s' "$INNER" ''
  HL=${HL// /═}
  drop_y=()
  drop_len=()
  local c
  for ((c=1; c<=COLS; c++)); do
    drop_y[c]=$(( -(RANDOM % ROWS) ))
    drop_len[c]=$(( 5 + RANDOM % ROWS ))
  done
}

hv_screen() {
  [[ -t 1 ]] || { _tx_err "Run this in a real terminal."; return 1; }
  hv_size
  if (( COLS < 50 || ROWS < 14 )); then
    _tx_err "Terminal too small (${COLS}x${ROWS}, need at least 50x14)."
    return 1
  fi
  hv_layout
  P_LEFT=99999; P_TOP=99999; PH=0
}

hv_check_resize() {
  (( RESIZED )) || return 1
  RESIZED=0
  hv_size
  (( COLS < 50 || ROWS < 14 )) && return 1
  hv_layout
  printf '%s' "${E}[40m${E}[2J"
  return 0
}

hv_geometry() {
  PH=$(( ${#LINES[@]} + 2 ))
  P_LEFT=$(( (COLS - PW) / 2 + 1 )); (( P_LEFT < 1 )) && P_LEFT=1
  P_TOP=$(( (ROWS - PH) / 2 + 1 )); (( P_TOP < 1 )) && P_TOP=1
  return 0
}

hv_compact_lines() {
  local max_inner=$(( ROWS - 2 ))
  (( ${#LINES[@]} <= max_inner )) && return 0
  # First pass: drop middle __SEP__ separators (keep first and last)
  local -a out=()
  local i n=${#LINES[@]} first_sep=0 last_sep=-1
  for ((i=0; i<n; i++)); do
    [[ "${LINES[i]}" == "__SEP__" ]] && last_sep=$i
  done
  for ((i=0; i<n; i++)); do
    if [[ "${LINES[i]}" == "__SEP__" ]]; then
      if (( first_sep == 0 )); then
        first_sep=1; out+=("__SEP__")
      elif (( i == last_sep )); then
        out+=("__SEP__")
      fi
    else
      out+=("${LINES[i]}")
    fi
  done
  LINES=("${out[@]}")
  # Second pass: if still taller than terminal, trim lines just above footer
  while (( ${#LINES[@]} > max_inner && ${#LINES[@]} > 4 )); do
    local cut=$(( ${#LINES[@]} - 3 ))
    LINES=("${LINES[@]:0:$cut}" "${LINES[@]:$((cut+1))}")
  done
}

# ---------------------------------------------------------------------
#  rain engine (binary / hex / glyph)
# ---------------------------------------------------------------------
hv_put() {
  (( $1 < 1 || $1 > ROWS )) && return
  (( PH > 0 && $1 >= P_TOP && $1 < P_TOP + PH && $2 >= P_LEFT && $2 < P_LEFT + PW )) && return
  BUF+="${E}[$1;$2H$3$4"
}

hv_rain_frame() {
  BUF=""
  local c h l ch1 ch2 ch3
  local hex_c="0123456789ABCDEF" gly_c='!@#$%&*+=?~<>01'
  for ((c=1; c<=COLS; c+=2)); do
    h=$(( drop_y[c] + 1 )); drop_y[c]=$h; l=${drop_len[c]}
    case "$TX_RAIN" in
      hex)
        ch1="${hex_c:((RANDOM&15)):1}"; ch2="${hex_c:((RANDOM&15)):1}"; ch3="${hex_c:((RANDOM&15)):1}" ;;
      glyph)
        ch1="${gly_c:((RANDOM%14)):1}"; ch2="${gly_c:((RANDOM%14)):1}"; ch3="${gly_c:((RANDOM%14)):1}" ;;
      *)
        ch1=$((RANDOM&1)); ch2=$((RANDOM&1)); ch3=$((RANDOM&1)) ;;
    esac
    hv_put "$h"             "$c" "$W"  "$ch1"
    hv_put $(( h - 1 ))     "$c" "$BR" "$ch2"
    hv_put $(( h - l / 2 )) "$c" "$G"  "$ch3"
    hv_put $(( h - l ))     "$c" "$G"  " "
    if (( h - l > ROWS )); then
      drop_y[c]=$(( -(RANDOM % ROWS) ))
      drop_len[c]=$(( 5 + RANDOM % ROWS ))
    fi
  done
}

# ---------------------------------------------------------------------
#  panel helpers
# ---------------------------------------------------------------------
hv_ln() {
  local pad=$(( INNER - $2 )) sp
  (( pad < 0 )) && pad=0
  printf -v sp '%*s' "$pad" ''
  LINES+=("$1$sp")
}

hv_center() {
  local t
  t="$(_tx_strip_ctrl "$2")"
  t="${t:0:$INNER}"
  local lp=$(( (INNER - ${#t}) / 2 )); (( lp < 0 )) && lp=0
  local rp=$(( INNER - ${#t} - lp )); (( rp < 0 )) && rp=0
  local s1 s2
  printf -v s1 '%*s' "$lp" ''; printf -v s2 '%*s' "$rp" ''
  LINES+=("${1}${s1}${t}${s2}")
}

hv_kv() {
  local key="$1" val
  val="$(_tx_strip_ctrl "$2")"
  local avail=$(( INNER - 12 )); (( avail < 1 )) && avail=1
  local v="${val:0:$avail}" lab
  printf -v lab '%-9s' "${key:0:9}"
  local vlen="${3:-${#v}}"
  hv_ln " ${DIM}${lab} ${W}${v}" $(( 11 + vlen ))
}

hv_barline() {
  local p=$2 col bw=$(( INNER - 27 )) fill f e ex lab
  _tx_is_int "$p" || p=0
  (( bw < 4 )) && bw=4
  (( p > 100 )) && p=100; (( p < 0 )) && p=0
  local exw=$(( INNER - bw - 14 ))
  (( exw < 1 )) && exw=1
  (( exw > 13 )) && exw=13
  col=$BR; (( p >= 60 )) && col=$Y; (( p >= 85 )) && col=$R
  fill=$(( p * bw / 100 ))
  printf -v f '%*s' "$fill" ''; f=${f// /█}
  printf -v e '%*s' "$(( bw - fill ))" ''; e=${e// /░}
  local raw_ex
  raw_ex="$(_tx_strip_ctrl "$3")"
  printf -v ex "%-${exw}s" "${raw_ex:0:$exw}"
  printf -v lab '%-4s' "${1:0:4}"
  LINES+=(" ${DIM}${lab} ${G}[${col}${f}${DIM}${e}${G}] ${W}$(printf '%3d%%' "$p") ${G}${ex}")
}

hv_svc_lines() {
  if (( ! HAS_SYSTEMD && ! HAS_OPENRC )); then
    hv_center "$DIM" "services: n/a (no systemd/openrc on ${TX_DEVICE})"; return
  fi
  if (( ${#HV_SERVICES[@]} == 0 )); then
    hv_center "$DIM" "services: none configured"; return
  fi
  local cur=" " plain=1 s st col item ilen dot="*"
  _tx_is_utf8 && dot="●"
  for s in "${HV_SERVICES[@]}"; do
    st=${SVC_ST[$s]:-n/a}
    if [[ $st == active ]]; then col=$BR; else col=$R; fi
    item="${col}${dot} ${G}${s}  "; ilen=$(( ${#s} + 4 ))
    if (( plain + ilen > INNER )); then hv_ln "$cur" "$plain"; cur=" "; plain=1; fi
    cur+="$item"; plain=$(( plain + ilen ))
  done
  hv_ln "$cur" "$plain"
}

hv_draw_panel() {
  local r=$P_TOP ln rcol=$(( P_LEFT + PW - 1 ))
  BUF+="${E}[${r};${P_LEFT}H${G}╔${HL}╗"; r=$(( r + 1 ))
  for ln in "${LINES[@]}"; do
    if [[ $ln == __SEP__ ]]; then
      BUF+="${E}[${r};${P_LEFT}H${G}╠${HL}╣"
    else
      BUF+="${E}[${r};${P_LEFT}H${G}║${ln}${E}[${r};${rcol}H${G}║"
    fi
    r=$(( r + 1 ))
  done
  BUF+="${E}[${r};${P_LEFT}H${G}╚${HL}╝"
}

# ---------------------------------------------------------------------
#  system stats
# ---------------------------------------------------------------------
hv_rate() {
  local b=${1:-0}
  (( b < 0 )) && b=0
  if (( b >= 1048576 )); then
    printf '%d.%dMB/s' $(( b / 1048576 )) $(( (b % 1048576) * 10 / 1048576 ))
  else
    printf '%dKB/s' $(( b / 1024 ))
  fi
}

hv_ip() {
  local ip=""
  ip=$(hostname -I 2>/dev/null | awk '{print $1}')
  if [[ -z $ip ]] && command -v ip >/dev/null 2>&1; then
    ip=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}')
    [[ -z $ip ]] && ip=$(ip -4 -o addr show scope global 2>/dev/null | awk '{split($4,a,"/"); print a[1]; exit}')
  fi
  if [[ -z $ip ]] && command -v ifconfig >/dev/null 2>&1; then
    ip=$(ifconfig 2>/dev/null | awk '/inet / && $2!="127.0.0.1" && $2!="addr:127.0.0.1"{sub(/^addr:/,"",$2); print $2; exit}')
  fi
  printf '%s' "${ip:-n/a}"
}

hv_battery_sysfs() {
  local d cap="" st=""
  for d in /sys/class/power_supply/BAT* /sys/class/power_supply/battery; do
    [[ -r "$d/capacity" ]] || continue
    read -r cap < "$d/capacity" 2>/dev/null || continue
    [[ -r "$d/status" ]] && read -r st < "$d/status" 2>/dev/null || st=""
    printf '%s%%%s' "$cap" "${st:+ ($st)}"
    return 0
  done
  return 1
}

hv_temp_sysfs() {
  local f raw val deg_u="C"
  _tx_is_utf8 && deg_u="°C"
  for f in /sys/class/thermal/thermal_zone*/temp /sys/class/hwmon/hwmon*/temp1_input; do
    [[ -r "$f" ]] || continue
    read -r raw < "$f" 2>/dev/null || continue
    _tx_is_int "${raw#-}" || continue
    if (( raw > 1000 )); then
      val=$(( raw / 1000 ))
    else
      val=$raw
    fi
    if (( val > 0 && val < 150 )); then
      printf '%d%s' "$val" "$deg_u"
      return 0
    fi
  done
  return 1
}

hv_stats_static() {
  HOST=$(hostname 2>/dev/null || uname -n 2>/dev/null || echo "localhost")
  HOST=$(_tx_strip_ctrl "$HOST")
  IPADDR=$(hv_ip)
  if [[ $TX_DEVICE == termux ]]; then
    local av
    av=$(getprop ro.build.version.release 2>/dev/null)
    OSNAME="Android${av:+ $av} (Termux)"
    MODELNAME="$(getprop ro.product.manufacturer 2>/dev/null) $(getprop ro.product.model 2>/dev/null)"
  else
    OSNAME=$(grep -m1 '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
    MODELNAME=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || true)
    local virt=""
    if command -v systemd-detect-virt >/dev/null 2>&1; then
      virt=$(systemd-detect-virt 2>/dev/null || true)
    fi
    [[ -n $virt && $virt != none ]] && MODELNAME="${MODELNAME:+$MODELNAME }[${virt}]"
  fi
  OSNAME=$(_tx_strip_ctrl "$OSNAME")
  MODELNAME=$(_tx_strip_ctrl "$MODELNAME")
  [[ -z "${OSNAME// /}" ]] && OSNAME=$(uname -s 2>/dev/null || echo "Linux")
  [[ -z "${MODELNAME// /}" ]] && MODELNAME="$TX_DEVICE"
  KERN=$(uname -r 2>/dev/null || echo "n/a")
  NCPU=$(nproc 2>/dev/null || grep -c '^processor' /proc/cpuinfo 2>/dev/null || echo 1)
  _tx_is_int "$NCPU" && (( NCPU > 0 )) || NCPU=1
  CPUMODEL=$(grep -m1 -E '^(model name|Hardware|Processor)' /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^ *//')
  if [[ -z $CPUMODEL && $TX_DEVICE == termux ]]; then
    CPUMODEL=$(getprop ro.soc.model 2>/dev/null || getprop ro.board.platform 2>/dev/null || true)
  fi
  [[ -z $CPUMODEL ]] && CPUMODEL=$(uname -m 2>/dev/null || echo "unknown")
  CPUMODEL=$(_tx_strip_ctrl "$CPUMODEL")

  local cnt
  if command -v dpkg-query >/dev/null 2>&1; then
    cnt=$(dpkg-query -f '.\n' -W 2>/dev/null | wc -l | tr -d ' '); PKGS="${cnt} (dpkg)"
  elif command -v rpm >/dev/null 2>&1; then
    cnt=$(rpm -qa 2>/dev/null | wc -l | tr -d ' '); PKGS="${cnt} (rpm)"
  elif command -v apk >/dev/null 2>&1; then
    cnt=$(apk info 2>/dev/null | wc -l | tr -d ' '); PKGS="${cnt} (apk)"
  elif command -v pacman >/dev/null 2>&1; then
    cnt=$(pacman -Q 2>/dev/null | wc -l | tr -d ' '); PKGS="${cnt} (pacman)"
  else
    PKGS="n/a"
  fi

  SHELLNAME="${SHELL##*/} ${BASH_VERSION%%(*}"
  TERMNAME="${TERM_PROGRAM:-${TERM:-n/a}}"

  CPU=0; PREV_TOTAL=0; PREV_IDLE=0; PREV_RX=0; PREV_TX=0; PREV_T=$SECONDS
  RX_TXT="0KB/s"; TX_TXT="0KB/s"; NUSERS=0; HAS_SYSTEMD=0; HAS_OPENRC=0
  BAT_TXT=$(hv_battery_sysfs 2>/dev/null || echo "")
  TEMP_TXT=$(hv_temp_sysfs 2>/dev/null || echo "")
}

hv_stats_fast() {
  local a=0 b=0 c=0 d=0 e=0 f=0 g=0 h=0 idle total dt di
  CPU_EXTRA="${NCPU} core(s)"
  if { read -r _ a b c d e f g h _; } 2>/dev/null </proc/stat; then
    a=${a:-0}; b=${b:-0}; c=${c:-0}; d=${d:-0}; e=${e:-0}; f=${f:-0}; g=${g:-0}; h=${h:-0}
    if _tx_is_int "$a" && _tx_is_int "$d"; then
      idle=$(( d + e ))
      total=$(( a + b + c + d + e + f + g + h ))
      if (( PREV_TOTAL > 0 )); then
        dt=$(( total - PREV_TOTAL )); di=$(( idle - PREV_IDLE ))
        if (( dt > 0 && di >= 0 )); then
          CPU=$(( 100 * (dt - di) / dt ))
          (( CPU < 0 )) && CPU=0
          (( CPU > 100 )) && CPU=100
        fi
      fi
      PREV_TOTAL=$total; PREV_IDLE=$idle
    fi
  else
    CPU=0; CPU_EXTRA="n/a (no access)"
  fi

  local k v mt=0 ma=0 mf=0 mb=0 mc=0 st=0 sf=0
  if [[ -r /proc/meminfo ]]; then
    while read -r k v _; do
      _tx_is_int "$v" || continue
      case $k in
        MemTotal:)     mt=$v ;;
        MemAvailable:) ma=$v ;;
        MemFree:)      mf=$v ;;
        Buffers:)      mb=$v ;;
        Cached:)       mc=$v ;;
        SwapTotal:)    st=$v ;;
        SwapFree:)     sf=$v ;;
      esac
    done < /proc/meminfo
    (( ma == 0 && mf > 0 )) && ma=$(( mf + mb + mc ))
  fi
  if (( mt > 0 )); then
    (( ma > mt )) && ma=$mt
    MEM_PCT=$(( 100 * (mt - ma) / mt ))
    (( MEM_PCT < 0 )) && MEM_PCT=0
    (( MEM_PCT > 100 )) && MEM_PCT=100
    MEM_TXT="$(( (mt - ma) / 1024 ))/$(( mt / 1024 ))MB"
  else
    MEM_PCT=0; MEM_TXT="n/a"
  fi
  if (( st > 0 )); then
    SWAP_TXT="$(( (st - sf) / 1024 ))/$(( st / 1024 ))MB"
  else
    SWAP_TXT="off"
  fi

  local dsize="" dused="" dpct=""
  read -r _ dsize dused _ dpct _ < <(df -hP "$HV_DISK_PATH" 2>/dev/null | tail -1) || true
  dpct=${dpct%\%}
  _tx_is_int "$dpct" || dpct=0
  (( dpct > 100 )) && dpct=100
  DISK_PCT=$dpct
  DISK_TXT="${dused:-?}/${dsize:-?}"

  if { read -r L1 L2 L3 _; } 2>/dev/null </proc/loadavg; then
    :
  else
    L1="n/a"; L2=""; L3=""
  fi

  local up d2 h2 m2
  if { read -r up _; } 2>/dev/null </proc/uptime; then
    up=${up%.*}
    if _tx_is_int "$up"; then
      d2=$(( up / 86400 )); h2=$(( up % 86400 / 3600 )); m2=$(( up % 3600 / 60 ))
      UPTXT="${d2}d ${h2}h ${m2}m"
    else
      UPTXT="n/a"
    fi
  else
    UPTXT=$(uptime -p 2>/dev/null | sed 's/^up //')
    UPTXT=${UPTXT:-n/a}
  fi

  local rx=0 tx=0 line iface have=0 dtn drx dtx
  local -a _nf=()
  if [[ -r /proc/net/dev ]]; then
    while read -r line; do
      [[ $line == *:* ]] || continue
      iface=${line%%:*}; iface=${iface// /}
      [[ $iface == lo ]] && continue
      read -ra _nf <<< "${line#*:}"
      _tx_is_int "${_nf[0]:-}" && rx=$(( rx + _nf[0] ))
      _tx_is_int "${_nf[8]:-}" && tx=$(( tx + _nf[8] ))
      have=1
    done < /proc/net/dev
  fi
  if (( have )); then
    dtn=$(( SECONDS - PREV_T )); (( dtn < 1 )) && dtn=1
    if (( PREV_RX > 0 || PREV_TX > 0 )); then
      drx=$(( (rx - PREV_RX) / dtn )); (( drx < 0 )) && drx=0
      dtx=$(( (tx - PREV_TX) / dtn )); (( dtx < 0 )) && dtx=0
      RX_TXT=$(hv_rate "$drx")
      TX_TXT=$(hv_rate "$dtx")
    fi
    PREV_RX=$rx; PREV_TX=$tx; PREV_T=$SECONDS
  else
    RX_TXT="n/a"; TX_TXT="n/a"
  fi
}

hv_stats_slow() {
  local s st
  HAS_SYSTEMD=0; HAS_OPENRC=0
  if command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
    HAS_SYSTEMD=1
    for s in "${HV_SERVICES[@]}"; do
      st=$(systemctl is-active "$s" 2>/dev/null || true)
      if [[ $st != active && $s == ssh ]]; then st=$(systemctl is-active sshd 2>/dev/null || true); fi
      SVC_ST[$s]=${st:-n/a}
    done
  elif command -v rc-service >/dev/null 2>&1; then
    HAS_OPENRC=1
    for s in "${HV_SERVICES[@]}"; do
      if rc-service "$s" status >/dev/null 2>&1; then
        SVC_ST[$s]="active"
      elif [[ $s == ssh ]] && rc-service sshd status >/dev/null 2>&1; then
        SVC_ST[$s]="active"
      else
        SVC_ST[$s]="inactive"
      fi
    done
  fi
  NUSERS=$(who 2>/dev/null | wc -l | tr -d ' ')
  _tx_is_int "$NUSERS" || NUSERS=0
  BAT_TXT=$(hv_battery_sysfs 2>/dev/null || echo "")
  TEMP_TXT=$(hv_temp_sysfs 2>/dev/null || echo "")
}

# ---------------------------------------------------------------------
#  INTERACTIVE PANELS (shared loop)
# ---------------------------------------------------------------------
_hv_run_panel() {
  local builder="$1" refresh="$2" label="$3"
  hv_init
  hv_screen || return 1
  declare -A SVC_ST
  hv_stats_static; hv_stats_fast; hv_stats_slow
  "$builder"; hv_compact_lines; hv_geometry
  if (( PH > ROWS )); then
    _tx_err "Terminal too small for ${label} (need ${PH} rows, have ${ROWS})."
    return 1
  fi
  hv_enter
  local last=$SECONDS slow_last=$SECONDS paused=0 k
  while true; do
    if hv_check_resize; then
      "$builder"; hv_compact_lines; hv_geometry
    fi
    if (( refresh > 0 && ! paused && SECONDS != last )); then
      last=$SECONDS
      hv_stats_fast
      if (( SECONDS - slow_last >= 5 )); then hv_stats_slow; slow_last=$SECONDS; fi
      "$builder"; hv_compact_lines
    fi
    hv_rain_frame; hv_draw_panel; printf '%s' "$BUF"
    if read -rsn1 -t "${HV_FPS_DELAY:-0.05}" k; then
      case "$k" in
        q|Q) break ;;
        t|T) _tx_cycle_theme; "$builder"; hv_compact_lines ;;
        r|R) _tx_cycle_rain ;;
        p|P)
          if (( refresh > 0 )); then
            paused=$(( 1 - paused ))
            "$builder"; hv_compact_lines
          fi
          ;;
      esac
    fi
  done
  hv_leave
}

hv_build_dash() {
  LINES=()
  local net_str
  if _tx_is_utf8; then
    net_str="↓ ${RX_TXT}   ↑ ${TX_TXT}"
  else
    net_str="RX ${RX_TXT}   TX ${TX_TXT}"
  fi
  hv_center "$C" "[ ${HOST} // SYSTEM MONITOR // ${TX_THEME^^} ]"
  LINES+=("__SEP__")
  hv_kv HOST   "$HOST"
  hv_kv IP     "$IPADDR"
  hv_kv OS     "$OSNAME"
  hv_kv KERNEL "$KERN"
  hv_kv UPTIME "$UPTXT"
  hv_kv USERS  "${NUSERS} logged in"
  LINES+=("__SEP__")
  hv_barline CPU  "$CPU"      "$CPU_EXTRA"
  hv_barline RAM  "$MEM_PCT"  "$MEM_TXT"
  hv_barline DISK "$DISK_PCT" "$DISK_TXT"
  hv_kv LOAD "$L1  $L2  $L3"
  hv_kv NET  "$net_str" "${#net_str}"
  [[ -n $TEMP_TXT ]] && hv_kv TEMP    "$TEMP_TXT"
  [[ -n $BAT_TXT ]]  && hv_kv BATTERY "$BAT_TXT"
  LINES+=("__SEP__")
  hv_svc_lines
  LINES+=("__SEP__")
  hv_center "$DIM" "$(date '+%F %T') | t:theme r:rain p:pause q:quit"
}

hv_dash() { _hv_run_panel hv_build_dash 1 "monitor"; }

hv_build_sfetch() {
  LINES=()
  hv_center "$C" "[ ${HOST} // SYSTEM INFO // ${TX_THEME^^} ]"
  LINES+=("__SEP__")
  hv_kv USER   "${USER:-$(id -un 2>/dev/null || echo user)}"
  hv_kv HOST   "$HOST"
  hv_kv OS     "$OSNAME"
  hv_kv DEVICE "$MODELNAME"
  hv_kv KERNEL "$KERN"
  hv_kv UPTIME "$UPTXT"
  hv_kv SHELL  "$SHELLNAME"
  hv_kv TERM   "$TERMNAME"
  hv_kv PKGS   "$PKGS"
  LINES+=("__SEP__")
  hv_kv CPU    "$CPUMODEL"
  hv_kv MEMORY "$MEM_TXT ($MEM_PCT%)"
  hv_kv SWAP   "$SWAP_TXT"
  hv_kv DISK   "$DISK_TXT ($DISK_PCT%)"
  hv_kv IP     "$IPADDR"
  [[ -n $TEMP_TXT ]] && hv_kv TEMP    "$TEMP_TXT"
  [[ -n $BAT_TXT ]]  && hv_kv BATTERY "$BAT_TXT"
  LINES+=("__SEP__")
  hv_kv THEME  "Theam-X v$(tx_local_ver) (${TX_THEME})"
  LINES+=("__SEP__")
  hv_center "$DIM" "$(date '+%F %T') | t:theme r:rain q:quit"
}

hv_sfetch_cli() {
  tx_apply_palette "$TX_THEME"
  declare -A SVC_ST
  hv_stats_static; hv_stats_fast; hv_stats_slow
  local -a logo=(
    '  _____ __  __ '
    ' |_   _|\ \/ / '
    '   | |   \  /  '
    '   | |   /  \  '
    '   |_|  /_/\_\ '
    '               '
    '   THEAM-X     '
    "   v$(tx_local_ver)      "
  )
  local -a info=(
    "${TX_C2}${USER:-$(id -un 2>/dev/null || echo user)}${TX_CX}@${TX_CW}${HOST}${TX_CX}"
    "${TX_CD}──────────────────────────────${TX_CX}"
    "${TX_CA}OS     ${TX_CX}: ${OSNAME}"
    "${TX_CA}Device ${TX_CX}: ${MODELNAME}"
    "${TX_CA}Kernel ${TX_CX}: ${KERN}"
    "${TX_CA}Uptime ${TX_CX}: ${UPTXT}"
    "${TX_CA}Shell  ${TX_CX}: ${SHELLNAME}"
    "${TX_CA}Pkgs   ${TX_CX}: ${PKGS}"
    "${TX_CA}CPU    ${TX_CX}: ${CPUMODEL} (${NCPU}c)"
    "${TX_CA}Memory ${TX_CX}: ${MEM_TXT} (${MEM_PCT}%)"
    "${TX_CA}Disk   ${TX_CX}: ${DISK_TXT} (${DISK_PCT}%)"
    "${TX_CA}IP     ${TX_CX}: ${IPADDR}"
    "${TX_CA}Theme  ${TX_CX}: ${TX_THEME} / ${TX_PROMPT} (${TX_DEVICE})"
  )
  [[ -n $TEMP_TXT ]] && info+=("${TX_CA}Temp   ${TX_CX}: ${TEMP_TXT}")
  [[ -n $BAT_TXT ]]  && info+=("${TX_CA}Power  ${TX_CX}: ${BAT_TXT}")
  echo
  local i max=${#info[@]}
  (( ${#logo[@]} > max )) && max=${#logo[@]}
  for ((i=0; i<max; i++)); do
    printf '%s%-16s%s  %s\n' "$TX_C2" "${logo[i]:-}" "$TX_CX" "${info[i]:-}"
  done
  echo
}

hv_sfetch() {
  case "${1:-}" in
    -q|--cli|-c|--text) hv_sfetch_cli ;;
    -h|--help)
      echo "Usage: sfetch [-q|--cli] [-h|--help]"
      echo "  no args   animated matrix rain system info panel"
      echo "  -q, --cli quick ASCII logo + stats in terminal"
      ;;
    *) _hv_run_panel hv_build_sfetch 1 "sfetch" ;;
  esac
}

hv_build_dev() {
  LINES=()
  hv_center "$C" "[ ${TX_DEV_NAME} // DEVELOPER CARD ]"
  LINES+=("__SEP__")
  hv_kv NAME    "$TX_DEV_NAME"
  hv_kv ROLE    "$TX_DEV_ROLE"
  hv_kv STACK   "$TX_DEV_TAG"
  LINES+=("__SEP__")
  hv_kv GITHUB  "$TX_DEV_GITHUB"
  hv_kv REPO    "$TX_DEV_REPO"
  hv_kv PROJECT "Theam-X v$(tx_local_ver)"
  [[ -n $TX_DEV_SITE ]]    && hv_kv SITE    "$TX_DEV_SITE"
  [[ -n $TX_DEV_DISCORD ]] && hv_kv DISCORD "$TX_DEV_DISCORD"
  LINES+=("__SEP__")
  hv_kv DEVICE  "$TX_DEVICE"
  hv_kv THEME   "${TX_THEME} / ${TX_PROMPT} / ${TX_RAIN}"
  hv_kv SHELL   "$SHELLNAME"
  hv_kv TERM    "$TERMNAME"
  LINES+=("__SEP__")
  hv_center "$DIM" "$(date '+%F %T') | t:theme r:rain q:quit"
}

hv_dev() { _hv_run_panel hv_build_dev 0 "dev"; }

# ---------------------------------------------------------------------
#  BOOT SCREEN
# ---------------------------------------------------------------------
hv_build_boot() {
  LINES=()
  hv_center "$C" "[ ${HOST} // BOOT SEQUENCE ]"
  LINES+=("__SEP__")
  local view=("${LOGS[@]}")
  (( CUR_ON )) && view+=("RUN|${CUR}")
  local n=${#view[@]} start=0 i shown=0 tag st t tw=$(( INNER - 8 ))
  (( tw < 1 )) && tw=1
  (( n > LOGROWS )) && start=$(( n - LOGROWS ))
  for ((i=start; i<n; i++)); do
    st=${view[i]%%|*}; t="$(_tx_strip_ctrl "${view[i]#*|}")"; t="${t:0:$tw}"
    if [[ $st == OK ]]; then tag="${BR}[ OK ]"; else tag="${Y}[ .. ]"; fi
    hv_ln " ${tag} ${G}${t}" $(( 8 + ${#t} )); shown=$(( shown + 1 ))
  done
  for ((; shown<LOGROWS; shown++)); do hv_ln "" 0; done
  LINES+=("__SEP__")
  local bw=$(( INNER - 8 )) fill f e
  (( bw < 4 )) && bw=4
  fill=$(( PCT * bw / 100 ))
  printf -v f '%*s' "$fill" ''; f=${f// /█}
  printf -v e '%*s' "$(( bw - fill ))" ''; e=${e// /░}
  LINES+=(" ${G}[${BR}${f}${DIM}${e}${G}] ${W}$(printf '%3d%%' "$PCT") ")
  hv_center "$STATUS_COLOR" "$STATUS"
}

_hv_boot_wait() {
  local d="${HV_FPS_DELAY:-0.03}" k=""
  if [[ -t 0 ]] && ( : </dev/tty ) 2>/dev/null; then
    if read -rsn1 -t "$d" k </dev/tty 2>/dev/null; then
      return 1
    fi
  else
    sleep "$d" 2>/dev/null || true
  fi
  return 0
}

hv_boot() {
  hv_init
  hv_screen || return 1
  declare -A SVC_ST
  hv_stats_static; hv_stats_fast; hv_stats_slow
  local on=0 s tot=${#HV_SERVICES[@]} svc_txt
  for s in "${HV_SERVICES[@]}"; do [[ "${SVC_ST[$s]:-}" == active ]] && on=$(( on + 1 )); done
  svc_txt="Services ${on}/${tot} online"
  (( HAS_SYSTEMD || HAS_OPENRC )) || svc_txt="Services n/a (${TX_DEVICE})"

  local STEPS=(
    "Theam-X v$(tx_local_ver) [${TX_THEME}] on ${TX_DEVICE}"
    "Kernel ${KERN}"
    "Host ${HOST} online"
    "OS ${OSNAME}"
    "IPv4 ${IPADDR}"
    "CPU ${NCPU} core(s)  load ${L1}"
    "Memory ${MEM_TXT} (${MEM_PCT}%)"
    "Disk ${DISK_TXT} (${DISK_PCT}%)"
    "${svc_txt}"
    "Uptime ${UPTXT}"
    "Access granted. Welcome, ${USER:-$(id -un 2>/dev/null || echo user)}"
  )

  LOGROWS=$(( ROWS - 9 )); (( LOGROWS > 9 )) && LOGROWS=9; (( LOGROWS < 2 )) && LOGROWS=2
  LOGS=(); CUR=""; CUR_ON=0; PCT=0; STATUS="initializing... (any key to skip)"; STATUS_COLOR="$Y"
  hv_build_boot; hv_geometry
  hv_enter

  local total=${#STEPS[@]} i=0 n=0 hold=0 txt skip=0
  while (( i < total )); do
    txt=${STEPS[i]}
    if (( hold > 0 )); then
      hold=$(( hold - 1 ))
    else
      n=$(( n + 3 )); CUR_ON=1; CUR="${txt:0:n}"
      if (( n >= ${#txt} )); then
        LOGS+=("OK|$txt"); CUR_ON=0; i=$(( i + 1 )); n=0; hold=5
        PCT=$(( i * 100 / total ))
      fi
    fi
    if hv_check_resize; then
      LOGROWS=$(( ROWS - 9 )); (( LOGROWS > 9 )) && LOGROWS=9; (( LOGROWS < 2 )) && LOGROWS=2
      hv_geometry
    fi
    hv_build_boot; hv_rain_frame; hv_draw_panel; printf '%s' "$BUF"
    _hv_boot_wait || { skip=1; break; }
  done

  if (( ! skip )); then
    STATUS=">>> ACCESS GRANTED <<<"; STATUS_COLOR="$BR"
    for ((i=0; i<35; i++)); do
      hv_build_boot; hv_rain_frame; hv_draw_panel; printf '%s' "$BUF"
      _hv_boot_wait || break
    done
  fi
  hv_leave
}

# ---------------------------------------------------------------------
#  MATRIX
# ---------------------------------------------------------------------
hv_matrix() {
  hv_init
  hv_screen || return 1
  hv_enter
  local k delay="${HV_FPS_DELAY:-0.04}"
  while true; do
    hv_check_resize
    hv_rain_frame; printf '%s' "$BUF"
    if read -rsn1 -t "$delay" k; then
      case "$k" in
        t|T) _tx_cycle_theme ;;
        r|R) _tx_cycle_rain ;;
        +|-)
          if [[ "$k" == "+" ]]; then delay="0.02"; else delay="0.07"; fi ;;
        *) break ;;
      esac
    fi
  done
  hv_leave
}

# ---------------------------------------------------------------------
#  version + update + config persistence
# ---------------------------------------------------------------------
tx_get() {
  if command -v curl >/dev/null 2>&1; then curl -fsSL --max-time "${TX_TIMEOUT:-8}" "$1"
  elif command -v wget >/dev/null 2>&1; then wget -qO- -T "${TX_TIMEOUT:-8}" "$1"
  else return 127; fi
}

tx_local_ver() {
  local v f
  for f in "$(dirname "$HV_SELF")/ver.txt" "$TX_HOME/ver.txt"; do
    v=$(head -n1 "$f" 2>/dev/null | tr -d '[:space:]')
    [[ -n $v ]] && { printf '%s' "$v"; return; }
  done
  printf '0.0.0'
}

tx_ver_gt() {
  local IFS=.
  local -a a=($1) b=($2)
  local i n=${#a[@]}; (( ${#b[@]} > n )) && n=${#b[@]}
  for ((i=0; i<n; i++)); do
    (( 10#${a[i]:-0} > 10#${b[i]:-0} )) && return 0
    (( 10#${a[i]:-0} < 10#${b[i]:-0} )) && return 1
  done
  return 1
}

tx_remote_ver() {
  local b v
  for b in "$TX_BRANCH" master; do
    v=$(tx_get "${TX_RAW_BASE}/${TX_REPO}/${b}/ver.txt" 2>/dev/null | head -n1 | tr -d '[:space:]')
    if [[ $v =~ ^[0-9]+(\.[0-9]+)*$ ]]; then printf '%s %s' "$v" "$b"; return 0; fi
  done
  return 1
}

_tx_download_update() {
  local quiet="${1:-0}" lv rv rb base tmp
  lv=$(tx_local_ver)
  local out
  out=$(tx_remote_ver) || {
    (( quiet )) || _tx_err "cannot reach GitHub"
    return 1
  }
  read -r rv rb <<< "$out"
  (( quiet )) || printf '%s[*]%s installing v%s -> v%s ...\n' "$TX_CY" "$TX_CX" "$lv" "$rv"
  base="${TX_RAW_BASE}/${TX_REPO}/${rb}"
  mkdir -p "$TX_HOME" || return 1
  tmp="$TX_HOME/.tmp.$$"
  mkdir -p "$tmp" || return 1
  if tx_get "$base/theam-x.sh" > "$tmp/theam-x.sh" 2>/dev/null \
     && [[ -s "$tmp/theam-x.sh" ]] && bash -n "$tmp/theam-x.sh" 2>/dev/null \
     && grep -q 'THEAM-X' "$tmp/theam-x.sh"; then
    mv -f "$tmp/theam-x.sh" "$TX_HOME/theam-x.sh"
    chmod +x "$TX_HOME/theam-x.sh" 2>/dev/null || true
    printf '%s\n' "$rv" > "$TX_HOME/ver.txt"
    rm -rf "$tmp"
    if (( quiet )); then
      printf 'Theam-X updated v%s -> v%s\n' "$lv" "$rv" > "$TX_HOME/notice"
    else
      _tx_say "updated to v${rv}  (open a new shell or run: source ~/.bashrc)"
    fi
    return 0
  fi
  rm -rf "$tmp"
  (( quiet )) || _tx_err "update failed, kept v${lv}"
  return 1
}

tx_install()       { _tx_download_update 0; }
tx_install_quiet() { _tx_download_update 1; }

tx_update() {
  local lv out rv rb
  lv=$(tx_local_ver)
  out=$(tx_remote_ver) || { _tx_err "cannot reach GitHub"; return 1; }
  read -r rv rb <<< "$out"
  if ! tx_ver_gt "$rv" "$lv"; then
    _tx_say "up to date  (v${lv})"
    return 0
  fi
  tx_install
}

tx_version() {
  local lv out rv
  lv=$(tx_local_ver)
  printf '%sTheam-X%s v%s  %s(%s | theme:%s | prompt:%s)%s\n' \
    "$TX_C2" "$TX_CX" "$lv" "$TX_C1" "$TX_DEVICE" "$TX_THEME" "$TX_PROMPT" "$TX_CX"
  if out=$(tx_remote_ver); then
    rv=${out%% *}
    if tx_ver_gt "$rv" "$lv"; then
      _tx_warn "update available: v${rv}   (run: txupdate)"
    else
      _tx_say "you have the latest version"
    fi
  else
    _tx_err "cannot check GitHub right now"
  fi
}

tx_update_prompt() {
  [[ "${TX_AUTOUPDATE:-1}" == 1 ]] || return 0
  [[ -t 0 && -t 1 ]] || return 0
  local lv out rv rb
  lv=$(tx_local_ver)
  out=$(tx_remote_ver 2>/dev/null) || return 0
  read -r rv rb <<< "$out"
  tx_ver_gt "$rv" "$lv" || return 0

  printf '\n%s┌────────────────────────────────────────────────┐%s\n' "$TX_C2" "$TX_CX"
  printf '%s│%s %s[*] Theam-X update available%s                  %s│%s\n' "$TX_C2" "$TX_CX" "$TX_CY" "$TX_CX" "$TX_C2" "$TX_CX"
  printf '%s│%s    current: v%-10s  new: v%-10s   %s│%s\n' "$TX_C2" "$TX_CX" "$lv" "$rv" "$TX_C2" "$TX_CX"
  printf '%s└────────────────────────────────────────────────┘%s\n' "$TX_C2" "$TX_CX"
  printf '%sInstall now? [y/N] %s' "$TX_CY" "$TX_CX"

  local ans=""
  read -r -n 1 -t 20 ans </dev/tty 2>/dev/null || ans=""
  printf '\n'
  case "$ans" in
    y|Y)
      if tx_install_quiet; then
        _tx_say "updated to v${rv} — active in new shells"
      else
        _tx_err "update failed"
      fi
      ;;
    *)
      _tx_warn "skipped — run txupdate anytime to update"
      ;;
  esac
}

_tx_config_init() {
  mkdir -p "$TX_HOME" || return 1
  if [[ ! -f "$TX_HOME/config" ]]; then
    {
      echo "# Theam-X config  (edit via: txtheme / txconfig)"
      echo 'TX_THEME="matrix"          # matrix | cyber | crimson | amber | ice | purple | neon'
      echo 'TX_PROMPT="hacker"         # hacker | minimal | power | compact'
      echo 'TX_RAIN="binary"           # binary | hex | glyph'
      echo 'TX_BOOT=1                  # 1 = boot animation on login, 0 = skip'
      echo 'TX_BANNER=1                # 1 = compact status line on login, 0 = hide'
      echo 'TX_AUTOUPDATE=1            # 0 = never auto update'
      echo 'TX_CHECK_INTERVAL=86400    # seconds between update checks'
      echo 'HV_COOLDOWN=300            # seconds before the boot animation can replay'
      if [[ $TX_DEVICE == vps ]]; then
        echo 'HV_SERVICES_STR="ssh nginx docker wings"   # services shown in hv'
      fi
    } > "$TX_HOME/config"
  fi
}

_tx_config_set() {
  local key="$1" val="$2"
  [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]] || { _tx_err "invalid config key: $key"; return 1; }
  _tx_config_init || return 1
  local quoted
  printf -v quoted '%q' "$val"
  local tmp="$TX_HOME/.cfg.$$"
  TXK="$key" TXV="$quoted" awk '
    BEGIN { k=ENVIRON["TXK"]; v=ENVIRON["TXV"]; done=0 }
    $0 ~ "^[#[:space:]]*" k "=" {
      if (!done) { print k "=" v; done=1 }
      next
    }
    { print }
    END { if (!done) print k "=" v }
  ' "$TX_HOME/config" > "$tmp" && mv -f "$tmp" "$TX_HOME/config"
}

# ---------------------------------------------------------------------
#  THEME, CONFIG & HELP COMMANDS
# ---------------------------------------------------------------------
tx_theme() {
  local sub="${1:-menu}" arg="${2:-}"
  case "$sub" in
    -h|--help|help)
      cat <<'EOF'
Usage: txtheme [option]
  txtheme                         interactive theme & options menu
  txtheme list                    list all themes, prompts, and rain styles
  txtheme <theme>                 matrix | cyber | crimson | amber | ice | purple | neon
  txtheme prompt <style>          hacker | minimal | power | compact
  txtheme rain <mode>             binary | hex | glyph
  txtheme boot <on|off>           enable/disable login boot animation
  txtheme banner <on|off>         enable/disable login status banner
  txtheme autoupdate <on|off>     enable/disable daily update prompt
EOF
      return 0
      ;;
    list)
      printf '%sColor themes%s : %s  (active: %s%s%s)\n' "$TX_CA" "$TX_CX" "${TX_THEMES[*]}" "$TX_C2" "$TX_THEME" "$TX_CX"
      printf '%sPrompt styles%s: %s  (active: %s%s%s)\n' "$TX_CA" "$TX_CX" "${TX_PROMPTS[*]}" "$TX_C2" "$TX_PROMPT" "$TX_CX"
      printf '%sRain modes%s   : %s  (active: %s%s%s)\n' "$TX_CA" "$TX_CX" "${TX_RAINS[*]}" "$TX_C2" "$TX_RAIN" "$TX_CX"
      printf '%sBoot screen%s  : %s\n' "$TX_CA" "$TX_CX" "$([[ $TX_BOOT == 1 && ${HV_QUICK:-0} != 1 ]] && echo on || echo off)"
      printf '%sLogin banner%s : %s\n' "$TX_CA" "$TX_CX" "$([[ ${TX_BANNER:-1} == 1 ]] && echo on || echo off)"
      printf '%sAuto-update%s  : %s\n' "$TX_CA" "$TX_CX" "$([[ $TX_AUTOUPDATE == 1 ]] && echo on || echo off)"
      return 0
      ;;
    prompt)
      _tx_in_list "$arg" "${TX_PROMPTS[@]}" || { _tx_err "unknown prompt '$arg'. Choose: ${TX_PROMPTS[*]}"; return 1; }
      TX_PROMPT="$arg"
      _tx_config_set "TX_PROMPT" "$arg"
      _tx_say "prompt style -> ${arg}"
      return 0
      ;;
    rain)
      _tx_in_list "$arg" "${TX_RAINS[@]}" || { _tx_err "unknown rain mode '$arg'. Choose: ${TX_RAINS[*]}"; return 1; }
      TX_RAIN="$arg"
      _tx_config_set "TX_RAIN" "$arg"
      _tx_say "rain mode -> ${arg}"
      return 0
      ;;
    boot)
      case "$arg" in
        on|1|true)  TX_BOOT=1; HV_QUICK=0; _tx_config_set "TX_BOOT" "1"; _tx_config_set "HV_QUICK" "0"; _tx_say "boot animation -> ON" ;;
        off|0|false) TX_BOOT=0; _tx_config_set "TX_BOOT" "0"; _tx_say "boot animation -> OFF" ;;
        *) _tx_err "usage: txtheme boot <on|off>"; return 1 ;;
      esac
      return 0
      ;;
    banner)
      case "$arg" in
        on|1|true)  TX_BANNER=1; _tx_config_set "TX_BANNER" "1"; _tx_say "login banner -> ON" ;;
        off|0|false) TX_BANNER=0; _tx_config_set "TX_BANNER" "0"; _tx_say "login banner -> OFF" ;;
        *) _tx_err "usage: txtheme banner <on|off>"; return 1 ;;
      esac
      return 0
      ;;
    autoupdate)
      case "$arg" in
        on|1|true)  TX_AUTOUPDATE=1; _tx_config_set "TX_AUTOUPDATE" "1"; _tx_say "auto-update -> ON" ;;
        off|0|false) TX_AUTOUPDATE=0; _tx_config_set "TX_AUTOUPDATE" "0"; _tx_say "auto-update -> OFF" ;;
        *) _tx_err "usage: txtheme autoupdate <on|off>"; return 1 ;;
      esac
      return 0
      ;;
    menu|"")
      [[ -t 0 && -t 1 ]] || { tx_theme list; return 0; }
      printf '\n%s=== THEAM-X OPTIONS (%s) ===%s\n' "$TX_C2" "$TX_DEVICE" "$TX_CX"
      tx_theme list
      echo
      echo "  [1] Color Theme    (matrix / cyber / crimson / amber / ice / purple / neon)"
      echo "  [2] Prompt Style   (hacker / minimal / power / compact)"
      echo "  [3] Rain Mode      (binary / hex / glyph)"
      echo "  [4] Toggle Boot    (currently $([[ $TX_BOOT == 1 && ${HV_QUICK:-0} != 1 ]] && echo on || echo off))"
      echo "  [5] Toggle Banner  (currently $([[ ${TX_BANNER:-1} == 1 ]] && echo on || echo off))"
      echo "  [6] Toggle Update  (currently $([[ $TX_AUTOUPDATE == 1 ]] && echo on || echo off))"
      echo "  [0] Exit"
      printf '\n%sSelect [0-6]: %s' "$TX_CY" "$TX_CX"
      local ch="" val=""
      read -r ch
      case "$ch" in
        1) printf 'Theme (%s): ' "${TX_THEMES[*]}"; read -r val; [[ -n $val ]] && tx_theme "$val" ;;
        2) printf 'Prompt (%s): ' "${TX_PROMPTS[*]}"; read -r val; [[ -n $val ]] && tx_theme prompt "$val" ;;
        3) printf 'Rain (%s): ' "${TX_RAINS[*]}"; read -r val; [[ -n $val ]] && tx_theme rain "$val" ;;
        4) if [[ $TX_BOOT == 1 && ${HV_QUICK:-0} != 1 ]]; then tx_theme boot off; else tx_theme boot on; fi ;;
        5) if [[ ${TX_BANNER:-1} == 1 ]]; then tx_theme banner off; else tx_theme banner on; fi ;;
        6) if [[ $TX_AUTOUPDATE == 1 ]]; then tx_theme autoupdate off; else tx_theme autoupdate on; fi ;;
        0|"") ;;
        *) _tx_err "invalid selection" ;;
      esac
      return 0
      ;;
    *)
      if _tx_in_list "$sub" "${TX_THEMES[@]}"; then
        tx_apply_palette "$sub"
        _tx_config_set "TX_THEME" "$sub"
        _tx_say "color theme -> ${sub}"
        return 0
      fi
      _tx_err "unknown option '$sub'. Run: txtheme --help"
      return 1
      ;;
  esac
}

tx_config() {
  local sub="${1:-show}" key="${2:-}" val="${3:-}"
  _tx_config_init || return 1
  case "$sub" in
    show|"")
      printf '%sConfig file:%s %s\n\n' "$TX_CA" "$TX_CX" "$TX_HOME/config"
      cat "$TX_HOME/config"
      ;;
    get)
      [[ -n $key ]] || { _tx_err "usage: txconfig get <KEY>"; return 1; }
      printf '%s\n' "${!key:-}"
      ;;
    set)
      [[ -n $key && $# -ge 3 ]] || { _tx_err "usage: txconfig set <KEY> <VALUE>"; return 1; }
      shift 2
      _tx_config_set "$key" "$*" || return 1
      . "$TX_HOME/config"
      tx_apply_palette "$TX_THEME"
      _tx_say "${key} updated"
      ;;
    edit)
      local ed="${EDITOR:-}"
      [[ -z $ed ]] && { command -v nano >/dev/null 2>&1 && ed=nano || ed=vi; }
      "$ed" "$TX_HOME/config"
      if bash -n "$TX_HOME/config" 2>/dev/null; then
        . "$TX_HOME/config"
        tx_apply_palette "$TX_THEME"
        _tx_say "config reloaded"
      else
        _tx_err "syntax error in $TX_HOME/config — please fix it"
        return 1
      fi
      ;;
    reset)
      rm -f "$TX_HOME/config"
      _tx_config_init
      TX_THEME="matrix"; TX_PROMPT="hacker"; TX_RAIN="binary"; TX_BOOT=1; HV_QUICK=0; TX_AUTOUPDATE=1
      . "$TX_HOME/config"
      tx_apply_palette "$TX_THEME"
      _tx_say "config reset to defaults"
      ;;
    -h|--help|help)
      cat <<'EOF'
Usage: txconfig [show|get <KEY>|set <KEY> <VAL>|edit|reset]
EOF
      ;;
    *)
      _tx_err "unknown subcommand '$sub'. Try: txconfig show|set|get|edit|reset"
      return 1
      ;;
  esac
}

tx_help() {
  printf '\n%s=== THEAM-X v%s (%s | theme:%s | prompt:%s | rain:%s) ===%s\n\n' \
    "$TX_C2" "$(tx_local_ver)" "$TX_DEVICE" "$TX_THEME" "$TX_PROMPT" "$TX_RAIN" "$TX_CX"
  cat <<EOF
${TX_CA}Small AI Assistant (/ai)${TX_CX}
  /ai                         Setup wizard (first run) or interactive AI chat
  /ai <prompt>                Ask AI directly (also supports piped stdin)
  /ai -c <task>               Generate a shell command (asks before running)
  /ai config | status | test  Configure base_url / api_key / model / type / etcs
  /ai set <key> <value>       Set type, base_url, api_key, model, system, temp, max_tokens

${TX_CA}Theme & Visuals${TX_CX}
  txtheme [name|prompt|rain]  Switch colors, prompt style, rain, boot, banner, update
  txconfig [show|set|edit]    Manage ~/.sino/config safely
  sfetch [-q]                 System info (animated panel, or -q for quick CLI)
  hv                          Live system monitor (t:theme r:rain p:pause q:quit)
  hvboot                      Replay boot animation (press any key to skip)
  matrix                      Full-screen rain (t:theme r:rain +/-:speed)
  dev                         Developer card

${TX_CA}Network & Security${TX_CX}
  myip                        Local + Public IP & geo/ISP lookup
  ports                       Open listening TCP/UDP ports & processes
  netinfo                     Interfaces, gateway & DNS servers
  pingtest [host]             Latency test (default: 1.1.1.1, 8.8.8.8, github.com)
  dns <domain> [type]         DNS lookup (dig/host/nslookup/getent fallback)
  passgen [len] [count]       Cryptographic random password generator
  txssh [status|keys|addkey]  SSH status, active sessions & authorized_keys helper

${TX_CA}System, VPS & Termux${TX_CX}
  txcpu                       CPU model, cores, frequency, load & temp
  txmem                       RAM/Swap breakdown + top memory processes
  txtemp                      Thermal zones & hardware sensors
  txlog [sys|auth|kernel|svc] View system, SSH auth, kernel, or service logs
  diskinfo [path]             Clean filesystem usage + largest items in path
  proctop [n]                 Top CPU & RAM processes
  svc [cmd] [name]            Service manager (systemd / openrc / termux-services)
  sysup [-y]                  Update OS packages (apt/dnf/yum/apk/pacman/pkg)
  txclean [--all]             Clean package & temp caches (--all: ~/.cache/journal)
  txdiag                      Full VPS + Termux environment & health check
  txbattery                   Battery percentage, status & temp
  txstorage                   Termux shared storage setup / VPS mounts
  txwake [on|off]             Termux CPU wake-lock toggle

${TX_CA}Files & Helpers${TX_CX}
  extract <archive>           Extract tar.*, zip, gz, bz2, xz, 7z, rar
  mkcd <dir>                  Create directory and cd into it
  backup <file|dir>           Create timestamped .bak or .tar.gz backup
  serve [port] [dir]          Quick HTTP file server (default port 8080)

${TX_CA}Updates${TX_CX}
  txver | txupdate            Check version / update from GitHub
  txuninstall                 Remove Theam-X cleanly
EOF
  echo
}

tx_uninstall() {
  printf '%s[!]%s This will remove Theam-X (%s) and clean ~/.bashrc. Continue? [y/N] %s' "$TX_CY" "$TX_CX" "$TX_HOME" "$TX_CX"
  local ans=""
  read -r -n 1 ans </dev/tty 2>/dev/null || ans=""
  echo
  [[ "$ans" == y || "$ans" == Y ]] || { _tx_warn "cancelled"; return 0; }
  local rc="$HOME/.bashrc"
  [[ -f "$rc" ]] && sed -i '/\.sino\/theam-x\.sh/d;/^# Theam-X$/d' "$rc"
  rm -f "${XDG_RUNTIME_DIR:-${TMPDIR:-$HOME}}/.hv_boot_${UID:-0}" 2>/dev/null || true
  rm -rf "$TX_HOME"
  PROMPT_COMMAND="${PROMPT_COMMAND//hv_prompt;/}"
  PROMPT_COMMAND="${PROMPT_COMMAND//hv_prompt/}"
  PS1='\u@\h:\w\$ '
  _tx_say "Theam-X removed. Open a new shell if needed."
}

# ---------------------------------------------------------------------
#  USEFUL COMMANDS (VPS + Termux)
# ---------------------------------------------------------------------
tx_myip() {
  local lip="" lip6="" pip="" info=""
  lip=$(hv_ip)
  if command -v ip >/dev/null 2>&1; then
    lip6=$(ip -6 -o addr show scope global 2>/dev/null | awk '{split($4,a,"/"); print a[1]; exit}')
  fi
  printf '%sLocal IPv4 :%s %s\n' "$TX_CA" "$TX_CX" "$lip"
  [[ -n $lip6 ]] && printf '%sLocal IPv6 :%s %s\n' "$TX_CA" "$TX_CX" "$lip6"
  if info=$(TX_TIMEOUT=4 tx_get "https://ipinfo.io/json" 2>/dev/null) && [[ -n $info ]]; then
    local city country org
    pip=$(printf '%s' "$info" | awk -F'"' '/"ip":/{print $4; exit}')
    city=$(printf '%s' "$info" | awk -F'"' '/"city":/{print $4; exit}')
    country=$(printf '%s' "$info" | awk -F'"' '/"country":/{print $4; exit}')
    org=$(printf '%s' "$info" | awk -F'"' '/"org":/{print $4; exit}')
    printf '%sPublic IP  :%s %s\n' "$TX_CA" "$TX_CX" "${pip:-n/a}"
    [[ -n $city || -n $country ]] && printf '%sLocation   :%s %s%s%s\n' "$TX_CA" "$TX_CX" "$city" "${city:+, }" "$country"
    [[ -n $org ]] && printf '%sISP / Org  :%s %s\n' "$TX_CA" "$TX_CX" "$org"
  else
    pip=$(TX_TIMEOUT=4 tx_get "https://api.ipify.org" 2>/dev/null || true)
    printf '%sPublic IP  :%s %s\n' "$TX_CA" "$TX_CX" "${pip:-offline / unavailable}"
  fi
  return 0
}

_tx_proc_net_ports() {
  local proto f="$1" line laddr port st hexip ip1 ip2 ip3 ip4
  proto=$(basename "$f" | tr '[:lower:]' '[:upper:]')
  [[ -r "$f" ]] || return 1
  local first=1
  while read -r line; do
    if (( first )); then first=0; continue; fi
    read -r _ laddr _ st _ <<< "$line"
    # 0A = LISTEN for TCP; 07 = UNCONN/LISTEN for UDP
    if [[ $proto == TCP* && $st != "0A" ]]; then continue; fi
    hexip=${laddr%:*}
    port=$(( 16#${laddr#*:} ))
    if (( ${#hexip} == 8 )); then
      ip4=$(( 16#${hexip:0:2} )); ip3=$(( 16#${hexip:2:2} ))
      ip2=$(( 16#${hexip:4:2} )); ip1=$(( 16#${hexip:6:2} ))
      printf '%-6s %-22s LISTEN\n' "$proto" "${ip1}.${ip2}.${ip3}.${ip4}:${port}"
    else
      printf '%-6s [ipv6]:%-15d LISTEN\n' "$proto" "$port"
    fi
  done < "$f"
}

tx_ports() {
  printf '%s=== LISTENING PORTS ===%s\n' "$TX_C2" "$TX_CX"
  if command -v ss >/dev/null 2>&1; then
    ss -tulnp 2>/dev/null || ss -tuln 2>/dev/null || _tx_warn "ss failed (permission denied on this device)"
  elif command -v netstat >/dev/null 2>&1; then
    netstat -tulnp 2>/dev/null || netstat -tuln 2>/dev/null || _tx_warn "netstat failed"
  elif [[ -r /proc/net/tcp ]]; then
    printf '%-6s %-22s %s\n' "PROTO" "LOCAL ADDRESS" "STATE"
    _tx_proc_net_ports /proc/net/tcp
    _tx_proc_net_ports /proc/net/udp
  else
    _tx_warn "no ss/netstat and /proc/net/tcp is restricted on this device"
  fi
}

tx_netinfo() {
  printf '%s=== NETWORK INFO ===%s\n' "$TX_C2" "$TX_CX"
  if command -v ip >/dev/null 2>&1; then
    printf '%sInterfaces:%s\n' "$TX_CA" "$TX_CX"
    ip -br -4 addr 2>/dev/null || ip -4 -o addr show 2>/dev/null | awk '{print $2, $4}'
    local gw
    gw=$(ip -4 route show default 2>/dev/null | awk '{print $3 " via " $5; exit}')
    printf '%sGateway   :%s %s\n' "$TX_CA" "$TX_CX" "${gw:-n/a}"
  elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig 2>/dev/null | awk '/^[a-zA-Z0-9]/{iface=$1} /inet /{print iface, $2}'
  fi
  local dns_list=""
  if [[ -r /etc/resolv.conf ]]; then
    dns_list=$(awk '/^nameserver/{print $2}' /etc/resolv.conf 2>/dev/null | paste -sd ', ' -)
  fi
  if [[ -z $dns_list && $TX_DEVICE == termux ]]; then
    local d1 d2
    d1=$(getprop net.dns1 2>/dev/null || true)
    d2=$(getprop net.dns2 2>/dev/null || true)
    dns_list="${d1}${d2:+, $d2}"
  fi
  printf '%sDNS       :%s %s\n' "$TX_CA" "$TX_CX" "${dns_list:-n/a}"
  printf '%sLocal IP  :%s %s\n' "$TX_CA" "$TX_CX" "$(hv_ip)"
}

tx_pingtest() {
  command -v ping >/dev/null 2>&1 || { _tx_err "ping not installed"; return 1; }
  if [[ -n ${1:-} ]]; then
    ping -c 4 -W 2 "$1"
    return $?
  fi
  printf '%s=== CONNECTIVITY TEST ===%s\n' "$TX_C2" "$TX_CX"
  local h out avg
  for h in 1.1.1.1 8.8.8.8 github.com; do
    if out=$(ping -c 2 -W 2 "$h" 2>/dev/null); then
      avg=$(printf '%s\n' "$out" | awk -F'/' '/rtt|round-trip/{print $5 " ms"; exit}')
      printf '  %s[OK]%s   %-14s %s\n' "$TX_C2" "$TX_CX" "$h" "${avg:-reachable}"
    else
      printf '  %s[FAIL]%s %-14s unreachable\n' "$TX_CR" "$TX_CX" "$h"
    fi
  done
}

tx_dns() {
  local dom="${1:-}" qtype="${2:-A}"
  [[ -n $dom ]] || { _tx_err "usage: dns <domain> [A|AAAA|MX|TXT|NS]"; return 1; }
  printf '%sDNS %s (%s):%s\n' "$TX_CA" "$dom" "$qtype" "$TX_CX"
  if command -v dig >/dev/null 2>&1; then
    dig +short "$dom" "$qtype"
  elif command -v host >/dev/null 2>&1; then
    host -t "$qtype" "$dom"
  elif command -v nslookup >/dev/null 2>&1; then
    nslookup -type="$qtype" "$dom"
  elif command -v getent >/dev/null 2>&1; then
    getent ahosts "$dom" | awk '{print $1}' | sort -u
  else
    _tx_err "no DNS lookup tool found (install dnsutils or bind-tools)"
    return 1
  fi
}

tx_passgen() {
  local len="${1:-16}" cnt="${2:-1}"
  if ! _tx_is_int "$len" || (( len < 4 || len > 128 )); then
    _tx_err "length must be 4..128 (usage: passgen [len] [count])"; return 1
  fi
  if ! _tx_is_int "$cnt" || (( cnt < 1 || cnt > 20 )); then
    _tx_err "count must be 1..20 (usage: passgen [len] [count])"; return 1
  fi
  local i pw
  local charset='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*_-'
  for ((i=0; i<cnt; i++)); do
    if [[ -r /dev/urandom ]]; then
      pw=$(LC_ALL=C tr -dc "$charset" </dev/urandom 2>/dev/null | head -c "$len" 2>/dev/null || true)
    fi
    while (( ${#pw} < len )); do
      pw+="${charset:(( RANDOM % ${#charset} )):1}"
    done
    printf '%s\n' "${pw:0:$len}"
    pw=""
  done
}

tx_diskinfo() {
  local target="${1:-.}"
  printf '%s=== FILESYSTEMS ===%s\n' "$TX_C2" "$TX_CX"
  df -hP 2>/dev/null | awk 'NR==1 || $1 !~ /^(tmpfs|devtmpfs|udev|none|overlay|squashfs|shm)$/'
  if [[ -e "$target" ]]; then
    printf '\n%s=== LARGEST IN %s ===%s\n' "$TX_C2" "$target" "$TX_CX"
    du -sh "$target"/* "$target"/.[!.]* 2>/dev/null | sort -hr 2>/dev/null | head -n 10
  fi
}

tx_proctop() {
  local n="${1:-10}"
  _tx_is_int "$n" && (( n > 0 && n <= 50 )) || n=10
  printf '%s=== TOP %d PROCESSES ===%s\n' "$TX_C2" "$n" "$TX_CX"
  if ps aux --sort=-%cpu >/dev/null 2>&1; then
    ps aux --sort=-%cpu | head -n $(( n + 1 ))
  elif ps -eo pid,user,%cpu,%mem,comm >/dev/null 2>&1; then
    ps -eo pid,user,%cpu,%mem,comm | head -n $(( n + 1 ))
  else
    ps 2>/dev/null | head -n $(( n + 1 ))
  fi
}

tx_svc() {
  local action="${1:-}" name="${2:-}"
  local SUDO=""
  if [[ $TX_DEVICE != termux && $EUID -ne 0 ]] && command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  fi

  if command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
    if [[ -z $action || $action == list ]]; then
      printf '%s=== SYSTEMD SERVICES ===%s\n' "$TX_C2" "$TX_CX"
      local s st
      for s in "${HV_SERVICES[@]}"; do
        st=$(systemctl is-active "$s" 2>/dev/null || true)
        [[ $st != active && $s == ssh ]] && st=$(systemctl is-active sshd 2>/dev/null || true)
        if [[ $st == active ]]; then
          printf '  %s[●]%s %-16s %s\n' "$TX_C2" "$TX_CX" "$s" "$st"
        else
          printf '  %s[●]%s %-16s %s\n' "$TX_CR" "$TX_CX" "$s" "${st:-inactive}"
        fi
      done
      local failed
      failed=$(systemctl --failed --no-legend 2>/dev/null | wc -l | tr -d ' ')
      printf '\n%sFailed units:%s %s\n' "$TX_CA" "$TX_CX" "$failed"
      return 0
    fi
    [[ -n $name ]] || { _tx_err "usage: svc <status|start|stop|restart|enable|disable|logs> <service>"; return 1; }
    case "$action" in
      status)  systemctl status "$name" --no-pager ;;
      logs)    journalctl -u "$name" -n 40 --no-pager ;;
      start|stop|restart|reload|enable|disable)
        $SUDO systemctl "$action" "$name" && _tx_say "${name}: ${action} ok" ;;
      *) _tx_err "unknown svc action '$action'"; return 1 ;;
    esac
  elif command -v rc-service >/dev/null 2>&1; then
    if [[ -z $action || $action == list ]]; then
      rc-status
    else
      [[ -n $name ]] || { _tx_err "usage: svc <status|start|stop|restart> <service>"; return 1; }
      $SUDO rc-service "$name" "$action"
    fi
  elif command -v sv >/dev/null 2>&1 && [[ -d "${PREFIX:-}/var/service" ]]; then
    if [[ -z $action || $action == list ]]; then
      sv status "$PREFIX"/var/service/* 2>/dev/null || _tx_warn "no termux-services enabled"
    else
      [[ -n $name ]] || { _tx_err "usage: svc <status|up|down|restart> <service>"; return 1; }
      sv "$action" "$name"
    fi
  else
    _tx_warn "no init/service manager detected on ${TX_DEVICE}; showing user processes:"
    tx_proctop 8
  fi
}

tx_sysup() {
  local yes=0
  [[ "${1:-}" == "-y" || "${1:-}" == "--yes" ]] && yes=1
  if (( ! yes )); then
    printf '%s[*]%s Update all system packages on %s? [y/N] %s' "$TX_CY" "$TX_CX" "$TX_DEVICE" "$TX_CX"
    local ans=""
    read -r -n 1 ans </dev/tty 2>/dev/null || ans=""
    echo
    [[ "$ans" == y || "$ans" == Y ]] || { _tx_warn "cancelled"; return 0; }
  fi
  local SUDO=""
  if [[ $TX_DEVICE != termux && $EUID -ne 0 ]] && command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  fi
  if [[ $TX_DEVICE == termux ]] && command -v pkg >/dev/null 2>&1; then
    pkg update -y && pkg upgrade -y
  elif command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update && $SUDO apt-get upgrade -y
  elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf upgrade -y
  elif command -v yum >/dev/null 2>&1; then
    $SUDO yum update -y
  elif command -v apk >/dev/null 2>&1; then
    $SUDO apk update && $SUDO apk upgrade
  elif command -v pacman >/dev/null 2>&1; then
    $SUDO pacman -Syu --noconfirm
  else
    _tx_err "no supported package manager found"
    return 1
  fi
}

tx_clean() {
  local all=0
  [[ "${1:-}" == "--all" || "${1:-}" == "-a" ]] && all=1
  local SUDO=""
  if [[ $TX_DEVICE != termux && $EUID -ne 0 ]] && command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  fi
  printf '%s[*]%s cleaning temporary & package caches...\n' "$TX_CY" "$TX_CX"
  rm -rf "$TX_HOME"/.tmp.* 2>/dev/null || true
  if [[ $TX_DEVICE == termux ]]; then
    command -v pkg >/dev/null 2>&1 && pkg clean 2>/dev/null || true
    command -v apt-get >/dev/null 2>&1 && apt-get clean 2>/dev/null || true
  elif command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get autoremove -y 2>/dev/null || true
    $SUDO apt-get clean 2>/dev/null || true
  elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf clean all 2>/dev/null || true
  elif command -v apk >/dev/null 2>&1; then
    $SUDO apk cache clean 2>/dev/null || true
  elif command -v pacman >/dev/null 2>&1; then
    $SUDO pacman -Sc --noconfirm 2>/dev/null || true
  fi
  if (( all )); then
    if [[ -d "$HOME/.cache" ]]; then
      rm -rf "$HOME/.cache"/* 2>/dev/null || true
      _tx_say "cleared ~/.cache"
    fi
    if command -v journalctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
      $SUDO journalctl --vacuum-time=7d 2>/dev/null || true
    fi
  fi
  _tx_say "cleanup finished"
  df -hP "$HV_DISK_PATH" 2>/dev/null | tail -n 2
}

tx_extract() {
  local f="${1:-}"
  [[ -n $f ]] || { _tx_err "usage: extract <archive>"; return 1; }
  [[ -f $f ]] || { _tx_err "file not found: $f"; return 1; }
  case "$f" in
    *.tar.bz2|*.tbz2) tar -xjf "$f" ;;
    *.tar.gz|*.tgz)   tar -xzf "$f" ;;
    *.tar.xz|*.txz)   tar -xJf "$f" ;;
    *.tar.zst)        tar --zstd -xf "$f" ;;
    *.tar)            tar -xf "$f" ;;
    *.bz2)            bunzip2 "$f" ;;
    *.gz)             gunzip "$f" ;;
    *.xz)             unxz "$f" ;;
    *.zip)            command -v unzip >/dev/null 2>&1 && unzip "$f" || { _tx_err "unzip not installed"; return 1; } ;;
    *.7z)             command -v 7z >/dev/null 2>&1 && 7z x "$f" || { _tx_err "7z not installed"; return 1; } ;;
    *.rar)            command -v unrar >/dev/null 2>&1 && unrar x "$f" || { _tx_err "unrar not installed"; return 1; } ;;
    *)                _tx_err "unsupported archive format: $f"; return 1 ;;
  esac
}

tx_mkcd() {
  [[ -n ${1:-} ]] || { _tx_err "usage: mkcd <directory>"; return 1; }
  mkdir -p -- "$1" && cd -- "$1"
}

tx_backup() {
  local src="${1:-}"
  [[ -n $src ]] || { _tx_err "usage: backup <file|dir>"; return 1; }
  [[ -e $src ]] || { _tx_err "not found: $src"; return 1; }
  src="${src%/}"
  local ts
  ts=$(date '+%Y%m%d_%H%M%S')
  if [[ -d $src ]]; then
    local out="${src}_${ts}.tar.gz"
    tar -czf "$out" "$src" && _tx_say "backup created: $out ($(du -sh "$out" 2>/dev/null | awk '{print $1}'))"
  else
    local out="${src}.bak.${ts}"
    cp -p -- "$src" "$out" && _tx_say "backup created: $out"
  fi
}

tx_serve() {
  local port="${1:-8080}" dir="${2:-.}"
  if ! _tx_is_int "$port" || (( port < 1 || port > 65535 )); then
    _tx_err "invalid port '$port' (usage: serve [port] [dir])"; return 1
  fi
  [[ -d $dir ]] || { _tx_err "directory not found: $dir"; return 1; }
  local lip
  lip=$(hv_ip)
  _tx_say "serving ${dir} on http://127.0.0.1:${port}  (LAN: http://${lip}:${port})  Ctrl+C to stop"
  if command -v python3 >/dev/null 2>&1; then
    python3 -m http.server "$port" --directory "$dir"
  elif command -v python >/dev/null 2>&1; then
    ( cd "$dir" && python -m SimpleHTTPServer "$port" )
  elif command -v php >/dev/null 2>&1; then
    php -S "0.0.0.0:${port}" -t "$dir"
  elif command -v busybox >/dev/null 2>&1; then
    busybox httpd -f -p "$port" -h "$dir"
  else
    _tx_err "need python3, php, or busybox httpd to serve files"
    return 1
  fi
}

tx_battery() {
  if command -v termux-battery-status >/dev/null 2>&1; then
    local json pct st temp
    if json=$(termux-battery-status 2>/dev/null) && [[ -n $json ]]; then
      pct=$(printf '%s' "$json" | awk -F'[:, ]+' '/"percentage"/{print $3; exit}')
      st=$(printf '%s' "$json" | awk -F'"' '/"status"/{print $4; exit}')
      temp=$(printf '%s' "$json" | awk -F'[:, ]+' '/"temperature"/{print $3; exit}')
      printf '%sBattery :%s %s%% (%s)%s\n' "$TX_CA" "$TX_CX" "${pct:-?}" "${st:-?}" "${temp:+ | ${temp}C}"
      return 0
    fi
  fi
  local sys
  if sys=$(hv_battery_sysfs); then
    printf '%sBattery :%s %s\n' "$TX_CA" "$TX_CX" "$sys"
  else
    _tx_say "No battery detected (AC / VPS environment)"
  fi
}

tx_storage() {
  if [[ $TX_DEVICE == termux ]]; then
    if [[ -d "$HOME/storage" ]]; then
      _tx_say "Termux storage is linked at ~/storage:"
      ls -la "$HOME/storage"
    else
      _tx_warn "~/storage not set up yet."
      if command -v termux-setup-storage >/dev/null 2>&1; then
        printf '%s[*]%s Run termux-setup-storage now? [y/N] %s' "$TX_CY" "$TX_CX" "$TX_CX"
        local ans=""
        read -r -n 1 ans </dev/tty 2>/dev/null || ans=""
        echo
        [[ "$ans" == y || "$ans" == Y ]] && termux-setup-storage
      else
        _tx_warn "Run: termux-setup-storage"
      fi
    fi
  else
    df -hT -x tmpfs -x devtmpfs 2>/dev/null || df -hP
  fi
}

tx_wake() {
  if [[ $TX_DEVICE != termux ]]; then
    _tx_warn "txwake is for Termux (Android) wake-lock control."
    return 0
  fi
  case "${1:-on}" in
    on|lock)
      command -v termux-wake-lock >/dev/null 2>&1 || { _tx_err "termux-wake-lock not found"; return 1; }
      termux-wake-lock && _tx_say "Termux wake-lock ENABLED"
      ;;
    off|unlock)
      command -v termux-wake-unlock >/dev/null 2>&1 || { _tx_err "termux-wake-unlock not found"; return 1; }
      termux-wake-unlock && _tx_say "Termux wake-lock RELEASED"
      ;;
    *)
      _tx_err "usage: txwake <on|off>"; return 1 ;;
  esac
}

tx_diag() {
  local ok="${TX_C2}[OK]${TX_CX}" wn="${TX_CY}[WARN]${TX_CX}" ms="${TX_CR}[MISS]${TX_CX}"
  printf '\n%s=== THEAM-X DIAGNOSTICS ===%s\n' "$TX_C2" "$TX_CX"
  printf '  %b bash %s (%s)\n' "$ok" "$BASH_VERSION" "$TX_DEVICE"
  if [[ -f "$TX_HOME/config" ]] && bash -n "$TX_HOME/config" 2>/dev/null; then
    printf '  %b config %s/config (theme=%s prompt=%s rain=%s)\n' "$ok" "$TX_HOME" "$TX_THEME" "$TX_PROMPT" "$TX_RAIN"
  else
    printf '  %b config missing or invalid (%s/config)\n' "$wn" "$TX_HOME"
  fi
  local cmd
  for cmd in curl wget git python3 tar unzip; do
    if command -v "$cmd" >/dev/null 2>&1; then
      printf '  %b %s\n' "$ok" "$cmd"
    else
      printf '  %b %s (optional)\n' "$ms" "$cmd"
    fi
  done
  if [[ -r /proc/stat ]]; then printf '  %b /proc/stat readable\n' "$ok"
  else printf '  %b /proc/stat restricted (normal on Android 10+)\n' "$wn"; fi
  if [[ -r /proc/meminfo ]]; then printf '  %b /proc/meminfo readable\n' "$ok"
  else printf '  %b /proc/meminfo unreadable\n' "$wn"; fi
  if [[ $TX_DEVICE == termux ]]; then
    if [[ -d "$HOME/storage" ]]; then printf '  %b Termux ~/storage linked\n' "$ok"
    else printf '  %b Termux ~/storage not linked (run: txstorage)\n' "$wn"; fi
    if command -v termux-battery-status >/dev/null 2>&1; then printf '  %b termux-api available\n' "$ok"
    else printf '  %b termux-api missing (optional: pkg install termux-api)\n' "$wn"; fi
  else
    if command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
      printf '  %b systemd active\n' "$ok"
    else
      printf '  %b systemd not running (container/openrc)\n' "$wn"
    fi
  fi
  hv_size
  if (( COLS >= 50 && ROWS >= 14 )); then
    printf '  %b terminal size %dx%d (>= 50x14)\n' "$ok" "$COLS" "$ROWS"
  else
    printf '  %b terminal size %dx%d (too small for panels, need 50x14)\n' "$wn" "$COLS" "$ROWS"
  fi
  if [[ -f "$TX_HOME/ai.conf" ]]; then
    printf '  %b /ai config present (%s)\n' "$ok" "$TX_HOME/ai.conf"
  else
    printf '  %b /ai not configured yet (run: /ai config)\n' "$wn"
  fi
  echo
}

tx_cpu() {
  hv_stats_static
  hv_stats_fast
  local temp_str
  temp_str=$(hv_temp_sysfs 2>/dev/null || echo "n/a")
  local freq="n/a" cur_khz=""
  if [[ -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]]; then
    read -r cur_khz < /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || cur_khz=""
    _tx_is_int "$cur_khz" && freq="$(( cur_khz / 1000 )) MHz"
  elif [[ -r /proc/cpuinfo ]]; then
    local mhz
    mhz=$(awk -F: '/^cpu MHz/{gsub(/ /,"",$2); printf "%.0f", $2; exit}' /proc/cpuinfo 2>/dev/null || true)
    [[ -n $mhz ]] && freq="${mhz} MHz"
  fi
  printf '%s=== CPU INFO ===%s\n' "$TX_C2" "$TX_CX"
  printf '%sModel  :%s %s\n' "$TX_CA" "$TX_CX" "$CPUMODEL"
  printf '%sArch   :%s %s (%s core(s))\n' "$TX_CA" "$TX_CX" "$(uname -m 2>/dev/null || echo unknown)" "$NCPU"
  printf '%sFreq   :%s %s\n' "$TX_CA" "$TX_CX" "$freq"
  printf '%sLoad   :%s %s  %s  %s\n' "$TX_CA" "$TX_CX" "$L1" "$L2" "$L3"
  printf '%sTemp   :%s %s\n' "$TX_CA" "$TX_CX" "$temp_str"
}

tx_mem() {
  printf '%s=== MEMORY & SWAP ===%s\n' "$TX_C2" "$TX_CX"
  if [[ -r /proc/meminfo ]]; then
    local k v mt=0 ma=0 mf=0 mb=0 mc=0 st=0 sf=0
    while read -r k v _; do
      _tx_is_int "$v" || continue
      case $k in
        MemTotal:)     mt=$v ;;
        MemAvailable:) ma=$v ;;
        MemFree:)      mf=$v ;;
        Buffers:)      mb=$v ;;
        Cached:)       mc=$v ;;
        SwapTotal:)    st=$v ;;
        SwapFree:)     sf=$v ;;
      esac
    done < /proc/meminfo
    (( ma == 0 && mf > 0 )) && ma=$(( mf + mb + mc ))
    local used=$(( mt - ma ))
    (( used < 0 )) && used=0
    local pct=0
    (( mt > 0 )) && pct=$(( 100 * used / mt ))
    printf '%sRAM Total :%s %d MB\n' "$TX_CA" "$TX_CX" $(( mt / 1024 ))
    printf '%sRAM Used  :%s %d MB (%d%%)\n' "$TX_CA" "$TX_CX" $(( used / 1024 )) "$pct"
    printf '%sRAM Avail :%s %d MB  (Free: %d MB | Buf/Cache: %d MB)\n' \
      "$TX_CA" "$TX_CX" $(( ma / 1024 )) $(( mf / 1024 )) $(( (mb + mc) / 1024 ))
    if (( st > 0 )); then
      printf '%sSwap      :%s %d / %d MB used\n' "$TX_CA" "$TX_CX" $(( (st - sf) / 1024 )) $(( st / 1024 ))
    else
      printf '%sSwap      :%s disabled\n' "$TX_CA" "$TX_CX"
    fi
  else
    _tx_warn "/proc/meminfo unreadable"
  fi
  echo
  printf '%sTop RAM Processes:%s\n' "$TX_CA" "$TX_CX"
  if ps aux --sort=-%mem >/dev/null 2>&1; then
    ps aux --sort=-%mem | head -n 6
  elif ps -eo pid,user,%mem,%cpu,comm >/dev/null 2>&1; then
    ps -eo pid,user,%mem,%cpu,comm | head -n 6
  fi
}

tx_temp() {
  printf '%s=== THERMAL SENSORS ===%s\n' "$TX_C2" "$TX_CX"
  local found=0 deg_u="C"
  _tx_is_utf8 && deg_u="°C"
  if command -v sensors >/dev/null 2>&1; then
    sensors 2>/dev/null && found=1 || true
  fi
  local d ztype raw val
  for d in /sys/class/thermal/thermal_zone*; do
    [[ -r "$d/temp" ]] || continue
    read -r raw < "$d/temp" 2>/dev/null || continue
    _tx_is_int "${raw#-}" || continue
    [[ -r "$d/type" ]] && read -r ztype < "$d/type" 2>/dev/null || ztype="${d##*/}"
    if (( raw > 1000 )); then val="$(( raw / 1000 )).$(( (raw % 1000) / 100 ))"; else val="$raw"; fi
    printf '  %-20s %s%s\n' "${ztype:0:20}" "$val" "$deg_u"
    found=1
  done
  if (( ! found )); then
    _tx_warn "no thermal sensors exposed on this ${TX_DEVICE}"
  fi
}

tx_log() {
  local mode="${1:-sys}" svcname="${2:-}"
  local SUDO=""
  if [[ $TX_DEVICE != termux && $EUID -ne 0 ]] && command -v sudo >/dev/null 2>&1; then SUDO="sudo"; fi
  case "$mode" in
    -h|--help|help)
      echo "Usage: txlog [sys|auth|kernel|svc <name>]"
      return 0
      ;;
    sys)
      if command -v journalctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
        $SUDO journalctl -n 40 --no-pager
      elif [[ -r /var/log/syslog ]]; then
        tail -n 40 /var/log/syslog
      elif [[ -r /var/log/messages ]]; then
        tail -n 40 /var/log/messages
      elif command -v logcat >/dev/null 2>&1; then
        logcat -d -t 40
      else
        _tx_warn "no readable system log found"
      fi
      ;;
    auth)
      if command -v journalctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
        $SUDO journalctl -u ssh -u sshd -n 40 --no-pager
      elif [[ -r /var/log/auth.log ]]; then
        $SUDO tail -n 40 /var/log/auth.log
      elif [[ -r /var/log/secure ]]; then
        $SUDO tail -n 40 /var/log/secure
      else
        _tx_warn "no readable SSH/auth log found"
      fi
      ;;
    kernel|dmesg)
      $SUDO dmesg -T 2>/dev/null | tail -n 40 || $SUDO dmesg 2>/dev/null | tail -n 40 || _tx_warn "dmesg unavailable"
      ;;
    svc)
      [[ -n $svcname ]] || { _tx_err "usage: txlog svc <service>"; return 1; }
      if command -v journalctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
        $SUDO journalctl -u "$svcname" -n 40 --no-pager
      else
        _tx_warn "journalctl unavailable"
      fi
      ;;
    *)
      tx_log svc "$mode"
      ;;
  esac
}

tx_ssh() {
  local sub="${1:-status}"
  case "$sub" in
    -h|--help|help)
      echo "Usage: txssh [status|keys|addkey <pubkey>]"
      return 0
      ;;
    status|"")
      printf '%s=== SSH STATUS ===%s\n' "$TX_C2" "$TX_CX"
      if command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
        local st
        st=$(systemctl is-active ssh 2>/dev/null || systemctl is-active sshd 2>/dev/null || echo "inactive")
        printf '%sService  :%s %s\n' "$TX_CA" "$TX_CX" "$st"
      elif pgrep -x sshd >/dev/null 2>&1; then
        printf '%sService  :%s running (sshd)\n' "$TX_CA" "$TX_CX"
      else
        printf '%sService  :%s not running\n' "$TX_CA" "$TX_CX"
      fi
      local port="22"
      if [[ -r /etc/ssh/sshd_config ]]; then
        local p
        p=$(awk '/^[[:space:]]*Port[[:space:]]+/{print $2; exit}' /etc/ssh/sshd_config 2>/dev/null || true)
        [[ -n $p ]] && port="$p"
      fi
      printf '%sPort     :%s %s\n' "$TX_CA" "$TX_CX" "$port"
      local kcnt=0
      [[ -f "$HOME/.ssh/authorized_keys" ]] && kcnt=$(grep -cve '^[[:space:]]*$' -e '^[[:space:]]*#' "$HOME/.ssh/authorized_keys" 2>/dev/null || echo 0)
      printf '%sAuthKeys :%s %s key(s) in ~/.ssh/authorized_keys\n' "$TX_CA" "$TX_CX" "$kcnt"
      printf '%sSessions :%s\n' "$TX_CA" "$TX_CX"
      who 2>/dev/null || true
      ;;
    keys)
      if [[ ! -s "$HOME/.ssh/authorized_keys" ]]; then
        _tx_warn "no keys in ~/.ssh/authorized_keys"
        return 0
      fi
      if command -v ssh-keygen >/dev/null 2>&1; then
        ssh-keygen -lf "$HOME/.ssh/authorized_keys" 2>/dev/null || cat "$HOME/.ssh/authorized_keys"
      else
        cat "$HOME/.ssh/authorized_keys"
      fi
      ;;
    addkey)
      shift
      local key="$*"
      [[ -n $key ]] || { _tx_err "usage: txssh addkey \"ssh-ed25519 AAAA...\""; return 1; }
      [[ "$key" == ssh-* || "$key" == ecdsa-* ]] || { _tx_err "invalid SSH public key format"; return 1; }
      mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
      touch "$HOME/.ssh/authorized_keys" && chmod 600 "$HOME/.ssh/authorized_keys"
      if grep -qxF "$key" "$HOME/.ssh/authorized_keys" 2>/dev/null; then
        _tx_warn "key already present in ~/.ssh/authorized_keys"
        return 0
      fi
      printf '%s\n' "$key" >> "$HOME/.ssh/authorized_keys"
      _tx_say "added key to ~/.ssh/authorized_keys"
      ;;
    *)
      _tx_err "usage: txssh [status|keys|addkey <pubkey>]"
      return 1
      ;;
  esac
}

# =====================================================================
#  SMALL AI ASSISTANT (/ai | ai | txai)
# =====================================================================
TX_AI_TYPES=(openai gemini anthropic ollama)

_tx_ai_default_url() {
  case "$1" in
    openai)    printf 'https://api.openai.com/v1' ;;
    gemini)    printf 'https://generativelanguage.googleapis.com/v1beta' ;;
    anthropic) printf 'https://api.anthropic.com/v1' ;;
    ollama)    printf 'http://127.0.0.1:11434' ;;
    *)         printf 'https://api.openai.com/v1' ;;
  esac
}

_tx_ai_default_model() {
  case "$1" in
    openai)    printf 'gpt-4o-mini' ;;
    gemini)    printf 'gemini-2.5-flash' ;;
    anthropic) printf 'claude-3-5-haiku-latest' ;;
    ollama)    printf 'llama3.2' ;;
    *)         printf 'gpt-4o-mini' ;;
  esac
}

_tx_ai_load() {
  TX_AI_TYPE=""
  TX_AI_BASE_URL=""
  TX_AI_API_KEY=""
  TX_AI_MODEL=""
  TX_AI_SYSTEM="You are a concise, accurate Linux VPS and Termux terminal assistant."
  TX_AI_TEMP="0.7"
  TX_AI_MAX_TOKENS="1024"
  TX_AI_TIMEOUT="45"
  [[ -f "$TX_HOME/ai.conf" ]] && . "$TX_HOME/ai.conf"
  TX_AI_BASE_URL="${TX_AI_BASE_URL%/}"
}

_tx_ai_save() {
  mkdir -p "$TX_HOME" || return 1
  local tmp="$TX_HOME/.aicfg.$$"
  local q_type q_url q_key q_model q_sys q_temp q_tok q_to
  printf -v q_type  '%q' "$TX_AI_TYPE"
  printf -v q_url   '%q' "${TX_AI_BASE_URL%/}"
  printf -v q_key   '%q' "$TX_AI_API_KEY"
  printf -v q_model '%q' "$TX_AI_MODEL"
  printf -v q_sys   '%q' "$TX_AI_SYSTEM"
  printf -v q_temp  '%q' "$TX_AI_TEMP"
  printf -v q_tok   '%q' "$TX_AI_MAX_TOKENS"
  printf -v q_to    '%q' "$TX_AI_TIMEOUT"
  (
    umask 077
    {
      echo "# Theam-X AI config (chmod 600 — keep private)"
      echo "TX_AI_TYPE=$q_type"
      echo "TX_AI_BASE_URL=$q_url"
      echo "TX_AI_API_KEY=$q_key"
      echo "TX_AI_MODEL=$q_model"
      echo "TX_AI_SYSTEM=$q_sys"
      echo "TX_AI_TEMP=$q_temp"
      echo "TX_AI_MAX_TOKENS=$q_tok"
      echo "TX_AI_TIMEOUT=$q_to"
    } > "$tmp"
  ) && chmod 600 "$tmp" && mv -f "$tmp" "$TX_HOME/ai.conf" && chmod 600 "$TX_HOME/ai.conf"
}

_tx_ai_is_configured() {
  _tx_in_list "${TX_AI_TYPE:-}" "${TX_AI_TYPES[@]}" || return 1
  [[ -n ${TX_AI_BASE_URL:-} && -n ${TX_AI_MODEL:-} ]] || return 1
  if [[ "$TX_AI_TYPE" != "ollama" && -z ${TX_AI_API_KEY:-} ]]; then
    return 1
  fi
  return 0
}

_tx_ai_mask_key() {
  local k="$1" n=${#1}
  if (( n == 0 )); then printf '(none)'
  elif (( n <= 8 )); then printf '****'
  else printf '%s****%s' "${k:0:4}" "${k:n-4:4}"; fi
}

_tx_ai_status() {
  _tx_ai_load
  printf '\n%s=== /ai CONFIGURATION ===%s\n' "$TX_C2" "$TX_CX"
  if [[ ! -f "$TX_HOME/ai.conf" ]]; then
    _tx_warn "Not configured yet. Run: /ai config"
    return 1
  fi
  printf '%sType       :%s %s\n' "$TX_CA" "$TX_CX" "${TX_AI_TYPE:-unset}"
  printf '%sBase URL   :%s %s\n' "$TX_CA" "$TX_CX" "${TX_AI_BASE_URL:-unset}"
  printf '%sAPI Key    :%s %s\n' "$TX_CA" "$TX_CX" "$(_tx_ai_mask_key "${TX_AI_API_KEY:-}")"
  printf '%sModel      :%s %s\n' "$TX_CA" "$TX_CX" "${TX_AI_MODEL:-unset}"
  printf '%sTemp       :%s %s\n' "$TX_CA" "$TX_CX" "${TX_AI_TEMP:-0.7}"
  printf '%sMax Tokens :%s %s\n' "$TX_CA" "$TX_CX" "${TX_AI_MAX_TOKENS:-1024}"
  printf '%sTimeout    :%s %ss\n' "$TX_CA" "$TX_CX" "${TX_AI_TIMEOUT:-45}"
  printf '%sSystem     :%s %s\n' "$TX_CA" "$TX_CX" "${TX_AI_SYSTEM:-}"
  printf '%sFile       :%s %s\n\n' "$TX_CA" "$TX_CX" "$TX_HOME/ai.conf"
}

_tx_ai_wizard() {
  _tx_ai_load
  [[ -t 0 && -t 1 ]] || {
    _tx_err "/ai is not configured. Configure with:"
    echo "  /ai set type openai|gemini|anthropic|ollama"
    echo "  /ai set base_url <url>"
    echo "  /ai set api_key <key>"
    echo "  /ai set model <model>"
    return 1
  }

  printf '\n%s=== /ai SETUP WIZARD ===%s\n' "$TX_C2" "$TX_CX"
  echo "  [1] openai    (OpenAI, Groq, OpenRouter, DeepSeek, Together, vLLM)"
  echo "  [2] gemini    (Google Gemini REST API)"
  echo "  [3] anthropic (Anthropic Claude API)"
  echo "  [4] ollama    (Local Ollama server)"

  local cur_type="${TX_AI_TYPE:-openai}" ans=""
  printf '%sProvider type [%s]: %s' "$TX_CY" "$cur_type" "$TX_CX"
  read -r ans </dev/tty
  ans="${ans:-$cur_type}"
  case "$ans" in
    1) ans="openai" ;;
    2) ans="gemini" ;;
    3) ans="anthropic" ;;
    4) ans="ollama" ;;
  esac
  _tx_in_list "$ans" "${TX_AI_TYPES[@]}" || { _tx_err "invalid type '$ans'"; return 1; }
  local prev_type="$TX_AI_TYPE"
  TX_AI_TYPE="$ans"

  local def_url def_model
  if [[ -n ${TX_AI_BASE_URL:-} && "$prev_type" == "$TX_AI_TYPE" ]]; then
    def_url="$TX_AI_BASE_URL"
  else
    def_url=$(_tx_ai_default_url "$TX_AI_TYPE")
  fi
  printf '%sBase URL [%s]: %s' "$TX_CY" "$def_url" "$TX_CX"
  read -r ans </dev/tty
  TX_AI_BASE_URL="${ans:-$def_url}"
  TX_AI_BASE_URL="${TX_AI_BASE_URL%/}"

  local key_hint="required"
  [[ "$TX_AI_TYPE" == "ollama" ]] && key_hint="optional for ollama"
  [[ -n ${TX_AI_API_KEY:-} ]] && key_hint="keep $(_tx_ai_mask_key "$TX_AI_API_KEY")"
  printf '%sAPI Key (%s): %s' "$TX_CY" "$key_hint" "$TX_CX"
  read -rs ans </dev/tty
  echo
  if [[ -n $ans ]]; then
    TX_AI_API_KEY="$ans"
  elif [[ "$TX_AI_TYPE" != "ollama" && -z ${TX_AI_API_KEY:-} ]]; then
    _tx_err "API key is required for ${TX_AI_TYPE}"
    return 1
  fi

  if [[ -n ${TX_AI_MODEL:-} && "$prev_type" == "$TX_AI_TYPE" ]]; then
    def_model="$TX_AI_MODEL"
  else
    def_model=$(_tx_ai_default_model "$TX_AI_TYPE")
  fi
  printf '%sModel [%s]: %s' "$TX_CY" "$def_model" "$TX_CX"
  read -r ans </dev/tty
  TX_AI_MODEL="${ans:-$def_model}"

  printf '%sTemperature [%s]: %s' "$TX_CY" "$TX_AI_TEMP" "$TX_CX"
  read -r ans </dev/tty
  [[ -n $ans ]] && TX_AI_TEMP="$ans"

  printf '%sMax tokens [%s]: %s' "$TX_CY" "$TX_AI_MAX_TOKENS" "$TX_CX"
  read -r ans </dev/tty
  [[ -n $ans ]] && TX_AI_MAX_TOKENS="$ans"

  printf '%sSystem prompt [Enter = default]: %s' "$TX_CY" "$TX_CX"
  read -r ans </dev/tty
  [[ -n $ans ]] && TX_AI_SYSTEM="$ans"

  _tx_ai_save || { _tx_err "failed to save $TX_HOME/ai.conf"; return 1; }
  _tx_say "saved AI config to $TX_HOME/ai.conf (mode 600)"

  printf '%sTest connection now? [Y/n] %s' "$TX_CY" "$TX_CX"
  read -r -n 1 ans </dev/tty 2>/dev/null || ans="n"
  echo
  if [[ "$ans" != n && "$ans" != N ]]; then
    _tx_ai_test
  fi
  return 0
}

_tx_json_escape() {
  # Reads raw string from stdin, prints JSON-escaped content (without outer quotes)
  awk '
    BEGIN { ORS=""; first_line=1 }
    {
      if (!first_line) printf "\\n"
      first_line=0
      n=length($0)
      for (i=1; i<=n; i++) {
        c=substr($0, i, 1)
        if      (c == "\\") printf "\\\\"
        else if (c == "\"") printf "\\\""
        else if (c == "\r") printf "\\r"
        else if (c == "\t") printf "\\t"
        else if (c == "\b") printf "\\b"
        else if (c == "\f") printf "\\f"
        else printf "%s", c
      }
    }
  '
}

_tx_ai_parse_reply() {
  local ptype="$1" resp_file="$2"
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$ptype" "$resp_file" <<'PY'
import json, sys
ptype, path = sys.argv[1], sys.argv[2]
with open(path, "r", encoding="utf-8", errors="replace") as f:
    raw = f.read()
try:
    data = json.loads(raw)
except Exception:
    print("ERROR: invalid JSON response:\n" + raw[:400])
    sys.exit(2)

if isinstance(data, dict) and "error" in data:
    err = data["error"]
    msg = err.get("message", str(err)) if isinstance(err, dict) else str(err)
    print("ERROR: " + msg)
    sys.exit(1)

txt = ""
try:
    if ptype == "openai":
        txt = data["choices"][0]["message"]["content"]
    elif ptype == "gemini":
        parts = data["candidates"][0]["content"]["parts"]
        txt = "".join(p.get("text", "") for p in parts)
    elif ptype == "anthropic":
        parts = data["content"]
        txt = "".join(p.get("text", "") for p in parts if p.get("type") == "text")
    elif ptype == "ollama":
        txt = data.get("message", {}).get("content", "") or data.get("response", "")
except Exception as e:
    print("ERROR: unexpected response format: " + raw[:400])
    sys.exit(1)

if not txt:
    print("ERROR: empty reply from model")
    sys.exit(1)
sys.stdout.write(txt.rstrip("\n") + "\n")
PY
    return $?
  fi

  if command -v jq >/dev/null 2>&1; then
    local err
    err=$(jq -r 'if .error then (.error.message // .error | tostring) else empty end' "$resp_file" 2>/dev/null || true)
    if [[ -n $err ]]; then
      printf 'ERROR: %s\n' "$err"
      return 1
    fi
    local txt=""
    case "$ptype" in
      openai)    txt=$(jq -r '.choices[0].message.content // empty' "$resp_file" 2>/dev/null || true) ;;
      gemini)    txt=$(jq -r '[.candidates[0].content.parts[]?.text] | join("")' "$resp_file" 2>/dev/null || true) ;;
      anthropic) txt=$(jq -r '[.content[]? | select(.type=="text") | .text] | join("")' "$resp_file" 2>/dev/null || true) ;;
      ollama)    txt=$(jq -r '.message.content // .response // empty' "$resp_file" 2>/dev/null || true) ;;
    esac
    if [[ -n $txt ]]; then
      printf '%s\n' "$txt"
      return 0
    fi
    printf 'ERROR: unexpected JSON response\n'
    return 1
  fi

  # Pure-awk JSON string fallback (for minimal VPS/Termux without python3 or jq)
  awk -v ptype="$ptype" '
    BEGIN { RS=""; ORS="" }
    {
      s = $0
      key = (ptype == "gemini" || ptype == "anthropic") ? "\"text\"" : "\"content\""
      if (index(s, "\"error\"") > 0 && index(s, key) == 0) {
        key = "\"message\""
        is_err = 1
      }
      pos = index(s, key)
      if (pos == 0) {
        print "ERROR: could not parse response: " substr(s, 1, 250) "\n"
        exit 1
      }
      s = substr(s, pos + length(key))
      sub(/^[[:space:]]*:[[:space:]]*"/, "", s)
      out = ""
      n = length(s)
      for (i=1; i<=n; i++) {
        c = substr(s, i, 1)
        if (c == "\\") {
          i++
          nc = substr(s, i, 1)
          if      (nc == "n") out = out "\n"
          else if (nc == "t") out = out "\t"
          else if (nc == "r") out = out ""
          else out = out nc
        } else if (c == "\"") {
          break
        } else {
          out = out c
        }
      }
      if (is_err) { print "ERROR: " out "\n"; exit 1 }
      print out "\n"
    }
  ' "$resp_file"
}

_tx_ai_call() {
  # args: system_override(or empty), user_msg, [hist_pairs...]
  local sys_ovr="$1"; shift
  local sys="${sys_ovr:-$TX_AI_SYSTEM}"
  local -a msgs=("$@")
  local tmp="$TX_HOME/.aitmp.$$"
  ( umask 077 && mkdir -p "$tmp" ) || { _tx_err "cannot create temp dir"; return 1; }
  trap 'rm -rf "$tmp"' RETURN

  local esys endpoint="" hdr_file="$tmp/curl.cfg" body_file="$tmp/body.json" resp_file="$tmp/resp.json"
  esys=$(printf '%s' "$sys" | _tx_json_escape)
  local temp_num="${TX_AI_TEMP:-0.7}"
  local tok_num="${TX_AI_MAX_TOKENS:-1024}"
  _tx_is_int "$tok_num" || tok_num=1024

  local i role emsg msg_json=""
  case "$TX_AI_TYPE" in
    openai|ollama)
      [[ -n $esys ]] && msg_json="{\"role\":\"system\",\"content\":\"$esys\"}"
      for ((i=0; i<${#msgs[@]}; i+=2)); do
        role="${msgs[i]}"
        emsg=$(printf '%s' "${msgs[i+1]}" | _tx_json_escape)
        msg_json+="${msg_json:+,}{\"role\":\"${role}\",\"content\":\"${emsg}\"}"
      done
      if [[ "$TX_AI_TYPE" == "openai" ]]; then
        endpoint="${TX_AI_BASE_URL%/}"
        [[ "$endpoint" == */chat/completions ]] || endpoint="${endpoint}/chat/completions"
        printf '{"model":"%s","messages":[%s],"temperature":%s,"max_tokens":%s}' \
          "$(printf '%s' "$TX_AI_MODEL" | _tx_json_escape)" "$msg_json" "$temp_num" "$tok_num" > "$body_file"
      else
        endpoint="${TX_AI_BASE_URL%/}"
        [[ "$endpoint" == */api/chat ]] || endpoint="${endpoint}/api/chat"
        printf '{"model":"%s","messages":[%s],"stream":false,"options":{"temperature":%s,"num_predict":%s}}' \
          "$(printf '%s' "$TX_AI_MODEL" | _tx_json_escape)" "$msg_json" "$temp_num" "$tok_num" > "$body_file"
      fi
      ;;
    gemini)
      endpoint="${TX_AI_BASE_URL%/}"
      [[ "$endpoint" == *:generateContent ]] || endpoint="${endpoint}/models/${TX_AI_MODEL}:generateContent"
      local contents="" grole
      for ((i=0; i<${#msgs[@]}; i+=2)); do
        role="${msgs[i]}"
        grole="user"; [[ "$role" == "assistant" ]] && grole="model"
        emsg=$(printf '%s' "${msgs[i+1]}" | _tx_json_escape)
        contents+="${contents:+,}{\"role\":\"${grole}\",\"parts\":[{\"text\":\"${emsg}\"}]}"
      done
      if [[ -n $esys ]]; then
        printf '{"system_instruction":{"parts":[{"text":"%s"}]},"contents":[%s],"generationConfig":{"temperature":%s,"maxOutputTokens":%s}}' \
          "$esys" "$contents" "$temp_num" "$tok_num" > "$body_file"
      else
        printf '{"contents":[%s],"generationConfig":{"temperature":%s,"maxOutputTokens":%s}}' \
          "$contents" "$temp_num" "$tok_num" > "$body_file"
      fi
      ;;
    anthropic)
      endpoint="${TX_AI_BASE_URL%/}"
      [[ "$endpoint" == */messages ]] || endpoint="${endpoint}/messages"
      for ((i=0; i<${#msgs[@]}; i+=2)); do
        role="${msgs[i]}"
        emsg=$(printf '%s' "${msgs[i+1]}" | _tx_json_escape)
        msg_json+="${msg_json:+,}{\"role\":\"${role}\",\"content\":\"${emsg}\"}"
      done
      if [[ -n $esys ]]; then
        printf '{"model":"%s","max_tokens":%s,"temperature":%s,"system":"%s","messages":[%s]}' \
          "$(printf '%s' "$TX_AI_MODEL" | _tx_json_escape)" "$tok_num" "$temp_num" "$esys" "$msg_json" > "$body_file"
      else
        printf '{"model":"%s","max_tokens":%s,"temperature":%s,"messages":[%s]}' \
          "$(printf '%s' "$TX_AI_MODEL" | _tx_json_escape)" "$tok_num" "$temp_num" "$msg_json" > "$body_file"
      fi
      ;;
    *)
      _tx_err "unsupported AI type: $TX_AI_TYPE"
      return 1
      ;;
  esac

  local http_code=""
  if command -v curl >/dev/null 2>&1; then
    {
      echo 'header = "Content-Type: application/json"'
      case "$TX_AI_TYPE" in
        openai|ollama)
          [[ -n $TX_AI_API_KEY ]] && printf 'header = "Authorization: Bearer %s"\n' "$TX_AI_API_KEY" ;;
        gemini)
          printf 'header = "x-goog-api-key: %s"\n' "$TX_AI_API_KEY" ;;
        anthropic)
          printf 'header = "x-api-key: %s"\n' "$TX_AI_API_KEY"
          echo 'header = "anthropic-version: 2023-06-01"' ;;
      esac
    } > "$hdr_file"
    http_code=$(curl -sS -K "$hdr_file" -o "$resp_file" -w '%{http_code}' \
      --max-time "${TX_AI_TIMEOUT:-45}" -X POST -d @"$body_file" "$endpoint" 2>"$tmp/err.txt") || {
      _tx_err "request failed: $(cat "$tmp/err.txt" 2>/dev/null)"
      return 1
    }
  elif command -v wget >/dev/null 2>&1; then
    local -a whdrs=(--header="Content-Type: application/json")
    case "$TX_AI_TYPE" in
      openai|ollama) [[ -n $TX_AI_API_KEY ]] && whdrs+=(--header="Authorization: Bearer ${TX_AI_API_KEY}") ;;
      gemini)        whdrs+=(--header="x-goog-api-key: ${TX_AI_API_KEY}") ;;
      anthropic)     whdrs+=(--header="x-api-key: ${TX_AI_API_KEY}" --header="anthropic-version: 2023-06-01") ;;
    esac
    wget -qO "$resp_file" -T "${TX_AI_TIMEOUT:-45}" "${whdrs[@]}" --post-file="$body_file" "$endpoint" 2>"$tmp/err.txt" || {
      _tx_err "request failed: $(cat "$tmp/err.txt" 2>/dev/null)"
      return 1
    }
    http_code="200"
  else
    _tx_err "curl or wget is required for /ai"
    return 1
  fi

  local parsed rc=0
  parsed=$(_tx_ai_parse_reply "$TX_AI_TYPE" "$resp_file") || rc=$?
  if (( rc != 0 )) || [[ "$parsed" == ERROR:* ]]; then
    _tx_err "HTTP ${http_code:-?}: ${parsed#ERROR: }"
    return 1
  fi
  if _tx_is_int "$http_code" && (( http_code >= 400 )); then
    _tx_err "HTTP ${http_code}: $parsed"
    return 1
  fi
  printf '%s\n' "$parsed"
}

_tx_ai_test() {
  _tx_ai_load
  _tx_ai_is_configured || { _tx_err "AI not configured. Run: /ai config"; return 1; }
  printf '%s[*]%s testing %s (%s @ %s)...\n' "$TX_CY" "$TX_CX" "$TX_AI_MODEL" "$TX_AI_TYPE" "$TX_AI_BASE_URL"
  local reply
  reply=$(_tx_ai_call "Reply with only: OK" "user" "Say OK") || return 1
  _tx_say "connection OK -> ${reply}"
}

_tx_ai_cmd_helper() {
  local task="$*"
  [[ -n $task ]] || { _tx_err "usage: /ai -c <describe task>"; return 1; }
  local sys="Return ONLY a single safe bash command for ${TX_DEVICE} (${OSNAME:-Linux}) with no markdown fences, no backticks, and no explanation."
  local cmd
  cmd=$(_tx_ai_call "$sys" "user" "$task") || return 1
  cmd="${cmd#\`\`\`bash}"; cmd="${cmd#\`\`\`sh}"; cmd="${cmd#\`\`\`}"
  cmd="${cmd%\`\`\`}"
  cmd=$(printf '%s' "$cmd" | sed '/^[[:space:]]*$/d' | head -n1)
  printf '%s[command]%s %s\n' "$TX_CA" "$TX_CX" "$cmd"
  if [[ -t 0 && -t 1 ]]; then
    printf '%sRun this command? [y/N] %s' "$TX_CY" "$TX_CX"
    local ans=""
    read -r -n 1 ans </dev/tty 2>/dev/null || ans=""
    echo
    if [[ "$ans" == y || "$ans" == Y ]]; then
      eval "$cmd"
    fi
  fi
}

_tx_ai_chat() {
  printf '\n%s=== /ai CHAT (%s | %s) ===%s\n' "$TX_C2" "$TX_AI_TYPE" "$TX_AI_MODEL" "$TX_CX"
  printf '%sCommands: /help  /clear  /model <m>  /config  /status  /exit%s\n\n' "$TX_CD" "$TX_CX"
  local -a hist=()
  local line reply
  while true; do
    printf '%syou > %s' "$TX_C2" "$TX_CX"
    IFS= read -r line || { echo; break; }
    [[ -z "${line// /}" ]] && continue
    case "$line" in
      /exit|/quit|exit|quit|q) break ;;
      /clear)
        hist=()
        _tx_say "chat history cleared"
        continue
        ;;
      /status)
        _tx_ai_status
        continue
        ;;
      /config)
        _tx_ai_wizard
        _tx_ai_load
        continue
        ;;
      /model\ *)
        TX_AI_MODEL="${line#/model }"
        _tx_ai_save && _tx_say "model -> $TX_AI_MODEL"
        continue
        ;;
      /help)
        echo "  /clear         clear conversation history"
        echo "  /model <name>  switch model"
        echo "  /config        re-run setup wizard"
        echo "  /status        show current AI config"
        echo "  /exit          leave chat"
        continue
        ;;
    esac
    hist+=("user" "$line")
    if (( ${#hist[@]} > 20 )); then
      hist=("${hist[@]:2}")
    fi
    reply=$(_tx_ai_call "" "${hist[@]}") || continue
    hist+=("assistant" "$reply")
    printf '\n%sai >%s %s\n\n' "$TX_CA" "$TX_CX" "$reply"
  done
}

tx_ai() {
  _tx_ai_load
  local sub="${1:-}"
  case "$sub" in
    -h|--help|help)
      cat <<'EOF'
Usage: /ai [option | prompt]
  /ai                         First-time setup wizard, or interactive AI chat
  /ai <prompt>                One-shot question (also accepts piped stdin)
  /ai -c <task>               Generate a shell command and prompt before running
  /ai config | setup          Configure type, base_url, api_key, model, temp, tokens, system
  /ai set <key> <value>       Set: type | base_url | api_key | model | system | temp | max_tokens | timeout
  /ai status | show           Show active AI settings (API key masked)
  /ai test                    Test API connectivity
  /ai reset                   Remove ~/.sino/ai.conf
EOF
      return 0
      ;;
    config|setup)
      _tx_ai_wizard
      return $?
      ;;
    status|show)
      _tx_ai_status
      return $?
      ;;
    test)
      _tx_ai_test
      return $?
      ;;
    reset)
      rm -f "$TX_HOME/ai.conf"
      _tx_say "removed $TX_HOME/ai.conf"
      return 0
      ;;
    set)
      local k="${2:-}"
      [[ -n $k && $# -ge 3 ]] || { _tx_err "usage: /ai set <type|base_url|api_key|model|system|temp|max_tokens|timeout> <value>"; return 1; }
      shift 2
      local v="$*"
      case "$k" in
        type)
          _tx_in_list "$v" "${TX_AI_TYPES[@]}" || { _tx_err "type must be: ${TX_AI_TYPES[*]}"; return 1; }
          TX_AI_TYPE="$v"
          [[ -z $TX_AI_BASE_URL ]] && TX_AI_BASE_URL=$(_tx_ai_default_url "$v")
          [[ -z $TX_AI_MODEL ]]    && TX_AI_MODEL=$(_tx_ai_default_model "$v")
          ;;
        base_url|url)     TX_AI_BASE_URL="${v%/}" ;;
        api_key|api|key)  TX_AI_API_KEY="$v" ;;
        model)            TX_AI_MODEL="$v" ;;
        system)           TX_AI_SYSTEM="$v" ;;
        temp|temperature) TX_AI_TEMP="$v" ;;
        max_tokens|tokens) TX_AI_MAX_TOKENS="$v" ;;
        timeout)          TX_AI_TIMEOUT="$v" ;;
        *) _tx_err "unknown key '$k'"; return 1 ;;
      esac
      _tx_ai_save && _tx_say "/ai ${k} saved"
      return $?
      ;;
  esac

  if ! _tx_ai_is_configured; then
    _tx_warn "/ai needs configuration first (type, base_url, api_key, model)."
    _tx_ai_wizard || return 1
    _tx_ai_load
    (( $# == 0 )) && return 0
  fi

  local piped=""
  if [[ ! -t 0 ]]; then
    piped=$(head -c 16384 2>/dev/null || true)
  fi

  if [[ "$sub" == "-c" || "$sub" == "--cmd" || "$sub" == "cmd" ]]; then
    shift
    _tx_ai_cmd_helper "$*"
    return $?
  fi

  local prompt="$*"
  if [[ -n $piped ]]; then
    if [[ -n $prompt ]]; then
      prompt="${prompt}"$'\n\n'"Input:"$'\n'"${piped}"
    else
      prompt="$piped"
    fi
  fi

  if [[ -n $prompt ]]; then
    local ans
    ans=$(_tx_ai_call "" "user" "$prompt") || return 1
    printf '%s\n' "$ans"
  else
    _tx_ai_chat
  fi
}

# =====================================================================
#  AUTOCOMPLETE
# =====================================================================
_tx_expand_cur() {
  local c="$1"
  case "$c" in
    "~")   printf '%s/' "$HOME" ;;
    "~/"*) printf '%s'  "${HOME}/${c#\~/}" ;;
    *)     printf '%s'  "$c" ;;
  esac
}

_tx_path_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local curx; curx=$(_tx_expand_cur "$cur")
  local dir="" base=""
  if [[ "$curx" == */* ]]; then
    dir="${curx%/*}/"; base="${curx##*/}"
  else
    base="$curx"
  fi

  local had_ng=0 had_dg=0 had_ncg=0
  shopt -q nullglob   && had_ng=1
  shopt -q dotglob    && had_dg=1
  shopt -q nocaseglob && had_ncg=1

  local -a cands=()
  local entry name
  shopt -s nullglob dotglob 2>/dev/null

  if [[ -n "$dir" ]]; then
    for entry in "$dir"*; do
      name="${entry##*/}"
      [[ -z "$base" || "$name" == "$base"* ]] && cands+=("$entry")
    done
  else
    for entry in *; do
      [[ -z "$base" || "$entry" == "$base"* ]] && cands+=("$entry")
    done
  fi

  if (( ${#cands[@]} == 0 )) && [[ -n "$base" ]]; then
    shopt -s nocaseglob 2>/dev/null
    if [[ -n "$dir" ]]; then
      for entry in "$dir"*; do
        name="${entry##*/}"
        [[ "${name,,}" == "${base,,}"* ]] && cands+=("$entry")
      done
    else
      for entry in *; do
        [[ "${entry,,}" == "${base,,}"* ]] && cands+=("$entry")
      done
    fi
    (( had_ncg )) || shopt -u nocaseglob 2>/dev/null
  fi
  (( had_ng )) || shopt -u nullglob 2>/dev/null
  (( had_dg )) || shopt -u dotglob  2>/dev/null

  local -a out=()
  local c is_dir=0 has_dir=0
  for c in "${cands[@]}"; do
    is_dir=0
    [[ -d "$c" ]] && is_dir=1
    if [[ "$cur" == "~" || "$cur" == "~/"* ]]; then
      c="~/${c#"$HOME"/}"
    fi
    if (( is_dir )); then
      out+=("$c/")
      has_dir=1
    else
      out+=("$c")
    fi
  done
  (( has_dir )) && compopt -o nospace 2>/dev/null || true
  COMPREPLY=("${out[@]}")
}

_tx_cd_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local curx; curx=$(_tx_expand_cur "$cur")
  local dir="" base=""
  if [[ "$curx" == */* ]]; then
    dir="${curx%/*}/"; base="${curx##*/}"
  else
    base="$curx"
  fi

  local had_ng=0 had_dg=0 had_ncg=0
  shopt -q nullglob   && had_ng=1
  shopt -q dotglob    && had_dg=1
  shopt -q nocaseglob && had_ncg=1

  local -a cands=()
  local entry name
  shopt -s nullglob dotglob 2>/dev/null
  if [[ -n "$dir" ]]; then
    for entry in "$dir"*; do
      [[ -d "$entry" ]] || continue
      name="${entry##*/}"
      [[ -z "$base" || "$name" == "$base"* ]] && cands+=("$entry")
    done
  else
    for entry in *; do
      [[ -d "$entry" ]] || continue
      [[ -z "$base" || "$entry" == "$base"* ]] && cands+=("$entry")
    done
  fi
  if (( ${#cands[@]} == 0 )) && [[ -n "$base" ]]; then
    shopt -s nocaseglob 2>/dev/null
    if [[ -n "$dir" ]]; then
      for entry in "$dir"*; do
        [[ -d "$entry" ]] || continue
        name="${entry##*/}"
        [[ "${name,,}" == "${base,,}"* ]] && cands+=("$entry")
      done
    else
      for entry in *; do
        [[ -d "$entry" ]] || continue
        [[ "${entry,,}" == "${base,,}"* ]] && cands+=("$entry")
      done
    fi
    (( had_ncg )) || shopt -u nocaseglob 2>/dev/null
  fi
  (( had_ng )) || shopt -u nullglob 2>/dev/null
  (( had_dg )) || shopt -u dotglob  2>/dev/null

  local -a out=()
  local c
  for c in "${cands[@]}"; do
    if [[ "$cur" == "~" || "$cur" == "~/"* ]]; then
      c="~/${c#"$HOME"/}"
    fi
    out+=("$c/")
  done
  compopt -o nospace 2>/dev/null || true
  COMPREPLY=("${out[@]}")
}

_tx_subcmd_complete() {
  local cmd="${COMP_WORDS[0]}" cur="${COMP_WORDS[COMP_CWORD]}" prev="${COMP_WORDS[COMP_CWORD-1]:-}"
  local words=""
  case "$cmd" in
    txtheme)
      if (( COMP_CWORD == 1 )); then
        words="matrix cyber crimson amber ice purple neon prompt rain boot banner autoupdate list menu"
      elif [[ "$prev" == prompt ]]; then
        words="hacker minimal power compact"
      elif [[ "$prev" == rain ]]; then
        words="binary hex glyph"
      elif [[ "$prev" == boot || "$prev" == banner || "$prev" == autoupdate ]]; then
        words="on off"
      fi
      ;;
    /ai|ai|txai)
      if (( COMP_CWORD == 1 )); then
        words="config setup status show test set reset -c cmd --help"
      elif [[ "$prev" == set ]]; then
        words="type base_url api_key model system temp max_tokens timeout"
      elif [[ "$prev" == type ]]; then
        words="openai gemini anthropic ollama"
      fi
      ;;
    txlog)
      (( COMP_CWORD == 1 )) && words="sys auth kernel svc"
      ;;
    txssh)
      (( COMP_CWORD == 1 )) && words="status keys addkey"
      ;;
    txconfig)
      (( COMP_CWORD == 1 )) && words="show get set edit reset"
      ;;
    sfetch|Sfetch)
      (( COMP_CWORD == 1 )) && words="-q --cli --help"
      ;;
    svc)
      if (( COMP_CWORD == 1 )); then
        words="list status start stop restart reload enable disable logs"
      elif (( COMP_CWORD == 2 )); then
        words="${HV_SERVICES[*]}"
      fi
      ;;
    txwake)
      (( COMP_CWORD == 1 )) && words="on off"
      ;;
    dns)
      (( COMP_CWORD == 2 )) && words="A AAAA MX TXT NS CNAME"
      ;;
    txclean)
      (( COMP_CWORD == 1 )) && words="--all"
      ;;
    sysup)
      (( COMP_CWORD == 1 )) && words="-y --yes"
      ;;
  esac
  local -a matches=()
  local w
  for w in $words; do
    [[ "$w" == "$cur"* ]] && matches+=("$w")
  done
  COMPREPLY=("${matches[@]}")
}

_tx_register_complete() {
  complete -o bashdefault -o default -F _tx_cd_complete cd pushd mkcd 2>/dev/null || true
  complete -o bashdefault -o default -F _tx_path_complete \
    ls cat less more head tail cp mv rm mkdir rmdir touch chmod chown \
    ln vim nano vi nvim find grep rg tar zip unzip scp rsync \
    ssh python python3 node npm extract backup diskinfo serve 2>/dev/null || true
  complete -o bashdefault -o default -F _tx_subcmd_complete \
    txtheme txconfig sfetch Sfetch svc txwake dns txclean sysup txlog txssh /ai ai txai 2>/dev/null || true
}
_tx_register_complete

# ---------------------------------------------------------------------
#  commands
# ---------------------------------------------------------------------
hv()          { ( hv_dash ); }
sfetch()      { ( hv_sfetch "$@" ); }
Sfetch()      { ( hv_sfetch "$@" ); }
dev()         { ( hv_dev ); }
hvboot()      { ( hv_boot ); }
matrix()      { ( hv_matrix ); }
txver()       { tx_version; }
txupdate()    { tx_update; }
txtheme()     { tx_theme "$@"; }
txconfig()    { tx_config "$@"; }
theamx()      { tx_help "$@"; }
txhelp()      { tx_help "$@"; }
txuninstall() { tx_uninstall "$@"; }
myip()        { tx_myip "$@"; }
ports()       { tx_ports "$@"; }
netinfo()     { tx_netinfo "$@"; }
pingtest()    { tx_pingtest "$@"; }
dns()         { tx_dns "$@"; }
passgen()     { tx_passgen "$@"; }
diskinfo()    { tx_diskinfo "$@"; }
proctop()     { tx_proctop "$@"; }
svc()         { tx_svc "$@"; }
sysup()       { tx_sysup "$@"; }
txclean()     { tx_clean "$@"; }
extract()     { tx_extract "$@"; }
mkcd()        { tx_mkcd "$@"; }
backup()      { tx_backup "$@"; }
serve()       { tx_serve "$@"; }
txdiag()      { tx_diag "$@"; }
txbattery()   { tx_battery "$@"; }
txstorage()   { tx_storage "$@"; }
txwake()      { tx_wake "$@"; }
txcpu()       { tx_cpu "$@"; }
txmem()       { tx_mem "$@"; }
txtemp()      { tx_temp "$@"; }
txlog()       { tx_log "$@"; }
txssh()       { tx_ssh "$@"; }
/ai()         { tx_ai "$@"; }
ai()          { tx_ai "$@"; }
txai()        { tx_ai "$@"; }

# ---------------------------------------------------------------------
#  prompt theme
# ---------------------------------------------------------------------
hv_prompt() {
  local ec=$?
  local c1='\[\e[0;32m\]' c2='\[\e[1;92m\]' ca='\[\e[1;96m\]'
  case "${TX_THEME:-matrix}" in
    cyber)   c1='\[\e[0;36m\]'; c2='\[\e[1;96m\]'; ca='\[\e[1;95m\]' ;;
    crimson) c1='\[\e[0;31m\]'; c2='\[\e[1;91m\]'; ca='\[\e[1;97m\]' ;;
    amber)   c1='\[\e[0;33m\]'; c2='\[\e[1;93m\]'; ca='\[\e[1;97m\]' ;;
    ice)     c1='\[\e[0;34m\]'; c2='\[\e[1;94m\]'; ca='\[\e[1;96m\]' ;;
    purple)  c1='\[\e[0;35m\]'; c2='\[\e[1;95m\]'; ca='\[\e[1;96m\]' ;;
    neon)    c1='\[\e[0;92m\]'; c2='\[\e[1;95m\]'; ca='\[\e[1;93m\]' ;;
  esac
  local r='\[\e[1;91m\]' w='\[\e[1;97m\]' x='\[\e[0m\]'
  local uc=$c2; (( EUID == 0 )) && uc=$r
  local st="" br="" gb=""
  local ico_err="x" ico_git="git:" ico_arr=">"
  if _tx_is_utf8; then
    ico_err="✘"; ico_git="⎇ "; ico_arr="▶"
  fi
  (( ec != 0 )) && st="${c1}─[${r}${ico_err} ${ec}${c1}]"
  if command -v git >/dev/null 2>&1; then
    gb=$(git symbolic-ref --short -q HEAD 2>/dev/null || git rev-parse --short -q HEAD 2>/dev/null || true)
    [[ -n $gb ]] && br="${c1}─[${w}${ico_git}${gb}${c1}]"
  fi

  case "${TX_PROMPT:-hacker}" in
    minimal)
      local mst="" mbr=""
      (( ec != 0 )) && mst=" ${r}[${ec}]"
      [[ -n $gb ]] && mbr=" ${ca}(${gb})"
      PS1="${uc}\u${c1}@${w}\h ${c2}\w${mbr}${mst} ${uc}${ico_arr} ${x}"
      ;;
    power)
      local dt; dt=$(date '+%H:%M' 2>/dev/null || echo "--:--")
      PS1="${c1}┌─[${ca}${TX_DEVICE}${c1}]─[${uc}\u${c1}@${w}\h${c1}]─[${c2}\w${c1}]${br}${st}─[${w}${dt}${c1}]\n${c1}└─${uc}${ico_arr} ${x}"
      ;;
    compact)
      local cst="" cbr=""
      (( ec != 0 )) && cst="${r}${ec} "
      [[ -n $gb ]] && cbr="${ca}(${gb}) "
      PS1="${c1}[${c2}\W${c1}] ${cbr}${cst}${uc}${ico_arr} ${x}"
      ;;
    *)
      PS1="${c1}┌──[${uc}\u${c1}@${w}\h${c1}]─[${c2}\w${c1}]${br}${st}\n${c1}└─${uc}${ico_arr} ${x}"
      ;;
  esac
}

# ---------------------------------------------------------------------
#  entry point
# ---------------------------------------------------------------------
if (return 0 2>/dev/null); then
  if [[ $- == *i* ]]; then
    if [[ "$(declare -p PROMPT_COMMAND 2>/dev/null)" == "declare -a"* ]]; then
      [[ " ${PROMPT_COMMAND[*]} " == *" hv_prompt "* ]] || PROMPT_COMMAND=("hv_prompt" "${PROMPT_COMMAND[@]}")
    else
      PROMPT_COMMAND="${PROMPT_COMMAND#;}"
      PROMPT_COMMAND="${PROMPT_COMMAND%;}"
      [[ "$PROMPT_COMMAND" == *hv_prompt* ]] || PROMPT_COMMAND="hv_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    fi

    if [[ -t 1 && -z "${HV_BOOTED:-}" ]]; then
      export HV_BOOTED=1
      if [[ -z "${TMUX:-}" && "${TX_BOOT:-1}" == 1 && "${HV_QUICK:-0}" != 1 ]]; then
        tx_stamp="${XDG_RUNTIME_DIR:-${TMPDIR:-$HOME}}/.hv_boot_${UID:-0}"
        tx_now=$(printf '%(%s)T' -1); tx_last=$(cat "$tx_stamp" 2>/dev/null || echo 0)
        _tx_is_int "$tx_last" || tx_last=0
        if (( tx_now - tx_last > ${HV_COOLDOWN:-300} )); then
          ( hv_boot )
          echo "$tx_now" > "$tx_stamp" 2>/dev/null || true
        fi
        unset tx_stamp tx_now tx_last
      fi
      if [[ -s "$TX_HOME/notice" ]]; then
        printf '%s[*]%s %s\n' "$TX_CY" "$TX_CX" "$(cat "$TX_HOME/notice")"; rm -f "$TX_HOME/notice"
      fi
      if [[ "${TX_BANNER:-1}" == 1 ]]; then
        printf '%s[THEAM-X v%s]%s %s | theme:%s | prompt:%s | /ai ready\n' \
          "$TX_C2" "$(tx_local_ver)" "$TX_C1" "$TX_DEVICE" "$TX_THEME" "$TX_PROMPT"
      fi
      printf '%s[+] ready.%s  theamx | /ai | txtheme | sfetch | hv | txcpu | txmem | txdiag\n' "$TX_C2" "$TX_C1"
      printf '%s' "$TX_CX"

      tx_stamp="$TX_HOME/.last_check"
      tx_now=$(printf '%(%s)T' -1); tx_last=$(cat "$tx_stamp" 2>/dev/null || echo 0)
      _tx_is_int "$tx_last" || tx_last=0
      if (( tx_now - tx_last >= ${TX_CHECK_INTERVAL:-86400} )); then
        echo "$tx_now" > "$tx_stamp" 2>/dev/null || true
        tx_update_prompt
      fi
      unset tx_stamp tx_now tx_last
    fi
  fi
else
  _cmd="${1:-help}"
  shift 2>/dev/null || true
  case "$_cmd" in
    sfetch|Sfetch) hv_sfetch "$@" ;;
    dev)           hv_dev ;;
    dash|hv)       hv_dash ;;
    boot|hvboot)   hv_boot ;;
    matrix)        hv_matrix ;;
    update|txupdate) tx_update ;;
    version|ver|txver) tx_version ;;
    theme|txtheme) tx_theme "$@" ;;
    config|txconfig) tx_config "$@" ;;
    help|theamx|txhelp) tx_help "$@" ;;
    myip)          tx_myip "$@" ;;
    ports)         tx_ports "$@" ;;
    netinfo)       tx_netinfo "$@" ;;
    pingtest)      tx_pingtest "$@" ;;
    dns)           tx_dns "$@" ;;
    passgen)       tx_passgen "$@" ;;
    diskinfo)      tx_diskinfo "$@" ;;
    proctop)       tx_proctop "$@" ;;
    svc)           tx_svc "$@" ;;
    sysup)         tx_sysup "$@" ;;
    clean|txclean) tx_clean "$@" ;;
    extract)       tx_extract "$@" ;;
    backup)        tx_backup "$@" ;;
    serve)         tx_serve "$@" ;;
    diag|txdiag)   tx_diag "$@" ;;
    battery|txbattery) tx_battery "$@" ;;
    storage|txstorage) tx_storage "$@" ;;
    wake|txwake)   tx_wake "$@" ;;
    cpu|txcpu)     tx_cpu "$@" ;;
    mem|txmem)     tx_mem "$@" ;;
    temp|txtemp)   tx_temp "$@" ;;
    log|txlog)     tx_log "$@" ;;
    ssh|txssh)     tx_ssh "$@" ;;
    ai|/ai|txai)   tx_ai "$@" ;;
    *) echo "usage: $0 {help|ai|/ai|theme|config|sfetch|dev|hv|boot|matrix|myip|ports|netinfo|pingtest|dns|passgen|txcpu|txmem|txtemp|txlog|txssh|diskinfo|proctop|svc|sysup|txclean|extract|backup|serve|txdiag|txbattery|txstorage|txwake|update|version}"; exit 1 ;;
  esac
fi
