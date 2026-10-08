#!/bin/bash
# .NOME Sincronizar data e hora
# .CATEGORIA Manutenção
# .DESCRICAO Ativa o NTP e força a sincronização do relógio.
# .PERIGOSO Nao
# .ADMIN Sim
titulo "Sincronização de horário"
executar timedatectl set-ntp true
systemctl restart systemd-timesyncd 2>/dev/null || systemctl restart chronyd 2>/dev/null
sleep 3
timedatectl | sed 's/^/  /'
