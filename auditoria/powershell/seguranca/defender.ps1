<#
  CoreAxis Tech Toolbox - Ações do Microsoft Defender (saída em texto, streaming)
  -Acao Rapida | Completa | Atualizar | Offline
#>
param([ValidateSet('Rapida', 'Completa', 'Atualizar', 'Offline')][string]$Acao = 'Rapida')
. "$PSScriptRoot\..\lib\comum.ps1"

switch ($Acao) {
    'Atualizar' {
        Titulo 'Atualizando assinaturas do Microsoft Defender'
        Update-MpSignature -ErrorAction Continue
        $s = Get-MpComputerStatus
        Write-Output "[OK] Versão das assinaturas: $($s.AntivirusSignatureVersion) ($(Fmt-Data $s.AntivirusSignatureLastUpdated))"
    }
    'Rapida' {
        Titulo 'Verificação rápida do Microsoft Defender'
        Write-Output 'Em andamento... (normalmente 2 a 10 minutos)'
        Start-MpScan -ScanType QuickScan -ErrorAction Continue
        Write-Output '[OK] Verificação rápida concluída.'
    }
    'Completa' {
        Titulo 'Verificação completa do Microsoft Defender'
        Write-Output 'Em andamento... pode levar mais de 1 hora.'
        Start-MpScan -ScanType FullScan -ErrorAction Continue
        Write-Output '[OK] Verificação completa concluída.'
    }
    'Offline' {
        Exigir-Admin
        Titulo 'Microsoft Defender Offline'
        Write-Output 'O computador será REINICIADO para executar a verificação offline (~15 min).'
        Start-MpWDOScan
    }
}
$t = @(Get-MpThreatDetection -ErrorAction SilentlyContinue | Where-Object { $_.InitialDetectionTime -gt (Get-Date).AddHours(-3) })
if ($Acao -in 'Rapida', 'Completa') {
    if ($t.Count) { Write-Output "[ATENÇÃO] $($t.Count) ameaça(s) detectada(s) nas últimas 3 horas. Veja a aba Defender." }
    else { Write-Output 'Nenhuma ameaça encontrada.' }
}
