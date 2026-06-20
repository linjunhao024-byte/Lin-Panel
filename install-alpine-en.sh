#!/bin/sh

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
echo -e "${C_YELLOW}           Minimalist Traffic Panel · v1.0.5${C_RESET}"
echo ""
echo -e "${C_CYAN}╭──────────────────────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_YELLOW}│              Welcome to LIN-PANEL Installer                       │${C_RESET}"
echo -e "${C_CYAN}╰──────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

echo -e "${C_CYAN}┌──────────── Configuration ────────────┐${C_RESET}"
echo ""

printf "Enter traffic limit (GB) [default: 350]: "
read LIMIT
LIMIT="${LIMIT:-350}"
echo -e "  -> Traffic limit: ${C_YELLOW}${LIMIT}GB${C_RESET}"
echo ""

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

printf "Enter monthly reset time\n"
printf "  Day (1-31) [default 1]: "
read DAY
DAY="${DAY:-1}"
case "$DAY" in [1-9]|[12][0-9]|3[01]) ;; *) echo -e "  ${C_RED}⚠ Day invalid, default 1${C_RESET}"; DAY=1 ;;
esac

printf "  Hour (0-23) [default 0]: "
read HOUR
HOUR="${HOUR:-0}"
case "$HOUR" in [0-9]|1[0-9]|2[0-3]) ;; *) echo -e "  ${C_RED}⚠ Hour invalid, default 0${C_RESET}"; HOUR=0 ;;
esac

printf "  Minute (0-59) [default 0]: "
read MINUTE
MINUTE="${MINUTE:-0}"
case "$MINUTE" in [0-9]|[1-4][0-9]|5[0-9]) ;; *) echo -e "  ${C_RED}⚠ Minute invalid, default 0${C_RESET}"; MINUTE=0 ;;
esac

printf "  Second (0-59) [default 0]: "
read SECOND
SECOND="${SECOND:-0}"
case "$SECOND" in [0-9]|[1-4][0-9]|5[0-9]) ;; *) echo -e "  ${C_RED}⚠ Second invalid, default 0${C_RESET}"; SECOND=0 ;;
esac
echo -e "  -> Reset: Monthly ${C_YELLOW}${DAY} ${HOUR}:${MINUTE}:${SECOND}${C_RESET}"
echo ""

printf "Show panel on SSH login? [Y/n] [default: Y]: "
read LOGIN_AUTO
if [ "$LOGIN_AUTO" = "N" ] || [ "$LOGIN_AUTO" = "n" ]; then
    ENABLE_LOGIN_AUTO=0
    echo -e "  -> Auto-start: ${C_RED}OFF${C_RESET}"
else
    ENABLE_LOGIN_AUTO=1
    echo -e "  -> Auto-start: ${C_GREEN}ON${C_RESET}"
fi
echo ""

printf "Enter command name [default: lin-panel]: "
read CMD
CMD="${CMD:-lin-panel}"
case "$CMD" in */*|*\ *|*[\<\>\&\|\;\$\`\!]*) echo -e "  ${C_RED}⚠ Command name contains illegal characters, using default lin-panel${C_RESET}"; CMD="lin-panel" ;;
esac
echo -e "  -> Command: ${C_YELLOW}${CMD}${C_RESET}"
echo ""

printf "Has the server been running? Enter traffic already used (GB) [default: 0]: "
read BASELINE
BASELINE="${BASELINE:-0}"
case "$BASELINE" in *[!0-9.]*) echo -e "  ${C_RED}⚠ Invalid input, default 0${C_RESET}"; BASELINE=0 ;; esac
if [ "$BASELINE" != "0" ]; then
    echo -e "  -> Traffic baseline: ${C_YELLOW}${BASELINE}GB${C_RESET} (added to vnstat stats)"
else
    echo -e "  -> No baseline, counting from zero"
fi
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
        apk add --no-cache tzdata >/dev/null 2>&1
        cp "/usr/share/zoneinfo/$TZ_TARGET" /etc/localtime
        echo "$TZ_TARGET" > /etc/timezone
        apk del tzdata >/dev/null 2>&1
    fi
    hwclock --systohc >/dev/null 2>&1 || true
    echo -e "  -> Timezone: ${C_YELLOW}${TZ_TARGET}${C_RESET}"
else
    echo -e "  -> Keeping: ${C_YELLOW}${CURRENT_TZ}${C_RESET}"
fi

echo -e "${C_GREEN}[2/7] 📦 Installing deps (vnstat)...${C_RESET}"

apk update && apk add bash vnstat jq >/dev/null 2>&1
rc-service vnstatd start >/dev/null 2>&1
rc-update add vnstatd default >/dev/null 2>&1

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
BASELINE=${BASELINE}
RESET_DAY=${DAY}
RESET_HOUR=${HOUR}
RESET_MIN=${MINUTE}
RESET_SEC=${SECOND}

PCT=""
ALERT=""
USED_GB=0
BILLING_LABEL="Bidirectional"

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
        BILLING_LABEL="Inbound"
        TRAFFIC_BYTES=\$RX
    elif [ "\$BILLING_MODE" = "3" ]; then
        BILLING_LABEL="Outbound"
        TRAFFIC_BYTES=\$TX
    else
        BILLING_LABEL="Both"
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
    CDOWN=\${CD_D}d \${CD_H}h \${CD_M}m
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
echo -e "\${C_CYAN}║\${C_RESET} \${C_GREEN}💵 Current Traffic ─ \${BILLING_LABEL}Limit: ${LIMIT}GB\${C_RESET}\${C_CYAN}║\${C_RESET}"
if [ -n "\$PCT" ]; then
    CLR="\${C_GREEN}"
    [ "\$ALERT" = "yellow" ] && CLR="\${C_YELLOW}"
    [ "\$ALERT" = "red" ] && CLR="\${C_RED}"
    ICON="✅"; [ "\$ALERT" = "yellow" ] && ICON="⚠️"
    [ "\$ALERT" = "red" ] && ICON="🚨"
    echo -e "\${C_CYAN}║\${C_RESET} \${CLR}\${ICON} Used: \${USED_GB} / ${LIMIT} GB (\${PCT}%)\${C_RESET}\${C_CYAN}║\${C_RESET}"
else
    echo -e "\${C_CYAN}║\${C_RESET} \${C_WHITE}📊 Used: \${USED_GB} / ${LIMIT} GB\${C_RESET}\${C_CYAN}║\${C_RESET}"
fi
if [ -n "\$CDOWN" ]; then
    echo -e "\${C_CYAN}║\${C_RESET} \${C_WHITE}⏱️  Reset in: \${C_YELLOW}\${CDOWN}\${C_RESET}\${C_CYAN}║\${C_RESET}"
fi
echo -e "\${C_CYAN}╚════════════════════════════════════════════════════════════════╝\${C_RESET}"
echo ""
VSTAT_M=\$(vnstat -m -i "\$MAIN_INTERFACE" 2>/dev/null | sed -e "s/\$MAIN_INTERFACE/Interface/g" -e 's/-/─/g' -e 's/+/┼/g' -e 's/|/│/g')
printf "\${C_CYAN}%s\n\${C_RESET}" "\$VSTAT_M"

echo ""
echo -e "\${C_GREEN}  📅 Daily Details\${C_RESET}"
VSTAT_D=\$(vnstat -d -i "\$MAIN_INTERFACE" 2>/dev/null | sed -e "s/\$MAIN_INTERFACE/Interface/g" -e 's/-/─/g' -e 's/+/┼/g' -e 's/|/│/g')
printf "\${C_CYAN}%s\n\${C_RESET}" "\$VSTAT_D"

echo ""
echo -e "\${C_CYAN}╔════════════════════════════════════════════════════════════════╗\${C_RESET}"
echo -e "\${C_CYAN}║\${C_RESET}\${C_YELLOW}                      ⚙️  System Status                          \${C_RESET}\${C_CYAN}║\${C_RESET}"
echo -e "\${C_CYAN}╠════════════════════════════════════════════════════════════════╣\${C_RESET}"

VNSTAT_STATUS="Stopped"
VNSTAT_CLR="\${C_RED}"
if systemctl is-active --quiet vnstat 2>/dev/null || rc-service vnstatd status 2>/dev/null | grep -q "started"; then
    VNSTAT_STATUS="Running"
    VNSTAT_CLR="\${C_GREEN}"
fi

CRON_STATUS="Inactive"
CRON_CLR="\${C_RED}"
if systemctl is-active --quiet cron 2>/dev/null || systemctl is-active --quiet crond 2>/dev/null || rc-service crond status 2>/dev/null | grep -q "started"; then
    CRON_STATUS="Active"
    CRON_CLR="\${C_GREEN}"
fi

TG_STATUS="Disabled"
TG_CLR="\${C_WHITE}"
if [ -f /root/traffic_check.sh ]; then
    TG_STATUS="Enabled"
    TG_CLR="\${C_GREEN}"
fi

echo -e "\${C_CYAN}║\${C_RESET} \${C_WHITE}vnstat state:\${C_RESET}     \${VNSTAT_CLR}\${VNSTAT_STATUS}\${C_RESET}\${C_CYAN}║\${C_RESET}"
echo -e "\${C_CYAN}║\${C_RESET} \${C_WHITE}Cron scheduler:\${C_RESET}   \${CRON_CLR}\${CRON_STATUS}\${C_RESET}\${C_CYAN}║\${C_RESET}"
echo -e "\${C_CYAN}║\${C_RESET} \${C_WHITE}Telegram Push:\${C_RESET}    \${TG_CLR}\${TG_STATUS}\${C_RESET}\${C_CYAN}║\${C_RESET}"
echo -e "\${C_CYAN}╚════════════════════════════════════════════════════════════════╝\${C_RESET}"

show_trend() {
    echo ""
    echo -e "\${C_GREEN}  📊 7-Day Trend\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
    TREND=\$(vnstat -d -i "\$MAIN_INTERFACE" 2>/dev/null | awk '/[0-9]+\\.[0-9]+/{d=\\\$1; v=\\\$NF; if(d~/^[0-9]/) print d" "v}' | tail -7)
    if [ -z "\$TREND" ]; then
        echo -e "  \${C_WHITE}No history data\${C_RESET}"
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
    echo -e "\${C_GREEN}  🌐 Network Connections\${C_RESET}"
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
    echo -e "  \${C_WHITE}🔍 Local Ports Top 5:\${C_RESET}"
    if command -v ss >/dev/null 2>&1; then
        ss -tun state established 2>/dev/null | tail -n +2 | awk '{print \$4}' | grep -oE ':[0-9]+' | sort | uniq -c | sort -rn | head -5 | while read CNT PORT; do
            echo -e "    \${C_YELLOW}\${CNT}\${C_RESET} times  →  \${C_CYAN}\${PORT}\${C_RESET}"
        done
    elif command -v netstat >/dev/null 2>&1; then
        netstat -an 2>/dev/null | grep ESTABLISHED | awk '{print \$4}' | grep -oE ':[0-9]+' | sort | uniq -c | sort -rn | head -5 | while read CNT PORT; do
            echo -e "    \${C_YELLOW}\${CNT}\${C_RESET} times  →  \${C_CYAN}\${PORT}\${C_RESET}"
        done
    fi
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
}

show_speed() {
    echo ""
    echo -e "\${C_GREEN}  ⚡ Speed (2s sample)\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
    IFACE=\$(ip route 2>/dev/null | grep default | awk '{print \$5}' | head -n1)
    if [ -z "\$IFACE" ]; then
        IFACE=\$(ls /sys/class/net/ 2>/dev/null | grep -v lo | head -n 1)
    fi
    [ -z "\$IFACE" ] && IFACE="eth0"
    if [ -d "/sys/class/net/\$IFACE/statistics" ]; then
        echo -e "  \${C_WHITE}Sampling...\${C_RESET}"
        R1=\$(cat /sys/class/net/\$IFACE/statistics/rx_bytes 2>/dev/null || echo 0)
        T1=\$(cat /sys/class/net/\$IFACE/statistics/tx_bytes 2>/dev/null || echo 0)
        sleep 2
        R2=\$(cat /sys/class/net/\$IFACE/statistics/rx_bytes 2>/dev/null || echo 0)
        T2=\$(cat /sys/class/net/\$IFACE/statistics/tx_bytes 2>/dev/null || echo 0)
        DL=\$(awk "BEGIN{d=(\$R2-\$R1)/2; if(d>=1073741824) printf \"\\\033[1;31m%.2f GB/s\\\033[0m\", d/1073741824; else if(d>=1048576) printf \"\\\033[1;33m%.2f MB/s\\\033[0m\", d/1048576; else printf \"\\\033[1;32m%.0f KB/s\\\033[0m\", d/1024}")
        UL=\$(awk "BEGIN{d=(\$T2-\$T1)/2; if(d>=1073741824) printf \"\\\033[1;31m%.2f GB/s\\\033[0m\", d/1073741824; else if(d>=1048576) printf \"\\\033[1;33m%.2f MB/s\\\033[0m\", d/1048576; else printf \"\\\033[1;32m%.0f KB/s\\\033[0m\", d/1024}")
        echo -e "  ⬇  DL: \${DL}"
        echo -e "  ⬆  UL: \${UL}"
    else
        echo -e "  \${C_RED}Cannot read NIC \${IFACE} speed data\${C_RESET}"
    fi
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
}

do_manual_push() {
    echo ""
    echo -e "\${C_GREEN}  📤 Manual Push Traffic Report\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
    if [ -f /root/traffic_check.sh ]; then
        echo -e "  \${C_WHITE}Pushing...\${C_RESET}"
        /root/traffic_check.sh
        echo -e "  \${C_GREEN}✅ Push complete, check your Telegram\${C_RESET}"
    else
        echo -e "  \${C_RED}❌ Push script not found, please configure Telegram first\${C_RESET}"
    fi
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
}

do_modify_spike() {
    echo ""
    echo -e "\${C_GREEN}  📈 Modify Spike Alert Threshold\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
    echo -e "  \${C_WHITE}How it works: Checks traffic delta every 10 minutes\${C_RESET}"
    echo -e "  \${C_WHITE}If spike exceeds threshold, sends Telegram alert\${C_RESET}"
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
    if [ ! -f /root/traffic_spike_check.sh ]; then
        echo -e "  \${C_RED}Spike alert script not found. Please reinstall with spike feature enabled.\${C_RESET}"
        return
    fi
    OLD_SPIKE=\$(grep '^SPIKE_LIMIT=' /root/traffic_spike_check.sh | cut -d= -f2)
    if [ "\$OLD_SPIKE" = "0" ]; then
        echo -e "  \${C_WHITE}Status: \${C_RED}Disabled\${C_RESET}"
    else
        echo -e "  \${C_WHITE}Current threshold: \${C_YELLOW}\${OLD_SPIKE} GB / 10 mins\${C_RESET}"
    fi
    printf "  Enter new threshold (GB/10 mins) [0 to disable, Enter to cancel]: "
    read NEW_SPIKE
    [ -z "\$NEW_SPIKE" ] && return
    if [ "\$NEW_SPIKE" = "0" ]; then
        sed -i "s/^SPIKE_LIMIT=.*/SPIKE_LIMIT=0/" /root/traffic_spike_check.sh
        echo -e "  \${C_RED}Spike alert disabled\${C_RESET}"
    else
        sed -i "s/^SPIKE_LIMIT=.*/SPIKE_LIMIT=\$NEW_SPIKE/" /root/traffic_spike_check.sh
        echo -e "  \${C_GREEN}Spike alert threshold updated: \${C_YELLOW}\${NEW_SPIKE} GB / 10 mins\${C_RESET}"
    fi
    echo -e "\${C_CYAN}  ──────────────────────────────────────────────────────────\${C_RESET}"
}

do_uninstall() {
    echo ""
    echo -e "\${C_RED}  ⚠️  Uninstall LIN-Panel and all files\${C_RESET}"
    printf "  Confirm uninstall? [y/N]: "
    read CONFIRM
    if [ "\$CONFIRM" != "y" ] && [ "\$CONFIRM" != "Y" ]; then
        echo -e "  \${C_GREEN}Cancelled\${C_RESET}"
        return
    fi
    echo ""
    echo -e "  \${C_WHITE}Cleaning up...\${C_RESET}"
    rm -f /root/lin-panel.sh /root/lin-panel-en.sh
    echo -e "  ✅ Panel scripts removed"
    rm -f /root/traffic_reset.sh /root/traffic_reset_check.sh /root/traffic_check.sh /root/traffic_spike_check.sh
    echo -e "  ✅ Reset/push scripts removed"
    rm -f /root/traffic_history.log
    echo -e "  ✅ Traffic logs removed"
    rm -f /usr/local/bin/"${CMD}"
    echo -e "  ✅ Command shortcut removed"
   
    EXISTING=\$(crontab -l 2>/dev/null || true)
    CLEANED=\$(echo "\$EXISTING" | grep -v 'traffic_history\|traffic_reset\|traffic_check\|traffic_spike')
    echo "\$CLEANED" | sed '/^$/d' | crontab - 2>/dev/null
    echo -e "  ✅ Cron tasks cleaned"
   
    if [ -f /root/.profile ]; then
        sed -i '/LIN-PANEL-AUTO-START/,/END LIN-PANEL-AUTO-START/d' /root/.profile
        echo -e "  ✅ Login auto-start removed"
    fi
    echo ""
    printf "  Also uninstall vnstat (traffic tool)? [y/N] [default: N]: "
    read RM_VNSTAT
    if [ "\$RM_VNSTAT" = "y" ] || [ "\$RM_VNSTAT" = "Y" ]; then
        rc-service vnstatd stop 2>/dev/null || systemctl stop vnstat 2>/dev/null
        rc-update del vnstatd default 2>/dev/null || systemctl disable vnstat 2>/dev/null
        apk del vnstat 2>/dev/null || apt-get remove -y vnstat 2>/dev/null
        rm -rf /var/lib/vnstat
        echo -e "  ✅ vnstat uninstalled"
    else
        echo -e "  -> vnstat kept"
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
    echo -e "\${C_CYAN}  ┌──── Menu ────────┐\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[1] Refresh     \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[2] 7-Day Trend     \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[3] Connections     \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[4] Speed     \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[5] Push Now      \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_WHITE}[6] Spike Alert   \${C_CYAN}│\${C_RESET}"
    echo -e "\${C_CYAN}  │\${C_RESET}  \${C_RED}[7] Uninstall     \${C_CYAN}│\${C_RESET}"
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
        5) do_manual_push ;;
        6) do_modify_spike ;;
        7) do_uninstall ;;
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

echo -e "${C_GREEN}[5/7] 📊 Daily logging...${C_RESET}"

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
    echo -e "  -> Added ${C_YELLOW}$(echo "$NEW_ENTRIES" | wc -l | tr -d ' ')${C_RESET} cron"
else
    echo -e "  -> Cron exists, skip"
fi

rc-update add crond default >/dev/null 2>&1
rc-service crond start >/dev/null 2>&1

echo -e "  -> Monthly reset: ${C_YELLOW}Day ${DAY} ${HOUR}:${MINUTE}:${SECOND}${C_RESET}"

echo -e "${C_GREEN}[6/7] 📱 Telegram alerts...${C_RESET}"

printf "  Enable Telegram alerts? [Y/n] [default: N]: "
read TG_ENABLE
if [ "$TG_ENABLE" = "Y" ] || [ "$TG_ENABLE" = "y" ]; then
    TG_OK=0
    while [ "$TG_OK" = "0" ]; do
        printf "  Bot Token: "
        read TG_TOKEN
        printf "  Chat ID: "
        read TG_CHAT
        echo ""
        echo -e "  ${C_WHITE}Sending test message...${C_RESET}"
        if curl -sf -o /tmp/.tg_test.json -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" -d chat_id="${TG_CHAT}" -d text="🔔 LIN-Panel Test" -d parse_mode="HTML" 2>/dev/null; then
            echo -e "  ${C_GREEN}✅ Test sent! Check your Telegram${C_RESET}"
            TG_OK=1
        else
            TG_ERR=$(grep -o '"description":"[^"]*"' /tmp/.tg_test.json 2>/dev/null | cut -d'"' -f4)
            echo -e "  ${C_RED}❌ Test failed${C_RESET}"
            [ -n "$TG_ERR" ] && echo -e "  ${C_RED}   Reason: ${TG_ERR}${C_RESET}"
            echo ""
            printf "  [1] Re-enter Token and Chat ID\n"
            printf "  [2] Skip push\n"
            printf "  [3] Force enable (not recommended)\n"
            printf "  Select [1/2/3] [default: 1]: "
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
    printf "  Frequency:\n"
    printf "    [1] Daily\n"
    printf "    [2] Weekly\n"
    printf "    [3] Monthly\n"
    printf "  Select [1/2/3] [default: 1]: "
    read TG_FREQ

    if [ "$TG_FREQ" = "1" ]; then
        printf "  Select daily push time (0-23) [default: 9]: "
        read TG_HOUR
        TG_HOUR="${TG_HOUR:-9}"
        case "$TG_HOUR" in [0-9]|1[0-9]|2[0-3]) ;; *) echo -e "  ${C_RED}⚠ Hour invalid, default 9${C_RESET}"; TG_HOUR=9 ;; esac
        TG_CRON="0 ${TG_HOUR} * * *"
        TG_LABEL="Daily ${TG_HOUR}:00"
    elif [ "$TG_FREQ" = "2" ]; then
        printf "  Select weekly push day:\n"
        printf "    [1] Mon  [2] Tue  [3] Wed  [4] Thu\n"
        printf "    [5] Fri  [6] Sat  [7] Sun\n"
        printf "  Select [1-7] [default: 1]: "
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
        printf "  Select push time (0-23) [default: 12]: "
        read TG_HOUR
        TG_HOUR="${TG_HOUR:-12}"
        case "$TG_HOUR" in [0-9]|1[0-9]|2[0-3]) ;; *) echo -e "  ${C_RED}⚠ Hour invalid, default 12${C_RESET}"; TG_HOUR=12 ;; esac
        WEEKDAY_LABEL="Sun"
        case "$TG_WEEKDAY" in 1) WEEKDAY_LABEL="Mon";; 2) WEEKDAY_LABEL="Tue";; 3) WEEKDAY_LABEL="Wed";; 4) WEEKDAY_LABEL="Thu";; 5) WEEKDAY_LABEL="Fri";; 6) WEEKDAY_LABEL="Sat";; 0) WEEKDAY_LABEL="Sun";; esac
        TG_CRON="0 ${TG_HOUR} * * ${TG_WEEKDAY}"
        TG_LABEL="${WEEKDAY_LABEL} ${TG_HOUR}:00"
    else
        PUSH_DAY=$((DAY - 1))
        [ "$PUSH_DAY" -lt 1 ] && PUSH_DAY=28
        TG_CRON="0 12 ${PUSH_DAY} * *"
        TG_LABEL="Day ${PUSH_DAY} 12:00 (12h before reset)"
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
        BILLING_LABEL="Inbound"
        TRAFFIC_BYTES=\$RX
    elif [ "\$BILLING_MODE" = "3" ]; then
        BILLING_LABEL="Outbound"
        TRAFFIC_BYTES=\$TX
    else
        BILLING_LABEL="Both"
        TRAFFIC_BYTES=\$TOTAL
    fi
fi
BASELINE_BYTES=\$(awk "BEGIN{printf \"%.0f\", \$BASELINE * 1073741824}")
TRAFFIC_BYTES=\$(( TRAFFIC_BYTES + BASELINE_BYTES ))
LIMIT_BYTES=\$(awk "BEGIN{printf \"%.0f\", \$LIMIT * 1073741824}")
[ "\$LIMIT_BYTES" -le 0 ] 2>/dev/null && exit 0
PCT=\$(awk "BEGIN{printf \"%.1f\", \$TRAFFIC_BYTES * 100 / \$LIMIT_BYTES}")
USED_GB=\$(awk "BEGIN{printf \"%.2f\", \$TRAFFIC_BYTES / 1073741824}")

ICON="✅"
awk "BEGIN{exit !(\$PCT >= 90)}" && ICON="🚨"
awk "BEGIN{exit !(\$PCT >= 70)}" && ICON="⚠️"

MSG="📊 LIN-Panel Traffic Report
━━━━━━━━━━━━━━━━
\${ICON} Used: \${USED_GB} / \${LIMIT} GB (\${PCT}%)
📈 Billing: \${BILLING_LABEL}
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
    echo ""
    echo -e "  ${C_WHITE}Test push scheduled in 10 minutes (waiting for vnstat data)...${C_RESET}"
    echo -e "  ${C_WHITE}Test message will be sent once to verify push functionality.${C_RESET}"
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
        BILLING_LABEL="Inbound"
        TRAFFIC_BYTES=\$RX
    elif [ "\$BILLING_MODE" = "3" ]; then
        BILLING_LABEL="Outbound"
        TRAFFIC_BYTES=\$TX
    else
        BILLING_LABEL="Both"
        TRAFFIC_BYTES=\$TOTAL
    fi
fi
BASELINE_BYTES=\$(awk "BEGIN{printf \"%.0f\", \$BASELINE * 1073741824}")
TRAFFIC_BYTES=\$(( TRAFFIC_BYTES + BASELINE_BYTES ))
LIMIT_BYTES=\$(awk "BEGIN{printf \"%.0f\", \$LIMIT * 1073741824}")
[ "\$LIMIT_BYTES" -le 0 ] 2>/dev/null && exit 0
PCT=\$(awk "BEGIN{printf \"%.1f\", \$TRAFFIC_BYTES * 100 / \$LIMIT_BYTES}")
USED_GB=\$(awk "BEGIN{printf \"%.2f\", \$TRAFFIC_BYTES / 1073741824}")

ICON="✅"
awk "BEGIN{exit !(\$PCT >= 90)}" && ICON="🚨"
awk "BEGIN{exit !(\$PCT >= 70)}" && ICON="⚠️"

MSG="📊 Push Test Message
━━━━━━━━━━━━━━━━
This is a test message to verify push functionality.
\${ICON} Used: \${USED_GB} / \${LIMIT} GB (\${PCT}%)
📈 Billing: \${BILLING_LABEL}
━━━━━━━━━━━━━━━━
If you received this, push is working correctly!
Official reports will follow your schedule (${TG_LABEL})."

curl -s -X POST "https://api.telegram.org/bot\${TG_TOKEN}/sendMessage" \\
    -d chat_id="\${TG_CHAT}" \\
    -d text="\${MSG}" \\
    -d parse_mode="HTML" >/dev/null 2>&1
rm -f /root/traffic_test.sh
TESTEOF
    chmod +x /root/traffic_test.sh
    nohup /root/traffic_test.sh >/dev/null 2>&1 &
    echo -e "  ${C_GREEN}✅ Test push scheduled, check Telegram in 10 minutes${C_RESET}"
    fi
else
    echo -e "  -> Telegram skipped"
fi

echo ""
printf "  Enter short-term traffic spike alert threshold (GB/10 mins) [default: 5, 0 to disable]: "
read SPIKE_LIMIT
SPIKE_LIMIT="${SPIKE_LIMIT:-5}"
if [ "$SPIKE_LIMIT" = "0" ]; then
    echo -e "  -> Short-term spike alert: ${C_RED}Disabled${C_RESET}"
else
    echo -e "  -> Spike alert threshold: ${C_YELLOW}${SPIKE_LIMIT}GB/10mins${C_RESET}"
    echo -e "  ${C_WHITE}How it works: Checks traffic delta every 10 minutes${C_RESET}"
    echo -e "  ${C_WHITE}If spike exceeds threshold, sends Telegram alert${C_RESET}"
    echo -e "  ${C_WHITE}You can modify threshold anytime from panel menu [6]${C_RESET}"
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
            MSG="🚨 Traffic Spike Alert
━━━━━━━━━━━━━━━━
⚠️ Interface: \${MAIN_INTERFACE}
📈 Spike in 10 mins: \${DELTA_GB} GB
🔔 Threshold: \${SPIKE_LIMIT} GB
━━━━━━━━━━━━━━━━"
            curl -s -X POST "https://api.telegram.org/bot\${TG_TOKEN}/sendMessage" -d chat_id="\${TG_CHAT}" -d text="\${MSG}" >/dev/null 2>&1
        fi
    fi
fi
echo "\$NOW_TOTAL" > "\$LAST_FILE"
SPIKEEOF
chmod +x /root/traffic_spike_check.sh

echo -e "${C_GREEN}[7/7] 🔐 Login config...${C_RESET}"

if [ "$ENABLE_LOGIN_AUTO" = "1" ]; then
    PANEL_MARKER="# LIN-PANEL-AUTO-START"
    if grep -q 'LIN-PANEL-AUTO-START' /root/.profile 2>/dev/null; then
        echo -e "  -> /root/.profile already configured, skip."
    else
        cat >> /root/.profile << 'AUTOSTART'

# LIN-PANEL-AUTO-START
case "$-" in
    *i*)
        case "$SSH_CONNECTION" in
            *" "*) [ -z "$SCP_OR_SFTP" ] && /root/lin-panel-en.sh ;;
        esac
        ;;
esac
# END LIN-PANEL-AUTO-START
AUTOSTART
        echo -e "  -> Added to /root/.profile, panel will auto-show on SSH login."
    fi
else
    echo -e "  -> Auto-start disabled."
fi

ln -sf /root/lin-panel-en.sh /usr/local/bin/"$CMD"
if [ -L "/usr/local/bin/$CMD" ] && [ -x "/usr/local/bin/$CMD" ]; then
    echo -e "  -> Command created: ${C_YELLOW}${CMD}${C_RESET}"
else
    echo -e "  ${C_RED}⚠ Command creation failed. Run manually: ln -sf /root/lin-panel-en.sh /usr/local/bin/${CMD}${C_RESET}"
fi

echo ""
echo -e "${C_CYAN}╭──────────────────────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_GREEN}│                    🎉 Installation Complete!                             │${C_RESET}"
echo -e "${C_CYAN}╰──────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""
echo -e "${C_WHITE}  Command: ${C_YELLOW}${CMD}${C_WHITE} (always available)${C_RESET}"
if [ "$ENABLE_LOGIN_AUTO" = "1" ]; then
    echo -e "${C_WHITE}  Auto-start: ${C_GREEN}ON${C_WHITE} (auto-show on SSH login)${C_RESET}"
fi
echo ""
echo -e "${C_YELLOW}  ⏳ vnstat is collecting data, panel will show stats in a few minutes${C_RESET}"
echo -e "${C_WHITE}  Run: ${C_YELLOW}${CMD}${C_RESET}"
echo ""
echo -e "${C_YELLOW}  ⭐ If this panel helps you, please give a Star!${C_RESET}"
echo -e "${C_WHITE}  🔗 https://github.com/linjunhao024-byte/Lin-Panel${C_RESET}"
echo ""
printf "Enter panel now? [Y/n] [default: Y]: "
read ENTER_PANEL
if [ "$ENTER_PANEL" != "N" ] && [ "$ENTER_PANEL" != "n" ]; then
    /root/lin-panel-en.sh
fi
