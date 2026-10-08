#!/bin/bash
# .NOME Atualizar Snaps e Flatpaks
# .CATEGORIA Manutenção
# .DESCRICAO Atualiza todos os aplicativos Snap e Flatpak.
# .PERIGOSO Nao
# .ADMIN Sim
titulo "Atualização de aplicativos"
tem snap && executar snap refresh
tem flatpak && executar flatpak update -y --noninteractive
ok "Concluído."
