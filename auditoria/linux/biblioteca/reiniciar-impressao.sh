#!/bin/bash
# .NOME Reiniciar serviço de impressão
# .CATEGORIA Impressão
# .DESCRICAO Cancela a fila travada e reinicia o CUPS.
# .PERIGOSO Sim
# .ADMIN Sim
titulo "Reiniciando o serviço de impressão"
executar cancel -a 2>/dev/null
executar systemctl restart cups
sleep 2
if systemctl is-active -q cups; then ok "CUPS em execução."; else erro "CUPS não iniciou."; fi
lpstat -p 2>/dev/null | sed 's/^/  /'
