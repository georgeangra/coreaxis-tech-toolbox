#!/bin/bash
# .NOME Informações rápidas do computador
# .CATEGORIA Diagnóstico
# .DESCRICAO Nome, sistema, kernel, CPU, memória, discos e IPs em uma tela.
# .PERIGOSO Nao
# .ADMIN Nao
titulo "Informações rápidas"
. /etc/os-release
info "Computador : $(hostname)"
info "Sistema    : $PRETTY_NAME"
info "Kernel     : $(uname -r)"
info "Fabricante : $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null) $(cat /sys/class/dmi/id/product_name 2>/dev/null)"
info "CPU        : $(LC_ALL=C lscpu | sed -n 's/^Model name: *//p')"
info "Memória    : $(free -h | awk '/^Mem/{print $2" total, "$7" disponível"}')"
info "Ligado há  : $(uptime -p)"
printf '\nDiscos:\n'; lsblk -d -o NAME,SIZE,MODEL,TRAN | sed 's/^/  /'
printf '\nEspaço:\n'; df -h -x tmpfs -x devtmpfs -x squashfs -x overlay | sed 's/^/  /'
printf '\nEndereços IP:\n'; ip -br -4 addr | grep -v '^lo' | sed 's/^/  /'
