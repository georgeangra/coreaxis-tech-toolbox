<#
  CoreAxis Tech Toolbox - DISM (reparo da imagem do Windows)
  -Modo CheckHealth | ScanHealth | RestoreHealth | ComponentCleanup
#>
param([ValidateSet('CheckHealth', 'ScanHealth', 'RestoreHealth', 'ComponentCleanup')][string]$Modo = 'RestoreHealth')
. "$PSScriptRoot\..\lib\comum.ps1"
Exigir-Admin

$dism = "$env:SystemRoot\System32\dism.exe"
switch ($Modo) {
    'CheckHealth'      { Titulo 'DISM /CheckHealth - verificação rápida'; Executar $dism '/Online /Cleanup-Image /CheckHealth' }
    'ScanHealth'       { Titulo 'DISM /ScanHealth - verificação completa'; Executar $dism '/Online /Cleanup-Image /ScanHealth' }
    'RestoreHealth'    { Titulo 'DISM /RestoreHealth - reparo da imagem (usa o Windows Update)'
                         Write-Output 'Requer internet. Pode levar 10-30 minutos e parecer parado em 62% - é normal.'
                         Executar $dism '/Online /Cleanup-Image /RestoreHealth' }
    'ComponentCleanup' { Titulo 'DISM /StartComponentCleanup - limpeza do WinSxS'; Executar $dism '/Online /Cleanup-Image /StartComponentCleanup' }
}
$codigo = $LASTEXITCODE
Write-Output ''
if ($codigo -eq 0) { Write-Output '[OK] Operação concluída com sucesso.' }
elseif ($codigo -eq 3010) { Write-Output '[OK] Concluído. É necessário reiniciar o computador.' }
else { Write-Output "[ERRO] DISM retornou o código $codigo. Consulte $env:SystemRoot\Logs\DISM\dism.log" }
exit $codigo
