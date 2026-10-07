<#
  CoreAxis Tech Toolbox - Aplicador de atualização do executável portátil.
  Aguarda o aplicativo fechar, substitui o .exe e o inicia novamente.
  O executável anterior é mantido como <nome>.old.exe para reversão manual.
#>
param(
    [Parameter(Mandatory)][int]$ProcessId,
    [Parameter(Mandatory)][string]$Atual,
    [Parameter(Mandatory)][string]$Novo,
    [Parameter(Mandatory)][ValidatePattern('^[0-9a-fA-F]{64}$')][string]$Sha256
)
$ErrorActionPreference = 'Stop'
$log = Join-Path (Split-Path $Novo) 'atualizacao.log'
function Log($m) { Add-Content -Path $log -Value "$(Get-Date -Format s) $m" -Encoding UTF8 }

try {
    Log "Aguardando PID $ProcessId encerrar..."
    $p = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
    if ($p) { $p.WaitForExit(60000) | Out-Null }
    Start-Sleep -Seconds 2

    # Reconfere o hash assinado imediatamente antes da troca
    $hash = (Get-FileHash -Path $Novo -Algorithm SHA256).Hash
    if ($hash -ne $Sha256.ToUpper()) { throw "Hash do novo executável não confere ($hash). Atualização cancelada." }

    $backup = [IO.Path]::ChangeExtension($Atual, '.old.exe')
    for ($i = 0; $i -lt 10; $i++) {
        try {
            if (Test-Path $backup) { Remove-Item $backup -Force }
            Move-Item -Path $Atual -Destination $backup -Force
            break
        } catch { Start-Sleep -Seconds 1 }
    }
    Copy-Item -Path $Novo -Destination $Atual -Force
    Remove-Item $Novo -Force -ErrorAction SilentlyContinue
    Log "Atualização aplicada: $Atual"
    Start-Process -FilePath $Atual
} catch {
    Log "ERRO: $($_.Exception.Message)"
    if ((-not (Test-Path $Atual)) -and (Test-Path $backup)) { Move-Item $backup $Atual -Force }
    Start-Process -FilePath $Atual
}
