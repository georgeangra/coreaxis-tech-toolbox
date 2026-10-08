# CoreAxis Tech Toolbox (Linux) - Identificação do dispositivo para licenciamento (JSON).
#   --Caminho : pasta onde está o programa (AppImage)
# Pendrive: fabricante (VID), produto (PID) e número de série gravados no hardware USB — os MESMOS
#           dados usados pela versão Windows, portanto o código CX-P-… do pendrive é o mesmo nos dois.
# PC: número de série do disco onde o Linux está instalado (não muda ao reinstalar o sistema);
#     /etc/machine-id como alternativa (máquinas virtuais sem número de série de disco).

A = args()
caminho = A.get('Caminho') or ''
r = {'caminho': caminho, 'usb': None, 'pc': None}


def disco_de(caminho):
    """Dispositivo de bloco (disco inteiro) e ponto de montagem que contém o caminho."""
    alvo = sh(['findmnt', '-n', '-o', 'SOURCE,TARGET', '-T', caminho]).split()
    if len(alvo) < 2 or not alvo[0].startswith('/dev/'):
        return None, None
    origem = alvo[0].split('[')[0]
    pai = sh(['lsblk', '-n', '-d', '-o', 'PKNAME', origem]).strip()
    return (f'/dev/{pai}' if pai else origem), alvo[1]


if caminho:
    disco, montagem = disco_de(caminho)
    if disco:
        p = udev_props(nome=disco)
        if p.get('ID_BUS') == 'usb':
            r['usb'] = {
                'modelo': ' '.join(x for x in (p.get('ID_VENDOR'), p.get('ID_MODEL')) if x).replace('_', ' '),
                'vid': (p.get('ID_VENDOR_ID') or '').upper(),
                'pid': (p.get('ID_MODEL_ID') or '').upper(),
                'serie': (p.get('ID_SERIAL_SHORT') or '').strip(),
                'tamanho': ler_int(f'/sys/class/block/{os.path.basename(disco)}/size', 0) * 512,
                'montagem': montagem,
            }

raiz, _ = disco_de('/')
serie_disco = ''
if raiz:
    p = udev_props(nome=raiz)
    if p.get('ID_BUS') != 'usb':
        serie_disco = (p.get('ID_SERIAL_SHORT') or p.get('ID_WWN') or '').strip()

r['pc'] = {
    'nome': socket.gethostname(),
    'disco': serie_disco,
    'machineId': ler('/etc/machine-id') or ler('/var/lib/dbus/machine-id') or '',
}
saida(r)
