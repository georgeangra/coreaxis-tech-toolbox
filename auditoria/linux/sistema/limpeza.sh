#!/bin/bash
# CoreAxis Tech Toolbox (Linux) - Limpeza de arquivos temporários.
#   Itens do usuário: --Usuario (~/.cache) --Miniaturas --Navegadores --Lixeira
#   Itens do sistema (exigem senha): --Sistema (/tmp e /var/tmp antigos) --Pacotes (cache e órfãos)
#                                    --Logs (journal > 7 dias / 200 MB) --Snaps (revisões antigas)
#   --Simular : apenas calcula o espaço que seria liberado.

SIM=${ARG_Simular:-}
H=$HOME_REAL
TOTAL=0

alvo() {  # nome, caminhos...
  local nome=$1; shift
  local antes depois lib
  antes=$(tamanho "$@")
  if [ -n "$SIM" ]; then
    printf '  %-40s %12s\n' "$nome" "$(mb "$antes")"
    TOTAL=$((TOTAL + antes)); return
  fi
  for c in "$@"; do
    [ -d "$c" ] && find "$c" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null
    [ -f "$c" ] && rm -f "$c" 2>/dev/null
  done
  depois=$(tamanho "$@")
  lib=$((antes > depois ? antes - depois : 0))
  TOTAL=$((TOTAL + lib))
  printf '  %-40s %12s liberados\n' "$nome" "$(mb "$lib")"
}

if [ -n "$SIM" ]; then titulo 'Análise de arquivos temporários (simulação)'; else titulo 'Limpeza de arquivos temporários'; fi

[ -n "${ARG_Usuario:-}" ] && alvo "Cache de aplicativos ($USUARIO_REAL)" "$H/.cache/pip" "$H/.cache/yarn" "$H/.cache/npm" "$H/.cache/go-build" "$H/.cache/fontconfig" "$H/.cache/tracker3" "$H/.cache/gstreamer-1.0" "$H/.cache/vscode-cpptools" "$H/.cache/JetBrains"
[ -n "${ARG_Miniaturas:-}" ] && alvo 'Cache de miniaturas' "$H/.cache/thumbnails"
if [ -n "${ARG_Navegadores:-}" ]; then
  alvo 'Cache dos navegadores' "$H/.cache/google-chrome" "$H/.cache/chromium" "$H/.cache/BraveSoftware" "$H/.cache/microsoft-edge" "$H/.cache/mozilla" \
    "$H/snap/firefox/common/.cache" "$H/snap/chromium/common/.cache" "$H/.var/app/org.mozilla.firefox/cache" "$H/.var/app/com.google.Chrome/cache"
fi
[ -n "${ARG_Lixeira:-}" ] && alvo 'Lixeira' "$H/.local/share/Trash/files" "$H/.local/share/Trash/info"

if [ -n "${ARG_Sistema:-}" ]; then
  if [ -n "$SIM" ]; then
    t=$(find /tmp /var/tmp -mindepth 1 -type f -atime +7 -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {print s+0}')
    printf '  %-40s %12s\n' 'Temporários do sistema (> 7 dias)' "$(mb "$t")"; TOTAL=$((TOTAL + t))
  else
    t=$(find /tmp /var/tmp -mindepth 1 -type f -atime +7 -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {print s+0}')
    find /tmp /var/tmp -mindepth 1 -type f -atime +7 -delete 2>/dev/null
    printf '  %-40s %12s liberados\n' 'Temporários do sistema (> 7 dias)' "$(mb "$t")"; TOTAL=$((TOTAL + t))
  fi
fi

if [ -n "${ARG_Pacotes:-}" ]; then
  case $PM in
    apt)
      if [ -n "$SIM" ]; then
        alvo 'Cache de pacotes baixados (apt)' /var/cache/apt/archives
        orf=$(apt-get -s autoremove 2>/dev/null | grep -c '^Remv')
        info "Pacotes órfãos que seriam removidos: $orf"
      else
        antes=$(tamanho /var/cache/apt/archives)
        apt-get clean >/dev/null 2>&1
        DEBIAN_FRONTEND=noninteractive apt-get -y autoremove --purge 2>&1 | grep -E '^(Removing|Removendo|Purging|Expurgando)' | sed 's/^/    /'
        depois=$(tamanho /var/cache/apt/archives); lib=$((antes - depois)); TOTAL=$((TOTAL + lib))
        printf '  %-40s %12s liberados\n' 'Cache de pacotes e órfãos (apt)' "$(mb "$lib")"
      fi ;;
    dnf) if [ -n "$SIM" ]; then alvo 'Cache de pacotes (dnf)' /var/cache/dnf; else alvo 'Cache de pacotes (dnf)' /var/cache/dnf; dnf -y autoremove >/dev/null 2>&1; fi ;;
  esac
fi

if [ -n "${ARG_Logs:-}" ]; then
  antes=$(journalctl --disk-usage 2>/dev/null | grep -oE '[0-9.]+[KMGT]' | head -1)
  if [ -n "$SIM" ]; then
    printf '  %-40s %12s (atual)\n' 'Logs do sistema (journal)' "${antes:-?}"
  else
    journalctl --vacuum-time=7d --vacuum-size=200M >/dev/null 2>&1
    find /var/log -type f \( -name '*.gz' -o -name '*.[0-9]' -o -name '*.old' \) -delete 2>/dev/null
    depois=$(journalctl --disk-usage 2>/dev/null | grep -oE '[0-9.]+[KMGT]' | head -1)
    printf '  %-40s %12s → %s\n' 'Logs do sistema (journal)' "${antes:-?}" "${depois:-?}"
  fi
fi

if [ -n "${ARG_Snaps:-}" ] && tem snap; then
  revs=$(LANG=C snap list --all 2>/dev/null | awk '/disabled/{print $1, $3}')
  if [ -n "$SIM" ]; then
    n=$(printf '%s\n' "$revs" | grep -c .)
    info "Revisões antigas de Snaps que seriam removidas: $n"
  else
    printf '%s\n' "$revs" | while read -r nome rev; do [ -n "$nome" ] && snap remove "$nome" --revision="$rev" >/dev/null 2>&1 && info "Snap $nome (revisão $rev) removido"; done
  fi
fi

printf '\n  %s: %s\n' "$([ -n "$SIM" ] && echo 'Total que pode ser liberado' || echo 'Total liberado')" "$(mb "$TOTAL")"
