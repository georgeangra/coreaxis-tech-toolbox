<#
.NOME Ativar plano de energia Alto Desempenho
.CATEGORIA Desempenho
.DESCRICAO Ativa o plano Alto Desempenho (cria se não existir) e lista os planos disponíveis.
.PERIGOSO Nao
#>
$alto = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
Executar powercfg.exe "/setactive $alto" | Out-Null
if ($LASTEXITCODE -ne 0) { Executar powercfg.exe "-duplicatescheme $alto" | Out-Null; Executar powercfg.exe "/setactive $alto" }
Executar powercfg.exe '/list'
