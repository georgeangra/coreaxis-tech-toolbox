#!/bin/bash
# .NOME Usuários locais
# .CATEGORIA Segurança
# .DESCRICAO Contas de usuário, administradores (sudo) e últimos acessos.
# .PERIGOSO Nao
# .ADMIN Nao
titulo "Usuários locais"
printf 'Contas de pessoas (UID >= 1000):\n'
getent passwd | awk -F: '$3>=1000 && $3<65534 {printf "  %-18s UID %-6s %s\n", $1, $3, $5}'
printf '\nAdministradores (grupos sudo/wheel):\n'
for g in sudo wheel admin; do getent group "$g" | cut -d: -f4 | tr , '\n' | sed '/^$/d;s/^/  /'; done
printf '\nÚltimos acessos:\n'; last -n 15 2>/dev/null | sed 's/^/  /'
