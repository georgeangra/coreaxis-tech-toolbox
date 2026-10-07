<#
.NOME Sincronizar data e hora (NTP.br)
.CATEGORIA Sistema
.DESCRICAO Configura os servidores do NTP.br e força a sincronização do relógio do Windows.
.PERIGOSO Nao
#>
Set-Service W32Time -StartupType Automatic
Start-Service W32Time
Executar w32tm.exe '/config /manualpeerlist:"a.st1.ntp.br b.st1.ntp.br pool.ntp.br" /syncfromflags:manual /update'
Executar w32tm.exe '/resync /force'
""
Executar w32tm.exe '/query /status'
