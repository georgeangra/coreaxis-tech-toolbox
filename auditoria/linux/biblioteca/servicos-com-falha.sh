#!/bin/bash
# .NOME Serviços com falha
# .CATEGORIA Diagnóstico
# .DESCRICAO Lista os serviços systemd que falharam e o motivo.
# .PERIGOSO Nao
# .ADMIN Nao
titulo "Serviços com falha"
n=$(systemctl --failed --no-legend | grep -c .)
if [ "$n" -eq 0 ]; then ok "Nenhum serviço com falha."; else
  systemctl --failed --no-pager
  for u in $(systemctl --failed --no-legend --plain | awk '{print $1}'); do printf '\n--- %s ---\n' "$u"; journalctl -u "$u" -b --no-pager -q -n 8; done
fi
