#!/bin/bash

C_CYAN='\033[1;36m'
C_YELLOW='\033[1;33m'
C_GREEN='\033[1;32m'
C_WHITE='\033[1;37m'
C_RED='\033[1;31m'
C_RESET='\033[0m'

clear
echo -e "${C_CYAN}"
echo '    __  ____ _  __          ____                   __'
echo '   / / /  // |/ /         / __ \____ _____  ___  / /'
echo '  / /  / / /    /  ______ / /_/ / __ `/ __ \/ _ \/ /'
echo ' / /__/ / / /|  / /_____// ____/ /_/ / / / /  __/ /'
echo '/____/___/_/ |_/        /_/    \__,_/_/ /_/\___/_/'
echo -e "${C_RESET}"
echo -e "${C_YELLOW}           极简流量监控伪面板 · v1.0.0${C_RESET}"
echo ""
echo -e "${C_CYAN}╭──────────────────────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_YELLOW}│              欢迎使用 LIN-PANEL 一键安装脚本                       │${C_RESET}"
echo -e "${C_CYAN}╰──────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

echo -e "${C_CYAN}┌──────────── 自定义配置 ────────────┐${C_RESET}"
echo ""

printf "请输入流量上限(GB) [默认: 350]: "
read LIMIT
LIMIT="${LIMIT:-350}"
echo -e "  -> 流量上限设置为: ${C_YELLOW}${LIMIT}GB${C_RESET}"
echo ""

printf "请选择计费模式\n"
printf "  [1] 双向计费 (入站+出站) [默认]\n"
printf "  [2] 入站计费 (仅下载)\n"
printf "  [3] 出站计费 (仅上传)\n"
printf "  请选择 [1/2/3] [默认: 1]: "
read BILLING
case "$BILLING" in
    2) BILLING_MODE=2; echo -e "  -> 计费模式: ${C_YELLOW}入站计费 (仅下载 RX)${C_RESET}" ;;
    3) BILLING_MODE=3; echo -e "  -> 计费模式: ${C_YELLOW}出站计费 (仅上传 TX)${C_RESET}" ;;
    *) BILLING_MODE=1; echo -e "  -> 计费模式: ${C_YELLOW}双向计费 (入站+出站)${C_RESET}" ;;
esac
echo ""

printf "请输入每月流量重置时间\n"
printf "  日期 (1-31) [默认 1]: "
read DAY
DAY="${DAY:-1}"
case "$DAY" in [1-9]|[12][0-9]|3[01]) ;; *) echo -e "  ${C_RED}⚠ 日期无效，已使用默认值 1${C_RESET}"; DAY=1 ;;
esac

printf "  小时 (0-23) [默认 0]: "
read HOUR
HOUR="${HOUR:-0}"
case "$HOUR" in [0-9]|1[0-9]|2[0-3]) ;; *) echo -e "  ${C_RED}⚠ 小时无效，已使用默认值 0${C_RESET}"; HOUR=0 ;;
esac

printf "  分钟 (0-59) [默认 0]: "
read MINUTE
MINUTE="${MINUTE:-0}"
case "$MINUTE" in [0-9]|[1-4][0-9]|5[0-9]) ;; *) echo -e "  ${C_RED}⚠ 分钟无效，已使用默认值 0${C_RESET}"; MINUTE=0 ;;
esac

printf "  秒数 (0-59) [默认 0]: "
read SECOND
SECOND="${SECOND:-0}"
case "$SECOND" in [0-9]|[1-4][0-9]|5[0-9]) ;; *) echo -e "  ${C_RED}⚠ 秒数无效，已使用默认值 0${C_RESET}"; SECOND=0 ;;
esac
echo -e "  -> 重置时间设置为: 每月 ${C_YELLOW}${DAY}日 ${HOUR}:${MINUTE}:${SECOND}${C_RESET}"
echo ""

printf "是否在每次通过 SSH 登录服务器时，自动展示流量监控面板？[Y/n] [默认: Y]: "
read LOGIN_AUTO
if [ "$LOGIN_AUTO" = "N" ] || [ "$LOGIN_AUTO" = "n" ]; then
    ENABLE_LOGIN_AUTO=0
    echo -e "  -> 登录自启: ${C_RED}已关闭${C_RESET}"
else
    ENABLE_LOGIN_AUTO=1
    echo -e "  -> 登录自启: ${C_GREEN}已开启${C_RESET}"
fi
echo ""

printf "请输入您的快捷命令名称 [默认: lin-panel]: "
read CMD
CMD="${CMD:-lin-panel}"
case "$CMD" in */*|*\ *) echo -e "  ${C_RED}⚠ 命令名不能包含 / 或空格，已使用默认值 lin-panel${C_RESET}"; CMD="lin-panel" ;;
esac
echo -e "  -> 快捷命令设置为: ${C_YELLOW}${CMD}${C_RESET}"
echo ""

printf "服务器是否已运行一段时间？请输入本月已使用流量(GB) [默认: 0]: "
read BASELINE
BASELINE="${BASELINE:-0}"
case "$BASELINE" in *[!0-9.]*) echo -e "  ${C_RED}⚠ 输入无效，已使用默认值 0${C_RESET}"; BASELINE=0 ;; esac
if [ "$BASELINE" != "0" ]; then
    echo -e "  -> 已使用流量基线: ${C_YELLOW}${BASELINE}GB${C_RESET} (将叠加到 vnstat 统计上)"
else
    echo -e "  -> 不设置基线，从零开始计算"
fi
echo ""
echo -e "${C_CYAN}└────────────────────────────────────┘${C_RESET}"
echo ""

echo -e "${C_GREEN}[1/7] 🌐 时区配置${C_RESET}"

CURRENT_TZ=$(cat /etc/timezone 2>/dev/null || date +%Z)
printf "  当前时区: ${C_YELLOW}%s${C_RESET}\n" "$CURRENT_TZ"
echo ""
printf "  请选择时区:\n"
printf "    [1] Asia/Shanghai    (UTC+8)  中国\n"
printf "    [2] Asia/Hong_Kong   (UTC+8)  香港\n"
printf "    [3] Asia/Tokyo       (UTC+9)  日本\n"
printf "    [4] Asia/Singapore   (UTC+8)  新加坡\n"
printf "    [5] America/New_York (UTC-5)  美东\n"
printf "    [6] America/Los_Angeles (UTC-8) 美西\n"
printf "    [7] Europe/London    (UTC+0)  英国\n"
printf "    [8] Europe/Berlin    (UTC+1)  欧洲\n"
printf "    [9] UTC              (UTC+0)  格林威治\n"
printf "    [0] 不修改\n"
printf "  请选择 [0-9] [默认: 0]: "
read TZ_CHOICE
case "$TZ_CHOICE" in
    1) TZ_TARGET="Asia/Shanghai" ;;
    2) TZ_TARGET="Asia/Hong_Kong" ;;
    3) TZ_TARGET="Asia/Tokyo" ;;
    4) TZ_TARGET="Asia/Singapore" ;;
    5) TZ_TARGET="America/New_York" ;;
    6) TZ_TARGET="America/Los_Angeles" ;;
    7) TZ_TARGET="Europe/London" ;;
    8) TZ_TARGET="Europe/Berlin" ;;
    9) TZ_TARGET="UTC" ;;
    *) TZ_TARGET="" ;;
esac
if [ -n "$TZ_TARGET" ]; then
    if [ -f "/usr/share/zoneinfo/$TZ_TARGET" ]; then
        cp "/usr/share/zoneinfo/$TZ_TARGET" /etc/localtime
        echo "$TZ_TARGET" > /etc/timezone
    else
        apt-get install -y tzdata >/dev/null 2>&1
        cp "/usr/share/zoneinfo/$TZ_TARGET" /etc/localtime
        echo "$TZ_TARGET" > /etc/timezone
        apt-get remove -y tzdata >/dev/null 2>&1
    fi
    hwclock --systohc >/dev/null 2>&1 || true
    echo -e "  -> 时区已修改为: ${C_YELLOW}${TZ_TARGET}${C_RESET}"
else
    echo -e "  -> 保持当前时区: ${C_YELLOW}${CURRENT_TZ}${C_RESET}"
fi

echo -e "${C_GREEN}[2/7] 📦 正在安装必要依赖 (vnstat)...${C_RESET}"

apt-get update -qq && apt-get install -y vnstat >/dev/null 2>&1
systemctl start vnstat >/dev/null 2>&1
systemctl enable vnstat >/dev/null 2>&1

echo -e "${C_GREEN}[3/7] 🎨 正在生成高级 TUI 监控面板...${C_RESET}"

cat << EOF > /root/lin-panel.sh
#!/bin/bash
C_CYAN='\\033[1;36m'
C_YELLOW='\\033[1;33m'
C_GREEN='\\033[1;32m'
C_WHITE='\\033[1;37m'
C_RED='\\033[1;31m'
C_RESET='\\033[0m'

LIMIT=${LIMIT}
BILLING_MODE=${BILLING_MODE}
BASELINE=${BASELINE}
RESET_DAY=${DAY}
RESET_HOUR=${HOUR}
RESET_MIN=${MINUTE}
RESET_SEC=${SECOND}

PCT=""
ALERT=""
USED_GB=0
BILLING_LABEL="双向计费"

VSTAT_RAW=\$(vnstat -m 2>/dev/null)
TRAFFIC_BYTES=0
if [ -n "\$VSTAT_RAW" ]; then
    UNIT=\$(echo "\$VSTAT_RAW" | awk '/GiB|TiB|MiB/{print \$3; exit}')
    TRAFFIC_RAW=""
    if [ "\$BILLING_MODE" = "2" ]; then
        BILLING_LABEL="入站计费"
        TRAFFIC_RAW=\$(echo "\$VSTAT_RAW" | awk '/[0-9]/{if(\$0~/[A-Z][a-z][a-z].*[0-9]/) v=\$3} END{print v}')
    elif [ "\$BILLING_MODE" = "3" ]; then
        BILLING_LABEL="出站计费"
        TRAFFIC_RAW=\$(echo "\$VSTAT_RAW" | awk '/[0-9]/{if(\$0~/[A-Z][a-z][a-z].*[0-9]/) v=\$4} END{print v}')
    else
        BILLING_LABEL="双向计费"
        TRAFFIC_RAW=\$(echo "\$VSTAT_RAW" | awk '/[0-9]+\\.[0-9]+/{last=\\\$NF} END{print last}')
    fi
    if [ -n "\$TRAFFIC_RAW" ] && [ -n "\$UNIT" ]; then
        case "\$UNIT" in
            *TiB*) TRAFFIC_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$TRAFFIC_RAW * 1099511627776}") ;;
            *GiB*) TRAFFIC_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$TRAFFIC_RAW * 1073741824}") ;;
            *MiB*) TRAFFIC_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$TRAFFIC_RAW * 1048576}") ;;
        esac
    fi
fi
BASELINE_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$BASELINE * 1073741824}")
TRAFFIC_BYTES=\$(( TRAFFIC_BYTES + BASELINE_BYTES ))
LIMIT_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$LIMIT * 1073741824}")
if [ "\$LIMIT_BYTES" -gt 0 ] && [ "\$TRAFFIC_BYTES" -gt 0 ]; then
    PCT=\$(awk "BEGIN{printf \\"%.1f\\", \$TRAFFIC_BYTES * 100 / \$LIMIT_BYTES}")
    USED_GB=\$(awk "BEGIN{printf \\"%.2f\\", \$TRAFFIC_BYTES / 1073741824}")
    if awk "BEGIN{exit !(\$PCT >= 90)}"; then
        ALERT="red"
    elif awk "BEGIN{exit !(\$PCT >= 70)}"; then
        ALERT="yellow"
    else
        ALERT="green"
    fi
fi

NOW_S=\$(date +%s)
CUR_M=\$(date +%-m)
NEXT_M=\$(( (CUR_M + 1) % 12 ))
NEXT_Y=\$(date +%Y)
if [ "\$NEXT_M" -eq 0 ]; then NEXT_M=12; NEXT_Y=\$((NEXT_Y + 1)); fi
MDAYS=31
case \$NEXT_M in 2) MDAYS=28;; 4|6|9|11) MDAYS=30;; esac
TDAY=\$RESET_DAY; [ "\$TDAY" -gt "\$MDAYS" ] && TDAY=\$MDAYS
D2=\$(echo "\$TDAY" | sed 's/^0//')
H2=\$(echo "\$RESET_HOUR" | sed 's/^0//')
MI2=\$(echo "\$RESET_MIN" | sed 's/^0//')
S2=\$(echo "\$RESET_SEC" | sed 's/^0//')
RESET_STR=\$(printf "%04d-%02d-%02d %02d:%02d:%02d" "\$NEXT_Y" "\$NEXT_M" "\$D2" "\$H2" "\$MI2" "\$S2")
NEXT_S=\$(date -d "\$RESET_STR" +%s 2>/dev/null)
CDOWN=""
if [ -n "\$NEXT_S" ] && [ "\$NEXT_S" -gt "\$NOW_S" ]; then
    DIFF=\$((\$NEXT_S - \$NOW_S))
    CD_D=\$((\$DIFF / 86400))
    CD_H=\$((\$DIFF % 86400 / 3600))
    CD_M=\$((\$DIFF % 3600 / 60))
    CDOWN=\${CD_D}天\${CD_H}时\${CD_M}分
fi

clear
echo -e "\${C_CYAN}╭──────────────────────────────────────────────────────────────╮\${C_RESET}"
echo -e "\${C_YELLOW}│              📊 LIN-PANEL 流量监控面板 (汉化版)              │\${C_RESET}"
echo -e "\${C_CYAN}╰──────────────────────────────────────────────────────────────╯\${C_RESET}"
echo ""
echo -e "\${C_GREEN}  📈 当期流量总账 ─ \${BILLING_LABEL}上限: ${LIMIT}GB\${C_RESET}"
if [ -n "\$PCT" ]; then
    CLR="\${C_GREEN}"
    [ "\$ALERT" = "yellow" ] && CLR="\${C_YELLOW}"
    [ "\$ALERT" = "red" ] && CLR="\${C_RED}"
    ICON="✅"; [ "\$ALERT" = "yellow" ] && ICON="⚠️"
    [ "\$ALERT" = "red" ] && ICON="🚨"
    echo -e "     \${CLR}\${ICON} 已用: \${USED_GB} / ${LIMIT} GB (\${PCT}%)\${C_RESET}"
else
    echo -e "     \${C_WHITE}📊 已用: \${USED_GB} / ${LIMIT} GB\${C_RESET}"
fi
if [ -n "\$CDOWN" ]; then
    echo -e "     ⏰ 距离重置: \${C_YELLOW}\${CDOWN}\${C_RESET}"
fi
echo -e "\${C_CYAN}────────────────────────────────────────────────────────────────\${C_RESET}"
echo ""
VSTAT_M=\$(vnstat -m 2>/dev/null | sed \\
    -e 's/rx/入站(RX)/g' \\
    -e 's/tx/出站(TX)/g' \\
    -e 's/total/合计(Total)/g' \\
    -e 's/estimated/预计/g' \\
    -e 's/month/月份/g' \\
    -e 's/-/─/g' \\
    -e 's/+/┼/g' \\
    -e 's/|/│/g')
printf "\${C_CYAN}%s\n\${C_RESET}" "\$VSTAT_M"

echo ""
echo -e "\${C_GREEN}  📅 每日流量明细\${C_RESET}"
VSTAT_D=\$(vnstat -d 2>/dev/null | sed \\
    -e 's/rx/入站(RX)/g' \\
    -e 's/tx/出站(TX)/g' \\
    -e 's/total/合计(Total)/g' \\
    -e 's/estimated/预计/g' \\
    -e 's/day/日期/g' \\
    -e 's/-/─/g' \\
    -e 's/+/┼/g' \\
    -e 's/|/│/g')
printf "\${C_CYAN}%s\n\${C_RESET}" "\$VSTAT_D"

show_trend() {
    echo ""
    echo -e "\${C_GREEN}  📊 近 7 天流量趋势\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
    TREND=\$(vnstat -d 2>/dev/null | awk '/[0-9]+\\.[0-9]+/{d=\\\$1; v=\\\$NF; if(d~/^[0-9]/) print d" "v}' | tail -7)
    if [ -z "\$TREND" ]; then
        echo -e "  \${C_WHITE}暂无历史数据\${C_RESET}"
    else
        MAX_V=\$(echo "\$TREND" | awk '{if(\\\$2+0>max)max=\\\$2+0}END{print max}')
        echo "\$TREND" | while read DATE VAL; do
            N=\$(awk "BEGIN{printf \\"%.0f\\", \$VAL * 30 / \$MAX_V}")
            BAR=""
            i=0
            while [ "\$i" -lt "\$N" ]; do BAR="\${BAR}█"; i=\$((i+1)); done
            while [ "\$i" -lt 30 ]; do BAR="\${BAR}░"; i=\$((i+1)); done
            echo -e "  \${C_WHITE}\${DATE}\${C_RESET}  \${C_CYAN}\${BAR}\${C_RESET}  \${C_YELLOW}\${VAL}\${C_RESET}"
        done
    fi
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
}

show_conn() {
    echo ""
    echo -e "\${C_GREEN}  🌐 网络连接概览\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
    if command -v ss >/dev/null 2>&1; then
        CONN=\$(ss -tun state established 2>/dev/null | tail -n +2 | wc -l)
    elif command -v netstat >/dev/null 2>&1; then
        CONN=\$(netstat -an 2>/dev/null | grep ESTABLISHED | wc -l)
    else
        CONN="N/A"
    fi
    echo -e "  \${C_WHITE}📡 活跃连接数: \${C_GREEN}\${CONN}\${C_RESET}"
    echo ""
    echo -e "  \${C_WHITE}🔍 本地监听端口 Top 5:\${C_RESET}"
    if command -v ss >/dev/null 2>&1; then
        ss -tun state established 2>/dev/null | tail -n +2 | awk '{print \$4}' | grep -oE ':[0-9]+' | sort | uniq -c | sort -rn | head -5 | while read CNT PORT; do
            echo -e "    \${C_YELLOW}\${CNT}\${C_RESET} 次  →  \${C_CYAN}\${PORT}\${C_RESET}"
        done
    elif command -v netstat >/dev/null 2>&1; then
        netstat -an 2>/dev/null | grep ESTABLISHED | awk '{print \$4}' | grep -oE ':[0-9]+' | sort | uniq -c | sort -rn | head -5 | while read CNT PORT; do
            echo -e "    \${C_YELLOW}\${CNT}\${C_RESET} 次  →  \${C_CYAN}\${PORT}\${C_RESET}"
        done
    fi
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
}

show_speed() {
    echo ""
    echo -e "\${C_GREEN}  ⚡ 实时流速 (2 秒采样)\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
    IFACE=\$(ip route 2>/dev/null | grep default | awk '{print \$5}' | head -n1)
    if [ -z "\$IFACE" ]; then
        IFACE=\$(ls /sys/class/net/ 2>/dev/null | grep -v lo | head -n 1)
    fi
    [ -z "\$IFACE" ] && IFACE="eth0"
    if [ -d "/sys/class/net/\$IFACE/statistics" ]; then
        echo -e "  \${C_WHITE}采样中，请稍候...\${C_RESET}"
        R1=\$(cat /sys/class/net/\$IFACE/statistics/rx_bytes 2>/dev/null || echo 0)
        T1=\$(cat /sys/class/net/\$IFACE/statistics/tx_bytes 2>/dev/null || echo 0)
        sleep 2
        R2=\$(cat /sys/class/net/\$IFACE/statistics/rx_bytes 2>/dev/null || echo 0)
        T2=\$(cat /sys/class/net/\$IFACE/statistics/tx_bytes 2>/dev/null || echo 0)
        DL=\$(( (R2 - R1) / 1024 / 2 ))
        UL=\$(( (T2 - T1) / 1024 / 2 ))
        echo -e "  ⬇️  下载: \${C_GREEN}\${DL} KB/s\${C_RESET}"
        echo -e "  ⬆️  上传: \${C_YELLOW}\${UL} KB/s\${C_RESET}"
    else
        echo -e "  \${C_RED}无法读取网卡 \${IFACE} 的流速数据\${C_RESET}"
    fi
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
}

do_uninstall() {
    echo ""
    echo -e "\${C_RED}  ⚠️  即将卸载 LIN-Panel 及所有相关文件\${C_RESET}"
    printf "  确认卸载？[y/N]: "
    read CONFIRM
    if [ "\$CONFIRM" != "y" ] && [ "\$CONFIRM" != "Y" ]; then
        echo -e "  \${C_GREEN}已取消\${C_RESET}"
        return
    fi
    echo ""
    echo -e "  \${C_WHITE}正在清理...\${C_RESET}"
    rm -f /root/lin-panel.sh /root/lin-panel-en.sh
    echo -e "  ✅ 面板脚本已删除"
    rm -f /root/traffic_reset.sh /root/traffic_reset_check.sh /root/traffic_check.sh
    echo -e "  ✅ 重置/推送脚本已删除"
    rm -f /root/traffic_history.log
    echo -e "  ✅ 流量日志已删除"
    rm -f /usr/local/bin/lin-panel
    echo -e "  ✅ 快捷命令已删除"
   
    EXISTING=\$(crontab -l 2>/dev/null || true)
    CLEANED=\$(echo "\$EXISTING" | grep -v 'traffic_history\|traffic_reset\|traffic_check')
    echo "\$CLEANED" | sed '/^$/d' | crontab - 2>/dev/null
    echo -e "  ✅ 定时任务已清理"
   
    if [ -f /root/.profile ]; then
        sed -i '/lin-panel/d' /root/.profile
        echo -e "  ✅ 登录自启已移除"
    fi
    echo ""
    printf "  是否同时卸载 vnstat（流量统计工具）？[y/N] [默认: N]: "
    read RM_VNSTAT
    if [ "\$RM_VNSTAT" = "y" ] || [ "\$RM_VNSTAT" = "Y" ]; then
        systemctl stop vnstat 2>/dev/null || systemctl stop vnstat 2>/dev/null
        systemctl disable vnstat 2>/dev/null || systemctl disable vnstat 2>/dev/null
        apk del vnstat 2>/dev/null || apt-get remove -y vnstat 2>/dev/null
        rm -rf /var/lib/vnstat
        echo -e "  ✅ vnstat 已卸载"
    else
        echo -e "  -> vnstat 已保留"
    fi
    echo ""
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────\${C_RESET}"
    echo -e "\${C_GREEN}  🎉 卸载完成！\${C_RESET}"
    echo ""
    echo -e "\${C_WHITE}  如果有不满意的地方，欢迎提交反馈：\${C_RESET}"
    echo -e "\${C_YELLOW}  🔗 https://github.com/linjunhao024-byte/Lin-Panel/issues\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────\${C_RESET}"
    echo ""
    exit 0
}

show_menu() {
    echo ""
    echo -e "\${C_CYAN}  ┌──── 操作菜单 ────┐\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[1] 刷新数据     \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[2] 近7天趋势    \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[3] 连接概览     \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[4] 实时流速     \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_RED}[5] 一键卸载     \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_RED}[0] 退出         \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  └──────────────────┘\${C_RESET}"
}

trap 'echo ""; exit 0' INT

while true; do
    show_menu
    printf "  \${C_WHITE}请选择 > \${C_RESET}"
    read CHOICE
    case "\$CHOICE" in
        1) exec "\$0" ;;
        2) show_trend ;;
        3) show_conn ;;
        4) show_speed ;;
        5) do_uninstall ;;
        0|"") echo -e "\n  \${C_GREEN}👋 已退出面板\${C_RESET}"; exit 0 ;;
        *) echo -e "  \${C_RED}无效选项，请重新输入\${C_RESET}" ;;
    esac
done
EOF

chmod +x /root/lin-panel.sh

echo -e "${C_GREEN}[4/7] 🔄 正在配置自动重置脚本...${C_RESET}"

cat << RESEOF > /root/traffic_reset_check.sh
#!/bin/bash
RESET_DAY=${DAY}
RESET_HOUR=${HOUR}
RESET_MIN=${MINUTE}
RESET_SEC=${SECOND}

TODAY=\$(date +%d)
MONTH=\$(date +%m)
YEAR=\$(date +%Y)

MAX_DAY=31
case \$MONTH in 02) MAX_DAY=28;; 04|06|09|11) MAX_DAY=30;; esac
if [ \$((YEAR % 4)) -eq 0 ] && [ "\$MONTH" = "02" ]; then MAX_DAY=29; fi

TARGET_DAY=\$RESET_DAY
[ "\$TARGET_DAY" -gt "\$MAX_DAY" ] && TARGET_DAY=\$MAX_DAY

if [ "\$TODAY" -ne "\$TARGET_DAY" ]; then
    exit 0
fi

NOW_S=\$(date +%s)
TARGET_S=\$(( \$(date -d "\$YEAR-\$MONTH-\$TARGET_DAY 00:00:00" +%s 2>/dev/null || echo \$NOW_S) + RESET_HOUR * 3600 + RESET_MIN * 60 + RESET_SEC ))
SLEEP=\$(( TARGET_S - NOW_S ))
[ "\$SLEEP" -gt 0 ] && sleep "\$SLEEP"

systemctl stop vnstat
rm -rf /var/lib/vnstat/*
systemctl start vnstat
RESEOF
chmod +x /root/traffic_reset_check.sh

echo -e "${C_GREEN}[5/7] 📊 正在配置每日流量记录与自动清理...${C_RESET}"

EXISTING_CRON=$(crontab -l 2>/dev/null || true)

CRON_TREND='59 23 * * * echo "$(date +%Y-%m-%d) $(vnstat -m | awk '\''/total/{print $NF}'\'')" >> /root/traffic_history.log && tail -30 /root/traffic_history.log > /tmp/.tl && mv /tmp/.tl /root/traffic_history.log'
CRON_RESET="0 0 * * * /root/traffic_reset_check.sh"

EXISTING_CRON=$(echo "$EXISTING_CRON" | grep -v 'traffic_history\.log')

NEW_ENTRIES=""
if ! echo "$EXISTING_CRON" | grep -qF 'traffic_history.log'; then
    NEW_ENTRIES="${NEW_ENTRIES}${CRON_TREND}\n"
fi
if ! echo "$EXISTING_CRON" | grep -qF 'traffic_reset_check.sh'; then
    NEW_ENTRIES="${NEW_ENTRIES}${CRON_RESET}\n"
fi

if [ -n "$NEW_ENTRIES" ]; then
    printf "%s\n%s" "$EXISTING_CRON" "$NEW_ENTRIES" | sed '/^$/d' | crontab -
    echo -e "  -> 已追加 ${C_YELLOW}$(echo "$NEW_ENTRIES" | wc -l | tr -d ' ')${C_RESET} 条定时任务"
else
    echo -e "  -> 定时任务已存在，跳过写入"
fi

systemctl enable cron >/dev/null 2>&1
systemctl start cron >/dev/null 2>&1

echo -e "  -> 每月流量重置已配置: ${C_YELLOW}每月${DAY}日 ${HOUR}:${MINUTE}:${SECOND}${C_RESET}"

echo -e "${C_GREEN}[6/7] 📱 正在配置 Telegram 流量推送...${C_RESET}"

printf "  是否启用 Telegram 流量推送？[Y/n] [默认: N]: "
read TG_ENABLE
if [ "$TG_ENABLE" = "Y" ] || [ "$TG_ENABLE" = "y" ]; then
    TG_OK=0
    while [ "$TG_OK" = "0" ]; do
        printf "  请输入 Telegram Bot Token: "
        read TG_TOKEN
        printf "  请输入 Telegram Chat ID: "
        read TG_CHAT
        echo ""
        echo -e "  ${C_WHITE}正在发送测试消息...${C_RESET}"
        if curl -sf -o /tmp/.tg_test.json -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" -d chat_id="${TG_CHAT}" -d text="🔔 LIN-Panel Test" -d parse_mode="HTML" 2>/dev/null; then
            echo -e "  ${C_GREEN}✅ 测试消息发送成功！请检查您的 Telegram${C_RESET}"
            TG_OK=1
        else
            TG_ERR=$(grep -o '"description":"[^"]*"' /tmp/.tg_test.json 2>/dev/null | cut -d'"' -f4)
            echo -e "  ${C_RED}❌ 测试消息发送失败${C_RESET}"
            [ -n "$TG_ERR" ] && echo -e "  ${C_RED}   原因: ${TG_ERR}${C_RESET}"
            echo ""
            printf "  [1] 重新填写 Token 和 Chat ID\n"
            printf "  [2] 跳过推送\n"
            printf "  [3] 仍然启用（不推荐）\n"
            printf "  请选择 [1/2/3] [默认: 1]: "
            read TG_RETRY
            case "$TG_RETRY" in
                2) TG_ENABLE="n"; TG_OK=1 ;;
                3) TG_OK=1 ;;
                *) echo "" ;;
            esac
        fi
        rm -f /tmp/.tg_test.json
    done
    echo ""
    if [ "$TG_ENABLE" = "Y" ] || [ "$TG_ENABLE" = "y" ]; then
    printf "  请选择推送频率:\n"
    printf "    [1] 每日汇报\n"
    printf "    [2] 每周汇报\n"
    printf "    [3] 每月汇报\n"
    printf "  请选择 [1/2/3] [默认: 1]: "
    read TG_FREQ
   
    PUSH_DAY=$((DAY - 1))
    [ "$PUSH_DAY" -lt 1 ] && PUSH_DAY=28
    case "$TG_FREQ" in
        2) TG_CRON="0 12 * * 1" ; TG_LABEL="每周一 12:00" ;;
        3) TG_CRON="0 12 ${PUSH_DAY} * *" ; TG_LABEL="每月${PUSH_DAY}日 12:00 (重置前12小时)" ;;
        *) TG_CRON="0 9 * * *" ; TG_LABEL="每日 09:00" ;;
    esac

    cat << TGEOF > /root/traffic_check.sh
#!/bin/bash
LIMIT=${LIMIT}
BILLING_MODE=${BILLING_MODE}
BASELINE=${BASELINE}
TG_TOKEN="${TG_TOKEN}"
TG_CHAT="${TG_CHAT}"

VSTAT_RAW=\$(vnstat -m 2>/dev/null)
TRAFFIC_BYTES=0
if [ -n "\$VSTAT_RAW" ]; then
    UNIT=\$(echo "\$VSTAT_RAW" | awk '/GiB|TiB|MiB/{print \$3; exit}')
    TRAFFIC_RAW=""
    if [ "\$BILLING_MODE" = "2" ]; then
        TRAFFIC_RAW=\$(echo "\$VSTAT_RAW" | awk '/[0-9]/{if(\$0~/[A-Z][a-z][a-z].*[0-9]/) v=\$3} END{print v}')
    elif [ "\$BILLING_MODE" = "3" ]; then
        TRAFFIC_RAW=\$(echo "\$VSTAT_RAW" | awk '/[0-9]/{if(\$0~/[A-Z][a-z][a-z].*[0-9]/) v=\$4} END{print v}')
    else
        TRAFFIC_RAW=\$(echo "\$VSTAT_RAW" | awk '/[0-9]+\.[0-9]+/{last=\$NF} END{print last}')
    fi
    if [ -n "\$TRAFFIC_RAW" ] && [ -n "\$UNIT" ]; then
        case "\$UNIT" in
            *TiB*) TRAFFIC_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$TRAFFIC_RAW * 1099511627776}") ;;
            *GiB*) TRAFFIC_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$TRAFFIC_RAW * 1073741824}") ;;
            *MiB*) TRAFFIC_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$TRAFFIC_RAW * 1048576}") ;;
        esac
    fi
fi
BASELINE_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$BASELINE * 1073741824}")
TRAFFIC_BYTES=\$(( TRAFFIC_BYTES + BASELINE_BYTES ))
LIMIT_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$LIMIT * 1073741824}")
[ "\$LIMIT_BYTES" -le 0 ] && exit 0
PCT=\$(awk "BEGIN{printf \\"%.1f\\", \$TRAFFIC_BYTES * 100 / \$LIMIT_BYTES}")
USED_GB=\$(awk "BEGIN{printf \\"%.2f\\", \$TRAFFIC_BYTES / 1073741824}")

ICON="✅"
awk "BEGIN{exit !(\$PCT >= 90)}" && ICON="🚨"
awk "BEGIN{exit !(\$PCT >= 70)}" && ICON="⚠️"

MSG="📊 LIN-Panel 流量报告
━━━━━━━━━━━━━━━━
\${ICON} 已用: \${USED_GB} / \${LIMIT} GB (\${PCT}%)
📈 计费模式: \${BILLING_MODE}
━━━━━━━━━━━━━━━━"

curl -s -X POST "https://api.telegram.org/bot\${TG_TOKEN}/sendMessage" \\
    -d chat_id="\${TG_CHAT}" \\
    -d text="\${MSG}" \\
    -d parse_mode="HTML" >/dev/null 2>&1
TGEOF
    chmod +x /root/traffic_check.sh

   
    EXISTING_CRON=$(crontab -l 2>/dev/null || true)
    EXISTING_CRON=$(echo "$EXISTING_CRON" | grep -v 'traffic_check\.sh')
    if ! echo "$EXISTING_CRON" | grep -qF 'traffic_check.sh'; then
        printf "%s\n%s\n" "$EXISTING_CRON" "${TG_CRON} /root/traffic_check.sh" | sed '/^$/d' | crontab -
    fi
    echo -e "  -> Telegram 推送已启用: ${C_YELLOW}${TG_LABEL}${C_RESET}"
    echo -e "  -> Bot: ${C_YELLOW}$(echo "$TG_TOKEN" | cut -c1-10)...${C_RESET}  Chat: ${C_YELLOW}${TG_CHAT}${C_RESET}"
    fi
else
    echo -e "  -> Telegram 推送已跳过"
fi

echo -e "${C_GREEN}[7/7] 🔐 正在配置登录自启与快捷命令...${C_RESET}"

if [ "$ENABLE_LOGIN_AUTO" = "1" ]; then
    if grep -q 'lin-panel.sh' /root/.profile 2>/dev/null; then
        echo -e "  -> /root/.profile 中已存在面板配置，跳过写入。"
    else
        echo "/root/lin-panel.sh" >> /root/.profile
        echo -e "  -> 已追加到 /root/.profile，SSH 登录时将自动展示面板。"
    fi
else
    echo -e "  -> 已跳过登录自启配置。"
fi

ln -sf /root/lin-panel.sh /usr/local/bin/"$CMD"
echo -e "  -> 快捷命令已创建: ${C_YELLOW}${CMD}${C_RESET}"

echo ""
echo -e "${C_CYAN}╭──────────────────────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_GREEN}│                    🎉 安装完成！                             │${C_RESET}"
echo -e "${C_CYAN}╰──────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""
echo -e "${C_WHITE}  快捷命令: ${C_YELLOW}${CMD}${C_WHITE} (随时可用)${C_RESET}"
if [ "$ENABLE_LOGIN_AUTO" = "1" ]; then
    echo -e "${C_WHITE}  登录自启: ${C_GREEN}已开启${C_WHITE} (下次 SSH 登录自动展示)${C_RESET}"
fi
echo ""
echo -e "${C_YELLOW}  ⏳ vnstat 正在收集数据，面板将在几分钟后显示流量统计${C_RESET}"
echo -e "${C_WHITE}  手动查看: ${C_YELLOW}${CMD}${C_RESET}"
echo ""
echo -e "${C_YELLOW}  ⭐ 如果这个面板对你有帮助，请给个 Star 支持一下！${C_RESET}"
echo -e "${C_WHITE}  🔗 https://github.com/linjunhao024-byte/Lin-Panel${C_RESET}"
echo ""
