#!/bin/bash
# .NOME Relatório da bateria
# .CATEGORIA Diagnóstico
# .DESCRICAO Carga, saúde (capacidade atual x projeto), ciclos e fabricante.
# .PERIGOSO Nao
# .ADMIN Nao
titulo "Bateria"
if ! ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then info "Nenhuma bateria encontrada (desktop)."; exit 0; fi
if tem upower; then upower -i "$(upower -e | grep -m1 BAT)" | sed 's/^/  /'; fi
for b in /sys/class/power_supply/BAT*; do
  d=$(cat "$b/energy_full_design" 2>/dev/null || cat "$b/charge_full_design" 2>/dev/null)
  c=$(cat "$b/energy_full" 2>/dev/null || cat "$b/charge_full" 2>/dev/null)
  [ -n "$d" ] && [ -n "$c" ] && printf '\n  Saúde de %s: %s%%  (ciclos: %s)\n' "$(basename "$b")" "$((c * 100 / d))" "$(cat "$b/cycle_count" 2>/dev/null || echo ?)"
done
