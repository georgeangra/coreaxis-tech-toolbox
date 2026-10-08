# CoreAxis Tech Toolbox (Linux) - funções comuns dos scripts Bash.
# Concatenado ANTES de cada script pelo aplicativo (conteúdo conferido por SHA-256 e enviado ao
# bash pela entrada padrão). Os parâmetros chegam como "--Nome valor" e ficam em ARG_Nome.

export LC_NUMERIC=C
set -o pipefail

while [ $# -gt 0 ]; do
  case "$1" in
    --*)
      _k="${1#--}"
      if [ $# -gt 1 ] && [ "${2#--}" = "$2" ]; then printf -v "ARG_$_k" '%s' "$2"; shift 2
      else printf -v "ARG_$_k" '%s' 1; shift; fi ;;
    *) shift ;;
  esac
done

titulo() {
  local linha; linha=$(printf '%*s' 64 '' | tr ' ' '=')
  printf '\n%s\n  %s\n  %s\n%s\n' "$linha" "$1" "$(date '+%d/%m/%Y %H:%M:%S')" "$linha"
}
info()  { printf '  %s\n' "$*"; }
ok()    { printf '  [OK] %s\n' "$*"; }
aviso() { printf '  [ATENÇÃO] %s\n' "$*"; }
erro()  { printf '  [ERRO] %s\n' "$*" >&2; }
tem()   { command -v "$1" >/dev/null 2>&1; }
eh_root() { [ "$(id -u)" -eq 0 ]; }
exigir_root() { eh_root || { erro 'Esta ação precisa de privilégios de administrador.'; exit 77; }; }

# Usuário que abriu o programa (mesmo quando elevado por pkexec/sudo)
if [ -n "${PKEXEC_UID:-}" ]; then USUARIO_REAL=$(getent passwd "$PKEXEC_UID" | cut -d: -f1)
elif [ -n "${SUDO_USER:-}" ]; then USUARIO_REAL=$SUDO_USER
else USUARIO_REAL=$(id -un); fi
HOME_REAL=$(getent passwd "$USUARIO_REAL" | cut -d: -f6)

# Gerenciador de pacotes
if tem apt-get; then PM=apt
elif tem dnf; then PM=dnf
elif tem zypper; then PM=zypper
elif tem pacman; then PM=pacman
else PM=; fi

# Executa um comando mostrando-o antes (como o "Executar" da versão Windows) e devolve o código
executar() {
  printf '\n$ %s\n' "$*"
  "$@"
  local rc=$?
  [ $rc -eq 0 ] || printf '  (código de saída %s)\n' "$rc"
  return $rc
}

mb() { awk -v b="${1:-0}" 'BEGIN { printf "%.1f MB", b/1048576 }'; }
tamanho() { local t=0 s; for c in "$@"; do [ -e "$c" ] && s=$(du -sb "$c" 2>/dev/null | awk '{print $1}') && t=$((t + ${s:-0})); done; echo "$t"; }
