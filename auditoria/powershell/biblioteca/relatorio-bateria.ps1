<#
.NOME Relatório de bateria (powercfg)
.CATEGORIA Hardware
.DESCRICAO Gera o relatório HTML de saúde da bateria na Área de Trabalho e o abre.
.PERIGOSO Nao
#>
$arq = Join-Path ([Environment]::GetFolderPath('Desktop')) "bateria_$env:COMPUTERNAME.html"
Executar powercfg.exe "/batteryreport /output `"$arq`""
if (Test-Path $arq) { "Relatório salvo em: $arq"; Start-Process $arq } else { "Nenhuma bateria encontrada neste equipamento." }
