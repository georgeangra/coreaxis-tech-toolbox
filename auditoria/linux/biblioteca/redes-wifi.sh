#!/bin/bash
# .NOME Redes Wi-Fi
# .CATEGORIA Rede
# .DESCRICAO Redes próximas com sinal e canal, e redes salvas neste computador.
# .PERIGOSO Nao
# .ADMIN Nao
titulo "Redes Wi-Fi"
if ! tem nmcli; then erro "NetworkManager não encontrado."; exit 1; fi
printf 'Redes próximas:\n'; nmcli -f IN-USE,SSID,SIGNAL,BARS,CHAN,SECURITY device wifi list --rescan yes | sed 's/^/  /'
printf '\nRedes salvas:\n'; nmcli -f NAME,TYPE,AUTOCONNECT connection show | grep -i wireless | sed 's/^/  /'
