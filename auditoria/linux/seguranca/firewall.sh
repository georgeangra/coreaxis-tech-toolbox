#!/bin/bash
# CoreAxis Tech Toolbox (Linux) - Ativar / desativar o firewall (executado com senha).
#   --Acao Ativar | Desativar | Instalar

case "${ARG_Acao:-}" in
  Ativar)
    if tem ufw; then
      ufw --force enable && ok 'UFW ativado (entrada bloqueada por padrão, saída liberada).'
      ufw status verbose
    elif tem firewall-cmd; then
      systemctl enable --now firewalld && ok 'firewalld ativado.'
      firewall-cmd --state
    else erro 'Nenhum firewall instalado. Use "Instalar UFW".'; exit 1; fi ;;
  Desativar)
    if tem ufw; then ufw disable && aviso 'UFW desativado.'
    elif tem firewall-cmd; then systemctl disable --now firewalld && aviso 'firewalld desativado.'
    fi ;;
  Instalar)
    case $PM in
      apt) DEBIAN_FRONTEND=noninteractive apt-get install -y ufw ;;
      dnf) dnf install -y firewalld ;;
      *) erro 'Instale um firewall pelo gerenciador de pacotes da distribuição.'; exit 1 ;;
    esac ;;
  *) erro 'Ação inválida'; exit 2 ;;
esac
