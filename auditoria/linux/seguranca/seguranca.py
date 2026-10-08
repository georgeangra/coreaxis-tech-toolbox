# CoreAxis Tech Toolbox (Linux) - Segurança (JSON).
#   --Acao Protecao | Firewall | Servicos | Processos | Assinaturas
# Assinaturas: no Linux os programas são verificados pelo gerenciador de pacotes — o executável
# precisa pertencer a um pacote instalado e conferir com o hash registrado pelo pacote (dpkg/rpm).

A = args()
ACAO = A.get('Acao', 'Protecao')


def ativo(servico):
    return sh(['systemctl', 'is-active', servico]).strip() == 'active'


def existe_unidade(servico):
    return 'LoadState=loaded' in sh(['systemctl', 'show', '-p', 'LoadState', servico])


# ------------------------------------------------------------------ proteção (antivírus, MAC, updates)
def protecao():
    clam = tem('clamscan') or tem('clamdscan')
    versao = assinaturas = idade = atualizadas = None
    if clam:
        v = sh(['clamscan', '--version']).strip()  # ClamAV 1.0.5/27420/Tue Oct  6 08:13:44 2026
        m = re.match(r'ClamAV\s+([\d.]+)(?:/(\d+)/(.+))?', v)
        if m:
            versao, assinaturas = m.group(1), m.group(2)
        bases = [f for f in glob.glob('/var/lib/clamav/daily.c[lv]d')]
        if bases:
            ts = max(os.stat(f).st_mtime for f in bases)
            atualizadas, idade = fmt_data(ts), int((time.time() - ts) // 86400)
    ameacas = []
    for log in glob.glob('/var/log/clamav/*.log') + glob.glob(os.path.expanduser('~/.local/share/CoreAxis/clamav-*.log')):
        for linha in (ler(log) or '').splitlines():
            m = re.match(r'^(.*?):\s+(.+)\s+FOUND$', linha)
            if m:
                ameacas.append({'Ameaca': m.group(2), 'Recurso': m.group(1), 'Data': fmt_data(os.stat(log).st_mtime)})
    ameacas = ameacas[-20:][::-1]

    aa_on = (ler('/sys/module/apparmor/parameters/enabled') or '').upper() == 'Y'
    selinux = ler('/sys/fs/selinux/enforce')
    auto = ler('/etc/apt/apt.conf.d/20auto-upgrades') or ''
    auto_on = bool(re.search(r'Unattended-Upgrade\s+"1"', auto)) if tem('apt-get') else (ativo('dnf-automatic.timer') or ativo('dnf-automatic-install.timer'))
    ssh_root = None
    if os.path.exists('/etc/ssh/sshd_config'):
        txt = (ler('/etc/ssh/sshd_config') or '') + ''.join(ler(f) or '' for f in glob.glob('/etc/ssh/sshd_config.d/*.conf'))
        m = re.search(r'^\s*PermitRootLogin\s+(\S+)', txt, re.M | re.I)
        ssh_root = m.group(1) if m else 'prohibit-password (padrão)'
    admins = []
    for g in ('sudo', 'wheel', 'admin'):
        linha = sh(['getent', 'group', g]).strip()
        if linha:
            admins += [u for u in linha.split(':')[-1].split(',') if u]

    produtos = [{'Nome': 'ClamAV (antivírus)', 'Ativo': clam and (ativo('clamav-daemon') or ativo('clamav-freshclam')), 'Atualizado': idade is not None and idade <= 3, 'Instalado': clam}]
    if aa_on or existe_unidade('apparmor'):
        produtos.append({'Nome': 'AppArmor (confinamento de aplicativos)', 'Ativo': aa_on, 'Atualizado': True, 'Instalado': True})
    if selinux is not None:
        produtos.append({'Nome': 'SELinux', 'Ativo': selinux == '1', 'Atualizado': True, 'Instalado': True})
    if tem('fail2ban-client') or existe_unidade('fail2ban'):
        produtos.append({'Nome': 'Fail2ban (bloqueio de ataques)', 'Ativo': ativo('fail2ban'), 'Atualizado': True, 'Instalado': True})

    return {
        'disponivel': clam,
        'servicoAtivo': ativo('clamav-daemon') if clam else None,
        'antivirus': clam,
        'tempoReal': ativo('clamav-clamonacc') if clam else None,
        'atualizacaoAssinaturas': ativo('clamav-freshclam') if clam else None,
        'versaoMotor': versao,
        'versaoAssinaturas': assinaturas,
        'assinaturasAtualizadas': atualizadas,
        'idadeAssinaturasDias': idade,
        'apparmor': aa_on,
        'selinux': None if selinux is None else selinux == '1',
        'atualizacoesAutomaticas': auto_on,
        'sshAtivo': ativo('ssh') or ativo('sshd'),
        'sshRoot': ssh_root,
        'administradores': sorted(set(admins)),
        'ameacas': ameacas,
        'produtos': produtos,
    }


# ------------------------------------------------------------------ firewall
def firewall():
    perfis, redes, regras = [], [], None
    if tem('ufw') or os.path.exists('/etc/ufw/ufw.conf'):
        conf = ler('/etc/ufw/ufw.conf') or ''
        pad = ler('/etc/default/ufw') or ''
        pol = lambda k: {'DROP': 'Bloquear', 'REJECT': 'Rejeitar', 'ACCEPT': 'Permitir'}.get(
            (re.search(rf'^{k}="?(\w+)', pad, re.M) or [None, '?'])[1], '?')
        on = bool(re.search(r'^ENABLED=yes', conf, re.M)) and ativo('ufw')
        perfis.append({'Perfil': 'UFW', 'Ativo': on, 'Entrada': pol('DEFAULT_INPUT_POLICY'), 'Saida': pol('DEFAULT_OUTPUT_POLICY'), 'Ferramenta': 'ufw'})
        if eh_root():
            regras = len(re.findall(r'^\[\s*\d+\]', sh(['ufw', 'status', 'numbered']), re.M))
        else:
            txt = ler('/etc/ufw/user.rules')
            regras = len(re.findall(r'^### tuple', txt, re.M)) if txt else None
    if tem('firewall-cmd'):
        on = ativo('firewalld')
        perfis.append({'Perfil': 'firewalld', 'Ativo': on, 'Entrada': 'Por zona', 'Saida': 'Permitir', 'Ferramenta': 'firewalld'})
        if on:
            atual = None
            for linha in sh(['firewall-cmd', '--get-active-zones']).splitlines():
                if not linha.startswith(' '):
                    atual = linha.strip()
                elif 'interfaces:' in linha:
                    for i in linha.split(':', 1)[1].split():
                        redes.append({'Rede': i, 'Categoria': f'Zona {atual}', 'Interface': i})
    if not perfis:
        perfis.append({'Perfil': 'Nenhum firewall gerenciado', 'Ativo': False, 'Entrada': '—', 'Saida': '—', 'Ferramenta': None})
    if not redes and tem('nmcli'):
        for linha in sh(['nmcli', '-t', '-f', 'NAME,TYPE,DEVICE', 'connection', 'show', '--active']).splitlines():
            p = linha.split(':')
            if len(p) >= 3 and p[2] and p[1] != 'loopback':
                redes.append({'Rede': p[0], 'Categoria': {'802-3-ethernet': 'Cabo', '802-11-wireless': 'Wi-Fi', 'vpn': 'VPN', 'wireguard': 'VPN'}.get(p[1], p[1]), 'Interface': p[2]})
    escuta = []
    for linha in sh(['ss', '-H', '-tuln']).splitlines():
        p = linha.split()
        if len(p) >= 5 and not re.match(r'^(127\.|\[::1\]|::1)', p[4]):
            escuta.append(f'{p[0].upper()} {p[4]}')
    return {'perfis': perfis, 'redesAtivas': redes, 'regrasAtivas': regras, 'regrasEntrada': None, 'regrasSaida': None,
            'portasExpostas': sorted(set(escuta)), 'ferramenta': next((p['Ferramenta'] for p in perfis if p['Ferramenta']), None)}


# ------------------------------------------------------------------ serviços críticos
CRITICOS = [
    ('ssh|sshd', 'Acesso remoto SSH'), ('ufw|firewalld', 'Firewall'), ('apparmor', 'AppArmor (segurança)'),
    ('NetworkManager|systemd-networkd', 'Gerenciador de rede'), ('systemd-resolved', 'Resolvedor DNS'),
    ('systemd-timesyncd|chronyd|chrony|ntp', 'Sincronização de horário'), ('cups', 'Impressão (CUPS)'),
    ('cron|crond|cronie', 'Agendador de tarefas (cron)'), ('unattended-upgrades|dnf-automatic.timer', 'Atualizações automáticas'),
    ('rsyslog|systemd-journald', 'Registro de eventos'), ('bluetooth', 'Bluetooth'), ('avahi-daemon', 'Descoberta de rede (Avahi)'),
    ('smbd|smb', 'Compartilhamento Windows (Samba)'), ('clamav-daemon', 'Antivírus ClamAV'), ('clamav-freshclam', 'Atualização do ClamAV'),
    ('fail2ban', 'Fail2ban'), ('snapd', 'Snap'), ('gdm|gdm3|lightdm|sddm', 'Tela de login'), ('polkit', 'Autorização (polkit)'),
    ('udisks2', 'Discos removíveis'), ('accounts-daemon', 'Contas de usuário'), ('upower', 'Energia / bateria'),
    ('thermald', 'Controle térmico'), ('power-profiles-daemon|tuned', 'Perfis de energia'), ('xrdp', 'Área de Trabalho Remota (xrdp)'),
    ('docker', 'Docker'), ('libvirtd', 'Virtualização (libvirt)'),
]


def servicos():
    lista = []
    for nomes, desc in CRITICOS:
        for nome in nomes.split('|'):
            unidade = nome if '.' in nome else f'{nome}.service'
            props = dict(l.split('=', 1) for l in sh(['systemctl', 'show', unidade, '-p', 'LoadState,ActiveState,SubState,UnitFileState,Description']).splitlines() if '=' in l)
            if props.get('LoadState') != 'loaded':
                continue
            rodando = props.get('ActiveState') == 'active'
            lista.append({
                'Nome': unidade, 'Descricao': desc, 'Exibicao': props.get('Description'),
                'Status': {'active': 'Em execução', 'inactive': 'Parado', 'failed': 'Falhou', 'activating': 'Iniciando'}.get(props.get('ActiveState'), props.get('ActiveState')),
                'Inicializacao': {'enabled': 'Automático', 'disabled': 'Desabilitado', 'static': 'Estático', 'masked': 'Mascarado',
                                  'indirect': 'Indireto', 'enabled-runtime': 'Automático'}.get(props.get('UnitFileState'), props.get('UnitFileState') or '—'),
                'Rodando': rodando,
                'Falhou': props.get('ActiveState') == 'failed',
            })
            break
    return lista


# ------------------------------------------------------------------ processos
HZ = os.sysconf('SC_CLK_TCK')
BOOT = time.time() - uptime_seg()


def stat_proc(pid):
    try:
        with open(f'/proc/{pid}/stat') as f:
            s = f.read()
        resto = s[s.rindex(')') + 2:].split()
        return int(resto[11]) + int(resto[12]), int(resto[1]), int(resto[19])
    except Exception:
        return None


def processos():
    pids = [int(p) for p in os.listdir('/proc') if p.isdigit()]
    t0 = {p: stat_proc(p) for p in pids}
    time.sleep(0.5)
    ncpu = os.cpu_count() or 1
    lista = []
    for pid in pids:
        a, b = t0.get(pid), stat_proc(pid)
        if not a or not b:
            continue
        try:
            st = os.stat(f'/proc/{pid}')
            usuario = safe(lambda: pwd.getpwuid(st.st_uid).pw_name, str(st.st_uid))
            nome = ler(f'/proc/{pid}/comm') or '?'
            cmd = (ler(f'/proc/{pid}/cmdline') or '').replace('\x00', ' ').strip()
            if not cmd:
                continue  # threads do kernel
            exe = safe(lambda: os.readlink(f'/proc/{pid}/exe'))
            if not exe:
                arg0 = cmd.split(' ')[0]
                exe = arg0 if arg0.startswith('/') else shutil.which(arg0)
            rss = re.search(r'VmRSS:\s*(\d+)', ler(f'/proc/{pid}/status') or '')
            lista.append({
                'PID': pid, 'Nome': nome,
                'CPU': round((b[0] - a[0]) / HZ / 0.5 * 100 / ncpu, 1),
                'MemoriaMB': round(int(rss.group(1)) / 1024, 1) if rss else 0,
                'Caminho': (exe or '').replace(' (deleted)', '') or None,
                'Empresa': usuario,
                'Descricao': cmd[:120],
                'Linha': cmd,
                'PaiPID': b[1],
                'Inicio': fmt_data(BOOT + b[2] / HZ),
            })
        except Exception:
            continue
    return sorted(lista, key=lambda x: (-x['CPU'], -x['MemoriaMB']))


# ------------------------------------------------------------------ verificação de executáveis
def md5(path):
    import hashlib
    h = hashlib.md5()
    with open(path, 'rb') as f:
        for bloco in iter(lambda: f.read(1 << 20), b''):
            h.update(bloco)
    return h.hexdigest()


def assinaturas():
    caminhos = sorted({p['Caminho'] for p in processos() if p.get('Caminho')})
    out = []
    donos = {}
    if tem('dpkg-query'):
        for linha in sh(['dpkg-query', '-S'] + caminhos, timeout=60).splitlines():
            m = re.match(r'^([^:]+(?::[^:]+)?):\s+(/.+)$', linha)
            if m:
                donos[m.group(2)] = m.group(1).split(',')[0].strip()
    for c in caminhos:
        r = {'Caminho': c, 'Valida': False, 'Status': 'Fora de pacote', 'Emissor': ''}
        real = os.path.realpath(c)
        if c.startswith('/snap/') or real.startswith('/snap/'):
            r.update(Valida=True, Status='Snap (assinado)', Emissor='Snap Store')
        elif c.startswith(('/app/', '/var/lib/flatpak/')) or '/flatpak/' in real:
            r.update(Valida=True, Status='Flatpak', Emissor='Flatpak')
        elif '/.mount_' in c or c.endswith('.AppImage'):
            r.update(Status='AppImage (sem verificação)')
        else:
            pacote = donos.get(c) or donos.get(real)
            if not pacote and c.startswith('/usr/') and os.path.exists('/' + c[5:]):
                pacote = donos.get('/' + c[5:])  # /usr/bin x /bin (usrmerge)
            if pacote:
                nome_pkg = pacote.split(':')[0]
                arq = (glob.glob(f'/var/lib/dpkg/info/{nome_pkg}.md5sums') + glob.glob(f'/var/lib/dpkg/info/{nome_pkg}:*.md5sums') or [None])[0]
                esperado = None
                if arq:
                    for linha in (ler(arq) or '').splitlines():
                        h, _, f = linha.partition('  ')
                        if '/' + f in (c, real) or '/usr/' + f.lstrip('/') in (c, real) or '/' + f == '/' + real.lstrip('/'):
                            esperado = h
                            break
                atual = safe(lambda: md5(real))
                if esperado and atual:
                    ok = esperado == atual
                    r.update(Valida=ok, Status='Pacote oficial (íntegro)' if ok else 'ARQUIVO ALTERADO', Emissor=f'Pacote {nome_pkg}')
                else:
                    r.update(Valida=True, Status='Pacote oficial', Emissor=f'Pacote {nome_pkg}')
            elif tem('rpm'):
                pk = sh(['rpm', '-qf', c]).strip()
                if pk and 'not owned' not in pk:
                    alterado = bool(re.search(r'^..5', sh(['rpm', '-Vf', c]), re.M))
                    r.update(Valida=not alterado, Status='ARQUIVO ALTERADO' if alterado else 'Pacote oficial (íntegro)', Emissor=f'Pacote {pk}')
        out.append(r)
    return out


saida({'Protecao': protecao, 'Firewall': firewall, 'Servicos': servicos, 'Processos': processos, 'Assinaturas': assinaturas}[ACAO]())
