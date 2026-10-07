<#
.NOME Atualizar políticas de grupo (GPUpdate)
.CATEGORIA Rede
.DESCRICAO Força a atualização das políticas de grupo e mostra o resumo aplicado (gpresult).
.PERIGOSO Nao
#>
Executar gpupdate.exe '/force'
""
Executar gpresult.exe '/r /scope computer'
