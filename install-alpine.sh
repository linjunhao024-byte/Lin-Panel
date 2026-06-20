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
echo -e "${C_YELLOW}           极简流量监控伪面板 · v1.0.5${C_RESET}"
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
case "$CMD" in */*|*\ *|*[\<\>\&\|\;\$\`\!]*) echo -e "  ${C_RED}⚠ 命令名包含非法字符，已使用默认值 lin-panel${C_RESET}"; CMD="lin-panel" ;;
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
        apk add --no-cache tzdata >/dev/null 2>&1
        cp "/usr/share/zoneinfo/$TZ_TARGET" /etc/localtime
        echo "$TZ_TARGET" > /etc/timezone
        apk del tzdata >/dev/null 2>&1
    fi
    hwclock --systohc >/dev/null 2>&1 || true
    echo -e "  -> 时区已修改为: ${C_YELLOW}${TZ_TARGET}${C_RESET}"
else
    echo -e "  -> 保持当前时区: ${C_YELLOW}${CURRENT_TZ}${C_RESET}"
fi

echo -e "${C_GREEN}[2/7] 📦 正在安装必要依赖 (vnstat)...${C_RESET}"

apk update && apk add bash vnstat jq >/dev/null 2>&1
rc-service vnstatd start >/dev/null 2>&1
rc-update add vnstatd default >/dev/null 2>&1

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

MAIN_INTERFACE=\$(ip route get 8.8.8.8 2>/dev/null | awk '{print \$5; exit}')
[ -z "\$MAIN_INTERFACE" ] && MAIN_INTERFACE=\$(ip route 2>/dev/null | grep default | awk '{print \$5; exit}')
[ -z "\$MAIN_INTERFACE" ] && MAIN_INTERFACE="eth0"

VSTAT_JSON=\$(vnstat -m -i "\$MAIN_INTERFACE" --json 2>/dev/null)
TRAFFIC_BYTES=0
if [ -n "\$VSTAT_JSON" ]; then
    RX=\$(echo "\$VSTAT_JSON" | grep -o '"rx":[^,}]*' | tail -1 | grep -o '[0-9]*')
    TX=\$(echo "\$VSTAT_JSON" | grep -o '"tx":[^,}]*' | tail -1 | grep -o '[0-9]*')
    TOTAL=\$(echo "\$VSTAT_JSON" | grep -o '"total":[^,}]*' | tail -1 | grep -o '[0-9]*')
    RX=\${RX:-0}; TX=\${TX:-0}; TOTAL=\${TOTAL:-0}
    if [ "\$BILLING_MODE" = "2" ]; then
        BILLING_LABEL="入站计费"
        TRAFFIC_BYTES=\$RX
    elif [ "\$BILLING_MODE" = "3" ]; then
        BILLING_LABEL="出站计费"
        TRAFFIC_BYTES=\$TX
    else
        BILLING_LABEL="双向计费"
        TRAFFIC_BYTES=\$TOTAL
    fi
fi
BASELINE_BYTES=\$(awk "BEGIN{printf \"%.0f\", \$BASELINE * 1073741824}")
TRAFFIC_BYTES=\$(( TRAFFIC_BYTES + BASELINE_BYTES ))
LIMIT_BYTES=\$(awk "BEGIN{printf \"%.0f\", \$LIMIT * 1073741824}")
if [ "\$LIMIT_BYTES" -gt 0 ] 2>/dev/null && [ "\$TRAFFIC_BYTES" -gt 0 ] 2>/dev/null; then
    PCT=\$(awk "BEGIN{printf \"%.1f\", \$TRAFFIC_BYTES * 100 / \$LIMIT_BYTES}")
    USED_GB=\$(awk "BEGIN{printf \"%.2f\", \$TRAFFIC_BYTES / 1073741824}")
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
LEAP=0
if [ \$((NEXT_Y % 4)) -eq 0 ] && [ \$((NEXT_Y % 100)) -ne 0 ] || [ \$((NEXT_Y % 400)) -eq 0 ]; then LEAP=1; fi
[ "\$NEXT_M" -eq 2 ] && MDAYS=\$((28 + LEAP))
TDAY=\$RESET_DAY; [ "\$TDAY" -gt "\$MDAYS" ] && TDAY=\$MDAYS
DOY=0
for _m in \$(seq 1 \$((NEXT_M - 1))); do
    case \$_m in 1|3|5|7|8|10) DOY=\$((DOY+31));; 4|6|9|11) DOY=\$((DOY+30));; 2) DOY=\$((DOY+28+LEAP));; esac
done
DOY=\$((DOY + TDAY))
NEXT_S=\$(( (NEXT_Y - 1970) * 31536000 + ((NEXT_Y - 1969) / 4) * 86400 - ((NEXT_Y - 1901) / 100) * 86400 + ((NEXT_Y - 1601) / 400) * 86400 + (DOY - 1) * 86400 + RESET_HOUR * 3600 + RESET_MIN * 60 + RESET_SEC ))
CDOWN=""
if [ "\$NEXT_S" -gt "\$NOW_S" ]; then
    DIFF=\$((\$NEXT_S - \$NOW_S))
    CD_D=\$((\$DIFF / 86400))
    CD_H=\$((\$DIFF % 86400 / 3600))
    CD_M=\$((\$DIFF % 3600 / 60))
    CDOWN=\${CD_D}天\${CD_H}时\${CD_M}分
fi

clear
COLS=\$(tput cols 2>/dev/null || echo 80)
UPTIME_STR=\$(uptime -p 2>/dev/null | sed 's/up //' || uptime 2>/dev/null | awk -F',' '{print \$1}' | awk '{\$1=""; print \$0}' | sed 's/^ //')
LOAD_STR=\$(awk '{printf "%.2f", \$1}' /proc/loadavg 2>/dev/null || uptime 2>/dev/null | awk -F'load average:' '{print \$2}' | awk -F',' '{gsub(/^ /,"",\$1); print \$1}')
LEFT=" 📊 LIN-PANEL v1.0.5 "
RIGHT=" UP: \${UPTIME_STR} | Load: \${LOAD_STR} "
LEFT_LEN=\${#LEFT}
RIGHT_LEN=\${#RIGHT}
PAD=\$(( COLS - LEFT_LEN - RIGHT_LEN ))
[ "\$PAD" -lt 1 ] && PAD=1
printf "\033[46;30m%s%*s%s\033[0m\n" "\$LEFT" "\$PAD" "" "\$RIGHT"
echo ""
echo -e "\${C_CYAN}╔════════════════════════════════════════════════════════════════╗\${C_RESET}"
echo -e "\${C_CYAN}║\${C_RESET} \${C_GREEN}💵 当期流量总账 ─ \${BILLING_LABEL}上限: ${LIMIT}GB\${C_RESET}\${C_CYAN}║\${C_RESET}"
if [ -n "\$PCT" ]; then
    CLR="\${C_GREEN}"
    [ "\$ALERT" = "yellow" ] && CLR="\${C_YELLOW}"
    [ "\$ALERT" = "red" ] && CLR="\${C_RED}"
    ICON="✅"; [ "\$ALERT" = "yellow" ] && ICON="⚠️"
    [ "\$ALERT" = "red" ] && ICON="🚨"
    echo -e "\${C_CYAN}║\${C_RESET} \${CLR}\${ICON} 已用: \${USED_GB} / ${LIMIT} GB (\${PCT}%)\${C_RESET}\${C_CYAN}║\${C_RESET}"
else
    echo -e "\${C_CYAN}║\${C_RESET} \${C_WHITE}📊 已用: \${USED_GB} / ${LIMIT} GB\${C_RESET}\${C_CYAN}║\${C_RESET}"
fi
if [ -n "\$CDOWN" ]; then
    echo -e "\${C_CYAN}║\${C_RESET} \${C_WHITE}⏱️  距离重置: \${C_YELLOW}\${CDOWN}\${C_RESET}\${C_CYAN}║\${C_RESET}"
fi
echo -e "\${C_CYAN}╚════════════════════════════════════════════════════════════════╝\${C_RESET}"
echo ""
VSTAT_M=\$(vnstat -m -i "\$MAIN_INTERFACE" 2>/dev/null | sed \\
    -e "s/\$MAIN_INTERFACE/网卡/g" \\
    -e 's/rx/入站(RX)/g' \\
    -e 's/tx/出站(TX)/g' \\
    -e 's/total/合计(Total)/g' \\
    -e 's/estimated/预计/g' \\
    -e 's/avg. rate/平均流速/g' \\
    -e 's/monthly/按月统计/g' \\
    -e 's/month/月份/g' \\
    -e 's/-/─/g' \\
    -e 's/+/┼/g' \\
    -e 's/|/│/g')
printf "\${C_CYAN}%s\n\${C_RESET}" "\$VSTAT_M"

echo ""
echo -e "\${C_GREEN}  📅 每日流量明细\${C_RESET}"
VSTAT_D=\$(vnstat -d -i "\$MAIN_INTERFACE" 2>/dev/null | sed \\
    -e "s/\$MAIN_INTERFACE/网卡/g" \\
    -e 's/rx/入站(RX)/g' \\
    -e 's/tx/出站(TX)/g' \\
    -e 's/total/合计(Total)/g' \\
    -e 's/estimated/预计/g' \\
    -e 's/avg. rate/平均流速/g' \\
    -e 's/daily/按日统计/g' \\
    -e 's/day/日期/g' \\
    -e 's/-/─/g' \\
    -e 's/+/┼/g' \\
    -e 's/|/│/g')
printf "\${C_CYAN}%s\n\${C_RESET}" "\$VSTAT_D"

echo ""
echo -e "\${C_CYAN}╔════════════════════════════════════════════════════════════════╗\${C_RESET}"
echo -e "\${C_CYAN}║\${C_RESET}\${C_YELLOW}                      ⚙️  系统状态                              \${C_RESET}\${C_CYAN}║\${C_RESET}"
echo -e "\${C_CYAN}╠════════════════════════════════════════════════════════════════╣\${C_RESET}"

VNSTAT_STATUS="已停止"
VNSTAT_CLR="\${C_RED}"
if systemctl is-active --quiet vnstat 2>/dev/null || rc-service vnstatd status 2>/dev/null | grep -q "started"; then
    VNSTAT_STATUS="运行中"
    VNSTAT_CLR="\${C_GREEN}"
fi

CRON_STATUS="未激活"
CRON_CLR="\${C_RED}"
if systemctl is-active --quiet cron 2>/dev/null || systemctl is-active --quiet crond 2>/dev/null || rc-service crond status 2>/dev/null | grep -q "started"; then
    CRON_STATUS="已激活"
    CRON_CLR="\${C_GREEN}"
fi

TG_STATUS="未启用"
TG_CLR="\${C_WHITE}"
if [ -f /root/traffic_check.sh ]; then
    TG_STATUS="已启用"
    TG_CLR="\${C_GREEN}"
fi

echo -e "\${C_CYAN}║\${C_RESET} \${C_WHITE}vnstat 状态:\${C_RESET}       \${VNSTAT_CLR}\${VNSTAT_STATUS}\${C_RESET}\${C_CYAN}                        ║\${C_RESET}"
echo -e "\${C_CYAN}║\${C_RESET} \${C_WHITE}定时任务:\${C_RESET}          \${CRON_CLR}\${CRON_STATUS}\${C_RESET}\${C_CYAN}                          ║\${C_RESET}"
echo -e "\${C_CYAN}║\${C_RESET} \${C_WHITE}Telegram 推送:\${C_RESET}     \${TG_CLR}\${TG_STATUS}\${C_RESET}\${C_CYAN}                        ║\${C_RESET}"
echo -e "\${C_CYAN}╚════════════════════════════════════════════════════════════════╝\${C_RESET}"

show_trend() {
    echo ""
    echo -e "\${C_GREEN}  📊 近 7 天流量趋势\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
    TREND=\$(vnstat -d -i "\$MAIN_INTERFACE" 2>/dev/null | awk '/[0-9]+\\.[0-9]+/{d=\\\$1; v=\\\$NF; if(d~/^[0-9]/) print d" "v}' | tail -7)
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
        DL=\$(awk "BEGIN{d=(\$R2-\$R1)/2; if(d>=1073741824) printf \"\\\033[1;31m%.2f GB/s\\\033[0m\", d/1073741824; else if(d>=1048576) printf \"\\\033[1;33m%.2f MB/s\\\033[0m\", d/1048576; else printf \"\\\033[1;32m%.0f KB/s\\\033[0m\", d/1024}")
        UL=\$(awk "BEGIN{d=(\$T2-\$T1)/2; if(d>=1073741824) printf \"\\\033[1;31m%.2f GB/s\\\033[0m\", d/1073741824; else if(d>=1048576) printf \"\\\033[1;33m%.2f MB/s\\\033[0m\", d/1048576; else printf \"\\\033[1;32m%.0f KB/s\\\033[0m\", d/1024}")
        echo -e "  ⬇  下载: \${DL}"
        echo -e "  ⬆  上传: \${UL}"
    else
        echo -e "  \${C_RED}无法读取网卡 \${IFACE} 的流速数据\${C_RESET}"
    fi
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
}

do_manual_push() {
    echo ""
    echo -e "\${C_GREEN}  📤 手动推送流量报告\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
    if [ -f /root/traffic_check.sh ]; then
        echo -e "  \${C_WHITE}正在推送...\${C_RESET}"
        /root/traffic_check.sh
        echo -e "  \${C_GREEN}✅ 推送完成，请检查 Telegram\${C_RESET}"
    else
        echo -e "  \${C_RED}❌ 推送脚本不存在，请先配置 Telegram 推送\${C_RESET}"
    fi
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
}

do_modify_spike() {
    echo ""
    echo -e "\${C_GREEN}  ⚡ 修改短时激增告警阈值\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
    echo -e "  \${C_WHITE}说明: 系统每 10 分钟自动检测网卡流量增量\${C_RESET}"
    echo -e "  \${C_WHITE}若 10 分钟内激增超过阈值，将通过 Telegram 推送告警\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
    if [ ! -f /root/traffic_spike_check.sh ]; then
        echo -e "  \${C_RED}❌ 激增告警脚本不存在\${C_RESET}"
        echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
        return
    fi
    CUR=\$(grep '^SPIKE_LIMIT=' /root/traffic_spike_check.sh | head -1 | cut -d= -f2)
    if [ "\$CUR" = "0" ]; then
        echo -e "  \${C_WHITE}当前状态: \${C_RED}已禁用\${C_RESET}"
    else
        echo -e "  \${C_WHITE}当前阈值: \${C_YELLOW}\${CUR} GB/10分钟\${C_RESET}"
    fi
    printf "  请输入新阈值(GB/10分钟) [输入 0 禁用]: "
    read NEW_SPIKE
    if [ -z "\$NEW_SPIKE" ]; then
        echo -e "  \${C_YELLOW}已取消\${C_RESET}"
    else
        sed -i "s/^SPIKE_LIMIT=.*/SPIKE_LIMIT=\${NEW_SPIKE}/" /root/traffic_spike_check.sh
        if [ "\$NEW_SPIKE" = "0" ]; then
            echo -e "  \${C_RED}短时激增告警已禁用\${C_RESET}"
        else
            echo -e "  \${C_GREEN}✅ 阈值已修改为: \${C_YELLOW}\${NEW_SPIKE} GB/10分钟\${C_RESET}"
        fi
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
    rm -f /root/traffic_reset.sh /root/traffic_reset_check.sh /root/traffic_check.sh /root/traffic_spike_check.sh
    echo -e "  ✅ 重置/推送脚本已删除"
    rm -f /root/traffic_history.log
    echo -e "  ✅ 流量日志已删除"
    rm -f /usr/local/bin/"${CMD}"
    echo -e "  ✅ 快捷命令已删除"
   
    EXISTING=\$(crontab -l 2>/dev/null || true)
    CLEANED=\$(echo "\$EXISTING" | grep -v 'traffic_history\|traffic_reset\|traffic_check\|traffic_spike')
    echo "\$CLEANED" | sed '/^$/d' | crontab - 2>/dev/null
    echo -e "  ✅ 定时任务已清理"
   
    if [ -f /root/.bashrc ]; then
        sed -i '/LIN-PANEL-AUTO-START/,/END LIN-PANEL-AUTO-START/d' /root/.bashrc
        echo -e "  ✅ 登录自启已移除"
    fi
    sed -i '/lin-panel/d' /root/.profile 2>/dev/null
    echo ""
    printf "  是否同时卸载 vnstat（流量统计工具）？[y/N] [默认: N]: "
    read RM_VNSTAT
    if [ "\$RM_VNSTAT" = "y" ] || [ "\$RM_VNSTAT" = "Y" ]; then
        rc-service vnstatd stop 2>/dev/null || systemctl stop vnstat 2>/dev/null
        rc-update del vnstatd default 2>/dev/null || systemctl disable vnstat 2>/dev/null
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
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[5] 手动推送     \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[6] 激增告警阈值 \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_RED}[7] 一键卸载     \${C_CYAN}│\${C_RESET}"
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
        5) do_manual_push ;;
        6) do_modify_spike ;;
        7) do_uninstall ;;
        0|"") echo -e "\n  \${C_GREEN}👋 已退出面板\${C_RESET}"; exit 0 ;;
        *) echo -e "  \${C_RED}无效选项，请重新输入\${C_RESET}" ;;
    esac
done
EOF

chmod +x /root/lin-panel.sh

echo -e "${C_GREEN}[4/7] 🔄 正在配置自动重置脚本...${C_RESET}"

cat << RESEOF > /root/traffic_reset_check.sh
#!/bin/sh
RESET_DAY=${DAY}
RESET_HOUR=${HOUR}
RESET_MIN=${MINUTE}
RESET_SEC=${SECOND}

TODAY=\$(date +%-d)
MONTH=\$(date +%-m)
YEAR=\$(date +%Y)

MAX_DAY=31
case \$MONTH in 2) MAX_DAY=28;; 4|6|9|11) MAX_DAY=30;; esac
if { [ \$((YEAR % 4)) -eq 0 ] && [ \$((YEAR % 100)) -ne 0 ]; } || [ \$((YEAR % 400)) -eq 0 ]; then
    [ "\$MONTH" -eq 2 ] && MAX_DAY=29
fi

TARGET_DAY=\$RESET_DAY
[ "\$TARGET_DAY" -gt "\$MAX_DAY" ] && TARGET_DAY=\$MAX_DAY

if [ "\$TODAY" -ne "\$TARGET_DAY" ]; then
    exit 0
fi

LEAP=0
if { [ \$((YEAR % 4)) -eq 0 ] && [ \$((YEAR % 100)) -ne 0 ]; } || [ \$((YEAR % 400)) -eq 0 ]; then LEAP=1; fi
DOY=0
for m in 1 2 3 4 5 6 7 8 9 10 11; do
    [ \$m -ge \$MONTH ] && break
    case \$m in 1|3|5|7|8|10) DOY=\$((DOY+31));; 4|6|9|11) DOY=\$((DOY+30));; 2) DOY=\$((DOY+28+LEAP));; esac
done
DOY=\$((DOY + TARGET_DAY))
NOW_S=\$(date +%s)
TARGET_S=\$(( (YEAR - 1970) * 31536000 + ((YEAR - 1969) / 4) * 86400 - ((YEAR - 1901) / 100) * 86400 + ((YEAR - 1601) / 400) * 86400 + (DOY - 1) * 86400 + RESET_HOUR * 3600 + RESET_MIN * 60 + RESET_SEC ))
SLEEP=\$(( TARGET_S - NOW_S ))
[ "\$SLEEP" -gt 0 ] && sleep "\$SLEEP"

rc-service vnstatd stop
rm -rf /var/lib/vnstat/*
rc-service vnstatd start
RESEOF
chmod +x /root/traffic_reset_check.sh

echo -e "${C_GREEN}[5/7] 📊 正在配置每日流量记录与自动清理...${C_RESET}"

EXISTING_CRON=$(crontab -l 2>/dev/null || true)

CRON_TREND='59 23 * * * MAIN_IF=$(ip route get 8.8.8.8 2>/dev/null | awk '"'"'{print $5; exit}'"'"'); [ -z "$MAIN_IF" ] && MAIN_IF=$(ip route 2>/dev/null | grep default | awk '"'"'{print $5; exit}'"'"'); [ -z "$MAIN_IF" ] && MAIN_IF="eth0"; echo "$(date +%Y-%m-%d) $(vnstat -m -i "$MAIN_IF" | awk '"'"'/total/{print $NF}'"'"')" >> /root/traffic_history.log && tail -30 /root/traffic_history.log > /tmp/.tl && mv /tmp/.tl /root/traffic_history.log'
CRON_RESET="0 0 * * * /root/traffic_reset_check.sh"
CRON_SPIKE="*/10 * * * * /root/traffic_spike_check.sh"

EXISTING_CRON=$(echo "$EXISTING_CRON" | grep -v 'traffic_history\.log')

NEW_ENTRIES=""
if ! echo "$EXISTING_CRON" | grep -qF 'traffic_history.log'; then
    NEW_ENTRIES="${NEW_ENTRIES}${CRON_TREND}\n"
fi
if ! echo "$EXISTING_CRON" | grep -qF 'traffic_reset_check.sh'; then
    NEW_ENTRIES="${NEW_ENTRIES}${CRON_RESET}\n"
fi
if ! echo "$EXISTING_CRON" | grep -qF 'traffic_spike_check.sh'; then
    NEW_ENTRIES="${NEW_ENTRIES}${CRON_SPIKE}\n"
fi

if [ -n "$NEW_ENTRIES" ]; then
    printf "%s\n%s" "$EXISTING_CRON" "$NEW_ENTRIES" | sed '/^$/d' | crontab -
    echo -e "  -> 已追加 ${C_YELLOW}$(echo "$NEW_ENTRIES" | wc -l | tr -d ' ')${C_RESET} 条定时任务"
else
    echo -e "  -> 定时任务已存在，跳过写入"
fi

rc-update add crond default >/dev/null 2>&1
rc-service crond start >/dev/null 2>&1

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

    if [ "$TG_FREQ" = "1" ]; then
        printf "  请选择每日推送时间 (0-23) [默认: 9]: "
        read TG_HOUR
        TG_HOUR="${TG_HOUR:-9}"
        case "$TG_HOUR" in [0-9]|1[0-9]|2[0-3]) ;; *) echo -e "  ${C_RED}⚠ 小时无效，已使用默认值 9${C_RESET}"; TG_HOUR=9 ;; esac
        TG_CRON="0 ${TG_HOUR} * * *"
        TG_LABEL="每日 ${TG_HOUR}:00"
    elif [ "$TG_FREQ" = "2" ]; then
        printf "  请选择每周推送时间:\n"
        printf "    [1] 周一  [2] 周二  [3] 周三  [4] 周四\n"
        printf "    [5] 周五  [6] 周六  [7] 周日\n"
        printf "  请选择 [1-7] [默认: 1]: "
        read TG_WEEKDAY
        case "$TG_WEEKDAY" in
            2) TG_WEEKDAY=2 ;;
            3) TG_WEEKDAY=3 ;;
            4) TG_WEEKDAY=4 ;;
            5) TG_WEEKDAY=5 ;;
            6) TG_WEEKDAY=6 ;;
            7) TG_WEEKDAY=0 ;;
            *) TG_WEEKDAY=1 ;;
        esac
        printf "  请选择推送时间 (0-23) [默认: 12]: "
        read TG_HOUR
        TG_HOUR="${TG_HOUR:-12}"
        case "$TG_HOUR" in [0-9]|1[0-9]|2[0-3]) ;; *) echo -e "  ${C_RED}⚠ 小时无效，已使用默认值 12${C_RESET}"; TG_HOUR=12 ;; esac
        WEEKDAY_LABEL="周日"
        case "$TG_WEEKDAY" in 1) WEEKDAY_LABEL="周一";; 2) WEEKDAY_LABEL="周二";; 3) WEEKDAY_LABEL="周三";; 4) WEEKDAY_LABEL="周四";; 5) WEEKDAY_LABEL="周五";; 6) WEEKDAY_LABEL="周六";; 0) WEEKDAY_LABEL="周日";; esac
        TG_CRON="0 ${TG_HOUR} * * ${TG_WEEKDAY}"
        TG_LABEL="每${WEEKDAY_LABEL} ${TG_HOUR}:00"
    else
        PUSH_DAY=$((DAY - 1))
        [ "$PUSH_DAY" -lt 1 ] && PUSH_DAY=28
        TG_CRON="0 12 ${PUSH_DAY} * *"
        TG_LABEL="每月${PUSH_DAY}日 12:00 (重置前12小时)"
    fi

    cat << TGEOF > /root/traffic_check.sh
#!/bin/sh
LIMIT=${LIMIT}
BILLING_MODE=${BILLING_MODE}
BASELINE=${BASELINE}
TG_TOKEN="${TG_TOKEN}"
TG_CHAT="${TG_CHAT}"

MAIN_INTERFACE=\$(ip route get 8.8.8.8 2>/dev/null | awk '{print \$5; exit}')
[ -z "\$MAIN_INTERFACE" ] && MAIN_INTERFACE=\$(ip route 2>/dev/null | grep default | awk '{print \$5; exit}')
[ -z "\$MAIN_INTERFACE" ] && MAIN_INTERFACE="eth0"

VSTAT_JSON=\$(vnstat -m -i "\$MAIN_INTERFACE" --json 2>/dev/null)
TRAFFIC_BYTES=0
if [ -n "\$VSTAT_JSON" ]; then
    RX=\$(echo "\$VSTAT_JSON" | grep -o '"rx":[^,}]*' | tail -1 | grep -o '[0-9]*')
    TX=\$(echo "\$VSTAT_JSON" | grep -o '"tx":[^,}]*' | tail -1 | grep -o '[0-9]*')
    TOTAL=\$(echo "\$VSTAT_JSON" | grep -o '"total":[^,}]*' | tail -1 | grep -o '[0-9]*')
    RX=\${RX:-0}; TX=\${TX:-0}; TOTAL=\${TOTAL:-0}
    if [ "\$BILLING_MODE" = "2" ]; then
        BILLING_LABEL="入站计费"
        TRAFFIC_BYTES=\$RX
    elif [ "\$BILLING_MODE" = "3" ]; then
        BILLING_LABEL="出站计费"
        TRAFFIC_BYTES=\$TX
    else
        BILLING_LABEL="双向计费"
        TRAFFIC_BYTES=\$TOTAL
    fi
fi
BASELINE_BYTES=\$(awk "BEGIN{printf \"%.0f\", \$BASELINE * 1073741824}")
TRAFFIC_BYTES=\$(( TRAFFIC_BYTES + BASELINE_BYTES ))
LIMIT_BYTES=\$(awk "BEGIN{printf \"%.0f\", \$LIMIT * 1073741824}")
[ "\$LIMIT_BYTES" -le 0 ] 2>/dev/null && exit 0
[ "\$TRAFFIC_BYTES" -le 0 ] 2>/dev/null && exit 0
PCT=\$(awk "BEGIN{printf \"%.1f\", \$TRAFFIC_BYTES * 100 / \$LIMIT_BYTES}")
USED_GB=\$(awk "BEGIN{printf \"%.2f\", \$TRAFFIC_BYTES / 1073741824}")

ICON="✅"
awk "BEGIN{exit !(\$PCT >= 90)}" && ICON="🚨"
awk "BEGIN{exit !(\$PCT >= 70)}" && ICON="⚠️"

MSG="📊 LIN-Panel 流量报告
━━━━━━━━━━━━━━━━
\${ICON} 已用: \${USED_GB} / \${LIMIT} GB (\${PCT}%)
📈 计费模式: \${BILLING_LABEL}
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
    echo ""
    echo -e "  ${C_WHITE}将在 10 分钟后发送数据推送测试消息（等待 vnstat 采集数据）...${C_RESET}"
    echo -e "  ${C_WHITE}测试消息仅发送一次，用于验证推送功能是否正常。${C_RESET}"
    cat << TESTEOF > /root/traffic_test.sh
#!/bin/sh
sleep 600
LIMIT=${LIMIT}
BILLING_MODE=${BILLING_MODE}
BASELINE=${BASELINE}
TG_TOKEN="${TG_TOKEN}"
TG_CHAT="${TG_CHAT}"

MAIN_INTERFACE=\$(ip route get 8.8.8.8 2>/dev/null | awk '{print \$5; exit}')
[ -z "\$MAIN_INTERFACE" ] && MAIN_INTERFACE=\$(ip route 2>/dev/null | grep default | awk '{print \$5; exit}')
[ -z "\$MAIN_INTERFACE" ] && MAIN_INTERFACE="eth0"

VSTAT_JSON=\$(vnstat -m -i "\$MAIN_INTERFACE" --json 2>/dev/null)
TRAFFIC_BYTES=0
if [ -n "\$VSTAT_JSON" ]; then
    RX=\$(echo "\$VSTAT_JSON" | grep -o '"rx":[^,}]*' | tail -1 | grep -o '[0-9]*')
    TX=\$(echo "\$VSTAT_JSON" | grep -o '"tx":[^,}]*' | tail -1 | grep -o '[0-9]*')
    TOTAL=\$(echo "\$VSTAT_JSON" | grep -o '"total":[^,}]*' | tail -1 | grep -o '[0-9]*')
    RX=\${RX:-0}; TX=\${TX:-0}; TOTAL=\${TOTAL:-0}
    if [ "\$BILLING_MODE" = "2" ]; then
        BILLING_LABEL="入站计费"
        TRAFFIC_BYTES=\$RX
    elif [ "\$BILLING_MODE" = "3" ]; then
        BILLING_LABEL="出站计费"
        TRAFFIC_BYTES=\$TX
    else
        BILLING_LABEL="双向计费"
        TRAFFIC_BYTES=\$TOTAL
    fi
fi
BASELINE_BYTES=\$(awk "BEGIN{printf \"%.0f\", \$BASELINE * 1073741824}")
TRAFFIC_BYTES=\$(( TRAFFIC_BYTES + BASELINE_BYTES ))
LIMIT_BYTES=\$(awk "BEGIN{printf \"%.0f\", \$LIMIT * 1073741824}")
[ "\$LIMIT_BYTES" -le 0 ] 2>/dev/null && exit 0
[ "\$TRAFFIC_BYTES" -le 0 ] 2>/dev/null && exit 0
PCT=\$(awk "BEGIN{printf \"%.1f\", \$TRAFFIC_BYTES * 100 / \$LIMIT_BYTES}")
USED_GB=\$(awk "BEGIN{printf \"%.2f\", \$TRAFFIC_BYTES / 1073741824}")

ICON="✅"
awk "BEGIN{exit !(\$PCT >= 90)}" && ICON="🚨"
awk "BEGIN{exit !(\$PCT >= 70)}" && ICON="⚠️"

MSG="📊 数据推送测试消息
━━━━━━━━━━━━━━━━
这是一条测试消息，用于验证推送功能是否正常。
\${ICON} 已用: \${USED_GB} / \${LIMIT} GB (\${PCT}%)
📈 计费模式: \${BILLING_LABEL}
━━━━━━━━━━━━━━━━
如果您收到了这条消息，说明推送配置成功！
正式推送将按照您设置的频率（${TG_LABEL}）进行。"

curl -s -X POST "https://api.telegram.org/bot\${TG_TOKEN}/sendMessage" \\
    -d chat_id="\${TG_CHAT}" \\
    -d text="\${MSG}" \\
    -d parse_mode="HTML" >/dev/null 2>&1
rm -f /root/traffic_test.sh
TESTEOF
    chmod +x /root/traffic_test.sh
    nohup /root/traffic_test.sh >/dev/null 2>&1 &
    echo -e "  ${C_GREEN}✅ 数据推送测试消息已计划，10 分后请检查 Telegram${C_RESET}"
    fi
else
    echo -e "  -> Telegram 推送已跳过"
fi

echo ""
printf "  请输入短时激增告警阈值(GB/10分钟) [默认: 5，输入 0 禁用此功能]: "
read SPIKE_LIMIT
SPIKE_LIMIT="${SPIKE_LIMIT:-5}"
if [ "$SPIKE_LIMIT" = "0" ]; then
    echo -e "  -> 短时激增告警: ${C_RED}已禁用${C_RESET}"
else
    echo -e "  -> 短时激增告警阈值: ${C_YELLOW}${SPIKE_LIMIT}GB/10分钟${C_RESET}"
    echo -e "  ${C_WHITE}工作原理: 每 10 分钟检测一次网卡流量增量${C_RESET}"
    echo -e "  ${C_WHITE}若 10 分钟内流量激增超过阈值，将通过 Telegram 推送告警${C_RESET}"
    echo -e "  ${C_WHITE}后续可在面板菜单 [6] 中随时修改阈值或禁用${C_RESET}"
fi

cat << SPIKEEOF > /root/traffic_spike_check.sh
#!/bin/bash
SPIKE_LIMIT=${SPIKE_LIMIT}
TG_TOKEN="${TG_TOKEN:-}"
TG_CHAT="${TG_CHAT:-}"
[ "\$SPIKE_LIMIT" = "0" ] && exit 0
MAIN_INTERFACE=\$(ip route get 8.8.8.8 2>/dev/null | awk '{print \$5; exit}')
[ -z "\$MAIN_INTERFACE" ] && MAIN_INTERFACE=\$(ip route 2>/dev/null | grep default | awk '{print \$5; exit}')
[ -z "\$MAIN_INTERFACE" ] && MAIN_INTERFACE="eth0"
STAT_PATH="/sys/class/net/\$MAIN_INTERFACE/statistics"
[ -d "\$STAT_PATH" ] || exit 0
RX=\$(cat "\$STAT_PATH/rx_bytes" 2>/dev/null || echo 0)
TX=\$(cat "\$STAT_PATH/tx_bytes" 2>/dev/null || echo 0)
NOW_TOTAL=\$(( RX + TX ))
LAST_FILE="/tmp/.lin_last_traffic"
if [ -f "\$LAST_FILE" ] && [ -n "\$TG_TOKEN" ] && [ -n "\$TG_CHAT" ]; then
    LAST_TOTAL=\$(cat "\$LAST_FILE")
    if [ "\$NOW_TOTAL" -gt "\$LAST_TOTAL" ] 2>/dev/null; then
        DELTA_BYTES=\$(( NOW_TOTAL - LAST_TOTAL ))
        SPIKE_BYTES=\$(awk "BEGIN{printf \"%.0f\", \$SPIKE_LIMIT * 1073741824}")
        if [ "\$DELTA_BYTES" -gt "\$SPIKE_BYTES" ] 2>/dev/null; then
            DELTA_GB=\$(awk "BEGIN{printf \"%.2f\", \$DELTA_BYTES / 1073741824}")
            MSG="🚨 流量激增告警
━━━━━━━━━━━━━━━━
⚠️ 网卡: \${MAIN_INTERFACE}
📈 10分钟内激增: \${DELTA_GB} GB
🔔 告警阈值: \${SPIKE_LIMIT} GB
━━━━━━━━━━━━━━━━"
            curl -s -X POST "https://api.telegram.org/bot\${TG_TOKEN}/sendMessage" -d chat_id="\${TG_CHAT}" -d text="\${MSG}" >/dev/null 2>&1
        fi
    fi
fi
echo "\$NOW_TOTAL" > "\$LAST_FILE"
SPIKEEOF
chmod +x /root/traffic_spike_check.sh

echo -e "${C_GREEN}[7/7] 🔐 正在配置登录自启与快捷命令...${C_RESET}"

if [ "$ENABLE_LOGIN_AUTO" = "1" ]; then
    PANEL_MARKER="# LIN-PANEL-AUTO-START"
    if grep -q 'LIN-PANEL-AUTO-START' /root/.bashrc 2>/dev/null; then
        echo -e "  -> /root/.bashrc 中已存在面板配置，跳过写入。"
    else
        cat >> /root/.bashrc << 'AUTOSTART'

# LIN-PANEL-AUTO-START
case "$-" in
    *i*)
        case "$SSH_CONNECTION" in
            *"",*) [ -z "$SCP_OR_SFTP" ] && /root/lin-panel.sh ;;
        esac
        ;;
esac
# END LIN-PANEL-AUTO-START
AUTOSTART
        echo -e "  -> 已追加到 /root/.bashrc，SSH 登录时将自动展示面板。"
    fi
    # 清理旧版 .profile 中的残留
    if grep -q 'lin-panel.sh' /root/.profile 2>/dev/null; then
        sed -i '/lin-panel.sh/d' /root/.profile
        echo -e "  -> 已清理 /root/.profile 中的旧配置。"
    fi
else
    echo -e "  -> 已跳过登录自启配置。"
fi

ln -sf /root/lin-panel.sh /usr/local/bin/"$CMD"
if [ -L "/usr/local/bin/$CMD" ] && [ -x "/usr/local/bin/$CMD" ]; then
    echo -e "  -> 快捷命令已创建: ${C_YELLOW}${CMD}${C_RESET}"
else
    echo -e "  ${C_RED}⚠ 快捷命令创建失败，请手动执行: ln -sf /root/lin-panel.sh /usr/local/bin/${CMD}${C_RESET}"
fi

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
printf "是否立即进入面板？[Y/n] [默认: Y]: "
read ENTER_PANEL
if [ "$ENTER_PANEL" != "N" ] && [ "$ENTER_PANEL" != "n" ]; then
    /root/lin-panel.sh
fi
