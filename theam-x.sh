#!/usr/bin/env bash
# =====================================================================
#  THEAM-X  |  hacker terminal theme for VPS + Termux
#  by Its2Pawan  -  https://github.com/Its2Pawan/Theam-x
#  Copyright (c) 2026 Its2Pawan. All Rights Reserved.
# =====================================================================

# force real bash even if launched with sh/dash
[ -n "$BASH_VERSION" ] || exec bash "$0" "$@"

HV_SELF="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")"
TX_HOME="${TX_HOME:-$HOME/.sino}"
[[ -f "$TX_HOME/config" ]] && . "$TX_HOME/config"

TX_REPO="Its2Pawan/Theam-x"
TX_BRANCH="${TX_BRANCH:-main}"
TX_RAW_BASE="${TX_RAW_BASE:-https://raw.githubusercontent.com}"

# developer card (edit freely; empty = hidden)
TX_DEV_NAME="${TX_DEV_NAME:-Its2Pawan}"
TX_DEV_ROLE="${TX_DEV_ROLE:-Developer}"
TX_DEV_TAG="${TX_DEV_TAG:-Discord Bots | Minecraft Plugins | Game Servers}"
TX_DEV_GITHUB="${TX_DEV_GITHUB:-https://github.com/Its2Pawan}"
TX_DEV_REPO="${TX_DEV_REPO:-https://github.com/Its2Pawan/Theam-x}"
TX_DEV_DISCORD="${TX_DEV_DISCORD:-}"
TX_DEV_SITE="${TX_DEV_SITE:-}"

# device: termux (Android) or vps (any Linux server)
if [[ -n "${TERMUX_VERSION:-}" || "${PREFIX:-}" == *com.termux* ]]; then
  TX_DEVICE=termux; HV_DISK_PATH="$HOME"; : "${HV_SERVICES_STR:=}"
else
  TX_DEVICE=vps; HV_DISK_PATH="/"; : "${HV_SERVICES_STR:=ssh nginx docker wings}"
fi
read -ra HV_SERVICES <<< "$HV_SERVICES_STR"

# ---------------------------------------------------------------------
#  basics  (ESC = octal \033 — works on every bash)
# ---------------------------------------------------------------------
hv_init() {
  E=$'\033'; X="${E}[0m"
  G="${E}[0;40;32m"; DIM="${E}[2;40;32m"; BR="${E}[1;40;92m"
  W="${E}[1;40;97m"; Y="${E}[1;40;93m"; R="${E}[1;40;91m"; C="${E}[1;40;96m"
  IN_ALT=0
  trap 'hv_cleanup' EXIT
  trap 'exit 130' INT TERM HUP
  RESIZED=0
  trap 'RESIZED=1' WINCH
}

hv_cleanup() {
  printf '%s' "${X}${E}[?7h${E}[?25h"
  (( IN_ALT )) && printf '%s' "${E}[?1049l"
  stty sane 2>/dev/null
}

hv_enter() { printf '%s' "${E}[?1049h${E}[?7l${E}[?25l${E}[40m${E}[2J"; IN_ALT=1; }
hv_leave() { printf '%s' "${E}[?1049l${E}[?7h${E}[?25h${X}"; IN_ALT=0; }

hv_size() {
  local r c
  read -r r c < <(stty size 2>/dev/null)
  ROWS=${r:-0}; COLS=${c:-0}
  (( ROWS > 0 )) || ROWS=$(tput lines 2>/dev/null || echo 24)
  (( COLS > 0 )) || COLS=$(tput cols  2>/dev/null || echo 80)
  ROWS=${ROWS:-24}; COLS=${COLS:-80}
  (( ROWS > 0 )) || ROWS=24
  (( COLS > 0 )) || COLS=80
}

hv_layout() {
  PW=$(( COLS - 2 )); (( PW > ${HV_WIDTH:-66} )) && PW=${HV_WIDTH:-66}
  (( PW < 20 )) && PW=20
  INNER=$(( PW - 2 )); (( INNER < 1 )) && INNER=1
  printf -v HL '%*s' "$INNER" ''; HL=${HL// /═}
  local c
  for ((c=1; c<=COLS; c++)); do
    drop_y[c]=$(( -(RANDOM % ROWS) ))
    drop_len[c]=$(( 5 + RANDOM % ROWS ))
  done
}

hv_screen() {
  [[ -t 1 ]] || { echo "Run this in a real terminal."; return 1; }
  hv_size
  if (( COLS < 50 || ROWS < 14 )); then
    echo "Terminal too small (need at least 50x14)."; return 1
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
}

# ---------------------------------------------------------------------
#  rain (0/1) - skips the panel area
# ---------------------------------------------------------------------
hv_put() {
  (( $1 < 1 || $1 > ROWS )) && return
  (( PH > 0 && $1 >= P_TOP && $1 < P_TOP + PH && $2 >= P_LEFT && $2 < P_LEFT + PW )) && return
  BUF+="${E}[$1;$2H$3$4"
}

hv_rain_frame() {
  BUF=""
  local c h l
  for ((c=1; c<=COLS; c+=2)); do
    h=$(( drop_y[c] + 1 )); drop_y[c]=$h; l=${drop_len[c]}
    hv_put "$h"             "$c" "$W"  $(( RANDOM & 1 ))
    hv_put $(( h - 1 ))     "$c" "$BR" $(( RANDOM & 1 ))
    hv_put $(( h - l / 2 )) "$c" "$G"  $(( RANDOM & 1 ))
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
  local pad=$(( INNER - $2 )) sp; (( pad < 0 )) && pad=0
  printf -v sp '%*s' "$pad" ''
  LINES+=("$1$sp")
}

hv_center() {
  local t="${2:0:$INNER}" lp rp s1 s2
  lp=$(( (INNER - ${#t}) / 2 )); (( lp < 0 )) && lp=0
  rp=$(( INNER - ${#t} - lp )); (( rp < 0 )) && rp=0
  printf -v s1 '%*s' "$lp" ''; printf -v s2 '%*s' "$rp" ''
  LINES+=("${1}${s1}${t}${s2}")
}

hv_kv() {
  local avail=$(( INNER - 12 )); (( avail < 1 )) && avail=1
  local v="${2:0:$avail}" lab
  printf -v lab '%-9s' "$1"
  hv_ln " ${DIM}${lab} ${W}${v}" $(( 11 + ${#v} ))
}

hv_barline() {
  local p=$2 col bw=$(( INNER - 27 )) fill f e ex lab
  (( bw < 4 )) && bw=4
  (( p > 100 )) && p=100; (( p < 0 )) && p=0
  col=$BR; (( p >= 60 )) && col=$Y; (( p >= 85 )) && col=$R
  fill=$(( p * bw / 100 ))
  printf -v f '%*s' "$fill" ''; f=${f// /█}
  printf -v e '%*s' "$(( bw - fill ))" ''; e=${e// /░}
  printf -v ex '%-13s' "${3:0:13}"; printf -v lab '%-4s' "$1"
  LINES+=(" ${DIM}${lab} ${G}[${col}${f}${DIM}${e}${G}] ${W}$(printf '%3d%%' "$p") ${G}${ex}")
}

hv_svc_lines() {
  if (( ! HAS_SYSTEMD )); then
    hv_center "$DIM" "services: n/a (no systemd on ${TX_DEVICE})"; return
  fi
  local cur=" " plain=1 s st col item ilen
  for s in "${HV_SERVICES[@]}"; do
    st=${SVC_ST[$s]:-n/a}
    if [[ $st == active ]]; then col=$BR; else col=$R; fi
    item="${col}● ${G}${s}  "; ilen=$(( ${#s} + 4 ))
    if (( plain + ilen > INNER )); then hv_ln "$cur" "$plain"; cur=" "; plain=1; fi
    cur+="$item"; plain=$(( plain + ilen ))
  done
  hv_ln "$cur" "$plain"
}

hv_draw_panel() {
  local r=$P_TOP ln
  BUF+="${E}[${r};${P_LEFT}H${G}╔${HL}╗"; r=$(( r + 1 ))
  for ln in "${LINES[@]}"; do
    if [[ $ln == __SEP__ ]]; then
      BUF+="${E}[${r};${P_LEFT}H${G}╠${HL}╣"
    else
      BUF+="${E}[${r};${P_LEFT}H${G}║${ln}${G}║"
    fi
    r=$(( r + 1 ))
  done
  BUF+="${E}[${r};${P_LEFT}H${G}╚${HL}╝"
}

# ---------------------------------------------------------------------
#  system stats
# ---------------------------------------------------------------------
hv_rate() {
  local b=$1
  if (( b >= 1048576 )); then printf '%d.%dMB/s' $(( b / 1048576 )) $(( (b % 1048576) * 10 / 1048576 ))
  else printf '%dKB/s' $(( b / 1024 )); fi
}

hv_ip() {
  local ip=""
  ip=$(hostname -I 2>/dev/null | awk '{print $1}')
  if [[ -z $ip ]] && command -v ip >/dev/null 2>&1; then
    ip=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}')
  fi
  if [[ -z $ip ]] && command -v ifconfig >/dev/null 2>&1; then
    ip=$(ifconfig 2>/dev/null | awk '/inet / && $2!="127.0.0.1"{print $2; exit}')
  fi
  printf '%s' "${ip:-n/a}"
}

hv_stats_static() {
  HOST=$(hostname 2>/dev/null || uname -n)
  IPADDR=$(hv_ip)
  if [[ $TX_DEVICE == termux ]]; then
    OSNAME="Android $(getprop ro.build.version.release 2>/dev/null) (Termux)"
  else
    OSNAME=$(grep -m1 '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
  fi
  [[ -z "${OSNAME// /}" ]] && OSNAME=$(uname -s)
  KERN=$(uname -r)
  NCPU=$(nproc 2>/dev/null); NCPU=${NCPU:-1}
  CPU=0; PREV_TOTAL=0; PREV_IDLE=0; PREV_RX=0; PREV_TX=0; PREV_T=$SECONDS
  RX_TXT="0KB/s"; TX_TXT="0KB/s"; NUSERS=0; HAS_SYSTEMD=0
}

hv_stats_fast() {
  local a b c d e f g h idle total dt di
  CPU_EXTRA="${NCPU} core(s)"
  if { read -r _ a b c d e f g h _; } 2>/dev/null </proc/stat; then
    idle=$(( d + e )); total=$(( a + b + c + d + e + f + g + h ))
    if (( PREV_TOTAL > 0 )); then
      dt=$(( total - PREV_TOTAL )); di=$(( idle - PREV_IDLE ))
      (( dt > 0 )) && CPU=$(( 100 * (dt - di) / dt ))
    fi
    PREV_TOTAL=$total; PREV_IDLE=$idle
  else
    CPU=0; CPU_EXTRA="n/a (no access)"
  fi

  local k v mt=0 ma=0
  if [[ -r /proc/meminfo ]]; then
    while read -r k v _; do
      case $k in MemTotal:) mt=$v;; MemAvailable:) ma=$v; break;; esac
    done < /proc/meminfo
  fi
  if (( mt > 0 )); then
    MEM_PCT=$(( 100 * (mt - ma) / mt )); MEM_TXT="$(( (mt - ma) / 1024 ))/$(( mt / 1024 ))MB"
  else
    MEM_PCT=0; MEM_TXT="n/a"
  fi

  local dsize dused dpct
  read -r _ dsize dused _ dpct _ < <(df -hP "$HV_DISK_PATH" 2>/dev/null | tail -1)
  DISK_PCT=${dpct%\%}; DISK_PCT=${DISK_PCT:-0}; DISK_TXT="${dused:-?}/${dsize:-?}"

  if { read -r L1 L2 L3 _; } 2>/dev/null </proc/loadavg; then :; else L1="n/a"; L2=""; L3=""; fi

  local up d2 h2 m2
  if { read -r up _; } 2>/dev/null </proc/uptime; then
    up=${up%.*}
    d2=$(( up / 86400 )); h2=$(( up % 86400 / 3600 )); m2=$(( up % 3600 / 60 ))
    UPTXT="${d2}d ${h2}h ${m2}m"
  else
    UPTXT=$(uptime -p 2>/dev/null | sed 's/^up //'); UPTXT=${UPTXT:-n/a}
  fi

  local rx=0 tx=0 line iface have=0 dtn
  if [[ -r /proc/net/dev ]]; then
    while read -r line; do
      [[ $line == *:* ]] || continue
      iface=${line%%:*}; iface=${iface// /}
      [[ $iface == lo ]] && continue
      set -- ${line#*:}
      rx=$(( rx + ${1:-0} )); tx=$(( tx + ${9:-0} )); have=1
    done < /proc/net/dev
  fi
  if (( have )); then
    dtn=$(( SECONDS - PREV_T )); (( dtn < 1 )) && dtn=1
    if (( PREV_RX > 0 )); then
      RX_TXT=$(hv_rate $(( (rx - PREV_RX) / dtn )))
      TX_TXT=$(hv_rate $(( (tx - PREV_TX) / dtn )))
    fi
    PREV_RX=$rx; PREV_TX=$tx; PREV_T=$SECONDS
  else
    RX_TXT="n/a"; TX_TXT="n/a"
  fi
}

hv_stats_slow() {
  local s st
  if command -v systemctl >/dev/null 2>&1; then
    HAS_SYSTEMD=1
    for s in "${HV_SERVICES[@]}"; do
      st=$(systemctl is-active "$s" 2>/dev/null)
      if [[ $st != active && $s == ssh ]]; then st=$(systemctl is-active sshd 2>/dev/null); fi
      SVC_ST[$s]=${st:-n/a}
    done
  else
    HAS_SYSTEMD=0
  fi
  NUSERS=$(who 2>/dev/null | wc -l)
}

# ---------------------------------------------------------------------
#  LIVE MONITOR
# ---------------------------------------------------------------------
hv_build_dash() {
  LINES=()
  hv_center "$C" "[ ${HOST} // SYSTEM MONITOR ]"
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
  hv_kv NET  "↓ ${RX_TXT}   ↑ ${TX_TXT}"
  LINES+=("__SEP__")
  hv_svc_lines
  LINES+=("__SEP__")
  hv_center "$DIM" "$(date '+%F  %T')   |   q = quit"
}

hv_dash() {
  hv_init
  hv_screen || return 1
  declare -A SVC_ST
  hv_stats_static; hv_stats_fast; hv_stats_slow
  hv_build_dash; hv_geometry
  if (( PH > ROWS )); then echo "Terminal too small for the monitor (need ${PH} rows)."; return 1; fi
  hv_enter
  local last=-1 slow_last=$SECONDS k
  while true; do
    if hv_check_resize; then hv_build_dash; hv_geometry; fi
    if (( SECONDS != last )); then
      last=$SECONDS
      hv_stats_fast
      if (( SECONDS - slow_last >= 5 )); then hv_stats_slow; slow_last=$SECONDS; fi
      hv_build_dash
    fi
    hv_rain_frame; hv_draw_panel; printf '%s' "$BUF"
    if read -rsn1 -t "${HV_FPS_DELAY:-0.05}" k; then
      [[ "$k" == q || "$k" == Q ]] && break
    fi
  done
  hv_leave
}

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
    st=${view[i]%%|*}; t="${view[i]#*|}"; t="${t:0:$tw}"
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

hv_boot() {
  hv_init
  hv_screen || return 1
  declare -A SVC_ST
  hv_stats_static; hv_stats_fast; hv_stats_slow
  local on=0 s tot=${#HV_SERVICES[@]} svc_txt
  for s in "${HV_SERVICES[@]}"; do [[ "${SVC_ST[$s]}" == active ]] && on=$(( on + 1 )); done
  svc_txt="Services ${on}/${tot} online"; (( HAS_SYSTEMD )) || svc_txt="Services n/a (no systemd)"

  local STEPS=(
    "Theam-X v$(tx_local_ver) on ${TX_DEVICE}"
    "Kernel ${KERN}"
    "Host ${HOST} online"
    "OS ${OSNAME}"
    "IPv4 ${IPADDR}"
    "CPU ${NCPU} core(s)  load ${L1}"
    "Memory ${MEM_TXT} (${MEM_PCT}%)"
    "Disk ${DISK_TXT} (${DISK_PCT}%)"
    "${svc_txt}"
    "Uptime ${UPTXT}"
    "Access granted. Welcome, ${USER:-$(id -un)}"
  )

  LOGROWS=$(( ROWS - 9 )); (( LOGROWS > 9 )) && LOGROWS=9; (( LOGROWS < 2 )) && LOGROWS=2
  LOGS=(); CUR=""; CUR_ON=0; PCT=0; STATUS="initializing..."; STATUS_COLOR="$Y"
  hv_build_boot; hv_geometry
  hv_enter

  local total=${#STEPS[@]} i=0 n=0 hold=0 txt
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
    if hv_check_resize; then LOGROWS=$(( ROWS - 9 )); (( LOGROWS > 9 )) && LOGROWS=9; (( LOGROWS < 2 )) && LOGROWS=2; hv_build_boot; hv_geometry; fi
    hv_build_boot; hv_rain_frame; hv_draw_panel; printf '%s' "$BUF"
    sleep "${HV_FPS_DELAY:-0.03}"
  done

  STATUS=">>> ACCESS GRANTED <<<"; STATUS_COLOR="$BR"
  for ((i=0; i<40; i++)); do
    hv_build_boot; hv_rain_frame; hv_draw_panel; printf '%s' "$BUF"
    sleep "${HV_FPS_DELAY:-0.03}"
  done
  hv_leave
}

# ---------------------------------------------------------------------
#  MATRIX
# ---------------------------------------------------------------------
hv_matrix() {
  hv_init
  hv_screen || return 1
  hv_enter
  local k
  while true; do
    hv_check_resize
    hv_rain_frame; printf '%s' "$BUF"
    read -rsn1 -t "${HV_FPS_DELAY:-0.04}" k && break
  done
  hv_leave
}

# ---------------------------------------------------------------------
#  version + auto update
# ---------------------------------------------------------------------
tx_get() {
  if command -v curl >/dev/null 2>&1; then curl -fsSL --max-time "${TX_TIMEOUT:-8}" "$1"
  elif command -v wget >/dev/null 2>&1; then wget -qO- -T "${TX_TIMEOUT:-8}" "$1"
  else return 127; fi
}

tx_local_ver() {
  local v f
  for f in "$TX_HOME/ver.txt" "$(dirname "$HV_SELF")/ver.txt"; do
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

tx_update() {
  local quiet=${1:-0} lv out rv rb base tmp
  lv=$(tx_local_ver)
  out=$(tx_remote_ver) || { (( quiet )) || printf '\033[1;91m[x]\033[0m can'"'"'t reach GitHub (offline, or repo files not found)\n'; return 1; }
  read -r rv rb <<< "$out"
  if ! tx_ver_gt "$rv" "$lv"; then
    (( quiet )) || printf '\033[1;92m[+]\033[0m up to date  (v%s)\n' "$lv"; return 0
  fi
  (( quiet )) || printf '\033[1;93m[*]\033[0m updating v%s -> v%s ...\n' "$lv" "$rv"
  base="${TX_RAW_BASE}/${TX_REPO}/${rb}"
  mkdir -p "$TX_HOME"; tmp="$TX_HOME/.tmp.$$"; mkdir -p "$tmp" || return 1
  if tx_get "$base/theam-x.sh" > "$tmp/theam-x.sh" 2>/dev/null \
     && [[ -s "$tmp/theam-x.sh" ]] && bash -n "$tmp/theam-x.sh" 2>/dev/null \
     && grep -q 'THEAM-X' "$tmp/theam-x.sh"; then
    mv -f "$tmp/theam-x.sh" "$TX_HOME/theam-x.sh"
    printf '%s\n' "$rv" > "$TX_HOME/ver.txt"
    rm -rf "$tmp"
    if (( quiet )); then
      printf 'Theam-X updated v%s -> v%s (active now in new shells)\n' "$lv" "$rv" > "$TX_HOME/notice"
    else
      printf '\033[1;92m[+]\033[0m updated to v%s  (open a new shell or run: source ~/.bashrc)\n' "$rv"
    fi
    return 0
  fi
  rm -rf "$tmp"
  (( quiet )) || printf '\033[1;91m[x]\033[0m update failed, kept v%s\n' "$lv"
  return 1
}

tx_auto_update() {
  [[ "${TX_AUTOUPDATE:-1}" == 1 ]] || return 0
  mkdir -p "$TX_HOME" 2>/dev/null || return 0
  local stamp="$TX_HOME/.last_check" now last
  now=$(printf '%(%s)T' -1); last=$(cat "$stamp" 2>/dev/null || echo 0)
  (( now - last < ${TX_CHECK_INTERVAL:-86400} )) && return 0
  echo "$now" > "$stamp"
  ( tx_update 1 >/dev/null 2>&1 & )
}

tx_version() {
  local lv out rv
  lv=$(tx_local_ver)
  printf '\033[1;92mTheam-X\033[0m v%s  \033[0;32m(%s)\033[0m\n' "$lv" "$TX_DEVICE"
  if out=$(tx_remote_ver); then
    rv=${out%% *}
    if tx_ver_gt "$rv" "$lv"; then printf '\033[1;93m[!]\033[0m update available: v%s   (run: txupdate)\n' "$rv"
    else printf '\033[1;92m[+]\033[0m you have the latest version\n'; fi
  else
    printf '\033[1;91m[x]\033[0m can'"'"'t check GitHub right now\n'
  fi
}

# ---------------------------------------------------------------------
#  terminal width helper
# ---------------------------------------------------------------------
tx_cols() {
  local c=""
  if [[ -t 1 ]]; then c=$(tput cols 2>/dev/null); fi
  [[ -z "$c" || "$c" -lt 1 ]] 2>/dev/null && c=80
  printf '%s' "$c"
}

# ---------------------------------------------------------------------
#  SFETCH
# ---------------------------------------------------------------------
tx_bits() { local n=$1 s="" i; for ((i=1; i<=n; i++)); do s+=$(( RANDOM & 1 )); (( i % 4 == 0 && i < n )) && s+=" "; done; printf '%s' "$s"; }

tx_sfetch() {
  local E=$'\033' g="${E}[1;92m" w="${E}[1;97m" d="${E}[0;32m" x="${E}[0m"
  local user host os model kern up pk shell term cpu mem disk ip ver virt
  user=${USER:-$(id -un 2>/dev/null)}; host=$(hostname 2>/dev/null || uname -n)

  if [[ $TX_DEVICE == termux ]]; then
    os="Android $(getprop ro.build.version.release 2>/dev/null) (Termux)"
    model="$(getprop ro.product.manufacturer 2>/dev/null) $(getprop ro.product.model 2>/dev/null)"
  else
    os=$(grep -m1 '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
    model=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null)
    virt=$(systemd-detect-virt 2>/dev/null)
    [[ -n $virt && $virt != none ]] && model="${model:+$model }[${virt}]"
  fi
  [[ -z "${os// /}" ]] && os=$(uname -sr)
  [[ -z "${model// /}" ]] && model="$TX_DEVICE"
  kern=$(uname -r)

  local upsec
  if { read -r upsec _; } 2>/dev/null </proc/uptime; then
    upsec=${upsec%.*}; up="$(( upsec / 86400 ))d $(( upsec % 86400 / 3600 ))h $(( upsec % 3600 / 60 ))m"
  else
    up=$(uptime -p 2>/dev/null | sed 's/^up //'); up=${up:-n/a}
  fi

  if command -v dpkg-query >/dev/null 2>&1; then pk="$(dpkg-query -f '.\n' -W 2>/dev/null | wc -l) (dpkg)"
  elif command -v rpm >/dev/null 2>&1; then pk="$(rpm -qa 2>/dev/null | wc -l) (rpm)"
  elif command -v apk >/dev/null 2>&1; then pk="$(apk info 2>/dev/null | wc -l) (apk)"
  elif command -v pacman >/dev/null 2>&1; then pk="$(pacman -Q 2>/dev/null | wc -l) (pacman)"
  else pk="n/a"; fi

  shell="${SHELL##*/} ${BASH_VERSION%%(*}"
  term="${TERM_PROGRAM:-${TERM:-n/a}}"

  cpu=$(grep -m1 -E '^(model name|Hardware)' /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^ *//')
  if [[ -z $cpu && $TX_DEVICE == termux ]]; then cpu=$(getprop ro.soc.model 2>/dev/null); fi
  [[ -z $cpu ]] && cpu=$(uname -m)
  cpu="${cpu} ($(nproc 2>/dev/null || echo 1))"

  local k v mt=0 ma=0
  if [[ -r /proc/meminfo ]]; then
    while read -r k v _; do
      case $k in MemTotal:) mt=$v;; MemAvailable:) ma=$v; break;; esac
    done < /proc/meminfo
  fi
  if (( mt > 0 )); then mem="$(( (mt-ma)/1024 ))MB / $(( mt/1024 ))MB ($(( 100*(mt-ma)/mt ))%)"; else mem="n/a"; fi

  local ds du dp
  read -r _ ds du _ dp _ < <(df -hP "$HV_DISK_PATH" 2>/dev/null | tail -1)
  disk="${du:-?} / ${ds:-?} (${dp:-?})"
  ip=$(hv_ip); ver=$(tx_local_ver)

  local cols maxv _v
  cols=$(tx_cols); maxv=$(( cols - 30 )); (( maxv < 12 )) && maxv=12
  for _v in os model kern up pk shell term cpu mem disk ip; do printf -v "$_v" '%s' "${!_v:0:$maxv}"; done

  local ul pal i
  printf -v ul '%*s' $(( ${#user} + ${#host} + 1 )) ''; ul=${ul// /─}
  pal=""; for i in 0 1 2 3 4 5 6 7; do pal+="${E}[4${i}m   "; done; pal+="${x}"

  local -a info=(
    "${g}${user}${w}@${g}${host}${x}"
    "${d}${ul}${x}"
    "${g}OS       ${w}${os}${x}"
    "${g}Device   ${w}${model}${x}"
    "${g}Kernel   ${w}${kern}${x}"
    "${g}Uptime   ${w}${up}${x}"
    "${g}Packages ${w}${pk}${x}"
    "${g}Shell    ${w}${shell}${x}"
    "${g}Terminal ${w}${term}${x}"
    "${g}CPU      ${w}${cpu}${x}"
    "${g}Memory   ${w}${mem}${x}"
    "${g}Disk     ${w}${disk}${x}"
    "${g}IP       ${w}${ip}${x}"
    "${g}Theme    ${w}Theam-X v${ver} ${d}by ${TX_DEV_NAME}${x}"
    ""
    "${pal}"
  )

  local LOGO
  IFS= read -r -d '' LOGO <<'LOGOEOF'
 _____ __  __
|_   _|\ \/ /
  | |   \  /
  | |   /  \
  |_|  /_/\_\
LOGOEOF
  local -a logo; mapfile -t logo <<< "$LOGO"
  logo+=("" "$(tx_bits 12)" "$(tx_bits 12)" "$(tx_bits 12)")

  local n=${#info[@]} nl=${#logo[@]} off li l
  off=$(( (n - nl) / 2 )); (( off < 0 )) && off=0
  echo
  for ((i=0; i<n; i++)); do
    li=$(( i - off )); l=""
    (( li >= 0 && li < nl )) && l=${logo[li]}
    printf '  %s%-15s%s  %s\n' "$g" "$l" "$x" "${info[i]}"
  done
  echo
}

# ---------------------------------------------------------------------
#  DEV
# ---------------------------------------------------------------------
tx_dev() {
  local E=$'\033' g="${E}[1;92m" w="${E}[1;97m" d="${E}[0;32m" x="${E}[0m"
  local cols inner hl vw
  cols=$(tx_cols)
  inner=$(( cols - 2 )); (( inner > 64 )) && inner=64; (( inner < 36 )) && inner=36
  printf -v hl '%*s' "$inner" ''; hl=${hl// /═}
  vw=$(( inner - 10 )); (( vw < 1 )) && vw=1
  local pause=0; [[ -t 1 ]] && pause=0.04
  _row() {
    local val="$2" lab="$1"
    [[ -z "$val" ]] && return
    while :; do
      printf '%s║%s %s%-8s%s %s%-*s%s%s║%s\n' \
        "$d" "$x" "$d" "$lab" "$x" "$w" "$vw" "${val:0:$vw}" "$x" "$d" "$x"
      val=${val:$vw}; lab=""
      [[ -z "$val" ]] && break
      sleep "$pause"
    done
  }
  local title="[ DEVELOPER INFO ]" lp rp s1 s2
  lp=$(( (inner - ${#title}) / 2 )); (( lp < 0 )) && lp=0
  rp=$(( inner - ${#title} - lp )); (( rp < 0 )) && rp=0
  printf -v s1 '%*s' "$lp" ''; printf -v s2 '%*s' "$rp" ''
  echo
  printf '%s╔%s╗%s\n' "$d" "$hl" "$x"
  printf '%s║%s%s%s%s%s║%s\n' "$d" "$g" "$s1" "$title" "$s2" "$d" "$x"
  printf '%s╠%s╣%s\n' "$d" "$hl" "$x"
  _row NAME    "$TX_DEV_NAME"
  _row ROLE    "$TX_DEV_ROLE"
  _row STACK   "$TX_DEV_TAG"
  _row GITHUB  "$TX_DEV_GITHUB"
  _row PROJECT "Theam-X v$(tx_local_ver)"
  _row REPO    "$TX_DEV_REPO"
  _row DISCORD "$TX_DEV_DISCORD"
  _row SITE    "$TX_DEV_SITE"
  _row DEVICE  "$TX_DEVICE"
  printf '%s╚%s╝%s\n' "$d" "$hl" "$x"
  unset -f _row
  echo
}

# ---------------------------------------------------------------------
#  commands
# ---------------------------------------------------------------------
hv()       { ( hv_dash ); }
hvboot()   { ( hv_boot ); }
matrix()   { ( hv_matrix ); }
sfetch()   { tx_sfetch "$@"; }
Sfetch()   { tx_sfetch "$@"; }
dev()      { tx_dev; }
txver()    { tx_version; }
txupdate() { tx_update 0; }

# ---------------------------------------------------------------------
#  prompt theme
# ---------------------------------------------------------------------
hv_prompt() {
  local ec=$?
  local g='\[\e[0;32m\]' b='\[\e[1;92m\]' r='\[\e[1;91m\]' w='\[\e[1;97m\]' x='\[\e[0m\]'
  local uc=$b; (( EUID == 0 )) && uc=$r
  local st="" br="" gb
  (( ec != 0 )) && st="${g}─[${r}✘ ${ec}${g}]"
  if command -v git >/dev/null 2>&1; then
    gb=$(git symbolic-ref --short -q HEAD 2>/dev/null) && [[ -n $gb ]] && br="${g}─[${w}⎇ ${gb}${g}]"
  fi
  PS1="${g}┌──[${uc}\u${g}@${w}\h${g}]─[${b}\w${g}]${br}${st}\n${g}└─${uc}▶ ${x}"
}

# ---------------------------------------------------------------------
#  entry point
# ---------------------------------------------------------------------
if (return 0 2>/dev/null); then
  if [[ $- == *i* ]]; then
    [[ "$PROMPT_COMMAND" == *hv_prompt* ]] || PROMPT_COMMAND="hv_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    if [[ -t 1 && -z "${HV_BOOTED:-}" ]]; then
      export HV_BOOTED=1
      if [[ -z "${TMUX:-}" && "${HV_QUICK:-0}" != 1 ]]; then
        hv_stamp="${XDG_RUNTIME_DIR:-/tmp}/.hv_boot_${UID:-0}"
        hv_now=$(printf '%(%s)T' -1); hv_last=$(cat "$hv_stamp" 2>/dev/null || echo 0)
        if (( hv_now - hv_last > ${HV_COOLDOWN:-300} )); then
          ( hv_boot )
          echo "$hv_now" > "$hv_stamp" 2>/dev/null
        fi
        unset hv_stamp hv_now hv_last
      fi
      if [[ -s "$TX_HOME/notice" ]]; then
        printf '\033[1;93m[*]\033[0m %s\n' "$(cat "$TX_HOME/notice")"; rm -f "$TX_HOME/notice"
      fi
      printf '\033[1;92m[+] ready.\033[0;32m  sfetch | dev | hv | matrix | txver | txupdate\033[0m\n'
      tx_auto_update
    fi
  fi
else
  case "${1:-sfetch}" in
    sfetch|Sfetch) tx_sfetch ;;
    dev)           tx_dev ;;
    dash|hv)       hv_dash ;;
    boot)          hv_boot ;;
    matrix)        hv_matrix ;;
    update)        tx_update 0 ;;
    version|ver)   tx_version ;;
    *) echo "usage: $0 {sfetch|dev|dash|boot|matrix|update|version}"; exit 1 ;;
  esac
fi
