#!/bin/bash
# .NOME O que está ocupando o disco
# .CATEGORIA Desempenho
# .DESCRICAO Maiores pastas do usuário e do sistema.
# .PERIGOSO Nao
# .ADMIN Nao
titulo "Uso de disco"
df -h -x tmpfs -x devtmpfs -x squashfs | sed 's/^/  /'
printf '\nMaiores pastas em %s:\n' "$HOME_REAL"
du -h --max-depth=1 "$HOME_REAL" 2>/dev/null | sort -rh | head -15 | sed 's/^/  /'
printf '\nMaiores pastas em /var:\n'
du -h --max-depth=1 /var 2>/dev/null | sort -rh | head -10 | sed 's/^/  /'
