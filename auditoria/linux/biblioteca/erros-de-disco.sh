#!/bin/bash
# .NOME Erros de disco e sistema de arquivos
# .CATEGORIA Diagnóstico
# .DESCRICAO Procura erros de leitura/gravação (I/O) e de sistema de arquivos no log do kernel.
# .PERIGOSO Nao
# .ADMIN Nao
titulo "Erros de disco no log do kernel"
erros=$(journalctl -k -b --no-pager -q | grep -iE 'i/o error|ata[0-9.]+: .*(error|failed)|nvme.*(error|timeout)|ext4-fs error|btrfs.*error|xfs.*error|medium error|bad sector' | tail -40)
if [ -n "$erros" ]; then aviso 'Erros encontrados:'; printf '%s\n' "$erros"; else ok 'Nenhum erro de disco registrado desde a inicialização.'; fi
printf '\nUso dos discos:\n'; df -h -x tmpfs -x devtmpfs -x squashfs | sed 's/^/  /'
