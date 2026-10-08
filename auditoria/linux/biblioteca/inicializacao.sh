#!/bin/bash
# .NOME Programas na inicialização
# .CATEGORIA Desempenho
# .DESCRICAO Serviços habilitados no boot e aplicativos que abrem com a sessão.
# .PERIGOSO Nao
# .ADMIN Nao
titulo "Inicialização"
printf 'Serviços habilitados:\n'; systemctl list-unit-files --type=service --state=enabled --no-pager --no-legend | awk '{print "  "$1}'
printf '\nAplicativos da sessão (autostart):\n'
for d in "$HOME_REAL/.config/autostart" /etc/xdg/autostart; do
  for f in "$d"/*.desktop; do [ -f "$f" ] && printf '  %-45s %s\n' "$(sed -n 's/^Name=//p' "$f" | head -1)" "$f"; done
done
printf '\nTempo de inicialização:\n'; systemd-analyze 2>/dev/null | sed 's/^/  /'; systemd-analyze blame 2>/dev/null | head -10 | sed 's/^/  /'
