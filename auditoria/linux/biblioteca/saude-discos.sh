#!/bin/bash
# .NOME Saúde dos discos (SMART)
# .CATEGORIA Diagnóstico
# .DESCRICAO Estado SMART, temperatura, horas ligado e desgaste de cada disco.
# .PERIGOSO Nao
# .ADMIN Sim
titulo "Saúde dos discos (SMART)"
if ! tem smartctl; then erro "smartmontools não instalado. No Ubuntu: sudo apt install smartmontools"; exit 1; fi
for d in $(lsblk -dn -o NAME,TYPE | awk '$2=="disk" {print $1}' | grep -vE '^(loop|zram|ram)'); do
  printf '\n--- /dev/%s ---\n' "$d"
  smartctl -H -i -A "/dev/$d" | grep -iE 'model|serial|capacity|result|temperature|power_on|percentage used|reallocated|pending|uncorrect|wear' | sed 's/^/  /'
done
