#!/bin/bash
# .NOME Erros recentes do sistema
# .CATEGORIA Diagnóstico
# .DESCRICAO Mensagens de erro e críticas do log do sistema desde a última inicialização.
# .PERIGOSO Nao
# .ADMIN Nao
titulo "Erros desde a última inicialização"
journalctl -b -p 3 --no-pager -q -o short-iso | tail -n 80
printf '\nResumo por origem:\n'
journalctl -b -p 3 --no-pager -q -o json 2>/dev/null | grep -o '"SYSLOG_IDENTIFIER":"[^"]*"' | cut -d'"' -f4 | sort | uniq -c | sort -rn | head -15 | sed 's/^/  /'
