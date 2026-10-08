#!/bin/bash
# CoreAxis Tech Toolbox (Linux) - Atualizações do sistema (equivalente ao Windows Update).
#   --Acao Buscar | Instalar | Historico | Reparar | Apps   (executado com senha)

ACAO=${ARG_Acao:-Buscar}
export DEBIAN_FRONTEND=noninteractive

case "$ACAO" in
  Buscar)
    titulo 'Buscando atualizações'
    case $PM in
      apt) executar apt-get update
           printf '\nPacotes que podem ser atualizados:\n'
           apt list --upgradable 2>/dev/null | sed '1d'
           n=$(apt list --upgradable 2>/dev/null | sed '1d' | grep -c .)
           printf '\nTotal: %s pacote(s).\n' "$n"
           [ -f /var/run/reboot-required ] && aviso 'Reinicialização pendente de uma atualização anterior.' ;;
      dnf) executar dnf -y makecache; executar dnf check-update ;;
      zypper) executar zypper --non-interactive refresh; executar zypper list-updates ;;
      pacman) executar pacman -Sy; executar pacman -Qu ;;
      *) erro 'Gerenciador de pacotes não reconhecido.'; exit 1 ;;
    esac ;;
  Instalar)
    titulo 'Instalando atualizações'
    case $PM in
      apt) executar apt-get update && executar apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold dist-upgrade
           executar apt-get -y autoremove ;;
      dnf) executar dnf -y upgrade --refresh ;;
      zypper) executar zypper --non-interactive update ;;
      pacman) executar pacman -Syu --noconfirm ;;
    esac
    rc=$?
    if [ -f /var/run/reboot-required ]; then aviso 'Reinicie o computador para concluir as atualizações.'; fi
    exit $rc ;;
  Apps)
    titulo 'Atualizando aplicativos Snap e Flatpak'
    if tem snap; then executar snap refresh; else info 'Snap não instalado.'; fi
    if tem flatpak; then executar flatpak update -y --noninteractive; else info 'Flatpak não instalado.'; fi ;;
  Historico)
    titulo 'Histórico de atualizações'
    if [ -f /var/log/apt/history.log ]; then
      { zcat -f /var/log/apt/history.log.*.gz 2>/dev/null; cat /var/log/apt/history.log; } \
        | awk '/^Start-Date/{d=$2" "$3} /^(Upgrade|Install|Remove):/{n=gsub(/\),/,"&"); print d"  "$1" "n+1" pacote(s)"}' | tail -40
    elif tem dnf; then dnf history list | head -40
    else info 'Histórico não disponível.'; fi ;;
  Reparar)
    titulo 'Reparo do gerenciador de pacotes'
    case $PM in
      apt) executar rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock /var/lib/dpkg/lock-frontend
           executar dpkg --configure -a
           executar apt-get clean
           executar apt-get update --fix-missing
           executar apt-get -y -f install ;;
      dnf) executar dnf clean all; executar rpm --rebuilddb; executar dnf -y makecache ;;
      *) executar true ;;
    esac ;;
  *) erro "Ação inválida: $ACAO"; exit 2 ;;
esac
