#!/bin/bash
# CoreAxis Tech Toolbox (Linux) - Cache DNS e reset de rede (executado com senha).
#   --Acao FlushDNS            : limpa o cache do resolvedor (systemd-resolved / nscd / dnsmasq)
#   --Acao Reset [--Completo]  : reinicia a rede; com --Completo reinicia o NetworkManager e renova o DHCP

case "${ARG_Acao:-FlushDNS}" in
  FlushDNS)
    titulo 'Limpeza do cache DNS'
    feito=
    if tem resolvectl && systemctl is-active -q systemd-resolved; then
      executar resolvectl statistics 2>/dev/null | grep -iE 'current cache size|cache' | head -3
      executar resolvectl flush-caches && ok 'Cache do systemd-resolved limpo.' && feito=1
    fi
    if systemctl is-active -q nscd 2>/dev/null; then executar nscd -i hosts && ok 'Cache do nscd limpo.' && feito=1; fi
    if systemctl is-active -q dnsmasq 2>/dev/null; then executar systemctl restart dnsmasq && ok 'dnsmasq reiniciado.' && feito=1; fi
    [ -n "$feito" ] || info 'Nenhum cache DNS local ativo (as consultas vão direto ao servidor DNS).' ;;
  Reset)
    titulo 'Reset de rede'
    if tem nmcli; then
      if [ -n "${ARG_Completo:-}" ]; then
        executar systemctl restart NetworkManager
        sleep 4
        for c in $(nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2 ~ /ethernet|wireless/ {print $1}'); do
          executar nmcli connection up "$c"
        done
      else
        executar nmcli networking off; sleep 3; executar nmcli networking on
      fi
      sleep 3
      executar nmcli -t -f DEVICE,STATE,CONNECTION device
    elif tem networkctl; then
      executar systemctl restart systemd-networkd
      executar networkctl status --no-pager | head -20
    else
      erro 'Nem NetworkManager nem systemd-networkd encontrados.'; exit 1
    fi
    tem resolvectl && resolvectl flush-caches 2>/dev/null
    ok 'Rede reiniciada.' ;;
  *) erro 'Ação inválida'; exit 2 ;;
esac
