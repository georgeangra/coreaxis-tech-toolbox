<#
  CoreAxis Tech Toolbox - Controle de serviço do Windows
  -Nome <serviço> -Acao Iniciar | Parar | Reiniciar
#>
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9_.\-]+$')][string]$Nome,
    [ValidateSet('Iniciar', 'Parar', 'Reiniciar')][string]$Acao
)
. "$PSScriptRoot\..\lib\comum.ps1"
$ErrorActionPreference = 'Stop'
try {
    switch ($Acao) {
        'Iniciar'   { Start-Service -Name $Nome }
        'Parar'     { Stop-Service -Name $Nome -Force }
        'Reiniciar' { Restart-Service -Name $Nome -Force }
    }
    $s = Get-Service -Name $Nome
    Saida-Json ([ordered]@{ ok = $true; status = [string]$s.Status })
} catch {
    Saida-Json ([ordered]@{ ok = $false; erro = $_.Exception.Message })
}
