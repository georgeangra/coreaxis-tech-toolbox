#!/bin/bash
# CoreAxis Tech Toolbox (Linux) - Reparo do sistema (equivalentes ao SFC/DISM do Windows).
#   --Modo Verificar : confere os arquivos instalados contra os hashes registrados pelos pacotes
#   --Modo Pacotes   : conclui instalações interrompidas e corrige dependências quebradas
#   --Modo Completo  : as duas etapas
# Executado com senha.

MODO=${ARG_Modo:-Verificar}

verificar() {
  titulo 'Verificação de integridade dos arquivos do sistema'
  case $PM in
    apt)
      info 'Conferindo os arquivos de todos os pacotes instalados (pode levar alguns minutos)...'
      saida=$(dpkg --verify 2>&1)
      # Arquivos de configuração alterados (c) são esperados; binários alterados (sem "c") são suspeitos
      bin=$(printf '%s\n' "$saida" | awk '$1 ~ /5/ && $2 != "c" { print }')
      cfg=$(printf '%s\n' "$saida" | awk '$1 ~ /5/ && $2 == "c"' | grep -c .)
      if [ -n "$bin" ]; then
        aviso 'Arquivos de programas diferentes do original do pacote:'
        printf '%s\n' "$bin" | awk '{print "    " $NF}'
        printf '\n'
        info 'Reinstale os pacotes indicados (Reparo → Pacotes) ou investigue.'
        printf '%s\n' "$bin" | awk '{print $NF}' | xargs -r dpkg -S 2>/dev/null | cut -d: -f1 | sort -u | sed 's/^/    pacote: /'
      else
        ok 'Nenhum arquivo de programa alterado.'
      fi
      info "Arquivos de configuração personalizados: ${cfg:-0} (normal)"
      executar dpkg --audit && ok 'Banco de dados de pacotes consistente.' ;;
    dnf)
      info 'Conferindo os arquivos de todos os pacotes (rpm -Va)...'
      rpm -Va 2>/dev/null | grep -E '^..5' | grep -v ' c /' || ok 'Nenhum arquivo de programa alterado.' ;;
    *) info 'Verificação não suportada nesta distribuição.' ;;
  esac
}

pacotes() {
  titulo 'Reparo de pacotes e dependências'
  export DEBIAN_FRONTEND=noninteractive
  case $PM in
    apt) executar dpkg --configure -a
         executar apt-get -y -f install
         executar apt-get -y check ;;
    dnf) executar dnf -y distro-sync ;;
    zypper) executar zypper --non-interactive verify ;;
    *) info 'Reparo não suportado nesta distribuição.' ;;
  esac
}

case "$MODO" in
  Verificar) verificar ;;
  Pacotes) pacotes ;;
  Completo) pacotes; verificar ;;
  *) erro "Modo inválido: $MODO"; exit 2 ;;
esac
