<#
.NOME Reiniciar spooler e limpar fila de impressão
.CATEGORIA Impressão
.DESCRICAO Para o spooler, remove trabalhos travados da fila e inicia o serviço novamente.
.PERIGOSO Nao
#>
"Parando o spooler de impressão..."
Stop-Service Spooler -Force
$fila = "$env:SystemRoot\System32\spool\PRINTERS"
$n = @(Get-ChildItem $fila -File -ErrorAction SilentlyContinue).Count
Remove-Item "$fila\*" -Force -ErrorAction SilentlyContinue
"$n arquivo(s) removido(s) da fila."
Start-Service Spooler
"Spooler: $((Get-Service Spooler).Status)"
