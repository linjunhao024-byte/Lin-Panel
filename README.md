<div align="center">

```text
    __  ____ _  __          ____                   __
   / / /  // |/ /         / __ \____ _____  ___  / /
  / /  / / /    /  ______ / /_/ / __ `/ __ \/ _ \/ /
 / /__/ / / /|  / /_____// ____/ /_/ / / / /  __/ /
/____/___/_/ |_/        /_/    \__,_/_/ /_/\___/_/
```

**如果这个项目对你有帮助，请给一个 ⭐ Star！**

![Stars](https://img.shields.io/github/stars/linjunhao024-byte/Lin-Panel?style=social)

# 📊 LIN-Panel

**极简流量监控伪面板 · Alpine / Debian / Ubuntu · v1.0.0**

> 不开端口 · 不跑服务 · 不装 Web 框架 · SSH 会话内完成一切

[English](README_EN.md) | **中文**

<br>

![Alpine](https://img.shields.io/badge/Alpine%20Linux-0A1628?style=for-the-badge&logo=alpinelinux&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Language](https://img.shields.io/badge/Language-POSIX%20sh-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-FF6B6B?style=for-the-badge)

</div>

---

## 📖 目录

- [🤔 为什么需要这个](#-为什么需要这个)
- [✨ 功能一览](#-功能一览)
- [🚀 快速安装](#-快速安装)
- [📋 安装向导](#-安装向导)
- [🖥️ 使用方式](#️-使用方式)
- [🖼️ 面板预览](#️-面板预览)
- [📁 文件结构](#-文件结构)
- [⚙️ 技术架构](#️-技术架构)
- [❓ 常见问题](#-常见问题)
- [📄 开源协议](#-开源协议)

---

## 🤔 为什么需要这个

你有一台海外 VPS，套餐流量有限，双向计费。你最怕的事情是：**某个月流量悄悄跑超，被限速或额外扣钱。**

市面上的解决方案要么太重（Web 面板占资源、开端口有风险），要么太轻（`vnstat` 命令行输出看不懂）。

**LIN-Panel** 在两者之间找到平衡：

| | Web 面板 | vnstat 命令行 | **LIN-Panel** |
|---|:---:|:---:|:---:|
| 开端口 | ✅ 需要 | ❌ 不需要 | ❌ **不需要** |
| 安全风险 | ⚠️ 被扫描 | ✅ 无 | ✅ **无** |
| 资源占用 | 100MB+ | ~0 | **~2MB** |
| 中文界面 | ✅ | ❌ | ✅ |
| 预警提醒 | ✅ | ❌ | ✅ |
| 安装难度 | 复杂 | 无需安装 | **一键** |

---

## ✨ 功能一览

<table>
<tr>
<td width="50%">

### 📊 数据展示
- 📈 实时流量总览（入站/出站/合计）
- ⏰ 重置倒计时（天/时/分）
- 📅 每日流量明细表
- 🌐 vnstat 月度/日度汉化表格

</td>
<td width="50%">

### 🔔 智能预警
- ✅ 绿色：流量 < 70%
- ⚠️ 黄色：流量 70-90%
- 🚨 红色：流量 > 90%
- 百分比 + 用量自动计算

</td>
</tr>
<tr>
<td width="50%">

### 📈 趋势分析
- 近 7 天流量柱状图
- 每日自动记录快照
- █░ 文本渲染，直观易读
- 自动归一化，适配任意量级

</td>
<td width="50%">

### 🌐 网络诊断
- 活跃连接数统计
- 目标端口 Top 5 排行
- 实时流速采样（上传/下载）
- 异常流量来源快速定位

</td>
</tr>
<tr>
<td width="50%">

### 🔐 计费模式
- 双向计费（入站 + 出站）
- 入站计费（仅下载）
- 出站计费（仅上传）
- 安装时自由选择

</td>
<td width="50%">

### ⌨️ 交互体验
- 自定义快捷命令名
- 数字菜单操作
- 登录自动展示（可选）
- 幂等安装，可重复运行

### 🌐 时区管理
- 9 个主流时区可选
- 中/港/日/新/美东/美西/英/欧/UTC

### 📱 Telegram 推送
- 流量报告自动推送到手机
- 支持每日/每周/每月频率
- 百分比预警（⚠️70% / 🚨90%）

</td>
</tr>
</table>

---

## 🚀 快速安装

根据你的系统选择对应的安装脚本：

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

### 英文版面板

如果希望面板界面显示英文，使用对应的 `-en` 脚本：

```bash
# Alpine Linux (English Panel)
wget -O install-alpine-en.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-alpine-en.sh && chmod +x install-alpine-en.sh && ./install-alpine-en.sh

# Debian (English Panel)
wget -O install-debian-en.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-debian-en.sh && chmod +x install-debian-en.sh && ./install-debian-en.sh

# Ubuntu (English Panel)
wget -O install-ubuntu-en.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-ubuntu-en.sh && chmod +x install-ubuntu-en.sh && ./install-ubuntu-en.sh
```

### 或者克隆安装

```bash
git clone https://github.com/linjunhao024-byte/Lin-Panel.git
cd Lin-Panel
# 根据系统选择：
chmod +x install.sh && ./install.sh           # Alpine
chmod +x install-debian.sh && ./install-debian.sh  # Debian
chmod +x install-ubuntu.sh && ./install-ubuntu.sh  # Ubuntu
```

### 系统要求

| 项目 | 要求 |
|------|------|
| 系统 | Alpine Linux / Debian / Ubuntu |
| 权限 | root |
| 依赖 | vnstat（脚本自动安装） |
| 磁盘 | < 5MB |
| 内存 | < 3MB |

---

## 📋 安装向导

安装过程为全交互式，所有参数可自定义，直接回车使用默认值：

```
╭──────────────────────────────────────────────────────────────╮
│          欢迎使用 linjunhao024-byte 极简流量面板一键安装脚本         │
╰──────────────────────────────────────────────────────────────╯

┌──────────── 自定义配置 ────────────┐

  ① 流量上限
     请输入流量上限(GB) [默认: 350]:

  ② 计费模式
     [1] 双向计费 (入站+出站) [默认]
     [2] 入站计费 (仅下载)
     [3] 出站计费 (仅上传)

  ③ 重置时间
     日期 (1-28)  [默认 1]:
     小时 (0-23)  [默认 0]:
     分钟 (0-59)  [默认 0]:
     秒数 (0-59)  [默认 0]:

  ④ 登录自启
     是否在 SSH 登录时自动展示面板？[Y/n] [默认: Y]

  ⑤ 快捷命令
     请输入命令名称 [默认: lin-panel]:

└────────────────────────────────────┘
```

### 安装步骤

| 步骤 | 操作 | 说明 |
|:---:|------|------|
| 1/7 | 🌐 时区配置 | 9 个主流时区可选，或保持当前 |
| 2/7 | 📦 安装 vnstat | 唯一硬依赖，内核层流量统计 |
| 3/7 | 🎨 生成面板 | heredoc 动态注入用户配置 |
| 4/7 | 🔄 重置脚本 | 每月清零 vnstat 数据 |
| 5/7 | 📊 定时任务 | 幂等追加，不覆盖已有 cron |
| 6/7 | 📱 Telegram 推送 | 可选，支持日/周/月频率 |
| 7/7 | 🔐 登录配置 | 幂等写入 .profile + 创建命令软链接 |

---

## 🖥️ 使用方式

### 方式一：自动展示（推荐）

安装时选择开启登录自启，每次 SSH 登录自动弹出面板。

### 方式二：快捷命令

```bash
lin-panel            # 默认命令名
your-custom-name     # 或你自定义的名称
```

### 方式三：直接执行

```bash
/root/lin-panel.sh
```

### 面板操作

```
  ┌──── 操作菜单 ────┐
  │  [1] 刷新数据     │  ← 重新加载面板
  │  [2] 近7天趋势     │  ← 查看柱状图
  │  [3] 连接概览     │  ← 查看连接状态
  │  [4] 实时流速     │  ← 测量当前速度
  │  [5] 一键卸载     │  ← 清理所有文件
  │  [0] 退出         │  ← 回到 Shell
  └──────────────────┘
```

---

## 🖼️ 面板预览

```
╭──────────────────────────────────────────────────────────────╮
│           📊 linjunhao024-byte 流量监控面板                   │
╰──────────────────────────────────────────────────────────────╯

  📈 当期流量总账 ─ 双向计费上限: 350GB
     ✅ 已用: 83.90 / 350 GB (24.0%)       ← 绿色 <70%
     ⚠️ 已用: 248.50 / 350 GB (71.0%)      ← 黄色 70-90%
     🚨 已用: 319.20 / 350 GB (91.2%)      ← 红色 >90%
     ⏰ 距离重置: 13天7时22分

  ┌──── 操作菜单 ────┐
  │  [1] 刷新         │
  │  [2] 7天趋势      │
  │  [3] 连接概览     │
  │  [4] 流速测试     │
  │  [5] 一键卸载     │
  │  [0] 退出         │
  └──────────────────┘
```

---

## 📁 文件结构

```
/root/
├── lin-panel.sh           # 面板脚本
├── traffic_reset.sh       # 月度重置
├── traffic_check.sh       # Telegram 推送（可选）
└── traffic_history.log    # 趋势日志（自动裁剪 30 天）

/usr/local/bin/
└── lin-panel → /root/lin-panel.sh

Crontab:
├── 59 23 * * *        每日记录 + 裁剪
├── MM HH DD * *       每月重置
└── 0 12 (DD-1) * *    Telegram 月报（可选）
```

---

## ⚙️ 技术架构

```
     ┌─────────────────────────────────────────────┐
     │              SSH Login                       │
     │    .profile → /root/lin-panel.sh             │
     └────────────────────┬────────────────────────┘
                          │
              ┌───────────▼───────────┐
              │     lin-panel.sh      │
              │    (纯 POSIX sh)      │
              └───────────┬───────────┘
                          │
         ┌────────────────┼────────────────┐
         │                │                │
    ┌────▼─────┐   ┌──────▼──────┐  ┌─────▼──────┐
    │ vnstat   │   │ /proc/net/  │  │ 运行时计算  │
    │ 数据库   │   │    dev      │  │            │
    │(内核统计)│   │ (内核接口)  │  │ 百分比     │
    │          │   │             │  │ 倒计时     │
    │ 月度/日度│   │ RX/TX 字节  │  │ 预警等级   │
    └──────────┘   └─────────────┘  └────────────┘
```

### 资源开销

| 组件 | 内存 | CPU | 端口 |
|------|:---:|:---:|:---:|
| vnstat | ~2MB | 0%（内核层） | 无 |
| 面板脚本 | 运行时 ~1MB | 运行时 ~0% | 无 |
| Cron 任务 | ~0 | ~0 | 无 |
| **总计** | **~3MB** | **~0%** | **0** |

---

## ❓ 常见问题

<details>
<summary><strong>Q: 面板显示"暂无数据"怎么办？</strong></summary>

vnstat 需要运行一段时间才能收集数据。安装后等待几分钟，或手动触发：

```bash
vnstat -u
```

</details>

<details>
<summary><strong>Q: 如何修改流量上限或计费模式？</strong></summary>

重新运行安装脚本即可，所有参数会重新配置，不会影响已有数据。

</details>

<details>
<summary><strong>Q: 如何卸载？</strong></summary>

```bash
# 删除面板脚本和快捷命令
rm -f /root/lin-panel.sh /usr/local/bin/lin-panel

# 删除重置脚本和日志
rm -f /root/traffic_reset.sh /root/traffic_history.log

# 从 .profile 中移除（手动编辑）
vi /root/.profile

# 从 crontab 中移除相关条目
crontab -e
```

</details>

<details>
<summary><strong>Q: 重复安装会怎样？</strong></summary>

安全。脚本使用幂等设计：

- `.profile` 检查已存在则跳过
- Cron 条目检查已存在则跳过
- 快捷命令 `ln -sf` 自动覆盖

</details>

<details>
<summary><strong>Q: 支持哪些 Linux 发行版？</strong></summary>

官方支持三个发行版，各自有独立的安装脚本：

| 发行版 | 安装脚本 | 包管理 | 服务管理 |
|--------|---------|--------|---------|
| Alpine Linux | `install.sh` | apk | OpenRC |
| Debian | `install-debian.sh` | apt-get | systemd |
| Ubuntu | `install-ubuntu.sh` | apt-get | systemd |

如需移植到其他发行版（如 CentOS、Arch），主要改动：

- 包管理器：`apk` / `apt-get` → `yum` / `pacman`
- 服务管理：`rc-service` / `systemctl` → 对应命令

</details>

<details>
<summary><strong>Q: 流量数据准确吗？</strong></summary>

数据来自 vnstat，通过读取内核网络接口统计计算流量，通常误差在 1-3% 以内。

</details>

---

## 📄 开源协议

[MIT License](LICENSE) © [linjunhao024-byte](https://github.com/linjunhao024-byte)

---

<div align="center">

**如果这个项目对你有帮助，请给一个 ⭐ Star！**

<br>

![Star](https://img.shields.io/github/stars/linjunhao024-byte/Lin-Panel?style=social)

</div>
