<div align="center">

```text
    __  ____ _  __          ____                   __
   / / /  // |/ /         / __ \____ _____  ___  / /
  / /  / / /    /  ______ / /_/ / __ `/ __ \/ _ \/ /
 / /__/ / / /|  / /_____// ____/ /_/ / / / /  __/ /
/____/___/_/ |_/        /_/    \__,_/_/ /_/\___/_/
```

**If this project helps you, please give it a ⭐ Star!**

![Stars](https://img.shields.io/github/stars/linjunhao024-byte/Lin-Panel?style=social)

# 📊 LIN-Panel

**Minimalist Traffic Monitor Pseudo-Panel · Alpine / Debian / Ubuntu · v1.0.0**

> No ports · No daemons · No web frameworks · Everything runs inside SSH

**English** | [中文](README.md)

<br>

![Alpine](https://img.shields.io/badge/Alpine%20Linux-0A1628?style=for-the-badge&logo=alpinelinux&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Language](https://img.shields.io/badge/Language-POSIX%20sh-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-FF6B6B?style=for-the-badge)

</div>

---

## 📖 Table of Contents

- [🤔 Why This Exists](#-why-this-exists)
- [✨ Features](#-features)
- [🚀 Quick Install](#-quick-install)
- [📋 Installation Wizard](#-installation-wizard)
- [🖥️ Usage](#️-usage)
- [🖼️ Preview](#️-preview)
- [📁 File Structure](#-file-structure)
- [⚙️ Architecture](#️-architecture)
- [❓ FAQ](#-faq)
- [📄 License](#-license)

---

## 🤔 Why This Exists

You have an overseas VPS with a monthly traffic cap and bidirectional billing. Your biggest fear: **silently exceeding the limit and getting throttled or charged extra.**

Existing solutions are either too heavy (web panels consume resources and expose ports) or too light (raw `vnstat` output is hard to read).

**LIN-Panel** strikes the balance:

| | Web Panel | vnstat CLI | **LIN-Panel** |
|---|:---:|:---:|:---:|
| Opens ports | ✅ Yes | ❌ No | ❌ **No** |
| Security risk | ⚠️ Scannable | ✅ None | ✅ **None** |
| Resource usage | 100MB+ | ~0 | **~2MB** |
| Human-readable | ✅ | ❌ | ✅ |
| Traffic alerts | ✅ | ❌ | ✅ |
| Installation | Complex | None needed | **One command** |

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 📊 Data Display
- 📈 Real-time traffic overview (RX/TX/Total)
- ⏰ Reset countdown (days/hours/minutes)
- 📅 Daily traffic detail table
- 🌐 Localized vnstat monthly/daily tables

</td>
<td width="50%">

### 🔔 Smart Alerts
- ✅ Green: traffic < 70%
- ⚠️ Yellow: traffic 70-90%
- 🚨 Red: traffic > 90%
- Auto-calculated percentage & usage

</td>
</tr>
<tr>
<td width="50%">

### 📈 Trend Analysis
- 7-day traffic bar chart
- Daily automatic snapshots
- █░ text rendering, intuitive
- Auto-normalized for any scale

</td>
<td width="50%">

### 🌐 Network Diagnostics
- Active connection count
- Top 5 destination ports
- Real-time speed sampling (UL/DL)
- Quick identification of traffic anomalies

</td>
</tr>
<tr>
<td width="50%">

### 🔐 Billing Modes
- Bidirectional (RX + TX)
- Inbound only (download)
- Outbound only (upload)
- Choose during installation

</td>
<td width="50%">

### ⌨️ Interactive UX
- Custom command name
- Numbered menu navigation
- Auto-show on login (optional)
- Idempotent install, safe to re-run

### 🌐 Timezone Management
- 9 popular timezones available
- CN/HK/JP/SG/US East/US West/UK/EU/UTC

### 📱 Telegram Alerts
- Auto-push traffic reports to your phone
- Daily / Weekly / Monthly frequency
- Percentage alerts (⚠️70% / 🚨90%)

</td>
</tr>
</table>

---

## 🚀 Quick Install

Choose the install script for your system:

### Alpine Linux

```bash
wget -O install.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install.sh && chmod +x install.sh && ./install.sh
```

### Debian

```bash
wget -O install-debian.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-debian.sh && chmod +x install-debian.sh && ./install-debian.sh
```

### Ubuntu

```bash
wget -O install-ubuntu.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-ubuntu.sh && chmod +x install-ubuntu.sh && ./install-ubuntu.sh
```

### English Panel Versions

If you prefer the panel UI in English, use the `-en` scripts:

```bash
# Alpine Linux (English Panel)
wget -O install-alpine-en.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-alpine-en.sh && chmod +x install-alpine-en.sh && ./install-alpine-en.sh

# Debian (English Panel)
wget -O install-debian-en.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-debian-en.sh && chmod +x install-debian-en.sh && ./install-debian-en.sh

# Ubuntu (English Panel)
wget -O install-ubuntu-en.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-ubuntu-en.sh && chmod +x install-ubuntu-en.sh && ./install-ubuntu-en.sh
```

### Or clone

```bash
git clone https://github.com/linjunhao024-byte/Lin-Panel.git
cd Lin-Panel
# Choose your system:
chmod +x install.sh && ./install.sh                # Alpine
chmod +x install-debian.sh && ./install-debian.sh  # Debian
chmod +x install-ubuntu.sh && ./install-ubuntu.sh  # Ubuntu
```

### Requirements

| Item | Requirement |
|------|-------------|
| OS | Alpine Linux / Debian / Ubuntu |
| Privileges | root |
| Dependencies | vnstat (auto-installed) |
| Disk | < 5MB |
| Memory | < 3MB |

---

## 📋 Installation Wizard

The installation is fully interactive. All parameters are customizable — press Enter for defaults:

```
╭──────────────────────────────────────────────────────────────╮
│       Welcome to linjunhao024-byte Minimalist Traffic Panel Installer │
╰──────────────────────────────────────────────────────────────╯

┌──────────── Configuration ────────────┐

  ① Traffic Limit
     Enter traffic limit (GB) [default: 350]:

  ② Billing Mode
     [1] Bidirectional (Inbound+Outbound) [default]
     [2] Inbound only (Download)
     [3] Outbound only (Upload)

  ③ Reset Time
     Day (1-28)    [default 1]:
     Hour (0-23)   [default 0]:
     Minute (0-59) [default 0]:
     Second (0-59) [default 0]:

  ④ Auto-Show on Login
     Show panel on SSH login? [Y/n] [default: Y]

  ⑤ Command Name
     Enter custom command name [default: lin-panel]:

└────────────────────────────────────┘
```

### Installation Steps

| Step | Action | Description |
|:---:|--------|-------------|
| 1/7 | 🌐 Timezone | 9 popular timezones, or keep current |
| 2/7 | 📦 vnstat | Install the only hard dependency |
| 3/7 | 🎨 Generate Panel | Heredoc with dynamic variable injection |
| 4/7 | 🔄 Reset Script | Monthly vnstat data cleanup |
| 5/7 | 📊 Cron Tasks | Idempotent append, no overwrite |
| 6/7 | 📱 Telegram | Optional, daily/weekly/monthly alerts |
| 7/7 | 🔐 Login Config | Idempotent .profile write + command symlink |

---

## 🖥️ Usage

### Option 1: Auto-Show (Recommended)

Enable during installation. The panel pops up automatically on every SSH login.

### Option 2: Custom Command

```bash
lin-panel            # default command name
your-custom-name     # or your chosen name
```

### Option 3: Direct Execution

```bash
/root/lin-panel.sh
```

### Menu Operations

```
  ┌──── Menu ────────┐
  │  [1] Refresh      │  ← Reload panel data
  │  [2] 7-Day Trend  │  ← View bar chart
  │  [3] Connections  │  ← View connection status
  │  [4] Speed Test   │  ← Measure current speed
  │  [5] Uninstall    │  ← Remove all files
  │  [0] Exit         │  ← Return to shell
  └──────────────────┘
```

---

## 🖼️ Preview

### 🟢 Normal State (< 70%)

```
╭──────────────────────────────────────────────────────────────╮
│           📊 linjunhao024-byte Traffic Monitor               │
╰──────────────────────────────────────────────────────────────╯

  📈 Current Traffic ─ Bidirectional Limit: 350GB
     ✅ Used: 83.90 / 350 GB (24.0%)       ← Green <70%
     ⚠️ Used: 248.50 / 350 GB (71.0%)      ← Yellow 70-90%
     🚨 Used: 319.20 / 350 GB (91.2%)      ← Red >90%
     ⏰ Reset in: 13d 7h 22m

  ┌──── Menu ────────┐
  │  [1] Refresh      │
  │  [2] 7-Day Trend  │
  │  [3] Connections  │
  │  [4] Speed Test   │
  │  [5] Uninstall    │
  │  [0] Exit         │
  └──────────────────┘
```

---

## 📁 File Structure

```
/root/
├── lin-panel.sh           # Panel script
├── traffic_reset.sh       # Monthly reset
├── traffic_check.sh       # Telegram alerts (optional)
└── traffic_history.log    # Trend log (auto-trim 30 days)

/usr/local/bin/
└── lin-panel → /root/lin-panel.sh

Crontab:
├── 59 23 * * *  Daily 23:59 record traffic snapshot
└── MM HH DD * * Monthly traffic reset
```

---

## ⚙️ Architecture

```
     ┌─────────────────────────────────────────────┐
     │              SSH Login                       │
     │    .profile → /root/lin-panel.sh             │
     └────────────────────┬────────────────────────┘
                          │
              ┌───────────▼───────────┐
              │     lin-panel.sh      │
              │   (Pure POSIX sh)     │
              └───────────┬───────────┘
                          │
         ┌────────────────┼────────────────┐
         │                │                │
    ┌────▼─────┐   ┌──────▼──────┐  ┌─────▼──────┐
    │ vnstat   │   │ /proc/net/  │  │ Runtime    │
    │ Database │   │    dev      │  │ Calculation│
    │(kernel)  │   │(kernel API) │  │            │
    │          │   │             │  │ Percentage │
    │ Monthly/ │   │ RX/TX bytes │  │ Countdown  │
    │ Daily    │   │             │  │ Alert Level│
    └──────────┘   └─────────────┘  └────────────┘
```

### Resource Usage

| Component | Memory | CPU | Ports |
|-----------|:---:|:---:|:---:|
| vnstat | ~2MB | 0% (kernel-level) | None |
| Panel script | ~1MB (runtime) | ~0% (runtime) | None |
| Cron tasks | ~0 | ~0 | None |
| **Total** | **~3MB** | **~0%** | **0** |

---

## ❓ FAQ

<details>
<summary><strong>Q: Panel shows "No historical data"?</strong></summary>

vnstat needs time to collect data. Wait a few minutes after installation, or trigger manually:

```bash
vnstat -u
```

</details>

<details>
<summary><strong>Q: How to change the traffic limit or billing mode?</strong></summary>

Re-run the installation script. All parameters will be reconfigured without affecting existing data.

</details>

<details>
<summary><strong>Q: How to uninstall?</strong></summary>

```bash
# Remove panel script and command
rm -f /root/lin-panel.sh /usr/local/bin/lin-panel

# Remove reset script and logs
rm -f /root/traffic_reset.sh /root/traffic_history.log

# Remove from .profile (manual edit)
vi /root/.profile

# Remove cron entries
crontab -e
```

</details>

<details>
<summary><strong>Q: What happens if I run the installer again?</strong></summary>

Safe by design. The script uses idempotent operations:

- `.profile`: checks before appending
- Cron: checks for existing entries before adding
- Symlink: `ln -sf` auto-overwrites

</details>

<details>
<summary><strong>Q: Which Linux distros are supported?</strong></summary>

Officially supported with dedicated install scripts:

| Distro | Install Script | Package Manager | Service Manager |
|--------|---------------|-----------------|-----------------|
| Alpine Linux | `install.sh` | apk | OpenRC |
| Debian | `install-debian.sh` | apt-get | systemd |
| Ubuntu | `install-ubuntu.sh` | apt-get | systemd |

To port to other distros (CentOS, Arch, etc.):

- Package manager: `apk` / `apt-get` → `yum` / `pacman`
- Service manager: `rc-service` / `systemctl` → equivalent commands

</details>

<details>
<summary><strong>Q: How accurate is the traffic data?</strong></summary>

Data comes from vnstat, which reads kernel network interface statistics. Typical accuracy is within 1-3%.

</details>

---

## 📄 License

[MIT License](LICENSE) © [linjunhao024-byte](https://github.com/linjunhao024-byte)

---

<div align="center">

**If this project helps you, please give it a ⭐ Star!**

<br>

![Star](https://img.shields.io/github/stars/linjunhao024-byte/Lin-Panel?style=social)

</div>
