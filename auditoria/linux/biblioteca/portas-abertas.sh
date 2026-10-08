#!/bin/bash
# .NOME Portas abertas
# .CATEGORIA Rede
# .DESCRICAO Portas TCP/UDP em escuta e o programa responsável.
# .PERIGOSO Nao
# .ADMIN Sim
titulo "Portas em escuta"
ss -tulpn | sed 's/^/  /'
