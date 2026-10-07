<#
  CoreAxis Tech Toolbox - Verificador de Arquivos do Sistema (SFC /Scannow)
#>
. "$PSScriptRoot\..\lib\comum.ps1"
Exigir-Admin

Titulo 'SFC /Scannow - Verificação de integridade dos arquivos do sistema'
Write-Output 'Isso pode levar de 5 a 20 minutos. Não desligue o computador.'
Write-Output ''

Executar "$env:SystemRoot\System32\sfc.exe" '/scannow' -Codificacao Unicode
$codigo = $LASTEXITCODE

Write-Output ''
Titulo 'Resultado'
switch ($codigo) {
    0 { Write-Output '[OK] Nenhuma violação de integridade encontrada.' }
    1 { Write-Output '[OK] Arquivos corrompidos foram encontrados e reparados.' }
    2 { Write-Output '[ATENÇÃO] Foram encontrados arquivos corrompidos que NÃO puderam ser reparados.'
        Write-Output '          Execute o DISM RestoreHealth e depois rode o SFC novamente.' }
    default { Write-Output "Código de saída: $codigo" }
}
Write-Output "Log detalhado: $env:SystemRoot\Logs\CBS\CBS.log"
exit $codigo
