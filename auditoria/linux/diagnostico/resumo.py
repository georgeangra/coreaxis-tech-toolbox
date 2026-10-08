# CoreAxis Tech Toolbox (Linux) - Resumo rápido para o Dashboard (execução < 3 s, sem senha).

osr = os_release()


def ativo(servico):
    return sh(['systemctl', 'is-active', servico]).strip() == 'active'


def firewall():
    """True = ativo, False = instalado mas desligado, None = nenhum firewall gerenciado."""
    if tem('ufw') or os.path.exists('/etc/ufw/ufw.conf'):
        conf = ler('/etc/ufw/ufw.conf') or ''
        return bool(re.search(r'^ENABLED=yes', conf, re.M)) and ativo('ufw')
    if tem('firewall-cmd'):
        return ativo('firewalld')
    return None


def antivirus():
    if tem('clamscan') or tem('clamdscan'):
        return ativo('clamav-daemon') or ativo('clamav-freshclam') or ativo('clamd@scan')
    return None


def atualizacoes_pendentes():
    txt = ler('/var/lib/update-notifier/updates-available')
    if txt:
        m = re.search(r'(\d+)\s+(update|atualiza)', txt)
        if m:
            return int(m.group(1))
    if tem('apt-get'):
        return len(re.findall(r'^Inst ', sh(['apt-get', '-s', '-o', 'Debug::NoLocking=1', 'upgrade'], timeout=15), re.M))
    return None


volumes, vistos = [], set()
for f in (sh_json(['findmnt', '-J', '-b', '-l', '-o', 'TARGET,SOURCE,FSTYPE,SIZE,AVAIL,LABEL']) or {}).get('filesystems', []):
    src = str(f.get('source', '')).split('[')[0]
    if not src.startswith('/dev/') or src.startswith('/dev/loop') or src in vistos:
        continue
    if f.get('fstype') in ('squashfs', 'iso9660', 'tmpfs') or f['target'].startswith(('/snap', '/boot', '/var/snap')):
        continue
    vistos.add(src)
    volumes.append({'Letra': f['target'], 'Rotulo': f.get('label') or src, 'Tamanho': int(f.get('size') or 0), 'Livre': int(f.get('avail') or 0)})
volumes.sort(key=lambda v: (v['Letra'] != '/', v['Letra']))

lc = {i.get('field', '').rstrip(':'): i.get('data') for i in (sh_json(['lscpu', '-J']) or {}).get('lscpu', [])}
meminfo = re.search(r'MemTotal:\s*(\d+)', ler('/proc/meminfo') or '')
u = usuario_real()

saida({
    'computador': socket.gethostname(),
    'fabricante': dmi('sys_vendor'),
    'modelo': dmi('product_name'),
    'usuario': u.pw_name if u else None,
    'so': osr.get('PRETTY_NAME') or 'Linux',
    'versao': '',
    'build': platform.release(),
    'arquitetura': platform.machine(),
    'cpu': re.sub(r'\s+', ' ', lc.get('Model name') or platform.processor() or '').strip(),
    'ramTotal': int(meminfo.group(1)) * 1024 if meminfo else None,
    'ultimoBoot': fmt_data(time.time() - uptime_seg()),
    'admin': eh_root(),
    'elevacao': tem('pkexec') or tem('sudo'),
    'reinicioPendente': os.path.exists('/var/run/reboot-required') or os.path.exists('/run/reboot-required'),
    'antivirus': antivirus(),
    'firewall': firewall(),
    'atualizacoes': atualizacoes_pendentes(),
    'volumes': volumes,
})
