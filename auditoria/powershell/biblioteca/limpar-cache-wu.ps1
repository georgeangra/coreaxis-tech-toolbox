<#
.NOME Limpar cache do Windows Update
.CATEGORIA Manutenção
.DESCRICAO Para os serviços de atualização e apaga a pasta SoftwareDistribution\Download.
.PERIGOSO Sim
#>
Stop-Service wuauserv, bits -Force
$p = "$env:SystemRoot\SoftwareDistribution\Download"
$tam = (Get-ChildItem $p -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
Remove-Item "$p\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service wuauserv, bits
"Liberados: {0:N1} MB" -f ($tam / 1MB)
