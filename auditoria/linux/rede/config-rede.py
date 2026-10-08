# CoreAxis Tech Toolbox (Linux) - Configuração de rede atual (JSON).
# Adaptadores virtuais (VPN, Docker, VirtualBox, pontes) são marcados como "Virtual": a velocidade
# deles é um valor nominal do driver, não uma medição real.

TIPOS = {'ethernet': 'Ethernet', 'wifi': 'Wi-Fi', '802-11-wireless': 'Wi-Fi', 'wireguard': 'VPN (WireGuard)', 'tun': 'VPN / Túnel',
         'vpn': 'VPN', 'bridge': 'Ponte', 'bond': 'Agregação', 'vlan': 'VLAN', 'loopback': 'Loopback', 'gsm': 'Modem 4G/5G'}


def nm_dispositivos():
    out = {}
    if not tem('nmcli'):
        return out
    for linha in sh(['nmcli', '-t', '-f', 'DEVICE,TYPE,STATE,CONNECTION', 'device']).splitlines():
        p = linha.split(':')
        if len(p) >= 4:
            out[p[0]] = {'tipo': p[1], 'estado': p[2], 'conexao': ':'.join(p[3:])}
    return out


def dns_de(iface):
    if tem('resolvectl'):
        ips = re.findall(r'(\d{1,3}(?:\.\d{1,3}){3})', sh(['resolvectl', 'dns', iface]))
        if ips:
            return list(dict.fromkeys(ips))
    return []


def velocidade(iface, virtual):
    if virtual:
        return 'Virtual (valor nominal)'
    if os.path.isdir(f'/sys/class/net/{iface}/wireless') and tem('iw'):
        m = re.search(r'tx bitrate:\s*([\d.]+)\s*MBit/s', sh(['iw', 'dev', iface, 'link']))
        return f'{m.group(1)} Mbps' if m else None
    s = ler_int(f'/sys/class/net/{iface}/speed')
    if not s or s < 0:
        return None
    return f'{s // 1000} Gbps' if s >= 1000 and s % 1000 == 0 else f'{s} Mbps'


rotas = sh_json(['ip', '-j', 'route', 'show', 'default']) or []
nm = nm_dispositivos()
dns_global = re.findall(r'^nameserver\s+(\S+)', ler('/etc/resolv.conf') or '', re.M)
adaptadores = []
for a in sh_json(['ip', '-j', 'addr']) or []:
    iface = a.get('ifname')
    if not iface or iface == 'lo' or 'UP' not in a.get('flags', []):
        continue
    v4 = [x for x in a.get('addr_info', []) if x.get('family') == 'inet']
    v6 = [x['local'] for x in a.get('addr_info', []) if x.get('family') == 'inet6' and x.get('scope') == 'global']
    if not v4 and not v6:
        continue
    real = os.path.realpath(f'/sys/class/net/{iface}')
    virtual = '/virtual/' in real or not os.path.exists(f'/sys/class/net/{iface}/device')
    p = {} if virtual else udev_props(caminho=real)
    info = nm.get(iface, {})
    tipo = TIPOS.get(info.get('tipo') or a.get('link_type'), info.get('tipo') or '')
    if virtual and not tipo:
        tipo = 'Virtual'
    desc = ' '.join(x for x in (p.get('ID_VENDOR_FROM_DATABASE'), p.get('ID_MODEL_FROM_DATABASE')) if x)
    if not desc:
        desc = {'docker': 'Docker', 'vboxnet': 'VirtualBox Host-Only', 'virbr': 'Libvirt / KVM', 'tailscale': 'Tailscale Tunnel',
                'wg': 'WireGuard', 'tun': 'Túnel VPN', 'br-': 'Ponte Docker', 'veth': 'Par virtual (contêiner)'}.get(
            next((k for k in ('docker', 'vboxnet', 'virbr', 'tailscale', 'wg', 'tun', 'br-', 'veth') if iface.startswith(k)), ''), iface)
    adaptadores.append({
        'Nome': iface,
        'Descricao': desc,
        'MAC': (a.get('address') or '').upper() if a.get('link_type') == 'ether' else None,
        'Velocidade': velocidade(iface, virtual),
        'IPv4': [f'{x["local"]}/{x["prefixlen"]}' for x in v4],
        'IPv6': v6,
        'Gateway': [r['gateway'] for r in rotas if r.get('dev') == iface and r.get('gateway')],
        'DNS': dns_de(iface) or ([] if virtual else dns_global),
        'DHCP': any(x.get('dynamic') for x in v4),
        'Perfil': 'Virtual' if virtual else tipo,
        'Rede': info.get('conexao') or None,
        'Virtual': virtual,
    })
adaptadores.sort(key=lambda x: (x['Virtual'], x['Nome']))

wifi = None
if tem('nmcli'):
    for linha in sh(['nmcli', '-t', '-f', 'ACTIVE,SSID,SIGNAL,CHAN,FREQ,RATE', 'device', 'wifi', 'list', '--rescan', 'no']).splitlines():
        p = re.split(r'(?<!\\):', linha)
        if len(p) >= 6 and p[0] == 'yes':
            freq = int(re.sub(r'\D', '', p[4]) or 0)
            wifi = {'SSID': p[1].replace('\\:', ':'), 'Sinal': f'{p[2]}%', 'Canal': p[3],
                    'Banda': '5 GHz' if freq >= 4900 else '2,4 GHz' if freq else None, 'Taxa': p[5]}
            break

saida({'hostname': socket.gethostname(), 'adaptadores': adaptadores, 'wifi': wifi})
