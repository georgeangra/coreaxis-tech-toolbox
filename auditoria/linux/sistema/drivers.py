# CoreAxis Tech Toolbox (Linux) - Drivers (JSON): dispositivos PCI/USB, driver do kernel em uso,
# dispositivos SEM driver e drivers proprietários recomendados (ubuntu-drivers).

def pci():
    lista = []
    for dev in sorted(glob.glob('/sys/bus/pci/devices/*')):
        slot = os.path.basename(dev)
        partes = re.findall(r'"([^"]*)"', sh(['lspci', '-mm', '-s', slot]))
        if len(partes) < 3:
            continue
        drv = os.path.basename(os.path.realpath(f'{dev}/driver')) if os.path.exists(f'{dev}/driver') else None
        lista.append({'Dispositivo': partes[2], 'Classe': partes[0], 'Fabricante': partes[1], 'Barramento': 'PCI', 'Slot': slot, 'Driver': drv})
    return lista


def usb():
    lista = []
    for dev in sorted(glob.glob('/sys/bus/usb/devices/*')):
        if ':' in os.path.basename(dev) or not os.path.exists(f'{dev}/idVendor'):
            continue
        if ler(f'{dev}/bDeviceClass') == '09':
            continue  # hubs
        drvs = set()
        for itf in glob.glob(f'{dev}/*:*'):
            if os.path.exists(f'{itf}/driver'):
                drvs.add(os.path.basename(os.path.realpath(f'{itf}/driver')))
        lista.append({'Dispositivo': ler(f'{dev}/product') or f'{ler(f"{dev}/idVendor")}:{ler(f"{dev}/idProduct")}',
                      'Classe': 'USB', 'Fabricante': ler(f'{dev}/manufacturer') or '', 'Barramento': 'USB',
                      'Slot': os.path.basename(dev), 'Driver': ', '.join(sorted(drvs)) or None})
    return lista


def versao(drv):
    if not drv:
        return None
    v = ler(f'/sys/module/{drv}/version')
    return v or ('kernel ' + platform.release())


def recomendados():
    if not tem('ubuntu-drivers'):
        return []
    out = []
    for linha in sh(['ubuntu-drivers', 'devices'], timeout=60).splitlines():
        m = re.match(r'^driver\s*:\s*(\S+)\s+-\s+(.*)$', linha.strip())
        if m:
            out.append({'Pacote': m.group(1), 'Detalhe': m.group(2), 'Recomendado': 'recommended' in m.group(2)})
    return out


devs = pci() + usb()
drivers = [{**d, 'Versao': versao(d['Driver']), 'Data': None, 'Assinado': True} for d in devs if d['Driver']]
problemas = [{'Nome': d['Dispositivo'], 'Classe': d['Classe'], 'Codigo': 'sem driver',
              'Descricao': f'{d["Fabricante"]} · {d["Barramento"]} {d["Slot"]}'} for d in devs if not d['Driver'] and d['Barramento'] == 'PCI'
             and not re.search(r'bridge|host|isa|smbus|signal processing|communication controller|system peripheral', d['Classe'], re.I)]
falta_firmware = sorted(set(re.findall(r'firmware: failed to load (\S+)', sh(['journalctl', '-k', '-b', '--no-pager', '-q'], timeout=20))))
for f in falta_firmware[:10]:
    problemas.append({'Nome': f, 'Classe': 'Firmware', 'Codigo': 'firmware ausente', 'Descricao': 'Instale o pacote linux-firmware atualizado'})

saida({'drivers': drivers, 'problemas': problemas, 'recomendados': recomendados(), 'kernel': platform.release()})
