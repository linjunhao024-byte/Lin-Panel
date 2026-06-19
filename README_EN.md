<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:000000,100:0b0f0b&height=220&section=header&text=LIN-Panel&fontSize=50&fontColor=00FF41&fontAlignY=35&desc=Lightweight%20Terminal%20Dashboard%20Core&descSize=15&descColor=00FF41&descAlignY=55&animation=twinkling" width="100%"/>

**If this project helps you, please give it a ⭐ Star!**

# 📊 LIN-Panel

**Minimalist Traffic Monitor Pseudo-Panel · v1.0.4**

> No ports · No daemons · No web frameworks · Everything runs inside SSH

**English** | [中文](README.md)

<br>

[![Stars](https://img.shields.io/github/stars/linjunhao024-byte/Lin-Panel?style=flat&logo=github&cacheSeconds=60)](https://github.com/linjunhao024-byte/Lin-Panel/stargazers)
[![Forks](https://img.shields.io/github/forks/linjunhao024-byte/Lin-Panel?style=flat&logo=github&cacheSeconds=60)](https://github.com/linjunhao024-byte/Lin-Panel/network/members)
[![Issues](https://img.shields.io/github/issues/linjunhao024-byte/Lin-Panel?style=flat&logo=github&cacheSeconds=60)](https://github.com/linjunhao024-byte/Lin-Panel/issues)
[![License](https://img.shields.io/github/license/linjunhao024-byte/Lin-Panel?style=flat&cacheSeconds=3600)](https://github.com/linjunhao024-byte/Lin-Panel/blob/main/LICENSE)
[![Language](https://img.shields.io/badge/Language-Shell-007ACC?style=flat&logo=gnu-bash)](#)
[![Dependencies](https://img.shields.io/badge/Dependencies-Zero-brightgreen?style=flat)](#)

</div>

---

## 🤔 Why This Exists

You have a VPS with a monthly traffic cap. Your biggest fear: **silently exceeding the limit and getting throttled.**

| | Web Panel | vnstat CLI | **LIN-Panel** |
|---|:---:|:---:|:---:|
| Opens ports | ✅ Yes | ❌ No | ❌ **No** |
| Security risk | ⚠️ Scannable | ✅ None | ✅ **None** |
| Resources | 100MB+ | ~0 | **~3MB** |
| Human-readable | ✅ | ❌ | ✅ |
| Alerts | ✅ | ❌ | ✅ |
| Install | Complex | None needed | **One command** |

---

## ✨ Features

| Module | Features |
|--------|----------|
| 📊 **Data Display** | Real-time traffic · Reset countdown · Daily details · Localized vnstat tables |
| 🔔 **Smart Alerts** | 🟢 <70% · 🟡 70-90% · 🔴 >90% · Auto-calculated percentage |
| 📈 **Trend Analysis** | 7-day bar chart · Daily snapshots · Auto-trim 30 days |
| 🌐 **Network Diag** | Active connections · Local ports Top 5 · Real-time speed |
| 🔐 **Billing Modes** | Bidirectional / Inbound / Outbound · Choose at install |
| 🌐 **Timezone** | 9 popular timezones · CN/HK/JP/SG/US/UK/EU/UTC |
| 📱 **Telegram** | Traffic reports · Daily/weekly/monthly · Test message verify |
| ⌨️ **Interactive** | Custom command · Numbered menu · One-click uninstall · Idempotent |

---

## 🚀 Quick Install

### Alpine Linux

```bash
wget -O install-alpine.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-alpine.sh && chmod +x install-alpine.sh && ./install-alpine.sh
```

### Debian

```bash
wget -O install-debian.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-debian.sh && chmod +x install-debian.sh && ./install-debian.sh
```

### Ubuntu

```bash
wget -O install-ubuntu.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-ubuntu.sh && chmod +x install-ubuntu.sh && ./install-ubuntu.sh
```

### English Panel

Use `-en` suffix scripts:

```bash
# Alpine (English)
wget -O install-alpine-en.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-alpine-en.sh && chmod +x install-alpine-en.sh && ./install-alpine-en.sh

# Debian (English)
wget -O install-debian-en.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-debian-en.sh && chmod +x install-debian-en.sh && ./install-debian-en.sh

# Ubuntu (English)
wget -O install-ubuntu-en.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-ubuntu-en.sh && chmod +x install-ubuntu-en.sh && ./install-ubuntu-en.sh
```

### Clone

```bash
git clone https://github.com/linjunhao024-byte/Lin-Panel.git
cd Lin-Panel
# Chinese
chmod +x install-alpine.sh && ./install-alpine.sh     # Alpine
chmod +x install-debian.sh && ./install-debian.sh     # Debian
chmod +x install-ubuntu.sh && ./install-ubuntu.sh     # Ubuntu
# English
chmod +x install-alpine-en.sh && ./install-alpine-en.sh   # Alpine
chmod +x install-debian-en.sh && ./install-debian-en.sh   # Debian
chmod +x install-ubuntu-en.sh && ./install-ubuntu-en.sh   # Ubuntu
```

### Requirements

| Item | Requirement |
|------|-------------|
| OS | Alpine / Debian / Ubuntu |
| Privileges | root |
| Dependencies | vnstat (auto-installed) |
| Disk | < 5MB |
| Memory | < 3MB |

---

## 📋 Installation Wizard

Fully interactive, press Enter for defaults:

```
┌──────────── Configuration ────────────┐

  ① Traffic limit     [default: 350GB]
  ② Billing mode      [Bidirectional / Inbound / Outbound]
  ③ Reset time        [Day 1-31 + H:M:S]
  ④ Login auto-start  [Y/n]
  ⑤ Command name      [default: lin-panel]

└───────────────────────────────────────┘

┌──────────── Steps ────────────────────┐

  [1/7] 🌐 Timezone      9 timezones
  [2/7] 📦 vnstat         Only dependency
  [3/7] 🎨 Generate       Dynamic injection
  [4/7] 🔄 Reset          Smart month-end fallback
  [5/7] 📊 Cron           Idempotent append
  [6/7] 📱 Telegram       Test message verify
  [7/7] 🔐 Login config   Idempotent write

└───────────────────────────────────────┘
```

---

## 🖥️ Usage

```bash
# Auto-show (recommended) — pops up on every SSH login
# Custom command — open anytime
lin-panel              # or your custom name

# Direct execution
/root/lin-panel.sh
```

### Menu

```
  ┌──── Menu ────────┐
  │  [1] Refresh      │  ← Reload panel
  │  [2] 7-Day Trend  │  ← Bar chart
  │  [3] Connections  │  ← Connection status
  │  [4] Speed Test   │  ← Measure speed
  │  [5] Uninstall    │  ← Remove all files
  │  [0] Exit         │  ← Back to shell
  └──────────────────┘
```

---

## 🖼️ Preview

```
╭──────────────────────────────────────────────────────────────╮
│                    📊 LIN-PANEL Traffic Monitor                    │
╰──────────────────────────────────────────────────────────────╯

  📈 Current Traffic ─ Bidirectional Limit: 350GB
     ✅ Used: 83.90 / 350 GB (24.0%)       ← 🟢 Normal
     ⚠️ Used: 248.50 / 350 GB (71.0%)      ← 🟡 Warning
     🚨 Used: 319.20 / 350 GB (91.2%)      ← 🔴 Critical
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
├── lin-panel.sh              # Panel script
├── traffic_reset_check.sh    # Smart reset (month-end fallback)
├── traffic_check.sh          # Telegram push (optional)
└── traffic_history.log       # Trend log (auto-trim 30 days)

/usr/local/bin/
└── lin-panel → /root/lin-panel.sh

Crontab:
├── 59 23 * * *        Daily record + trim
├── 0 0 * * *          Daily reset check
└── 0 9/12 * * *       Telegram push (optional)
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
              │  bash (Debian/Ubuntu) │
              │  sh (Alpine)          │
              └───────────┬───────────┘
                          │
         ┌────────────────┼────────────────┐
         │                │                │
    ┌────▼─────┐   ┌──────▼──────┐  ┌─────▼──────┐
    │ vnstat   │   │ sys/class/  │  │ Runtime    │
    │ Database │   │ net/        │  │ Calculation│
    │(kernel)  │   │(kernel API) │  │            │
    │          │   │             │  │ Percentage │
    │ Monthly/ │   │ RX/TX bytes │  │ Countdown  │
    │ Daily    │   │             │  │ Alert Level│
    └──────────┘   └─────────────┘  └────────────┘
```

| Component | Memory | CPU | Ports |
|-----------|:---:|:---:|:---:|
| vnstat | ~2MB | 0% (kernel) | None |
| Panel script | ~1MB (runtime) | ~0% (runtime) | None |
| Cron tasks | ~0 | ~0 | None |
| **Total** | **~3MB** | **~0%** | **0** |

---

## ❓ FAQ

<details>
<summary><strong>Q: Panel shows "No data"?</strong></summary>

vnstat needs a few minutes to collect data. Wait or run: `vnstat -u`

</details>

<details>
<summary><strong>Q: How to change config?</strong></summary>

Re-run the installer. All parameters reconfigure without affecting existing data.

</details>

<details>
<summary><strong>Q: How to uninstall?</strong></summary>

Use menu `[5] Uninstall`, or manually:

```bash
rm -f /root/lin-panel.sh /root/traffic_reset_check.sh /root/traffic_check.sh /root/traffic_history.log
rm -f /usr/local/bin/lin-panel
sed -i '/lin-panel/d' /root/.profile
crontab -e  # remove related entries
```

</details>

<details>
<summary><strong>Q: Re-install safe?</strong></summary>

Yes. Idempotent design: `.profile` checks before append, Cron deduplicates, `ln -sf` auto-overwrites.

</details>

<details>
<summary><strong>Q: Supported systems?</strong></summary>

| System | Script | Package Manager | Service Manager |
|--------|--------|-----------------|-----------------|
| Alpine | `install-alpine.sh` | apk | OpenRC |
| Debian | `install-debian.sh` | apt-get | systemd |
| Ubuntu | `install-ubuntu.sh` | apt-get | systemd |

</details>

<details>
<summary><strong>Q: How accurate?</strong></summary>

Data from vnstat (kernel network stats). Typical accuracy: 1-3%.

</details>

---

## 📄 License

[MIT License](LICENSE) © [linjunhao024-byte](https://github.com/linjunhao024-byte)

---

<div align="center">

**⭐ If this helps you, give a Star!**

![Star](https://img.shields.io/github/stars/linjunhao024-byte/Lin-Panel?style=social)

</div>
