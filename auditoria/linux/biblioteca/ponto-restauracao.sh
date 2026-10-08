#!/bin/bash
# .NOME Criar ponto de restauração
# .CATEGORIA Manutenção
# .DESCRICAO Cria um snapshot do sistema com o Timeshift (se instalado).
# .PERIGOSO Nao
# .ADMIN Sim
titulo "Ponto de restauração (Timeshift)"
if ! tem timeshift; then info "Timeshift não instalado. No Ubuntu: sudo apt install timeshift"; exit 1; fi
executar timeshift --create --comments "CoreAxis Tech Toolbox $(date +%d/%m/%Y)" --scripted
timeshift --list | tail -8 | sed 's/^/  /'
