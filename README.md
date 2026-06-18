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

**极简流量监控伪面板 · v1.0.0**

> 不开端口 · 不跑服务 · 不装 Web 框架 · SSH 会话内完成一切

[English](README_EN.md) | **中文**

<br>

![Alpine](https://img.shields.io/badge/Alpine%20Linux-0A1628?style=for-the-badge&logo=alpinelinux&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-FF6B6B?style=for-the-badge)

</div>

---

## 🤔 这是什么

你有一台 VPS，套餐流量有限，双向计费。最怕的事：**某个月流量悄悄跑超，被限速或额外扣钱。**

| | Web 面板 | vnstat 命令行 | **LIN-Panel** |
|---|:---:|:---:|:---:|
| 开端口 | ✅ 需要 | ❌ 不需要 | ❌ **不需要** |
| 安全风险 | ⚠️ 被扫描 | ✅ 无 | ✅ **无** |
| 资源占用 | 100MB+ | ~0 | **~3MB** |
| 中文界面 | ✅ | ❌ | ✅ |
| 预警提醒 | ✅ | ❌ | ✅ |
| 安装难度 | 复杂 | 无需安装 | **一键** |

---

## ✨ 功能

| 模块 | 功能 |
|------|------|
| 📊 **数据展示** | 实时流量总览 · 重置倒计时 · 每日明细 · vnstat 汉化表格 |
| 🔔 **智能预警** | 🟢 <70% · 🟡 70-90% · 🔴 >90% · 百分比自动计算 |
| 📈 **趋势分析** | 近 7 天柱状图 · 每日自动记录 · 自动裁剪 30 天 |
| 🌐 **网络诊断** | 活跃连接数 · 本地端口 Top 5 · 实时流速采样 |
| 🔐 **计费模式** | 双向 / 入站 / 出站 · 安装时自由选择 |
| 🌐 **时区管理** | 9 个主流时区可选 · 中/港/日/新/美/英/欧/UTC |
| 📱 **Telegram** | 流量报告推送 · 日/周/月频率 · 测试消息验证 |
| ⌨️ **交互体验** | 自定义命令名 · 数字菜单 · 一键卸载 · 幂等安装 |

---

## 🚀 快速安装

根据你的系统选择：

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

### 英文版面板

使用 `-en` 后缀的脚本：

```bash
# Alpine (English)
wget -O install-alpine-en.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-alpine-en.sh && chmod +x install-alpine-en.sh && ./install-alpine-en.sh

# Debian (English)
wget -O install-debian-en.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-debian-en.sh && chmod +x install-debian-en.sh && ./install-debian-en.sh

# Ubuntu (English)
wget -O install-ubuntu-en.sh https://raw.githubusercontent.com/linjunhao024-byte/Lin-Panel/main/install-ubuntu-en.sh && chmod +x install-ubuntu-en.sh && ./install-ubuntu-en.sh
```

### 克隆安装

```bash
git clone https://github.com/linjunhao024-byte/Lin-Panel.git
cd Lin-Panel
# 中文版
chmod +x install-alpine.sh && ./install-alpine.sh     # Alpine
chmod +x install-debian.sh && ./install-debian.sh     # Debian
chmod +x install-ubuntu.sh && ./install-ubuntu.sh     # Ubuntu
# 英文版
chmod +x install-alpine-en.sh && ./install-alpine-en.sh   # Alpine
chmod +x install-debian-en.sh && ./install-debian-en.sh   # Debian
chmod +x install-ubuntu-en.sh && ./install-ubuntu-en.sh   # Ubuntu
```

### 系统要求

| 项目 | 要求 |
|------|------|
| 系统 | Alpine / Debian / Ubuntu |
| 权限 | root |
| 依赖 | vnstat（脚本自动安装） |
| 磁盘 | < 5MB |
| 内存 | < 3MB |

---

## 📋 安装向导

全交互式，直接回车使用默认值：

```
┌──────────── 自定义配置 ────────────┐

  ① 流量上限        [默认: 350GB]
  ② 计费模式        [双向 / 入站 / 出站]
  ③ 重置时间        [日期 1-31 + 时分秒]
  ④ 登录自启        [Y/n]
  ⑤ 快捷命令名      [默认: lin-panel]

└────────────────────────────────────┘

┌──────────── 安装步骤 ────────────┐

  [1/7] 🌐 时区配置     9 个时区可选
  [2/7] 📦 安装 vnstat   唯一硬依赖
  [3/7] 🎨 生成面板      动态注入配置
  [4/7] 🔄 重置脚本      智能短月兜底
  [5/7] 📊 定时任务      幂等不覆盖
  [6/7] 📱 Telegram      测试消息验证
  [7/7] 🔐 登录配置      幂等写入

└────────────────────────────────────┘
```

---

## 🖥️ 使用方式

```bash
# 自动展示（推荐）— 每次 SSH 登录自动弹出
# 快捷命令 — 随时手动打开
lin-panel              # 或你自定义的命令名

# 直接执行
/root/lin-panel.sh
```

### 操作菜单

```
  ┌──── 操作菜单 ────┐
  │  [1] 刷新数据     │  ← 重新加载面板
  │  [2] 近7天趋势    │  ← 查看柱状图
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
│                    📊 LIN-PANEL 流量监控面板                        │
╰──────────────────────────────────────────────────────────────╯

  📈 当期流量总账 ─ 双向计费上限: 350GB
     ✅ 已用: 83.90 / 350 GB (24.0%)       ← 🟢 正常
     ⚠️ 已用: 248.50 / 350 GB (71.0%)      ← 🟡 注意
     🚨 已用: 319.20 / 350 GB (91.2%)      ← 🔴 警告
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
├── lin-panel.sh              # 面板脚本
├── traffic_reset_check.sh    # 智能重置（短月自动兜底）
├── traffic_check.sh          # Telegram 推送（可选）
└── traffic_history.log       # 趋势日志（自动裁剪 30 天）

/usr/local/bin/
└── lin-panel → /root/lin-panel.sh

Crontab:
├── 59 23 * * *        每日记录 + 裁剪
├── 0 0 * * *          每日检查是否重置日
└── 0 9/12 * * *       Telegram 推送（可选）
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
              │   bash (Debian/Ubuntu)│
              │   sh (Alpine)         │
              └───────────┬───────────┘
                          │
         ┌────────────────┼────────────────┐
         │                │                │
    ┌────▼─────┐   ┌──────▼──────┐  ┌─────▼──────┐
    │ vnstat   │   │ sys/class/  │  │ 运行时计算  │
    │ 数据库   │   │ net/        │  │            │
    │(内核统计)│   │(内核接口)   │  │ 百分比     │
    │          │   │             │  │ 倒计时     │
    │ 月度/日度│   │ RX/TX 字节  │  │ 预警等级   │
    └──────────┘   └─────────────┘  └────────────┘
```

| 组件 | 内存 | CPU | 端口 |
|------|:---:|:---:|:---:|
| vnstat | ~2MB | 0%（内核层） | 无 |
| 面板脚本 | 运行时 ~1MB | 运行时 ~0% | 无 |
| Cron 任务 | ~0 | ~0 | 无 |
| **总计** | **~3MB** | **~0%** | **0** |

---

## ❓ 常见问题

<details>
<summary><strong>Q: 面板显示"暂无数据"？</strong></summary>

vnstat 需要几分钟收集数据。等待或手动触发：`vnstat -u`

</details>

<details>
<summary><strong>Q: 如何修改配置？</strong></summary>

重新运行安装脚本，所有参数重新配置，不影响已有数据。

</details>

<details>
<summary><strong>Q: 如何卸载？</strong></summary>

面板菜单选 `[5] 一键卸载`，或手动：

```bash
rm -f /root/lin-panel.sh /root/traffic_reset_check.sh /root/traffic_check.sh /root/traffic_history.log
rm -f /usr/local/bin/lin-panel
sed -i '/lin-panel/d' /root/.profile
crontab -e  # 删除相关条目
```

</details>

<details>
<summary><strong>Q: 重复安装会怎样？</strong></summary>

安全。幂等设计：`.profile` 检查已存在则跳过，Cron 条目去重，命令 `ln -sf` 自动覆盖。

</details>

<details>
<summary><strong>Q: 支持哪些系统？</strong></summary>

| 系统 | 安装脚本 | 包管理 | 服务管理 |
|------|---------|--------|---------|
| Alpine | `install-alpine.sh` | apk | OpenRC |
| Debian | `install-debian.sh` | apt-get | systemd |
| Ubuntu | `install-ubuntu.sh` | apt-get | systemd |

</details>

<details>
<summary><strong>Q: 流量数据准确吗？</strong></summary>

来自 vnstat，读取内核网络接口统计，误差 1-3%。

</details>

---

## 📄 开源协议

[MIT License](LICENSE) © [linjunhao024-byte](https://github.com/linjunhao024-byte)

---

<div align="center">

**⭐ 如果对你有帮助，给个 Star 支持一下！**

![Star](https://img.shields.io/github/stars/linjunhao024-byte/Lin-Panel?style=social)

</div>
