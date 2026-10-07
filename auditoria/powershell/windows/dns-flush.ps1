<#
  CoreAxis Tech Toolbox - Limpeza do cache DNS
#>
param([switch]$Registrar)
. "$PSScriptRoot\..\lib\comum.ps1"

Titulo 'Limpeza do cache DNS'
$antes = @(Safe { Get-DnsClientCache }).Count
Write-Output "Entradas no cache antes: $antes"
Executar ipconfig.exe '/flushdns'
Safe { Clear-DnsClientCache }
if ($Registrar) {
    Write-Output ''
    Write-Output 'Registrando o computador novamente no DNS...'
    Executar ipconfig.exe '/registerdns'
}
Write-Output ''
Write-Output '[OK] Cache DNS limpo.'
