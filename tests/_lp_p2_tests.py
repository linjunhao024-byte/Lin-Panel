#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Lin-Panel 六条 P2 的离线回归测试（task t25）。

原则：只读安装脚本，把脚本里的片段抽出来在临时目录里跑。
绝不安装、不改系统、不写真实 crontab、不碰 /var/lib/vnstat。

用法：python tests/_lp_p2_tests.py    全部 PASS 时退出码 0
"""

import io
import os
import shutil
import subprocess
import sys
import tempfile

BS = chr(92)   # 反斜杠
NL = chr(10)   # 换行

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
ALPINE = 'install-alpine.sh'
DEBIAN = 'install-debian.sh'
FILES = [ALPINE, DEBIAN]

RESULTS = []
BASH = None


# --------------------------------------------------------------------------
# 基础设施
# --------------------------------------------------------------------------
def find_bash():
    cand = shutil.which('bash')
    if cand:
        return cand
    for p in (
        'C:/Program Files/Git/bin/bash.exe',
        'C:/Program Files (x86)/Git/bin/bash.exe',
        'C:/Users/83611/.dsh/profiles/desktop/node_modules/@dsh-ops/bash-win32-x64/usr/bin/bash.EXE',
    ):
        if os.path.exists(p):
            return p
    return None


def read(name):
    return io.open(os.path.join(REPO, name), encoding='utf-8', newline='').read()


def posix(path):
    return path.replace(BS, '/')


def bash(script, args=()):
    p = subprocess.run(
        [BASH, '-c', script, 'bash'] + list(args),
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    return p.returncode, (p.stdout + p.stderr).decode('utf-8', 'replace')


def bash_argv(args):
    p = subprocess.run([BASH] + list(args),
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return p.returncode, (p.stdout + p.stderr).decode('utf-8', 'replace')


def materialize(block):
    """把安装脚本 heredoc 里的转义还原成「生成的脚本」的样子。

    安装脚本用 cat << EOF（不加引号）生成子脚本：只有 \\ -> \ 和 \$ -> $
    会被处理；\" 在 heredoc 里不是转义，会原样留在生成的脚本里。
    """
    return block.replace(BS + BS, BS).replace(BS + '$', '$')


def mkdtemp():
    return tempfile.mkdtemp(prefix='lp_p2_')


def check(name, fn):
    try:
        ok, detail = fn()
    except Exception as exc:  # noqa: BLE001
        ok, detail = False, 'exception: %r' % (exc,)
    RESULTS.append((name, ok, detail))
    print(('PASS  ' if ok else 'FAIL  ') + name + ('   [' + detail + ']' if detail else ''))


# --------------------------------------------------------------------------
# 抽取助手
# --------------------------------------------------------------------------
def func_text(text, name):
    start = text.index(name + '() {')
    end = text.index(NL + '}' + NL, start) + len(NL + '}' + NL)
    return text[start:end]


def arith_block(text):
    lines = text.split(NL)
    start = None
    for i, line in enumerate(lines):
        if line.startswith('# 数值兜底'):
            start = i
            break
    if start is None:
        return None
    end = start
    while end < len(lines) and 'TRAFFIC_BYTES=' + BS + '$(( TRAFFIC_BYTES + BASELINE_BYTES ))' not in lines[end]:
        end += 1
    return NL.join(lines[start:end + 1])


def cron_block(text):
    lines = text.split(NL)
    defs = [l for l in lines
            if l.startswith('CRON_TREND=') or l.startswith('CRON_RESET=') or l.startswith('CRON_SPIKE=')]
    start = None
    for i, line in enumerate(lines):
        if line.startswith('EXISTING_CRON=$(echo "$EXISTING_CRON" | grep -v'):
            start = i
            break
    if start is None:
        return None
    end = start
    while end < len(lines) and not lines[end].rstrip().endswith('| crontab -'):
        end += 1
    return NL.join(defs + lines[start:end + 1])


def trend_reader_prog(text):
    for line in text.split(NL):
        if " /root/traffic_history.log 2>/dev/null | tail -7" in line:
            a = line.index("awk '") + len("awk '")
            b = line.index("' /root/traffic_history.log")
            return line[a:b]
    return None


def rm_guard(text):
    lines = text.split(NL)
    start = None
    for i, line in enumerate(lines):
        if line.startswith('VNSTAT_DB="/var/lib/vnstat"'):
            start = i
            break
    if start is None:
        return None
    end = start
    while end < len(lines) and lines[end].strip() != 'fi':
        end += 1
    return NL.join(lines[start:end + 1])


def heredocs(text):
    """抽出所有 `cat << MARKER > /path` 生成的子脚本，返回 [(target, body)]。"""
    out = []
    lines = text.split(NL)
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.startswith('cat << '):
            parts = line.split()
            marker = parts[2]
            target = parts[4] if len(parts) > 4 else '?'
            body = []
            j = i + 1
            while j < len(lines) and lines[j].strip() != marker:
                body.append(lines[j])
                j += 1
            out.append((target, NL.join(body)))
            i = j + 1
            continue
        i += 1
    return out


# --------------------------------------------------------------------------
# 1) 数字校验
# --------------------------------------------------------------------------
def t_is_num_accepts():
    fn = func_text(read(ALPINE), 'is_num')
    good = ['0', '350', '350.5', '12', '0.5', '99.99', '1000000']
    script = NL.join([fn, 'for v in ' + ' '.join(good) + '; do if is_num "$v"; then echo "A:$v"; else echo "R:$v"; fi; done'])
    rc, out = bash(script)
    got = [l[2:] for l in out.split(NL) if l.startswith('A:')]
    return rc == 0 and got == good, 'accepted=' + ','.join(got)


def t_is_num_rejects():
    fn = func_text(read(ALPINE), 'is_num')
    bad = ['""', '"."', '"1."', '".5"', '"1.2.3"', '"-1"', '"abc"', '" 5"', '"5 "', '"1,5"', '"+1"', '".."', '"1e5"']
    script = NL.join([fn, 'for v in ' + ' '.join(bad) + '; do if is_num "$v"; then echo "A:[$v]"; else echo "R:[$v]"; fi; done'])
    rc, out = bash(script)
    wrong = [l for l in out.split(NL) if l.startswith('A:')]
    return rc == 0 and not wrong, 'wrongly accepted=' + (','.join(wrong) if wrong else 'none')


def t_is_num_reused():
    details = []
    ok = True
    old_forms = [
        'case "$LIMIT" in ' + "''|*[!0-9.]*|*.*.*)",
        'case "$BASELINE" in *[!0-9.]*)',
        'case "$SPIKE_LIMIT" in ' + "''|*[!0-9.]*)",
    ]
    for name in FILES:
        text = read(name)
        defs = text.count('is_num() {')
        calls = [text.count(p) for p in ('is_num "$LIMIT"', 'is_num "$BASELINE"', 'is_num "$SPIKE_LIMIT"')]
        left = [o for o in old_forms if o in text]
        good = defs == 1 and all(c >= 1 for c in calls) and not left
        ok = ok and good
        details.append('%s:def=%d,calls=%s,old=%d' % (name, defs, calls, len(left)))
    return ok, '; '.join(details)


def t_arithmetic_guard():
    block = arith_block(read(ALPINE))
    if block is None:
        return False, 'arith block not found'
    body = materialize(block)
    cases = [
        ('.', '123', '123'),
        ('abc', '123', '123'),
        ('0', 'abc', '0'),
        ('0', '0', '0'),
        ('2', '0', '2147483648'),
    ]
    seen = []
    for baseline, traffic, expect in cases:
        script = NL.join([
            'BASELINE="' + baseline + '"',
            'TRAFFIC_BYTES="' + traffic + '"',
            body,
            'echo "RESULT=$TRAFFIC_BYTES"',
        ])
        rc, out = bash(script)
        hit = [l for l in out.split(NL) if l.startswith('RESULT=')]
        got = hit[0][7:] if hit else 'NO-OUTPUT'
        seen.append(baseline + '/' + traffic + '->' + got)
        if rc != 0 or got != expect:
            return False, 'rc=%d ' % rc + ';'.join(seen) + ' out=' + out.strip()[:150]
    return True, ';'.join(seen)


# --------------------------------------------------------------------------
# 2) cron 幂等
# --------------------------------------------------------------------------
def run_cron(block, cronfile, seed=None):
    if seed is None:
        if os.path.exists(cronfile):
            os.remove(cronfile)
    else:
        io.open(cronfile, 'w', encoding='utf-8', newline=NL).write(seed)
    head = NL.join([
        'CRONFILE="$1"',
        'crontab() {',
        '    if [ "$1" = "-l" ]; then',
        '        cat "$CRONFILE" 2>/dev/null',
        '    else',
        '        cat > "$CRONFILE"',
        '    fi',
        '}',
        'EXISTING_CRON=$(crontab -l 2>/dev/null || true)',
    ])
    return bash(head + NL + block, [cronfile])


def cron_lines(cronfile):
    if not os.path.exists(cronfile):
        return []
    txt = io.open(cronfile, encoding='utf-8').read()
    return [l for l in txt.split(NL) if l.strip()]


def t_cron_idempotent():
    block = cron_block(read(ALPINE))
    if block is None:
        return False, 'cron block not found'
    cf = os.path.join(mkdtemp(), 'crontab.txt')
    rc1, out1 = run_cron(block, cf)
    n1 = cron_lines(cf)
    rc2, out2 = run_cron(block, cf)
    n2 = cron_lines(cf)
    ok = rc1 == 0 and rc2 == 0 and len(n1) == 3 and len(n2) == 3 and len(set(n2)) == 3
    if not ok:
        return False, 'rc=%d/%d run1=%d run2=%d uniq=%d out=%s' % (
            rc1, rc2, len(n1), len(n2), len(set(n2)), (out1 + out2).strip()[:150])
    return True, 'run1=3 run2=3 unique=3'


def t_cron_repairs_legacy():
    block = cron_block(read(ALPINE))
    cf = os.path.join(mkdtemp(), 'crontab.txt')
    broken = ('59 23 * * * /root/traffic_trend.sh' + BS + 'n'
              '*/10 * * * * /root/traffic_reset_check.sh' + BS + 'n'
              '*/10 * * * * /root/traffic_spike_check.sh' + BS + 'n')
    seed = broken + NL + '0 3 * * * /usr/bin/backup.sh' + NL
    rc, out = run_cron(block, cf, seed=seed)
    lines = cron_lines(cf)
    ok = (rc == 0 and len(lines) == 4
          and any('backup.sh' in l for l in lines)
          and not any(BS + 'n' in l for l in lines)
          and len(set(lines)) == 4)
    return ok, 'lines=%d :: %s' % (len(lines), ' | '.join(lines))


def t_cron_filter_portable():
    for name in FILES:
        text = read(name)
        hits = [l for l in text.split(NL) if l.startswith('EXISTING_CRON=$(echo "$EXISTING_CRON" | grep -v')]
        if not hits:
            return False, name + ': filter line missing'
        line = hits[0]
        if 'grep -v -e' not in line:
            return False, name + ': not using multiple -e'
        if BS + '|' in line:
            return False, name + ': still uses BRE alternation'
        for pat in ('traffic_trend', 'traffic_reset_check', 'traffic_spike_check', 'traffic_history'):
            if pat not in line:
                return False, name + ': missing ' + pat
    return True, 'both files: grep -v -e x4'


# --------------------------------------------------------------------------
# 3) traffic_history.log 有读取方 + 降级
# --------------------------------------------------------------------------
def t_trend_has_reader_and_fallback():
    details = []
    for name in FILES:
        text = read(name)
        reader = '[ -r /root/traffic_history.log ]' in text
        writer = '>> /root/traffic_history.log' in text
        fallback = 'vnstat -d -i' in text
        degrade = 'if [ -z "' + BS + '$TREND" ]; then' in text
        if not (reader and writer and fallback and degrade):
            return False, '%s: reader=%s writer=%s fallback=%s degrade=%s' % (name, reader, writer, fallback, degrade)
        details.append(name + ':ok')
    return True, '; '.join(details)


def t_trend_reader_parses():
    prog = trend_reader_prog(read(ALPINE))
    if prog is None:
        return False, 'reader awk not found'
    prog = prog.replace(BS + '$', '$')
    tmp = mkdtemp()
    pf = os.path.join(tmp, 'prog.awk')
    df = os.path.join(tmp, 'hist.log')
    io.open(pf, 'w', encoding='utf-8', newline=NL).write(prog)
    data = [
        '2026-11-10 12.34',
        '2026-11-11 9.99',
        '2026-11-12 0.50',
        '2026-11-15 7',
        'bad-date 3.14',
        '2026-11-13 abc',
        '2026-11-14 1.2.3',
        '2026-11-16 1.0 extra',
        '',
    ]
    io.open(df, 'w', encoding='utf-8', newline=NL).write(NL.join(data) + NL)
    rc, out = bash('awk -f "$1" "$2"', [pf, df])
    got = [l for l in out.split(NL) if l.strip()]
    expect = ['2026-11-10 12.34', '2026-11-11 9.99', '2026-11-12 0.50', '2026-11-15 7']
    return rc == 0 and got == expect, 'kept=%d :: %s' % (len(got), ' | '.join(got))


# --------------------------------------------------------------------------
# 4) busybox date 不支持 %-m
# --------------------------------------------------------------------------
def t_no_percent_dash_m():
    for name in FILES:
        text = read(name)
        if 'date +%-m' in text:
            return False, name + ': still calls date +%-m'
        c = text.count('date +%m | sed')
        if c != 2:
            return False, '%s: portable month reads=%d (expect 2)' % (name, c)
    return True, 'both files: 2 portable month reads, no %-m call'


def t_month_value():
    text = read(ALPINE)
    expr = None
    for line in text.split(NL):
        if line.startswith('CUR_M='):
            expr = materialize(line[len('CUR_M='):])
            break
    if expr is None:
        return False, 'CUR_M line not found'
    stub = NL.join([
        'date() {',
        '    case "$1" in',
        '        +%m) echo "$STUB" ;;',
        '        +%Y) echo 2026 ;;',
        '        *) echo 0 ;;',
        '    esac',
        '}',
    ])
    expect = ['M=1;ARITH=2', 'M=2;ARITH=3', 'M=9;ARITH=10', 'M=10;ARITH=11', 'M=11;ARITH=0', 'M=12;ARITH=1']
    seen = []
    for m in ('01', '02', '09', '10', '11', '12'):
        script = NL.join([
            stub,
            'STUB=' + m,
            'M=' + expr,
            'echo "M=$M"',
            'echo "ARITH=$(( (M + 1) % 12 ))"',
        ])
        rc, out = bash(script)
        got = ';'.join([l for l in out.split(NL) if l.strip()])
        seen.append(got)
        if rc != 0:
            return False, 'stub=%s rc=%d %s' % (m, rc, out.strip()[:150])
    return seen == expect, ' | '.join(seen)


def t_month_old_form_breaks():
    """负向对照：旧写法在 busybox 语义下（date 原样输出 %-m）必须算不出来。"""
    stub = NL.join([
        'date() {',
        '    case "$1" in',
        '        +%-m) echo "%-m" ;;',
        '        *) echo 0 ;;',
        '    esac',
        '}',
    ])
    script = NL.join([stub, 'CUR_M=$(date +%-m)', 'echo "ARITH=$(( (CUR_M + 1) % 12 ))"'])
    rc, out = bash(script)
    return rc != 0, 'rc=%d out=%s' % (rc, out.strip()[:120])


# --------------------------------------------------------------------------
# 5) vnstat 清理保护
# --------------------------------------------------------------------------
def t_rm_guard_normal():
    block = materialize(rm_guard(read(ALPINE)))
    tmp = mkdtemp()
    for f in ('vnstat.db', 'vnstat.db-journal'):
        io.open(os.path.join(tmp, f), 'w', encoding='utf-8').write('x')
    rc, out = bash(block.replace('/var/lib/vnstat', posix(tmp)))
    left = sorted(os.listdir(tmp))
    return rc == 0 and left == [], 'rc=%d left=%s' % (rc, ','.join(left))


def t_rm_guard_whitelist():
    block = materialize(rm_guard(read(ALPINE)))
    tmp = mkdtemp()
    io.open(os.path.join(tmp, 'vnstat.db'), 'w', encoding='utf-8').write('x')
    # 只改赋值、不改白名单比较 → 必须拒绝删除
    script = block.replace('VNSTAT_DB="/var/lib/vnstat"', 'VNSTAT_DB="' + posix(tmp) + '"', 1)
    rc, out = bash(script)
    left = sorted(os.listdir(tmp))
    return rc == 0 and left == ['vnstat.db'] and '路径异常' in out, 'rc=%d left=%s msg=%s' % (
        rc, ','.join(left), out.strip()[:80])


def t_rm_guard_symlink():
    block = materialize(rm_guard(read(ALPINE)))
    tmp = mkdtemp()
    real = os.path.join(tmp, 'real')
    os.makedirs(real)
    io.open(os.path.join(real, 'keep.db'), 'w', encoding='utf-8').write('x')
    link = os.path.join(tmp, 'db')
    try:
        os.symlink(real, link, target_is_directory=True)
    except (OSError, NotImplementedError, AttributeError):
        # Windows 无符号链接权限：退回静态断言——-L 检查必须存在且排在 rm 之前
        blk = rm_guard(read(ALPINE))
        i_link = blk.find('[ -L "')
        i_rm = blk.find('rm -rf --')
        ok = i_link != -1 and i_rm != -1 and i_link < i_rm
        return ok, 'symlink unavailable; static order ok=%s' % ok
    rc, out = bash(block.replace('/var/lib/vnstat', posix(link)))
    kept = os.path.exists(os.path.join(real, 'keep.db'))
    return rc == 0 and kept and '符号链接' in out, 'rc=%d kept=%s msg=%s' % (rc, kept, out.strip()[:80])


# --------------------------------------------------------------------------
# 6) 发行版包管理器
# --------------------------------------------------------------------------
def invocations(text, tool):
    hits = []
    for lineno, raw in enumerate(text.split(NL), 1):
        if raw.lstrip().startswith('#'):
            continue
        line = raw
        idx = line.find(' #')
        if idx != -1:
            line = line[:idx]
        for seg in line.replace(';', NL).replace('&&', NL).replace('||', NL).split(NL):
            words = seg.split()
            while words and words[0] in ('if', 'then', 'else', 'elif', '!', 'sudo', 'exec'):
                words = words[1:]
            if words and words[0] == tool:
                hits.append('%d:%s' % (lineno, seg.strip()))
    return hits


def t_pkg_alpine_apk_only():
    text = read(ALPINE)
    bad = invocations(text, 'apt-get')
    ok = not bad and 'apk del vnstat' in text
    return ok, 'apt-get invocations=%d %s' % (len(bad), '; '.join(bad[:3]))


def t_pkg_debian_apt_only():
    text = read(DEBIAN)
    bad = invocations(text, 'apk')
    ok = not bad and 'apt-get remove -y vnstat' in text
    return ok, 'apk invocations=%d %s' % (len(bad), '; '.join(bad[:3]))


# --------------------------------------------------------------------------
# 7) 语法与旧写法
# --------------------------------------------------------------------------
def t_syntax_bash():
    for name in FILES:
        rc, out = bash_argv(['-n', posix(os.path.join(REPO, name))])
        if rc != 0:
            return False, name + ': ' + out.strip()[:150]
    return True, 'bash -n ok for 2 files'


def t_syntax_sh():
    rc, out = bash_argv(['--posix', '-n', posix(os.path.join(REPO, ALPINE))])
    return rc == 0, (out.strip()[:150] or 'posix-mode -n ok')


def t_generated_syntax():
    """把每个 heredoc 生成的子脚本还原出来做 bash -n（heredoc 体本身不被 bash -n 检查）。"""
    details = []
    for name in FILES:
        docs = heredocs(read(name))
        if len(docs) < 4:
            return False, '%s: only %d heredocs found' % (name, len(docs))
        tmp = mkdtemp()
        for k, (target, body) in enumerate(docs):
            path = os.path.join(tmp, 'gen%d.sh' % k)
            io.open(path, 'w', encoding='utf-8', newline=NL).write(materialize(body) + NL)
            rc, out = bash_argv(['-n', posix(path)])
            if rc != 0:
                return False, '%s %s: %s' % (name, target, out.strip()[:180])
        details.append('%s:%d' % (name, len(docs)))
    return True, '; '.join(details)


def t_no_bashism():
    text = read(ALPINE)
    bad = []
    if '[[' in text:
        bad.append('[[')
    if "$'" in text:
        bad.append("$'...'")
    if NL + 'function ' in text:
        bad.append('function keyword')
    return not bad, 'found=' + (','.join(bad) if bad else 'none')


def t_old_bugs_gone():
    probes = [
        ('case "$LIMIT" in', 'LIMIT 旧校验'),
        ('case "$BASELINE" in', 'BASELINE 旧校验'),
        ('case "$SPIKE_LIMIT" in', 'SPIKE 旧校验'),
        ('date +%-m', 'GNU-only %-m'),
        ('rm -rf /var/lib/vnstat/*', '未保护 glob'),
        (BS + '|traffic_reset_check', 'BRE 交替过滤'),
    ]
    left = []
    for name in FILES:
        text = read(name)
        for probe, desc in probes:
            if probe in text:
                left.append(name + ':' + desc)
    return not left, 'remaining=' + (', '.join(left) if left else 'none')


# --------------------------------------------------------------------------
TESTS = [
    ('is_num 接受合法数字', t_is_num_accepts),
    ('is_num 拒绝 "." / 空 / 多小数点 / 负号', t_is_num_rejects),
    ('is_num 单一定义 + 三处复用 + 旧 case 已移除', t_is_num_reused),
    ('算术兜底：非法 BASELINE 不再让脚本崩', t_arithmetic_guard),
    ('cron 连跑两次条目数不增加（幂等）', t_cron_idempotent),
    ('cron 修复旧版一行式坏条目且保留用户任务', t_cron_repairs_legacy),
    ('cron 过滤用多个 -e（busybox grep 兼容）', t_cron_filter_portable),
    ('趋势日志有读取方 + 保留 vnstat 降级', t_trend_has_reader_and_fallback),
    ('趋势读取 awk 只吃合法 "YYYY-MM-DD 数字" 行', t_trend_reader_parses),
    ('不再使用 date +%-m', t_no_percent_dash_m),
    ('月份 01..12 -> 1..12 且能直接进算术', t_month_value),
    ('负向对照：旧 %-m 写法在 busybox 语义下必然失败', t_month_old_form_breaks),
    ('vnstat 清理：正常目录会被清空', t_rm_guard_normal),
    ('vnstat 清理：路径不在白名单时拒绝删除', t_rm_guard_whitelist),
    ('vnstat 清理：符号链接不跟随', t_rm_guard_symlink),
    ('alpine 只用 apk，无 apt-get 调用', t_pkg_alpine_apk_only),
    ('debian 只用 apt-get，无 apk 调用', t_pkg_debian_apt_only),
    ('bash -n 两个安装脚本通过', t_syntax_bash),
    ('alpine 在 posix 模式语法通过（#!/bin/sh）', t_syntax_sh),
    ('heredoc 生成的子脚本逐个 bash -n 通过', t_generated_syntax),
    ('alpine 无 bashism（[[ / $\'...\' / function）', t_no_bashism),
    ('六条 P2 的旧写法全部消失', t_old_bugs_gone),
]


def main():
    global BASH
    BASH = find_bash()
    print('bash =', BASH)
    print('repo =', REPO)
    if not BASH:
        print('FAIL  找不到 bash，离线用例无法运行')
        return 1
    for name, fn in TESTS:
        check(name, fn)
    failed = [r for r in RESULTS if not r[1]]
    print('-' * 60)
    print('总计 %d 项：%d PASS，%d FAIL' % (len(RESULTS), len(RESULTS) - len(failed), len(failed)))
    return 0 if not failed else 1


if __name__ == '__main__':
    sys.exit(main())
