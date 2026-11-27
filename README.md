<div align="center">

```
  _____ __  __
 |_   _|\ \/ /
   | |   \  /
   | |   /  \
   |_|  /_/\_\
```

# Theam-X

**Hacker-style terminal theme, system toolkit & built-in `/ai` assistant for VPS and Termux**
7 color themes · 4 prompt styles · 3 matrix rain modes · `/ai` chat & command helper · live monitor · VPS & Termux utilities · auto-update

![version](https://img.shields.io/badge/version-2.9.0-brightgreen)
![shell](https://img.shields.io/badge/shell-bash-green)
![platform](https://img.shields.io/badge/platform-VPS%20%7C%20Termux-black)
![license](https://img.shields.io/badge/license-All%20Rights%20Reserved-red)

</div>

---

## Features

- **Built-in Small AI (`/ai`, `ai`, `txai`)**: Supports `openai` (OpenAI / Groq / OpenRouter / DeepSeek / vLLM), `gemini`, `anthropic`, and `ollama`. Prompts for provider type, base URL, API key, model, temperature, max tokens, and system prompt on first run (saved privately to `~/.sino/ai.conf` with `chmod 600`). Supports one-shot questions, piped logs, interactive multi-turn chat, and `-c` command generation.
- **7 Color Themes (`txtheme`)**: `matrix`, `cyber`, `crimson`, `amber`, `ice`, `purple`, `neon` — switch live or save to config.
- **4 Prompt Styles**: `hacker`, `minimal`, `power`, `compact`.
- **3 Rain Modes**: `binary` (`0/1`), `hex` (`0-9A-F`), `glyph` (`!@#$%&*...`).
- **Boot screen (`hvboot`)**: Matrix rain with typed startup log (press any key to skip; respects cooldown).
- **`sfetch` / `sfetch -q`**: Animated rain info panel or instant TX ASCII logo + system specs.
- **`hv`**: Live system monitor (CPU, RAM, Disk, Load, Network speed, Temp, Battery, Services) with live hotkeys (`t` theme, `r` rain, `p` pause, `q` quit).
- **VPS + Termux System Toolkit**: `txcpu`, `txmem`, `txtemp`, `txlog`, `txssh`, `myip`, `ports`, `netinfo`, `pingtest`, `dns`, `passgen`, `diskinfo`, `proctop`, `svc`, `sysup`, `txclean`, `extract`, `mkcd`, `backup`, `serve`, `txdiag`, `txbattery`, `txstorage`, `txwake`.
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

## Small AI (`/ai`)

On your first run of `/ai`, Theam-X asks you to configure:
- **Type**: `openai` | `gemini` | `anthropic` | `ollama`
- **Base URL**: e.g. `https://api.openai.com/v1`, `https://api.groq.com/openai/v1`, `https://generativelanguage.googleapis.com/v1beta`, `https://api.anthropic.com/v1`, `http://127.0.0.1:11434`
- **API Key**: hidden input, stored with `chmod 600` in `~/.sino/ai.conf` (optional for local `ollama`)
- **Model & Extras**: model name, temperature, max tokens, system prompt

```bash
/ai                              # First-time setup wizard, or interactive chat
/ai install cloudflare in termux # One-shot answer (formatted for terminal)
cat error.log | /ai summarize    # Pipe logs directly to AI
/ai -c find files larger than 100M  # Generate command and confirm before running
/ai auto safe                     # Auto-approve safe writes & commands (or: on / off)
/ai agent -y "build & test app.py"   # Full AGY/Claude CLI agent (ls, find, grep, read, write, patch, run, plan)
aiskill install all                  # Install all 7 built-in AGY SKILL.md packs
aiskill install owner/repo           # Install a SKILL.md directly from GitHub or URL
/ai make hello.py simple http server # Create new file (Save or Save & Run!)
/ai edit hello.py add /health route   # Edit file with diff preview & .bak backup
txenv | txbench | txcron             # Runtime check, CPU/disk/net benchmark, cron helper
/ai do install cloudflared           # Interactive command runner (auto-fixes errors!)
/ai code app.py                      # Analyze code file for bugs & improvements
/ai fix script.sh                    # Fix bugs in file (creates .bak backup)
/ai diff | /ai commit | /ai project  # Git diff review, commit msg, codebase summary
/ai err "python3 app.py"             # Run command and auto-diagnose any error
/ai explain nginx.conf               # Explain any code file or command
airoute add fast openai https://api.groq.com/openai/v1 gsk_... llama-3.3-70b-versatile
airoute add code anthropic https://api.anthropic.com/v1 sk-ant-... claude-3-5-sonnet-latest
/ai mood coder                   # Mood: fast | coder | teacher | strict | friendly
/remember my VPS domain is example.com
aimem                            # Manage AGY-style global, project & topic memories
/ai config                       # Re-run setup wizard
/ai status | /ai test | /ai reset
```

## Commands

### Theme & Visuals
| Command | What it does |
|---|---|
| `theamx` / `txhelp` | Show full command reference & active theme info |
| `txtheme` | Interactive options menu (`txtheme <color>`, `txtheme prompt <style>`, `txtheme rain <mode>`, `txtheme banner on\|off`) |
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
| `txssh [status\|keys\|addkey]` | SSH service status, active sessions & `authorized_keys` manager |

### System, VPS & Termux
| Command | What it does |
|---|---|
| `txcpu` | CPU model, architecture, cores, frequency, load & temp |
| `txmem` | RAM & Swap breakdown + top memory processes |
| `txtemp` | Thermal zones & hardware sensors |
| `txlog [sys\|auth\|kernel\|svc]` | Unified system, SSH auth, kernel, or service logs (`journalctl`/`dmesg`/`logcat`) |
| `diskinfo [path]` | Clean filesystem usage + top 10 largest items in path |
| `proctop [n]` | Top CPU/RAM processes (GNU & BusyBox compatible) |
| `svc [cmd] [name]` | Service manager (systemd / OpenRC / `termux-services`) |
| `sysup [-y]` | Update OS packages (`pkg`, `apt-get`, `dnf`, `yum`, `apk`, `pacman`) |
| `txclean [--all]` | Clean package & temp caches (`--all` also clears `~/.cache` & old journal logs) |
| `txdiag` | Full VPS + Termux environment & health diagnostic |
| `txbattery` | Battery level & status (`termux-battery-status` / sysfs) |
| `txstorage` | Termux `~/storage` check/setup, or VPS disk mounts |
| `txwake [on\|off]` | Toggle Termux CPU wake-lock |

### Files & Shortcuts
| Command | What it does |
|---|---|
| `py` / `py3` | Run `python3` (with `python` fallback) |
| `pipi <pkg>` | Install Python package via `pip` |
| `cls` / `tx` / `reload` | Clear screen / show command menu / reload Theam-X |
| `..` / `...` / `....` | Jump up 1, 2, or 3 parent directories |
| `ll` / `la` | Detailed (`ls -alF`) / hidden (`ls -A`) file listing |
| `gst` / `ga` / `gc` / `gp` / `gpush` / `gd` / `gl` | Git shortcuts (`status`, `add`, `commit`, `pull`, `push`, `diff`, `log`) |
| `extract <file>` | Extract `.tar.*`, `.zip`, `.gz`, `.bz2`, `.xz`, `.7z`, `.rar` |
| `mkcd <dir>` | Create directory and `cd` into it |
| `backup <file\|dir>` | Timestamped `.bak` or `.tar.gz` backup |
| `serve [port] [dir]` | Quick local HTTP file server (default port `8080`) |

### Updates & Removal
| Command | What it does |
|---|---|
| `txver` / `txupdate` | Check version / update from GitHub |
| `txuninstall` | Uninstall Theam-X interactively |

## Configuration

`~/.sino/config` (created on install, kept on reinstall, editable via `txtheme` or `txconfig`):

```bash
TX_THEME="matrix"          # matrix | cyber | crimson | amber | ice | purple | neon
TX_PROMPT="hacker"         # hacker | minimal | power | compact
TX_RAIN="binary"           # binary | hex | glyph
TX_BOOT=1                  # 1 = boot animation on login, 0 = skip
TX_BANNER=1                # 1 = compact status line on login, 0 = hide
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

## Author

**Its2Pawan** · https://github.com/Its2Pawan

## License

Copyright (c) 2026 Its2Pawan. **All Rights Reserved.** See [LICENSE](LICENSE).
