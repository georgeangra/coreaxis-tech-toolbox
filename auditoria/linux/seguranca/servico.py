# CoreAxis Tech Toolbox (Linux) - Iniciar / parar / reiniciar um serviço systemd (executado com senha).
#   --Nome unidade.service   --Acao Iniciar | Parar | Reiniciar

A = args()
nome, acao = A.get('Nome', ''), A.get('Acao', '')
cmd = {'Iniciar': 'start', 'Parar': 'stop', 'Reiniciar': 'restart'}.get(acao)
if not re.fullmatch(r'[A-Za-z0-9@._-]{1,120}\.(service|timer|socket)', nome) or not cmd:
    saida({'ok': False, 'erro': 'Serviço ou ação inválida'})
    sys.exit(0)
r = subprocess.run(['systemctl', cmd, nome], capture_output=True, text=True, timeout=90, env=ENV_C)
estado = sh(['systemctl', 'is-active', nome]).strip()
saida({'ok': r.returncode == 0, 'erro': (r.stderr or '').strip()[:400],
       'status': {'active': 'Em execução', 'inactive': 'Parado', 'failed': 'Falhou'}.get(estado, estado)})
