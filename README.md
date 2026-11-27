<div align="center">

```
  _____ __  __
 |_   _|\ \/ /
   | |   \  /
   | |   /  \
   |_|  /_/\_\
```

# Theam-X

**Hacker-style terminal theme for your VPS and Termux**
0/1 matrix rain · boot screen · live monitor · `sfetch` · auto-update

![version](https://img.shields.io/badge/version-1.0.1-brightgreen)
![shell](https://img.shields.io/badge/shell-bash-green)
![platform](https://img.shields.io/badge/platform-VPS%20%7C%20Termux-black)
![license](https://img.shields.io/badge/license-All%20Rights%20Reserved-red)

</div>

---

## Features

- **Boot screen**: 0/1 matrix rain with a typed-out startup log (kernel, OS, IP, CPU, RAM, disk, services, uptime) every time you log in. It will not replay on quick reconnects.
- **`sfetch`**: system info next to a TX logo. Works on VPS and Termux.
- **`dev`**: developer info card.
- **`hv`**: live system monitor (CPU, RAM, disk, load, network, services) over the rain.
- **`matrix`**: full-screen 0/1 rain.
- **Hacker prompt**: shows user, host, path, git branch and the last command's error code.
- **Auto-update**: checks `ver.txt` on GitHub once a day and updates itself.
- **Multi-device**: detects VPS or Termux and adapts (no systemd or blocked `/proc` on Android is handled).

## Install

**VPS** (Ubuntu / Debian / CentOS / Alpine / Arch, as root or with sudo)

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

Everything is installed into the hidden folder `~/.sino` (`/root/.sino` on a root VPS) and loaded from `~/.bashrc`.

## Commands

| Command | What it does |
|---|---|
| `sfetch` / `Sfetch` | System info (OS, device, kernel, uptime, packages, CPU, RAM, disk, IP) |
| `dev` | Developer info |
| `hv` | Live monitor (`q` to quit) |
| `hvboot` | Replay the boot screen |
| `matrix` | Full-screen 0/1 rain (any key to exit) |
| `txver` | Show installed version and check for updates |
| `txupdate` | Update now from GitHub |

## Auto-update

On login, Theam-X compares your local `~/.sino/ver.txt` with `ver.txt` in this repository (at most once every 24 hours, in the background, so login is never slowed). If the repository has a higher version, it downloads `theam-x.sh`, checks that it is valid bash, replaces the old one, and tells you at your next login.

Turn it off in `~/.sino/config`:

```bash
TX_AUTOUPDATE=0
```

## Configuration

`~/.sino/config` (created on install, kept on reinstall):

```bash
TX_AUTOUPDATE=1            # 0 = never auto update
TX_CHECK_INTERVAL=86400    # seconds between update checks
HV_COOLDOWN=300            # seconds before the boot animation can replay
HV_SERVICES_STR="ssh nginx docker wings"   # services shown in `hv` (VPS)
# HV_QUICK=1               # skip the boot animation
# TX_DEV_DISCORD=""        # extra rows for the `dev` card
# TX_DEV_SITE=""
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/Its2Pawan/Theam-x/main/install.sh | bash -s uninstall
```

or manually:

```bash
sed -i '/\.sino\/theam-x\.sh/d;/^# Theam-X$/d' ~/.bashrc && rm -rf ~/.sino
```

## Repository layout

```
Theam-x/
├── install.sh     installer / uninstaller (VPS + Termux)
├── theam-x.sh     the theme (boot, sfetch, dev, hv, matrix, prompt, updater)
├── ver.txt        current version (used by auto-update)
├── LICENSE        All Rights Reserved
└── README.md
```

### Releasing an update

1. Edit `theam-x.sh`.
2. Raise the number in `ver.txt` (for example `1.0.1` to `1.0.2`).
3. Push to `main`. Every installed device picks it up within a day, or immediately with `txupdate`.

## Requirements

- bash 4+ (Termux and all current VPS distros have it)
- `curl` or `wget` (the installer installs curl if both are missing)
- A terminal of at least 50x14 characters for the animations

## Notes

- Theam-X is a **bash** theme; it is loaded from `~/.bashrc`.
- Auto-update runs code from this repository on your device. Only install from the official repository.
- Android blocks some system stats in Termux (for example CPU usage); those rows show `n/a`.

## Author

**Its2Pawan** · https://github.com/Its2Pawan

## License

Copyright (c) 2026 Its2Pawan. **All Rights Reserved.** See [LICENSE](LICENSE).
