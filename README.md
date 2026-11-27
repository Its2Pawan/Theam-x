<div align="center">

```
  _____ __  __
 |_   _|\ \/ /
   | |   \  /
   | |   /  \
   |_|  /_/\_\
```

# Theam-X

**Hacker-style terminal theme & toolkit for VPS and Termux**
6 color themes · 4 prompt styles · 3 matrix rain modes · live monitor · VPS & Termux utilities · auto-update

![version](https://img.shields.io/badge/version-2.0.0-brightgreen)
![shell](https://img.shields.io/badge/shell-bash-green)
![platform](https://img.shields.io/badge/platform-VPS%20%7C%20Termux-black)
![license](https://img.shields.io/badge/license-All%20Rights%20Reserved-red)

</div>

---

## Features

- **Multiple Color Themes (`txtheme`)**: `matrix`, `cyber`, `crimson`, `amber`, `ice`, `purple` — switch live or save to config.
- **Multiple Prompt Styles**: `hacker` (2-line box), `minimal` (1-line), `power` (device + time + git + exit code), `compact`.
- **Multiple Rain Modes**: `binary` (`0/1`), `hex` (`0-9A-F`), `glyph` (`!@#$%&*...`).
- **Boot screen (`hvboot`)**: Matrix rain with typed startup log (press any key to skip; respects cooldown).
- **`sfetch`**: Animated rain info panel, or `sfetch -q` / `--cli` for instant TX ASCII logo + system specs.
- **`hv`**: Live system monitor (CPU, RAM, Disk, Load, Network speed, Battery, Services) with live hotkeys (`t` theme, `r` rain, `p` pause, `q` quit).
- **Useful VPS + Termux Toolkit**: `myip`, `ports`, `netinfo`, `pingtest`, `dns`, `passgen`, `diskinfo`, `proctop`, `svc`, `sysup`, `txclean`, `extract`, `mkcd`, `backup`, `serve`, `txdiag`, `txbattery`, `txstorage`, `txwake`.
- **Smart Bash Completion**: Case-insensitive path completion, `~/` directory completion, and subcommand completion.
- **Auto-update**: Checks `ver.txt` on GitHub once a day with safe bash syntax validation before applying.

## Install

**VPS** (Ubuntu / Debian / CentOS / RHEL / Alpine / Arch, as root or with sudo)

```bash
curl -fsSL https://raw.githubusercontent.com/Its2Pawan/Theam-x/main/install.sh | bash
```

**Termux** (Android)

```bash
pkg install -y curl && curl -fsSL https://raw.githubusercontent.com/Its2Pawan/Theam-x/main/install.sh | bash
```

**With wget**

```bash
wget -qO- https://raw.githubusercontent.com/Its2Pawan/Theam-x/main/install.sh | bash
```

Then load it:

```bash
source ~/.bashrc
```

Everything is installed into `~/.sino` (`/root/.sino` on a root VPS) and loaded from `~/.bashrc`.

## Commands

### Theme & Visuals
| Command | What it does |
|---|---|
| `theamx` / `txhelp` | Show full command reference & active theme info |
| `txtheme` | Interactive options menu (`txtheme <color>`, `txtheme prompt <style>`, `txtheme rain <mode>`) |
| `txconfig` | View/set/edit/reset `~/.sino/config` safely (`show`, `get`, `set`, `edit`, `reset`) |
| `sfetch` / `sfetch -q` | System info panel (`-q` / `--cli` for instant terminal output) |
| `hv` | Live monitor (`t` theme, `r` rain, `p` pause, `q` quit) |
| `hvboot` | Replay boot animation (any key to skip) |
| `matrix` | Full-screen rain (`t` theme, `r` rain, `+`/`-` speed, any other key to exit) |
| `dev` | Developer card |

### Network & Security
| Command | What it does |
|---|---|
| `myip` | Local IPv4/IPv6 + Public IP & ISP/location |
| `ports` | Listening TCP/UDP ports (`ss`, `netstat`, or `/proc/net/tcp` fallback) |
| `netinfo` | Network interfaces, default gateway, DNS servers |
| `pingtest [host]` | Quick latency test (defaults to `1.1.1.1`, `8.8.8.8`, `github.com`) |
| `dns <domain> [type]` | DNS record lookup (`dig`/`host`/`nslookup`/`getent`) |
| `passgen [len] [count]` | Cryptographic random password generator |

### System, VPS & Termux
| Command | What it does |
|---|---|
| `diskinfo [path]` | Clean filesystem usage + top 10 largest items in path |
| `proctop [n]` | Top CPU/RAM processes (GNU & BusyBox compatible) |
| `svc [cmd] [name]` | Service manager (systemd / OpenRC / `termux-services`) |
| `sysup [-y]` | Update OS packages (`pkg`, `apt-get`, `dnf`, `yum`, `apk`, `pacman`) |
| `txclean [--all]` | Clean package & temp caches (`--all` also clears `~/.cache` & old journal logs) |
| `txdiag` | Full VPS + Termux environment & health diagnostic |
| `txbattery` | Battery level & status (`termux-battery-status` / sysfs) |
| `txstorage` | Termux `~/storage` check/setup, or VPS disk mounts |
| `txwake [on\|off]` | Toggle Termux CPU wake-lock |

### Files & Helpers
| Command | What it does |
|---|---|
| `extract <file>` | Extract `.tar.*`, `.zip`, `.gz`, `.bz2`, `.xz`, `.7z`, `.rar` |
| `mkcd <dir>` | Create directory and `cd` into it |
| `backup <file\|dir>` | Timestamped `.bak` or `.tar.gz` backup |
| `serve [port] [dir]` | Quick local HTTP file server (default port `8080`) |

### Updates & Removal
| Command | What it does |
|---|---|
| `txver` | Show installed version, active theme, and check for updates |
| `txupdate` | Update now from GitHub |
| `txuninstall` | Uninstall Theam-X interactively |

## Configuration

`~/.sino/config` (created on install, kept on reinstall, editable via `txtheme` or `txconfig`):

```bash
TX_THEME="matrix"          # matrix | cyber | crimson | amber | ice | purple
TX_PROMPT="hacker"         # hacker | minimal | power | compact
TX_RAIN="binary"           # binary | hex | glyph
TX_BOOT=1                  # 1 = boot animation on login, 0 = skip
TX_AUTOUPDATE=1            # 0 = never auto update
TX_CHECK_INTERVAL=86400    # seconds between update checks
HV_COOLDOWN=300            # seconds before the boot animation can replay
HV_SERVICES_STR="ssh nginx docker wings"   # services shown in `hv` (VPS)
```

## Uninstall

Run `txuninstall` in your shell, or:

```bash
curl -fsSL https://raw.githubusercontent.com/Its2Pawan/Theam-x/main/install.sh | bash -s uninstall
```

## Requirements

- bash 4+ (Termux and all current VPS distros have it)
- `curl` or `wget` (the installer installs curl if both are missing)
- A terminal of at least 50x14 characters for the animated panels

## Author

**Its2Pawan** · https://github.com/Its2Pawan

## License

Copyright (c) 2026 Its2Pawan. **All Rights Reserved.** See [LICENSE](LICENSE).
