#!/bin/bash
# CoreAxis Tech Toolbox (Linux) - Ações de drivers (executado com senha).
#   --Acao Recomendados : instala os drivers proprietários recomendados (ubuntu-drivers)
#   --Acao Firmware     : busca e aplica atualizações de firmware (fwupd / LVFS)
#   --Acao Reescanear   : redetecta o hardware (udev)

case "${ARG_Acao:-Reescanear}" in
  Recomendados)
    titulo 'Drivers recomendados'
    if tem ubuntu-drivers; then
      executar ubuntu-drivers devices
      executar ubuntu-drivers install && aviso 'Reinicie o computador para carregar os novos drivers.'
    else
      info 'ubuntu-drivers não disponível nesta distribuição. Use o utilitário de drivers da sua distribuição.'
    fi ;;
  Firmware)
    titulo 'Atualização de firmware (fwupd)'
    if tem fwupdmgr; then
      executar fwupdmgr refresh --force
      executar fwupdmgr get-updates
      executar fwupdmgr update -y --no-reboot-check
    else
      info 'fwupd não instalado. No Ubuntu: sudo apt install fwupd'
    fi ;;
  Reescanear)
    titulo 'Procurando alterações de hardware'
    executar udevadm trigger --action=add
    executar udevadm settle --timeout=20
    ok 'Hardware redetectado.'
    executar lsusb ;;
  *) erro 'Ação inválida'; exit 2 ;;
esac
