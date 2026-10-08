#!/bin/bash
# .NOME Limpar cache de pacotes
# .CATEGORIA Manutenção
# .DESCRICAO Apaga pacotes baixados e remove dependências órfãs.
# .PERIGOSO Sim
# .ADMIN Sim
titulo "Limpeza do cache de pacotes"
case $PM in
  apt) antes=$(du -sb /var/cache/apt/archives | cut -f1); executar apt-get clean
       DEBIAN_FRONTEND=noninteractive executar apt-get -y autoremove --purge
       printf '\n  Liberados no cache: %s\n' "$(mb "$antes")" ;;
  dnf) executar dnf clean all; executar dnf -y autoremove ;;
  *) info "Gerenciador de pacotes não suportado." ;;
esac
