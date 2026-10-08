#!/bin/bash
# .NOME Perfil de energia
# .CATEGORIA Desempenho
# .DESCRICAO Mostra o perfil de energia ativo (economia, equilibrado, desempenho).
# .PERIGOSO Nao
# .ADMIN Nao
titulo "Perfil de energia"
if tem powerprofilesctl; then powerprofilesctl list | sed 's/^/  /'
elif tem tlp-stat; then tlp-stat -s | sed 's/^/  /'
elif tem tuned-adm; then tuned-adm active; tuned-adm list
else info "Nenhum gerenciador de perfis de energia encontrado."; fi
printf '\nGovernador da CPU: %s\n' "$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo indisponível)"
