#!/bin/bash
# .NOME Listar impressoras
# .CATEGORIA Impressão
# .DESCRICAO Impressoras instaladas, padrão, status e fila de impressão (CUPS).
# .PERIGOSO Nao
# .ADMIN Nao
titulo "Impressoras (CUPS)"
if ! tem lpstat; then erro "CUPS não instalado."; exit 1; fi
lpstat -t 2>&1 | sed 's/^/  /'
