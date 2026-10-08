#!/bin/bash
# CoreAxis Tech Toolbox (Linux) - Antivírus ClamAV (executado com senha).
#   --Acao Rapida    : pastas mais visadas (Downloads, Área de Trabalho, /tmp, autostart)
#   --Acao Completa  : todo o sistema (exceto /proc, /sys, /dev, /run, /snap)
#   --Acao Atualizar : atualiza as assinaturas (freshclam)
#   --Acao Instalar  : instala o ClamAV pelo gerenciador de pacotes

LOG=/var/log/clamav/coreaxis-$(date +%Y%m%d-%H%M%S).log
H=$HOME_REAL

precisa_clam() { tem clamscan || { erro 'ClamAV não instalado. Use "Instalar ClamAV".'; exit 1; }; }

case "${ARG_Acao:-Rapida}" in
  Instalar)
    titulo 'Instalação do ClamAV'
    case $PM in
      apt) DEBIAN_FRONTEND=noninteractive executar apt-get install -y clamav clamav-daemon clamav-freshclam ;;
      dnf) executar dnf install -y clamav clamav-update clamd ;;
      zypper) executar zypper --non-interactive install clamav ;;
      pacman) executar pacman -S --noconfirm clamav ;;
    esac
    systemctl enable --now clamav-freshclam 2>/dev/null
    ok 'ClamAV instalado. A primeira atualização de assinaturas pode levar alguns minutos.' ;;
  Atualizar)
    precisa_clam
    titulo 'Atualização das assinaturas'
    if systemctl is-active -q clamav-freshclam; then
      systemctl stop clamav-freshclam; executar freshclam; systemctl start clamav-freshclam
    else executar freshclam; fi ;;
  Rapida|Completa)
    precisa_clam
    mkdir -p /var/log/clamav
    if [ "$ARG_Acao" = Completa ]; then
      titulo 'Verificação completa (ClamAV)'
      alvos=(/)
      extra=(--exclude-dir='^/(proc|sys|dev|run|snap|var/lib/docker)' --max-filesize=200M --max-scansize=400M)
    else
      titulo 'Verificação rápida (ClamAV)'
      alvos=()
      for d in "$H/Downloads" "$H/Transferências" "$H/Desktop" "$H/Área de Trabalho" "$H/.config/autostart" "$H/.local/bin" /tmp /var/tmp /dev/shm; do
        [ -e "$d" ] && alvos+=("$d")
      done
      extra=(--max-filesize=100M)
    fi
    info "Pastas: ${alvos[*]}"
    info "Relatório: $LOG"
    printf '\n'
    clamscan -r -i "${extra[@]}" --log="$LOG" "${alvos[@]}" 2>/dev/null
    rc=$?
    printf '\n'
    case $rc in
      0) ok 'Nenhuma ameaça encontrada.' ;;
      1) aviso 'AMEAÇAS ENCONTRADAS (listadas acima). Os arquivos NÃO foram apagados — avalie e remova manualmente.' ;;
      *) erro "A verificação terminou com erro (código $rc)." ;;
    esac
    exit $([ $rc -le 1 ] && echo 0 || echo $rc) ;;
  *) erro 'Ação inválida'; exit 2 ;;
esac
