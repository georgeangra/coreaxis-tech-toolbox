# CoreAxis Tech Toolbox (Linux) - funções comuns dos coletores Python.
# Este arquivo é concatenado ANTES de cada coletor pelo aplicativo (o conteúdo é conferido por
# SHA-256 e enviado ao python3 pela entrada padrão), por isso não há "import" entre arquivos.
import datetime
import glob
import json
import os
import platform
import pwd
import re
import shutil
import socket
import subprocess
import sys
import time

ENV_C = dict(os.environ, LC_ALL='C', LANG='C', LANGUAGE='C')


def sh(cmd, timeout=20, env=None, ok_codes=None):
    """Executa um comando (lista) e devolve a saída padrão (texto). Nunca lança exceção."""
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout, env=env or ENV_C,
                           errors='replace', stdin=subprocess.DEVNULL)
        if ok_codes is not None and r.returncode not in ok_codes:
            return ''
        return r.stdout
    except Exception:
        return ''


def sh_json(cmd, timeout=20):
    try:
        return json.loads(sh(cmd, timeout) or 'null')
    except Exception:
        return None


def ler(path, default=None):
    try:
        with open(path, encoding='utf-8', errors='replace') as f:
            return f.read().strip()
    except Exception:
        return default


def ler_int(path, default=None):
    v = ler(path)
    try:
        return int(v)
    except Exception:
        return default


def tem(cmd):
    return shutil.which(cmd) is not None


def eh_root():
    return os.geteuid() == 0


LIXO = re.compile(r'^(to be filled by o\.?e\.?m\.?|default string|system (product name|serial number|version|manufacturer)|'
                  r'not (specified|applicable|available)|none|n/?a|o\.?e\.?m\.?|0+|x+|123456789|chassis serial number|'
                  r'base board serial number|type1productconfigid|unknown)$', re.I)


def limpar(v):
    """Remove valores genéricos que fabricantes deixam no firmware."""
    if v is None:
        return None
    v = re.sub(r'\s+', ' ', str(v)).strip()
    return None if not v or LIXO.match(v) else v


def dmi(campo):
    return limpar(ler(f'/sys/class/dmi/id/{campo}'))


def fmt_data(ts):
    try:
        return datetime.datetime.fromtimestamp(float(ts)).strftime('%d/%m/%Y %H:%M:%S')
    except Exception:
        return None


def agora():
    return datetime.datetime.now().strftime('%d/%m/%Y %H:%M:%S')


def uptime_seg():
    try:
        return float(ler('/proc/uptime').split()[0])
    except Exception:
        return 0.0


def fmt_uptime(s):
    s = int(s)
    return f'{s // 86400}d {(s % 86400) // 3600}h {(s % 3600) // 60}min'


def os_release():
    out = {}
    for linha in (ler('/etc/os-release') or '').splitlines():
        if '=' in linha:
            k, v = linha.split('=', 1)
            out[k] = v.strip().strip('"')
    return out


def args():
    """--Chave valor  |  --Flag  →  {'Chave': 'valor', 'Flag': True}"""
    out, a = {}, sys.argv[1:]
    i = 0
    while i < len(a):
        if a[i].startswith('--'):
            k = a[i][2:]
            if i + 1 < len(a) and not a[i + 1].startswith('--'):
                out[k] = a[i + 1]
                i += 2
                continue
            out[k] = True
        i += 1
    return out


def safe(fn, default=None):
    try:
        return fn()
    except Exception:
        return default


def usuario_real():
    """Usuário que abriu o programa, mesmo quando o script roda elevado (pkexec/sudo)."""
    uid = os.environ.get('PKEXEC_UID') or os.environ.get('SUDO_UID')
    try:
        return pwd.getpwuid(int(uid) if uid else os.getuid())
    except Exception:
        return None


def udev_props(nome=None, caminho=None):
    cmd = ['udevadm', 'info', '--query=property']
    cmd += ['--name', nome] if nome else ['--path', caminho]
    props = {}
    for linha in sh(cmd).splitlines():
        if '=' in linha:
            k, v = linha.split('=', 1)
            props[k] = v
    return props


def gerenciador_pacotes():
    for g in ('apt-get', 'dnf', 'zypper', 'pacman'):
        if tem(g):
            return g
    return None


def saida(obj):
    sys.stdout.write(json.dumps(obj, ensure_ascii=False, default=str))
    sys.stdout.flush()
