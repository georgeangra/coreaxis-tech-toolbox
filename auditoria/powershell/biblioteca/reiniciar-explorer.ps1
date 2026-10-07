<#
.NOME Reiniciar Windows Explorer
.CATEGORIA Sistema
.DESCRICAO Reinicia o explorer.exe (barra de tarefas ou área de trabalho travadas).
.PERIGOSO Nao
#>
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2
if (-not (Get-Process explorer -ErrorAction SilentlyContinue)) { Start-Process explorer.exe }
"Windows Explorer reiniciado."
