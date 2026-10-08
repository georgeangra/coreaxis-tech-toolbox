# CoreAxis Tech Toolbox (Linux) - Leitura de sensores de temperatura (hwmon / ACPI).
# Não exige senha: o kernel expõe os sensores em /sys/class/hwmon para qualquer usuário.

NOMES = {'coretemp': 'CPU', 'k10temp': 'CPU', 'zenpower': 'CPU', 'cpu_thermal': 'CPU', 'acpitz': 'Zona térmica ACPI',
         'nvme': 'Disco NVMe', 'drivetemp': 'Disco', 'amdgpu': 'GPU AMD', 'nouveau': 'GPU NVIDIA', 'radeon': 'GPU AMD',
         'iwlwifi_1': 'Wi-Fi', 'thinkpad': 'ThinkPad', 'dell_smm': 'Dell'}

lista = []
for h in sorted(glob.glob('/sys/class/hwmon/hwmon*')):
    nome = ler(f'{h}/name') or 'sensor'
    for t in sorted(glob.glob(f'{h}/temp*_input')):
        v = ler_int(t)
        if v is None or v <= 0 or v > 150000:
            continue
        rot = ler(t.replace('_input', '_label'))
        mx = ler_int(t.replace('_input', '_crit')) or ler_int(t.replace('_input', '_max'))
        base = NOMES.get(nome, nome)
        lista.append({'Sensor': f'{base}: {rot}' if rot else base, 'Celsius': round(v / 1000, 1),
                      'Max': round(mx / 1000) if mx else None, 'Origem': f'hwmon ({nome})'})
if not lista:
    for z in sorted(glob.glob('/sys/class/thermal/thermal_zone*')):
        v = ler_int(f'{z}/temp')
        if v and v > 0:
            lista.append({'Sensor': f'Zona térmica {ler(f"{z}/type") or os.path.basename(z)}', 'Celsius': round(v / 1000, 1), 'Origem': 'ACPI'})

# NVIDIA proprietário não usa hwmon
if tem('nvidia-smi'):
    for i, linha in enumerate(sh(['nvidia-smi', '--query-gpu=name,temperature.gpu', '--format=csv,noheader,nounits']).splitlines()):
        p = [x.strip() for x in linha.split(',')]
        if len(p) == 2 and p[1].isdigit():
            lista.append({'Sensor': f'GPU: {p[0]}', 'Celsius': int(p[1]), 'Origem': 'nvidia-smi'})

saida({'admin': eh_root(), 'sensores': lista})
