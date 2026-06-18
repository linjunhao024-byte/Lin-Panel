#!/bin/sh
# LIN Minimalist Traffic Panel Installer
# Target: Ubuntu (Interactive Edition v1.0.0)

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
echo -e "${C_YELLOW}           Minimalist Traffic Panel · v1.0.0${C_RESET}"
echo ""
echo -e "${C_CYAN}╭──────────────────────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_YELLOW}│              Welcome to LIN Installer                       │${C_RESET}"
echo -e "${C_CYAN}╰──────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

echo -e "${C_CYAN}┌──────────── Configuration ────────────┐${C_RESET}"
echo ""

# 1. 流量上限自定义
printf "Enter traffic limit (GB) [default: 350]: "
read LIMIT
LIMIT="${LIMIT:-350}"
echo -e "  -> Traffic limit: ${C_YELLOW}${LIMIT}GB${C_RESET}"
echo ""

# 2. Billing mode
printf "Select billing mode\n"
printf "  [1] Bidirectional [default]\n"
printf "  [2] Inbound only\n"
printf "  [3] Outbound only\n"
printf "  Select [1/2/3] [default: 1]: "
read BILLING
case "$BILLING" in
    2) BILLING_MODE=2; echo -e "  -> Billing: ${C_YELLOW}Inbound only (RX)${C_RESET}" ;;
    3) BILLING_MODE=3; echo -e "  -> Billing: ${C_YELLOW}Outbound only (TX)${C_RESET}" ;;
    *) BILLING_MODE=1; echo -e "  -> Billing: ${C_YELLOW}Bidirectional (In+Out)${C_RESET}" ;;
esac
echo ""

# 3. 重置时间自定义
printf "Enter monthly reset time\n"
printf "  Day (1-31) [default 1]: "
read DAY
DAY="${DAY:-1}"
case "$DAY" in [1-9]|[12][0-9]|3[01]) ;; *) echo -e "  ${C_RED}⚠ 日期invalid, default 1${C_RESET}"; DAY=1 ;;
esac

printf "  Hour (0-23) [default 0]: "
read HOUR
HOUR="${HOUR:-0}"
case "$HOUR" in [0-9]|1[0-9]|2[0-3]) ;; *) echo -e "  ${C_RED}⚠ 小时invalid, default 0${C_RESET}"; HOUR=0 ;;
esac

printf "  Minute (0-59) [default 0]: "
read MINUTE
MINUTE="${MINUTE:-0}"
case "$MINUTE" in [0-9]|[1-4][0-9]|5[0-9]) ;; *) echo -e "  ${C_RED}⚠ 分钟invalid, default 0${C_RESET}"; MINUTE=0 ;;
esac

printf "  Second (0-59) [default 0]: "
read SECOND
SECOND="${SECOND:-0}"
case "$SECOND" in [0-9]|[1-4][0-9]|5[0-9]) ;; *) echo -e "  ${C_RED}⚠ 秒数invalid, default 0${C_RESET}"; SECOND=0 ;;
esac
echo -e "  -> Reset: Monthly ${C_YELLOW}${DAY}日 ${HOUR}:${MINUTE}:${SECOND}${C_RESET}"
echo ""

# 4. 是否开启登录自启
printf "Show panel on SSH login？[Y/n] [default: Y]: "
read LOGIN_AUTO
if [ "$LOGIN_AUTO" = "N" ] || [ "$LOGIN_AUTO" = "n" ]; then
    ENABLE_LOGIN_AUTO=0
    echo -e "  -> Auto-start: ${C_RED}OFF${C_RESET}"
else
    ENABLE_LOGIN_AUTO=1
    echo -e "  -> Auto-start: ${C_GREEN}ON${C_RESET}"
fi
echo ""

# 5. 自定义快捷命令名
printf "Enter command name [default: lin-panel]: "
read CMD
CMD="${CMD:-lin-panel}"
echo -e "  -> Command: ${C_YELLOW}${CMD}${C_RESET}"
echo ""
echo -e "${C_CYAN}└────────────────────────────────────┘${C_RESET}"
echo ""

echo -e "${C_GREEN}[1/7] 🌐 Timezone${C_RESET}"

CURRENT_TZ=$(cat /etc/timezone 2>/dev/null || date +%Z)
printf "  Current: ${C_YELLOW}%s${C_RESET}\n" "$CURRENT_TZ"
echo ""
printf "  Select timezone:\n"
printf "    [1] Asia/Shanghai    (UTC+8)  China\n"
printf "    [2] Asia/Hong_Kong   (UTC+8)  HK\n"
printf "    [3] Asia/Tokyo       (UTC+9)  Japan\n"
printf "    [4] Asia/Singapore   (UTC+8)  Singapore\n"
printf "    [5] America/New_York (UTC-5)  US East\n"
printf "    [6] America/Los_Angeles (UTC-8) US West\n"
printf "    [7] Europe/London    (UTC+0)  UK\n"
printf "    [8] Europe/Berlin    (UTC+1)  Europe\n"
printf "    [9] UTC              (UTC+0)  UTC\n"
printf "    [0] Keep current\n"
printf "  Select [0-9] [default: 0]: "
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
    echo -e "  -> Timezone: ${C_YELLOW}${TZ_TARGET}${C_RESET}"
else
    echo -e "  -> Keeping: ${C_YELLOW}${CURRENT_TZ}${C_RESET}"
fi

echo -e "${C_GREEN}[2/7] 📦 Installing deps (vnstat)...${C_RESET}"

apt-get update -qq && apt-get install -y vnstat >/dev/null 2>&1
systemctl start vnstat >/dev/null 2>&1
systemctl enable vnstat >/dev/null 2>&1

echo -e "${C_GREEN}[3/7] 🎨 Generating panel...${C_RESET}"

cat << EOF > /root/lin-panel-en.sh
#!/bin/bash
C_CYAN='\\033[1;36m'
C_YELLOW='\\033[1;33m'
C_GREEN='\\033[1;32m'
C_WHITE='\\033[1;37m'
C_RED='\\033[1;31m'
C_RESET='\\033[0m'

LIMIT=${LIMIT}
BILLING_MODE=${BILLING_MODE}
RESET_DAY=${DAY}
RESET_HOUR=${HOUR}
RESET_MIN=${MINUTE}
RESET_SEC=${SECOND}

PCT=""
ALERT=""
USED_GB=0
BILLING_LABEL="Bidirectional"

VSTAT_RAW=\$(vnstat -m 2>/dev/null)
if [ -n "\$VSTAT_RAW" ]; then
    UNIT=\$(echo "\$VSTAT_RAW" | awk '/GiB|TiB|MiB/{print \$3; exit}')
    TRAFFIC_RAW=""
    if [ "\$BILLING_MODE" = "2" ]; then
        BILLING_LABEL="Inbound"
        TRAFFIC_RAW=\$(echo "\$VSTAT_RAW" | awk '/[0-9]/{if(\$0~/[A-Z][a-z][a-z].*[0-9]/) v=\$3} END{print v}')
    elif [ "\$BILLING_MODE" = "3" ]; then
        BILLING_LABEL="Outbound"
        TRAFFIC_RAW=\$(echo "\$VSTAT_RAW" | awk '/[0-9]/{if(\$0~/[A-Z][a-z][a-z].*[0-9]/) v=\$4} END{print v}')
    else
        BILLING_LABEL="Bidirectional"
        TRAFFIC_RAW=\$(echo "\$VSTAT_RAW" | awk '/[0-9]+\\.[0-9]+/{last=\\\$NF} END{print last}')
    fi
    if [ -n "\$TRAFFIC_RAW" ] && [ -n "\$UNIT" ]; then
        TRAFFIC_BYTES=0
        case "\$UNIT" in
            *TiB*) TRAFFIC_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$TRAFFIC_RAW * 1099511627776}") ;;
            *GiB*) TRAFFIC_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$TRAFFIC_RAW * 1073741824}") ;;
            *MiB*) TRAFFIC_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$TRAFFIC_RAW * 1048576}") ;;
        esac
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
echo -e "\${C_YELLOW}│              📊 LIN Traffic Monitor              │\${C_RESET}"
echo -e "\${C_CYAN}╰──────────────────────────────────────────────────────────────╯\${C_RESET}"
echo ""
echo -e "\${C_GREEN}  📈 Current Traffic ─ \${BILLING_LABEL}Limit: ${LIMIT}GB\${C_RESET}"
if [ -n "\$PCT" ]; then
    CLR="\${C_GREEN}"
    [ "\$ALERT" = "yellow" ] && CLR="\${C_YELLOW}"
    [ "\$ALERT" = "red" ] && CLR="\${C_RED}"
    ICON="✅"; [ "\$ALERT" = "yellow" ] && ICON="⚠️"
    [ "\$ALERT" = "red" ] && ICON="🚨"
    echo -e "     \${CLR}\${ICON} Used: \${USED_GB} / ${LIMIT} GB (\${PCT}%)\${C_RESET}"
else
    echo -e "     \${C_WHITE}📊 Used: \${USED_GB} / ${LIMIT} GB\${C_RESET}"
fi
if [ -n "\$CDOWN" ]; then
    echo -e "     ⏰ Reset in: \${C_YELLOW}\${CDOWN}\${C_RESET}"
fi
echo -e "\${C_CYAN}────────────────────────────────────────────────────────────────\${C_RESET}"
echo ""
echo -e "\${C_CYAN}  ┌──────────────────────────────────────────────────────────┐\${C_RESET}"
VSTAT_M=\$(vnstat -m 2>/dev/null | sed \\
    -e 's/rx/Inbound(RX)/g' \\
    -e 's/tx/Outbound(TX)/g' \\
    -e 's/total/Total/g' \\
    -e 's/estimated/Est./g' \\
    -e 's/month/Month/g' \\
    -e 's/-/─/g' \\
    -e 's/+/┼/g' \\
    -e 's/|/│/g')
printf "\${C_CYAN}"
printf '%s\\n' "\$VSTAT_M"
printf "\${C_RESET}"
echo -e "\${C_CYAN}  └──────────────────────────────────────────────────────────┘\${C_RESET}"

echo ""
echo -e "\${C_GREEN}  📅 Daily Details\${C_RESET}"
echo -e "\${C_CYAN}  ┌──────────────────────────────────────────────────────────┐\${C_RESET}"
VSTAT_D=\$(vnstat -d 2>/dev/null | sed \\
    -e 's/rx/Inbound(RX)/g' \\
    -e 's/tx/Outbound(TX)/g' \\
    -e 's/total/Total/g' \\
    -e 's/estimated/Est./g' \\
    -e 's/day/日期/g' \\
    -e 's/-/─/g' \\
    -e 's/+/┼/g' \\
    -e 's/|/│/g')
printf "\${C_CYAN}"
printf '%s\\n' "\$VSTAT_D"
printf "\${C_RESET}"
echo -e "\${C_CYAN}  └──────────────────────────────────────────────────────────┘\${C_RESET}"

show_trend() {
    echo ""
    echo -e "\${C_GREEN}  📊 7-Day Trend\${C_RESET}"
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
    echo -e "\${C_GREEN}  🌐 网络Connections\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
    if command -v ss >/dev/null 2>&1; then
        CONN=\$(ss -tun state established 2>/dev/null | tail -n +2 | wc -l)
    elif command -v netstat >/dev/null 2>&1; then
        CONN=\$(netstat -an 2>/dev/null | grep ESTABLISHED | wc -l)
    else
        CONN="N/A"
    fi
    echo -e "  \${C_WHITE}📡 Active: \${C_GREEN}\${CONN}\${C_RESET}"
    echo ""
    echo -e "  \${C_WHITE}🔍 Top 5 Ports:\${C_RESET}"
    if command -v ss >/dev/null 2>&1; then
        ss -tun state established 2>/dev/null | tail -n +2 | awk '{print \$5}' | grep -oE ':[0-9]+' | sort | uniq -c | sort -rn | head -5 | while read CNT PORT; do
            echo -e "    \${C_YELLOW}\${CNT}\${C_RESET} 次  →  \${C_CYAN}\${PORT}\${C_RESET}"
        done
    elif command -v netstat >/dev/null 2>&1; then
        netstat -an 2>/dev/null | grep ESTABLISHED | awk '{print \$5}' | grep -oE ':[0-9]+' | sort | uniq -c | sort -rn | head -5 | while read CNT PORT; do
            echo -e "    \${C_YELLOW}\${CNT}\${C_RESET} 次  →  \${C_CYAN}\${PORT}\${C_RESET}"
        done
    fi
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
}

show_speed() {
    echo ""
    echo -e "\${C_GREEN}  ⚡ Speed (2s sample)\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
    IFACE=\$(ip route 2>/dev/null | awk '/default/{print \$5; exit}')
    if [ -z "\$IFACE" ]; then
        IFACE=\$(awk -F: 'NR>2{n=\\\$1; gsub(/ /,\"\",n); if(n!=\"lo\"){print n; exit}}' /proc/net/dev)
    fi
    [ -z "\$IFACE" ] && IFACE="eth0"
    if [ -f /proc/net/dev ]; then
        R1=\$(awk -v iface="\$IFACE" '{split(\\\$0,a,/[: ]+/); if(a[1]==iface) print a[2]}' /proc/net/dev)
        T1=\$(awk -v iface="\$IFACE" '{split(\\\$0,a,/[: ]+/); if(a[1]==iface) print a[10]}' /proc/net/dev)
        [ -z "\$R1" ] && R1=0; [ -z "\$T1" ] && T1=0
        echo -e "  \${C_WHITE}Sampling...\${C_RESET}"
        sleep 2
        R2=\$(awk -v iface="\$IFACE" '{split(\\\$0,a,/[: ]+/); if(a[1]==iface) print a[2]}' /proc/net/dev)
        T2=\$(awk -v iface="\$IFACE" '{split(\\\$0,a,/[: ]+/); if(a[1]==iface) print a[10]}' /proc/net/dev)
        [ -z "\$R2" ] && R2=0; [ -z "\$T2" ] && T2=0
        DL=\$(( (R2 - R1) / 1024 / 2 ))
        UL=\$(( (T2 - T1) / 1024 / 2 ))
        echo -e "  ⬇️  DL: \${C_GREEN}\${DL} KB/s\${C_RESET}"
        echo -e "  ⬆️  UL: \${C_YELLOW}\${UL} KB/s\${C_RESET}"
    else
        echo -e "  \${C_RED}Cannot read /proc/net/dev\${C_RESET}"
    fi
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
}

do_uninstall() {
    echo ""
    echo -e "\${C_RED}  ⚠️  Uninstall LIN-Panel and all files\${C_RESET}"
    printf "  Confirm uninstall？[y/N]: "
    read CONFIRM
    if [ "\$CONFIRM" != "y" ] && [ "\$CONFIRM" != "Y" ]; then
        echo -e "  \${C_GREEN}Cancelled\${C_RESET}"
        return
    fi
    echo ""
    echo -e "  \${C_WHITE}Cleaning up...\${C_RESET}"
    rm -f /root/lin-panel-en.sh /root/lin-panel-en.sh
    echo -e "  ✅ Panel scripts removed"
    rm -f /root/traffic_reset.sh /root/traffic_reset_check.sh /root/traffic_check.sh
    echo -e "  ✅ Reset/push scripts removed"
    rm -f /root/traffic_history.log
    echo -e "  ✅ Traffic logs removed"
    rm -f /usr/local/bin/lin-panel
    echo -e "  ✅ Command shortcut removed"
   
    EXISTING=\$(crontab -l 2>/dev/null || true)
    CLEANED=\$(echo "\$EXISTING" | grep -v 'traffic_history\|traffic_reset\|traffic_check')
    echo "\$CLEANED" | sed '/^$/d' | crontab - 2>/dev/null
    echo -e "  ✅ Cron tasks cleaned"
   
    if [ -f /root/.profile ]; then
        sed -i '/lin-panel/d' /root/.profile
        echo -e "  ✅ Login auto-start removed"
    fi
    echo ""
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────\${C_RESET}"
    echo -e "\${C_GREEN}  🎉 Uninstall complete!\${C_RESET}"
    echo ""
    echo -e "\${C_WHITE}  Feedback welcome at:\${C_RESET}"
    echo -e "\${C_YELLOW}  🔗 https://github.com/linjunhao024-byte/Lin-Panel/issues\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────\${C_RESET}"
    echo ""
    exit 0
}

show_menu() {
    echo ""
    echo -e "\${C_CYAN}  ┌──── 操作菜单 ────┐\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[1] Refresh     \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[2] 7-Day Trend     \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[3] Connections     \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[4] Speed     \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_RED}[5] Uninstall     \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_RED}[0] Exit         \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  └──────────────────┘\${C_RESET}"
}

trap 'echo ""; exit 0' INT

while true; do
    show_menu
    printf "  \${C_WHITE}Select > \${C_RESET}"
    read CHOICE
    case "\$CHOICE" in
        1) exec "\$0" ;;
        2) show_trend ;;
        3) show_conn ;;
        4) show_speed ;;
        5) do_uninstall ;;
        0|"") echo -e "\n  \${C_GREEN}👋 Panel exited\${C_RESET}"; exit 0 ;;
        *) echo -e "  \${C_RED}Invalid option\${C_RESET}" ;;
    esac
done
EOF

chmod +x /root/lin-panel-en.sh

echo -e "${C_GREEN}[4/7] 🔄 Auto-reset script...${C_RESET}"

cat << RESEOF > /root/traffic_reset_check.sh
#!/bin/sh
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

echo -e "${C_GREEN}[5/7] 📊 Daily logging...${C_RESET}"

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
    echo -e "  -> Added ${C_YELLOW}$(echo "$NEW_ENTRIES" | wc -l | tr -d ' ')${C_RESET} cron"
else
    echo -e "  -> Cron exists, skip"
fi

systemctl enable cron >/dev/null 2>&1
systemctl start cron >/dev/null 2>&1

echo -e "  -> Monthly reset: ${C_YELLOW}Monthly${DAY}日 ${HOUR}:${MINUTE}:${SECOND}${C_RESET}"

echo -e "${C_GREEN}[6/7] 📱 Telegram alerts...${C_RESET}"

printf "  Enable Telegram alerts？[Y/n] [default: N]: "
read TG_ENABLE
if [ "$TG_ENABLE" = "Y" ] || [ "$TG_ENABLE" = "y" ]; then
    printf "  Bot Token: "
    read TG_TOKEN
    printf "  Chat ID: "
    read TG_CHAT
    echo ""
    printf "  Frequency:\n"
    printf "    [1] Daily\n"
    printf "    [2] Weekly\n"
    printf "    [3] Monthly\n"
    printf "  Select [1/2/3] [default: 1]: "
    read TG_FREQ
   
    PUSH_DAY=$((DAY - 1))
    [ "$PUSH_DAY" -lt 1 ] && PUSH_DAY=28
    case "$TG_FREQ" in
        2) TG_CRON="0 12 * * 1" ; TG_LABEL="每周一 12:00" ;;
        3) TG_CRON="0 12 ${PUSH_DAY} * *" ; TG_LABEL="Monthly${PUSH_DAY}日 12:00 (12h before reset)" ;;
        *) TG_CRON="0 9 * * *" ; TG_LABEL="Daily 09:00" ;;
    esac

    cat << TGEOF > /root/traffic_check.sh
#!/bin/sh
LIMIT=${LIMIT}
BILLING_MODE=${BILLING_MODE}
TG_TOKEN="${TG_TOKEN}"
TG_CHAT="${TG_CHAT}"

VSTAT_RAW=\$(vnstat -m 2>/dev/null)
[ -z "\$VSTAT_RAW" ] && exit 0
UNIT=\$(echo "\$VSTAT_RAW" | awk '/GiB|TiB|MiB/{print \$3; exit}')
TRAFFIC_RAW=""
if [ "\$BILLING_MODE" = "2" ]; then
    TRAFFIC_RAW=\$(echo "\$VSTAT_RAW" | awk '/[0-9]/{if(\$0~/[A-Z][a-z][a-z].*[0-9]/) v=\$3} END{print v}')
elif [ "\$BILLING_MODE" = "3" ]; then
    TRAFFIC_RAW=\$(echo "\$VSTAT_RAW" | awk '/[0-9]/{if(\$0~/[A-Z][a-z][a-z].*[0-9]/) v=\$4} END{print v}')
else
    TRAFFIC_RAW=\$(echo "\$VSTAT_RAW" | awk '/[0-9]+\.[0-9]+/{last=\$NF} END{print last}')
fi
[ -z "\$TRAFFIC_RAW" ] || [ -z "\$UNIT" ] && exit 0

TRAFFIC_BYTES=0
case "\$UNIT" in
    *TiB*) TRAFFIC_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$TRAFFIC_RAW * 1099511627776}") ;;
    *GiB*) TRAFFIC_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$TRAFFIC_RAW * 1073741824}") ;;
    *MiB*) TRAFFIC_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$TRAFFIC_RAW * 1048576}") ;;
esac
LIMIT_BYTES=\$(awk "BEGIN{printf \\"%.0f\\", \$LIMIT * 1073741824}")
[ "\$LIMIT_BYTES" -le 0 ] && exit 0
PCT=\$(awk "BEGIN{printf \\"%.1f\\", \$TRAFFIC_BYTES * 100 / \$LIMIT_BYTES}")
USED_GB=\$(awk "BEGIN{printf \\"%.2f\\", \$TRAFFIC_BYTES / 1073741824}")

ICON="✅"
awk "BEGIN{exit !(\$PCT >= 90)}" && ICON="🚨"
awk "BEGIN{exit !(\$PCT >= 70)}" && ICON="⚠️"

MSG="📊 LIN-Panel Traffic Report
━━━━━━━━━━━━━━━━
\${ICON} Used: \${USED_GB} / \${LIMIT} GB (\${PCT}%)
📈 Billing: \${BILLING_MODE}
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
    echo -e "  -> Telegram enabled: ${C_YELLOW}${TG_LABEL}${C_RESET}"
    echo -e "  -> Bot: ${C_YELLOW}$(echo "$TG_TOKEN" | cut -c1-10)...${C_RESET}  Chat: ${C_YELLOW}${TG_CHAT}${C_RESET}"
else
    echo -e "  -> Telegram skipped"
fi

echo -e "${C_GREEN}[7/7] 🔐 Login config...${C_RESET}"

if [ "$ENABLE_LOGIN_AUTO" = "1" ]; then
    if grep -q 'lin-panel-en.sh' /root/.profile 2>/dev/null; then
        echo -e "  -> /root/.profile already configured, skip。"
    else
        echo "/root/lin-panel-en.sh" >> /root/.profile
        echo -e "  -> Added到 /root/.profile，SSH 登录时将自动展示面板。"
    fi
else
    echo -e "  -> Auto-start disabled。"
fi

ln -sf /root/lin-panel-en.sh /usr/local/bin/"$CMD"
echo -e "  -> Command created: ${C_YELLOW}${CMD}${C_RESET}"

echo ""
echo -e "${C_CYAN}╭──────────────────────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_GREEN}│                    🎉 Installation Complete!                             │${C_RESET}"
echo -e "${C_CYAN}╰──────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""
echo -e "${C_WHITE}  Command: ${C_YELLOW}${CMD}${C_WHITE} (always available)${C_RESET}"
if [ "$ENABLE_LOGIN_AUTO" = "1" ]; then
    echo -e "${C_WHITE}  Auto-start: ${C_GREEN}ON${C_WHITE} (下次 SSH 登录自动展示)${C_RESET}"
fi
echo ""
echo -e "${C_YELLOW}  ⏳ vnstat is collecting data, panel will show stats in a few minutes${C_RESET}"
echo -e "${C_WHITE}  Run: ${C_YELLOW}${CMD}${C_RESET}"
echo ""
echo -e "${C_YELLOW}  ⭐ If this panel helps you, please give a Star!${C_RESET}"
echo -e "${C_WHITE}  🔗 https://github.com/linjunhao024-byte/Lin-Panel${C_RESET}"
echo ""
