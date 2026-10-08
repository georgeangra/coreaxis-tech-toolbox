#!/bin/bash
# .NOME Programas instalados
# .CATEGORIA Inventário
# .DESCRICAO Pacotes instalados manualmente, Snaps e Flatpaks.
# .PERIGOSO Nao
# .ADMIN Nao
titulo "Programas instalados"
if tem apt-mark; then printf '\nPacotes APT instalados manualmente (%s):\n' "$(apt-mark showmanual | wc -l)"; apt-mark showmanual | column | sed 's/^/  /'; fi
if tem rpm && ! tem apt-mark; then printf '\nPacotes RPM (%s):\n' "$(rpm -qa | wc -l)"; rpm -qa --qf '%{NAME}\n' | sort | column | sed 's/^/  /'; fi
if tem snap; then printf '\nSnaps:\n'; snap list | sed 's/^/  /'; fi
if tem flatpak; then printf '\nFlatpaks:\n'; flatpak list --app --columns=name,version,origin | sed 's/^/  /'; fi
