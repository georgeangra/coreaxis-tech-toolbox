<#
  CoreAxis Tech Toolbox - Windows Update via API COM (Microsoft.Update.Session)
  Não depende de módulos externos (PSWindowsUpdate).
  -Acao Buscar | Instalar | Historico | Reparar
  -Drivers : inclui atualizações de drivers
#>
param(
    [ValidateSet('Buscar', 'Instalar', 'Historico', 'Reparar')][string]$Acao = 'Buscar',
    [switch]$Drivers
)
. "$PSScriptRoot\..\lib\comum.ps1"

function Tam($b) { if ($b -gt 1GB) { '{0:N1} GB' -f ($b / 1GB) } else { '{0:N0} MB' -f ($b / 1MB) } }

if ($Acao -eq 'Reparar') {
    Exigir-Admin
    Titulo 'Reparo dos componentes do Windows Update'
    $svcs = 'wuauserv', 'bits', 'cryptsvc', 'msiserver'
    Write-Output 'Parando serviços...'
    Stop-Service $svcs -Force
    $sd = "$env:SystemRoot\SoftwareDistribution"; $cr = "$env:SystemRoot\System32\catroot2"
    $stamp = Get-Date -Format 'yyyyMMddHHmmss'
    Write-Output 'Renomeando SoftwareDistribution e catroot2...'
    if (Test-Path $sd) { Rename-Item $sd "SoftwareDistribution.bak$stamp" -Force }
    if (Test-Path $cr) { Rename-Item $cr "catroot2.bak$stamp" -Force }
    Write-Output 'Iniciando serviços...'
    Start-Service $svcs
    Write-Output '[OK] Componentes redefinidos. Busque por atualizações novamente.'
    exit 0
}

$sessao = New-Object -ComObject Microsoft.Update.Session
$sessao.ClientApplicationID = 'CoreAxis Tech Toolbox'

if ($Acao -eq 'Historico') {
    Titulo 'Histórico de atualizações (últimas 40)'
    $busca = $sessao.CreateUpdateSearcher()
    $n = $busca.GetTotalHistoryCount()
    if ($n -eq 0) { Write-Output 'Nenhum histórico.'; exit 0 }
    $busca.QueryHistory(0, [math]::Min(40, $n)) | Where-Object { $_.Title } | ForEach-Object {
        $r = switch ($_.ResultCode) { 2 {'OK     '} 3 {'PARCIAL'} 4 {'FALHOU '} 5 {'ABORTADO'} default {'?      '} }
        Write-Output ("{0:dd/MM/yyyy HH:mm}  [{1}]  {2}" -f $_.Date.ToLocalTime(), $r, $_.Title)
    }
    exit 0
}

Titulo 'Buscando atualizações no Windows Update...'
Write-Output 'Aguarde, isso pode levar alguns minutos.'
$busca = $sessao.CreateUpdateSearcher()
$criterio = "IsInstalled=0 and IsHidden=0 and Type='Software'"
if ($Drivers) { $criterio = "IsInstalled=0 and IsHidden=0" }
try {
    $resultado = $busca.Search($criterio)
} catch {
    Write-Output "[ERRO] Falha na busca: $($_.Exception.Message)"
    Write-Output 'Dica: use a opção "Reparar Windows Update" e tente novamente.'
    exit 1
}

$lista = @($resultado.Updates)
Write-Output ''
if ($lista.Count -eq 0) { Write-Output '[OK] O sistema está atualizado.'; exit 0 }
Write-Output "$($lista.Count) atualização(ões) disponível(is):"
$i = 0
foreach ($u in $lista) {
    $i++
    $tipo = if ($u.Type -eq 2) { 'Driver' } else { ($u.Categories | Select-Object -First 1).Name }
    Write-Output ("  {0,2}. [{1}] {2} ({3})" -f $i, $tipo, $u.Title, (Tam $u.MaxDownloadSize))
}

if ($Acao -ne 'Instalar') { exit 0 }
Exigir-Admin

$col = New-Object -ComObject Microsoft.Update.UpdateColl
foreach ($u in $lista) {
    if (-not $u.EulaAccepted) { $u.AcceptEula() }
    if ($u.InstallationBehavior.CanRequestUserInput) { Write-Output "  (ignorada - requer interação) $($u.Title)"; continue }
    [void]$col.Add($u)
}
if ($col.Count -eq 0) { Write-Output 'Nada a instalar.'; exit 0 }

Titulo "Baixando $($col.Count) atualização(ões)..."
$down = $sessao.CreateUpdateDownloader()
$down.Updates = $col
$rd = $down.Download()
Write-Output "Download concluído (código $($rd.ResultCode))."

Titulo 'Instalando...'
$inst = $sessao.CreateUpdateInstaller()
$inst.Updates = $col
$ri = $inst.Install()
for ($k = 0; $k -lt $col.Count; $k++) {
    $r = $ri.GetUpdateResult($k).ResultCode
    $txt = switch ($r) { 2 {'OK'} 3 {'Parcial'} 4 {'FALHOU'} 5 {'Abortada'} default {"código $r"} }
    Write-Output ("  [{0}] {1}" -f $txt, $col.Item($k).Title)
}
Write-Output ''
if ($ri.RebootRequired) { Write-Output '[!] REINICIALIZAÇÃO NECESSÁRIA para concluir a instalação.' }
else { Write-Output '[OK] Instalação concluída.' }
