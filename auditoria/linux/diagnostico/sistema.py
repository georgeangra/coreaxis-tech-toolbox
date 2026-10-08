# CoreAxis Tech Toolbox (Linux) - Coleta completa de hardware e sistema (JSON).
# Mesmo formato da versão Windows (consumido pelos módulos Diagnóstico e Inventário).
#   --Inventario : inclui softwares instalados e histórico de atualizações (mais lento).
# Sem privilégios de administrador, os dados que o Linux restringe ao root (módulos de memória,
# SMART, números de série da placa/BIOS) ficam indisponíveis; com "Coleta completa" (senha) aparecem.

A = args()
ROOT = eh_root()

# ---------------------------------------------------------------- computador
CHASSI = {3: 'Desktop', 4: 'Desktop', 5: 'Desktop', 6: 'Desktop', 7: 'Desktop', 13: 'Desktop', 15: 'Desktop', 16: 'Desktop',
          35: 'Desktop', 36: 'Desktop', 8: 'Notebook', 9: 'Notebook', 10: 'Notebook', 14: 'Notebook', 31: 'Notebook', 32: 'Notebook',
          11: 'Portátil', 17: 'Servidor', 23: 'Servidor', 28: 'Servidor', 30: 'Tablet'}


def tipo_computador():
    t = CHASSI.get(ler_int('/sys/class/dmi/id/chassis_type', 0))
    if t:
        return t
    v = sh(['systemd-detect-virt']).strip()
    if v and v != 'none':
        return 'Máquina virtual'
    return 'Outro'


def usuario_logado():
    u = usuario_real()
    return u.pw_name if u else os.environ.get('USER')


def dominio():
    if tem('realm'):
        r = sh(['realm', 'list', '--name-only']).strip()
        if r:
            return r.splitlines()[0]
    d = sh(['hostname', '-d']).strip()
    return d or 'Sem domínio (computador local)'


computador = {
    'Nome': socket.gethostname(),
    'Fabricante': dmi('sys_vendor'),
    'Modelo': dmi('product_name'),
    'Familia': dmi('product_family') or dmi('product_version'),
    'Dominio': dominio(),
    'Usuario': usuario_logado(),
    'Tipo': tipo_computador(),
}

# ---------------------------------------------------------------- sistema operacional
osr = os_release()
up = uptime_seg()


def data_instalacao():
    birth = sh(['stat', '-c', '%W', '/']).strip()
    if birth.isdigit() and int(birth) > 0:
        return fmt_data(int(birth))
    for p in ('/var/log/installer', '/var/log/anaconda', '/lost+found'):
        if os.path.exists(p):
            return fmt_data(os.stat(p).st_mtime)
    return None


def desktop():
    de = os.environ.get('XDG_CURRENT_DESKTOP') or os.environ.get('DESKTOP_SESSION') or ''
    sess = os.environ.get('XDG_SESSION_TYPE') or ('wayland' if os.environ.get('WAYLAND_DISPLAY') else 'x11' if os.environ.get('DISPLAY') else '')
    return ' · '.join(x for x in (de.replace(':', ' / '), sess.capitalize()) if x) or None


sistema = {
    'Nome': osr.get('PRETTY_NAME') or f'{osr.get("NAME", "Linux")} {osr.get("VERSION", "")}'.strip(),
    'VersaoExibicao': ' '.join(x for x in (osr.get('VERSION_ID'), f'({osr["VERSION_CODENAME"]})' if osr.get('VERSION_CODENAME') else '') if x),
    'Build': platform.release(),
    'Arquitetura': {'x86_64': 'x86_64 (64 bits)', 'aarch64': 'ARM 64 bits', 'i686': '32 bits'}.get(platform.machine(), platform.machine()),
    'Idioma': (os.environ.get('LANG') or '').split('.')[0] or None,
    'DataInstalacao': data_instalacao(),
    'UltimoBoot': fmt_data(time.time() - up),
    'Uptime': fmt_uptime(up),
    'Desktop': desktop(),
    'Distribuicao': osr.get('ID'),
}

# ---------------------------------------------------------------- CPU
def uso_cpu():
    def amostra():
        v = list(map(int, ler('/proc/stat').splitlines()[0].split()[1:]))
        return v[3] + v[4], sum(v)
    i1, t1 = amostra()
    time.sleep(0.4)
    i2, t2 = amostra()
    return round((1 - (i2 - i1) / max(1, t2 - t1)) * 100)


def lscpu():
    d = {}
    for item in (sh_json(['lscpu', '-J']) or {}).get('lscpu', []):
        d[item.get('field', '').rstrip(':')] = item.get('data')
    return d


def cache_kb(txt):
    if not txt:
        return None
    m = re.match(r'([\d.]+)\s*(KiB|MiB|GiB|K|M)', txt)
    if not m:
        return None
    n = float(m.group(1))
    return int(n * {'KiB': 1, 'K': 1, 'MiB': 1024, 'M': 1024, 'GiB': 1048576}[m.group(2)])


lc = lscpu()
flags = (lc.get('Flags') or '')
vend = {'GenuineIntel': 'Intel', 'AuthenticAMD': 'AMD'}.get(lc.get('Vendor ID'), lc.get('Vendor ID'))
sockets = int(lc.get('Socket(s)') or 1)
nucleos = int(lc.get('Core(s) per socket') or 1)
virt = 'Indisponível'
if 'vmx' in flags or 'svm' in flags:
    virt = ('Habilitada' if os.path.exists('/dev/kvm') else 'Suportada (pode estar desativada na BIOS)') + (' · VT-x' if 'vmx' in flags else ' · AMD-V')
clock_max = lc.get('CPU max MHz') or (ler_int('/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq', 0) / 1000 or None)
clock_cur = ler_int('/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq')
uso = uso_cpu()
cpu = [{
    'Nome': re.sub(r'\s+', ' ', lc.get('Model name') or platform.processor() or 'Processador').strip(),
    'Fabricante': vend,
    'Nucleos': nucleos,
    'Threads': (os.cpu_count() or 1) // sockets,
    'ClockMHz': round(float(clock_max)) if clock_max else None,
    'ClockAtual': round(clock_cur / 1000) if clock_cur else None,
    'Soquete': f'Soquete {i + 1} de {sockets}' if sockets > 1 else None,
    'L2KB': cache_kb(lc.get('L2 cache') or lc.get('L2')),
    'L3KB': cache_kb(lc.get('L3 cache') or lc.get('L3')),
    'Uso': uso,
    'Virtualizacao': virt,
} for i in range(sockets)]

# ---------------------------------------------------------------- BIOS / placa-mãe
def secure_boot():
    if not os.path.isdir('/sys/firmware/efi'):
        return 'Não suportado / modo Legacy'
    for f in glob.glob('/sys/firmware/efi/efivars/SecureBoot-*'):
        try:
            with open(f, 'rb') as h:
                return 'Ativado' if h.read()[-1] == 1 else 'Desativado'
        except Exception:
            pass
    out = sh(['mokutil', '--sb-state'])
    if 'enabled' in out:
        return 'Ativado'
    if 'disabled' in out:
        return 'Desativado'
    return 'Desconhecido'


def tpm():
    base = '/sys/class/tpm/tpm0'
    if not os.path.exists(base):
        return 'Ausente'
    v = ler(f'{base}/tpm_version_major')
    return f'Presente - versão {v}.0' if v else 'Presente'


def data_bios(d):
    m = re.match(r'(\d{2})/(\d{2})/(\d{4})', d or '')
    return f'{m.group(2)}/{m.group(1)}/{m.group(3)}' if m else d


smbios = None
if ROOT and tem('dmidecode'):
    m = re.search(r'SMBIOS ([\d.]+)', sh(['dmidecode', '-t', '0']))
    smbios = m.group(1) if m else None

bios = {
    'Fabricante': dmi('bios_vendor'),
    'Versao': dmi('bios_version'),
    'Data': data_bios(dmi('bios_date')),
    'NumeroSerie': dmi('product_serial'),  # legível só como root
    'SMBIOS': smbios,
    'ModoBoot': 'UEFI' if os.path.isdir('/sys/firmware/efi') else 'Legacy (BIOS)',
    'SecureBoot': secure_boot(),
    'TPM': tpm(),
}
placa_mae = {
    'Fabricante': dmi('board_vendor'),
    'Modelo': dmi('board_name'),
    'Versao': dmi('board_version'),
    'NumeroSerie': dmi('board_serial'),
}

# ---------------------------------------------------------------- memória
meminfo = {}
for linha in (ler('/proc/meminfo') or '').splitlines():
    k, _, v = linha.partition(':')
    meminfo[k] = int(v.split()[0]) * 1024 if v.split() else 0

modulos, slots, max_cap = [], None, None
if ROOT and tem('dmidecode'):
    txt = sh(['dmidecode', '-t', '16,17'])
    for bloco in txt.split('\n\n'):
        if 'Physical Memory Array' in bloco and 'System Memory' in bloco:
            m = re.search(r'Number Of Devices:\s*(\d+)', bloco)
            slots = (slots or 0) + int(m.group(1)) if m else slots
            m = re.search(r'Maximum Capacity:\s*([\d.]+)\s*(GB|TB|MB)', bloco)
            if m:
                max_cap = int(float(m.group(1)) * {'MB': 2**20, 'GB': 2**30, 'TB': 2**40}[m.group(2)])
        if 'Memory Device' in bloco:
            f = dict(re.findall(r'^\s*([^:\n]+):\s*(.*)$', bloco, re.M))
            tam = f.get('Size', '')
            m = re.match(r'(\d+)\s*(MB|GB|TB)', tam)
            if not m:
                continue
            modulos.append({
                'Slot': f.get('Locator') or f.get('Bank Locator'),
                'Capacidade': int(m.group(1)) * {'MB': 2**20, 'GB': 2**30, 'TB': 2**40}[m.group(2)],
                'Velocidade': safe(lambda: int(re.match(r'\d+', f.get('Configured Memory Speed') or f.get('Speed') or '').group(0))),
                'Tipo': limpar(f.get('Type')),
                'Fabricante': limpar(f.get('Manufacturer')),
                'PartNumber': limpar(f.get('Part Number')),
                'NumeroSerie': limpar(f.get('Serial Number')),
            })

memoria = {
    'Total': meminfo.get('MemTotal'),
    'Livre': meminfo.get('MemAvailable'),
    'Slots': slots,
    'MaxCapacidade': max_cap,
    'Modulos': modulos,
}

# ---------------------------------------------------------------- discos
hwmon_temp = {}
for h in glob.glob('/sys/class/hwmon/hwmon*'):
    nome = ler(f'{h}/name')
    disp = os.path.realpath(f'{h}/device') if os.path.exists(f'{h}/device') else ''
    t = ler_int(f'{h}/temp1_input')
    if nome in ('nvme', 'drivetemp') and t:
        hwmon_temp[disp] = round(t / 1000)


def smart(dev):
    if not (ROOT and tem('smartctl')):
        return {}
    d = sh_json(['smartctl', '-j', '-a', f'/dev/{dev}'], timeout=40) or {}
    out = {}
    passed = (d.get('smart_status') or {}).get('passed')
    out['Saude'] = None if passed is None else ('Saudável' if passed else 'Crítico')
    out['Temperatura'] = (d.get('temperature') or {}).get('current')
    out['HorasLigado'] = (d.get('power_on_time') or {}).get('hours')
    nv = d.get('nvme_smart_health_information_log') or {}
    if nv:
        out['Desgaste'] = nv.get('percentage_used')
        out['ErrosLeitura'] = nv.get('media_errors')
    for a in (d.get('ata_smart_attributes') or {}).get('table', []):
        raw = (a.get('raw') or {}).get('value')
        if a.get('id') in (5, 197, 198) and raw:
            out['Saude'] = 'Atenção' if out.get('Saude') == 'Saudável' else out.get('Saude')
        if a.get('id') in (177, 231, 233) and out.get('Desgaste') is None:
            out['Desgaste'] = max(0, 100 - (a.get('value') or 100))
        if a.get('id') == 187:
            out['ErrosLeitura'] = raw
    if (out.get('Desgaste') or 0) >= 90 and out.get('Saude') == 'Saudável':
        out['Saude'] = 'Atenção'
    return out


discos = []
for b in (sh_json(['lsblk', '-J', '-b', '-d', '-o', 'NAME,MODEL,SERIAL,SIZE,ROTA,TRAN,TYPE,REV,VENDOR,RM']) or {}).get('blockdevices', []):
    if b.get('type') != 'disk' or re.match(r'(loop|ram|zram|sr|fd)', b['name']) or not int(b.get('size') or 0):
        continue
    tran = (b.get('tran') or '').lower()
    tipo = 'SSD' if tran == 'nvme' or b['name'].startswith('nvme') or str(b.get('rota')) in ('False', '0', 'false') else 'HDD'
    if tran == 'usb':
        tipo = 'Removível (USB)'
    disp = os.path.realpath(f'/sys/block/{b["name"]}/device')
    temp = next((v for k, v in hwmon_temp.items() if k and (disp.startswith(k) or k.startswith(disp))), None)
    s = smart(b['name'])
    discos.append({
        'Modelo': ' '.join(x for x in (limpar(b.get('vendor')), limpar(b.get('model'))) if x) or b['name'],
        'Dispositivo': f'/dev/{b["name"]}',
        'Tipo': tipo,
        'Barramento': {'nvme': 'NVMe', 'sata': 'SATA', 'usb': 'USB', 'ata': 'ATA', 'sas': 'SAS', 'virtio': 'VirtIO'}.get(tran, tran.upper() or ('VirtIO' if b['name'].startswith('vd') else None)),
        'Tamanho': int(b['size']),
        'Saude': s.get('Saude') or ('Não verificado (requer senha)' if not ROOT else 'Sem suporte SMART'),
        'Status': 'OK',
        'NumeroSerie': limpar(b.get('serial')),
        'Firmware': limpar(b.get('rev')),
        'Temperatura': s.get('Temperatura') or temp,
        'Desgaste': s.get('Desgaste'),
        'HorasLigado': s.get('HorasLigado'),
        'ErrosLeitura': s.get('ErrosLeitura'),
    })

FS_REAIS = {'ext2', 'ext3', 'ext4', 'xfs', 'btrfs', 'vfat', 'exfat', 'ntfs', 'ntfs3', 'fuseblk', 'f2fs', 'zfs', 'jfs', 'reiserfs'}
volumes, vistos = [], set()
for f in (sh_json(['findmnt', '-J', '-b', '-l', '-o', 'TARGET,SOURCE,FSTYPE,SIZE,AVAIL,LABEL']) or {}).get('filesystems', []):
    if f.get('fstype') not in FS_REAIS or not str(f.get('source', '')).startswith('/dev/'):
        continue
    src = f['source'].split('[')[0]
    if src in vistos or f['target'].startswith(('/snap', '/boot/efi', '/var/snap')):
        continue
    vistos.add(src)
    tam, livre = int(f.get('size') or 0), int(f.get('avail') or 0)
    volumes.append({
        'Letra': f['target'],
        'Rotulo': f.get('label') or src,
        'Sistema': f['fstype'],
        'Tamanho': tam,
        'Livre': livre,
        'UsoPct': round((1 - livre / tam) * 100, 1) if tam else 0,
    })
volumes.sort(key=lambda v: (v['Letra'] != '/', v['Letra']))

# ---------------------------------------------------------------- vídeo
def pci_nome(slot):
    out = sh(['lspci', '-mm', '-s', slot])
    partes = re.findall(r'"([^"]*)"', out)
    return f'{partes[1]} {partes[2]}'.strip() if len(partes) >= 3 else slot


def resolucoes():
    out = []
    for st in glob.glob('/sys/class/drm/card*-*/status'):
        if ler(st) == 'connected':
            modos = (ler(os.path.join(os.path.dirname(st), 'modes')) or '').splitlines()
            if modos:
                out.append(modos[0])
    return out


video = []
res = resolucoes()
for dev in sorted(glob.glob('/sys/bus/pci/devices/*')):
    classe = ler(f'{dev}/class') or ''
    if not classe.startswith('0x03'):
        continue
    slot = os.path.basename(dev)
    drv = os.path.basename(os.path.realpath(f'{dev}/driver')) if os.path.exists(f'{dev}/driver') else None
    versao = None
    if drv == 'nvidia':
        m = re.search(r'Kernel Module\s+([\d.]+)', ler('/proc/driver/nvidia/version') or '')
        versao = m.group(1) if m else None
    elif drv:
        versao = sh(['modinfo', '-F', 'version', drv]).strip() or f'kernel {platform.release()}'
    vram = ler_int(glob.glob(f'{dev}/drm/card*/device/mem_info_vram_total')[0]) if glob.glob(f'{dev}/drm/card*/device/mem_info_vram_total') else None
    video.append({
        'Nome': pci_nome(slot),
        'Memoria': vram,
        'Driver': f'{drv} {versao or ""}'.strip() if drv else 'Sem driver',
        'DataDriver': None,
        'Resolucao': ', '.join(res) if res else '',
    })


def edid_info(raw):
    if len(raw) < 128 or raw[:8] != b'\x00\xff\xff\xff\xff\xff\xff\x00':
        return None
    m = (raw[8] << 8) | raw[9]
    fab = ''.join(chr(((m >> s) & 0x1f) + 64) for s in (10, 5, 0))
    modelo = serie = None
    for i in range(54, 126, 18):
        d = raw[i:i + 18]
        if d[0:3] == b'\x00\x00\x00' and d[3] in (0xFC, 0xFF):
            txt = d[5:18].split(b'\n')[0].decode('ascii', 'replace').strip()
            if d[3] == 0xFC:
                modelo = txt
            else:
                serie = txt
    return {'Fabricante': fab, 'Modelo': modelo, 'NumeroSerie': serie}


monitores = []
for e in glob.glob('/sys/class/drm/card*-*/edid'):
    try:
        with open(e, 'rb') as h:
            info = edid_info(h.read())
        if info:
            monitores.append(info)
    except Exception:
        pass

# ---------------------------------------------------------------- rede (adaptadores físicos)
def dns_servidores(iface=None):
    if tem('resolvectl'):
        out = sh(['resolvectl', 'dns'] + ([iface] if iface else []))
        ips = re.findall(r'(\d{1,3}(?:\.\d{1,3}){3})', out)
        if ips:
            return sorted(set(ips), key=ips.index)
    return re.findall(r'^nameserver\s+(\S+)', ler('/etc/resolv.conf') or '', re.M)


def velocidade(iface):
    if os.path.isdir(f'/sys/class/net/{iface}/wireless') and tem('iw'):
        m = re.search(r'tx bitrate:\s*([\d.]+)\s*MBit/s', sh(['iw', 'dev', iface, 'link']))
        return f'{m.group(1)} Mbps' if m else None
    s = ler_int(f'/sys/class/net/{iface}/speed')
    if not s or s < 0:
        return None
    return f'{s // 1000} Gbps' if s >= 1000 and s % 1000 == 0 else f'{s} Mbps'


rotas = sh_json(['ip', '-j', 'route', 'show', 'default']) or []
enderecos = {a['ifname']: a for a in (sh_json(['ip', '-j', 'addr']) or [])}
rede = []
for iface in sorted(os.listdir('/sys/class/net')):
    real = os.path.realpath(f'/sys/class/net/{iface}')
    if '/virtual/' in real or not os.path.exists(f'/sys/class/net/{iface}/device'):
        continue
    p = udev_props(caminho=real)
    info = enderecos.get(iface, {})
    v4 = [x for x in info.get('addr_info', []) if x.get('family') == 'inet']
    drv = os.path.basename(os.path.realpath(f'/sys/class/net/{iface}/device/driver')) if os.path.exists(f'/sys/class/net/{iface}/device/driver') else None
    oper = ler(f'/sys/class/net/{iface}/operstate')
    rede.append({
        'Nome': iface,
        'Descricao': ' '.join(x for x in (p.get('ID_VENDOR_FROM_DATABASE'), p.get('ID_MODEL_FROM_DATABASE')) if x) or iface,
        'MAC': (ler(f'/sys/class/net/{iface}/address') or '').upper(),
        'Velocidade': velocidade(iface) if oper == 'up' else None,
        'Status': {'up': 'Conectado', 'down': 'Desconectado', 'dormant': 'Aguardando'}.get(oper, oper),
        'IPs': [f'{x["local"]}/{x["prefixlen"]}' for x in v4],
        'Gateway': next((r.get('gateway') for r in rotas if r.get('dev') == iface), None),
        'DNS': dns_servidores(iface) if oper == 'up' else [],
        'DHCP': any(x.get('dynamic') for x in v4) if v4 else None,
        'Driver': drv,
        'Sem fio': os.path.isdir(f'/sys/class/net/{iface}/wireless'),
    })

# ---------------------------------------------------------------- bateria
bateria = None
bats = sorted(glob.glob('/sys/class/power_supply/BAT*'))
if bats:
    b = bats[0]
    design = ler_int(f'{b}/energy_full_design') or ler_int(f'{b}/charge_full_design')
    cheia = ler_int(f'{b}/energy_full') or ler_int(f'{b}/charge_full')
    unidade = 'mWh' if os.path.exists(f'{b}/energy_full') else 'mAh'
    bateria = {
        'Nome': ' '.join(x for x in (ler(f'{b}/manufacturer'), ler(f'{b}/model_name')) if x) or os.path.basename(b),
        'Carga': ler_int(f'{b}/capacity'),
        'Status': {'Discharging': 'Descarregando', 'Charging': 'Carregando', 'Full': 'Carregada', 'Not charging': 'Na tomada'}.get(ler(f'{b}/status'), ler(f'{b}/status')),
        'CapacidadeProjeto': f'{design // 1000} {unidade}' if design else None,
        'CapacidadeAtual': f'{cheia // 1000} {unidade}' if cheia else None,
        'Saude': f'{round(cheia / design * 100)}%' if design and cheia else None,
        'Ciclos': ler_int(f'{b}/cycle_count'),
    }

# ---------------------------------------------------------------- temperaturas
NOMES_SENSOR = {'coretemp': 'CPU', 'k10temp': 'CPU', 'zenpower': 'CPU', 'cpu_thermal': 'CPU', 'acpitz': 'Zona térmica ACPI',
                'nvme': 'Disco NVMe', 'drivetemp': 'Disco', 'amdgpu': 'GPU AMD', 'nouveau': 'GPU NVIDIA', 'radeon': 'GPU AMD',
                'pch_cannonlake': 'Chipset', 'pch_skylake': 'Chipset', 'iwlwifi_1': 'Wi-Fi', 'thinkpad': 'ThinkPad', 'dell_smm': 'Dell'}


def temperaturas():
    lista = []
    for h in sorted(glob.glob('/sys/class/hwmon/hwmon*')):
        nome = ler(f'{h}/name') or 'sensor'
        for t in sorted(glob.glob(f'{h}/temp*_input')):
            v = ler_int(t)
            if v is None or v <= 0 or v > 150000:
                continue
            rot = ler(t.replace('_input', '_label'))
            base = NOMES_SENSOR.get(nome, nome)
            lista.append({'Sensor': f'{base}: {rot}' if rot else base, 'Celsius': round(v / 1000, 1), 'Origem': f'hwmon ({nome})'})
    if not lista:
        for z in sorted(glob.glob('/sys/class/thermal/thermal_zone*')):
            v = ler_int(f'{z}/temp')
            if v and v > 0:
                lista.append({'Sensor': f'Zona térmica {ler(f"{z}/type") or os.path.basename(z)}', 'Celsius': round(v / 1000, 1), 'Origem': 'ACPI'})
    for d in discos:
        if d.get('Temperatura') and not any(x['Origem'].startswith('hwmon (nvme') or x['Origem'].startswith('hwmon (drivetemp') for x in lista):
            lista.append({'Sensor': f'Disco: {d["Modelo"]}', 'Celsius': d['Temperatura'], 'Origem': 'SMART'})
    return lista


resultado = {
    'coletadoEm': agora(),
    'admin': ROOT,
    'plataforma': 'linux',
    'computador': computador,
    'sistema': sistema,
    'cpu': cpu,
    'bios': bios,
    'placaMae': placa_mae,
    'memoria': memoria,
    'discos': discos,
    'volumes': volumes,
    'video': video,
    'monitores': monitores,
    'rede': rede,
    'bateria': bateria,
    'temperaturas': temperaturas(),
}

# ---------------------------------------------------------------- inventário (extras)
if A.get('Inventario'):
    def historico_atualizacoes():
        """Últimas transações do gerenciador de pacotes (equivalente aos hotfixes do Windows)."""
        itens = []
        logs = sorted(glob.glob('/var/log/apt/history.log*'))
        txt = ''
        for f in logs[:3]:
            if f.endswith('.gz'):
                txt += sh(['zcat', f])
            else:
                txt += ler(f) or ''
        for bloco in txt.split('\n\n'):
            m = re.search(r'Start-Date:\s*(\d{4})-(\d{2})-(\d{2})', bloco)
            if not m:
                continue
            for acao, nome in (('Upgrade', 'atualizado(s)'), ('Install', 'instalado(s)')):
                l = re.search(rf'^{acao}:\s*(.*)$', bloco, re.M)
                if l:
                    n = len(re.findall(r'\),', l.group(1) + '),'))
                    itens.append((f'{m.group(1)}{m.group(2)}{m.group(3)}', f'{n} pacote(s) {nome} ({m.group(3)}/{m.group(2)}/{m.group(1)})'))
        if not itens and tem('dnf'):
            for linha in sh(['dnf', 'history', 'list'], timeout=30).splitlines()[2:17]:
                partes = [p.strip() for p in linha.split('|')]
                if len(partes) >= 4:
                    itens.append((partes[2], f'{partes[3]} ({partes[2]})'))
        return [t for _, t in sorted(itens, reverse=True)[:15]]

    def softwares():
        lista = []
        if tem('apt-mark') and tem('dpkg-query'):
            manuais = set(sh(['apt-mark', 'showmanual'], timeout=60).split())
            for linha in sh(['dpkg-query', '-W', '-f', '${Package}\t${Version}\t${Maintainer}\t${Status}\n'], timeout=60).splitlines():
                p = linha.split('\t')
                if len(p) < 4 or p[0] not in manuais or 'installed' not in p[3]:
                    continue
                info = f'/var/lib/dpkg/info/{p[0]}.list'
                if not os.path.exists(info):
                    info = (glob.glob(f'/var/lib/dpkg/info/{p[0]}:*.list') or [None])[0]
                lista.append({'Nome': p[0], 'Versao': p[1], 'Fabricante': f'APT · {re.sub(r"<.*>", "", p[2]).strip()}',
                              'Data': fmt_data(os.stat(info).st_mtime)[:10] if info else None})
        elif tem('rpm'):
            for linha in sh(['rpm', '-qa', '--qf', '%{NAME}\t%{VERSION}-%{RELEASE}\t%{VENDOR}\t%{INSTALLTIME}\n'], timeout=60).splitlines():
                p = linha.split('\t')
                if len(p) == 4:
                    lista.append({'Nome': p[0], 'Versao': p[1], 'Fabricante': f'RPM · {p[2]}', 'Data': fmt_data(p[3])[:10] if p[3].isdigit() else None})
        if tem('snap'):
            for linha in sh(['snap', 'list'], timeout=30).splitlines()[1:]:
                p = linha.split()
                if len(p) >= 5:
                    lista.append({'Nome': p[0], 'Versao': p[1], 'Fabricante': f'Snap · {p[4].rstrip("*✓")}', 'Data': None})
        if tem('flatpak'):
            for linha in sh(['flatpak', 'list', '--app', '--columns=name,version,origin'], timeout=30).splitlines():
                p = linha.split('\t')
                if len(p) >= 3:
                    lista.append({'Nome': p[0], 'Versao': p[1], 'Fabricante': f'Flatpak · {p[2]}', 'Data': None})
        return sorted(lista, key=lambda x: x['Nome'].lower())

    resultado['sistema']['Hotfixes'] = historico_atualizacoes()
    resultado['sistema']['GerenciadorPacotes'] = gerenciador_pacotes()
    resultado['software'] = softwares()

saida(resultado)
