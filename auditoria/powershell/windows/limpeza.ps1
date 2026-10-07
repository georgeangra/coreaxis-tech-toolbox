<#
  CoreAxis Tech Toolbox - Limpeza de arquivos temporários
  Parâmetros (switch): -Usuario -Windows -Prefetch -WindowsUpdate -Miniaturas -Navegadores -Lixeira -Logs
  -Simular : apenas calcula o espaço que seria liberado.
#>
param(
    [switch]$Usuario, [switch]$Windows, [switch]$Prefetch, [switch]$WindowsUpdate,
    [switch]$Miniaturas, [switch]$Navegadores, [switch]$Lixeira, [switch]$Logs, [switch]$Simular
)
. "$PSScriptRoot\..\lib\comum.ps1"

function Tamanho($caminhos) {
    $total = 0
    foreach ($c in $caminhos) {
        $total += (Get-ChildItem -Path $c -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    }
    return [int64]$total
}

function MB($b) { '{0:N1} MB' -f ($b / 1MB) }

$liberadoTotal = 0
function Limpar-Alvo([string]$nome, [string[]]$caminhos) {
    $antes = Tamanho $caminhos
    if ($Simular) {
        Write-Output ("  {0,-38} {1,12}" -f $nome, (MB $antes))
        $script:liberadoTotal += $antes
        return
    }
    foreach ($c in $caminhos) {
        Get-ChildItem -Path $c -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
    $depois = Tamanho $caminhos
    $lib = [math]::Max(0, $antes - $depois)
    $script:liberadoTotal += $lib
    Write-Output ("  {0,-38} {1,12} liberados  ({2} em uso por outros programas)" -f $nome, (MB $lib), (MB $depois))
}

Titulo $(if ($Simular) { 'Análise de arquivos temporários (simulação)' } else { 'Limpeza de arquivos temporários' })

if ($Usuario) {
    $perfis = Get-ChildItem "$env:SystemDrive\Users" -Directory -Force | Where-Object { Test-Path "$($_.FullName)\AppData\Local\Temp" }
    Limpar-Alvo 'Temporários dos usuários' ($perfis | ForEach-Object { "$($_.FullName)\AppData\Local\Temp" })
}
if ($Windows)  { Limpar-Alvo 'Temporários do Windows' @("$env:SystemRoot\Temp") }
if ($Prefetch) { Limpar-Alvo 'Prefetch' @("$env:SystemRoot\Prefetch") }
if ($Logs)     { Limpar-Alvo 'Relatórios de erro (WER) e dumps' @("$env:ProgramData\Microsoft\Windows\WER\ReportArchive", "$env:ProgramData\Microsoft\Windows\WER\ReportQueue", "$env:SystemRoot\Minidump", "$env:LOCALAPPDATA\CrashDumps") }
if ($Miniaturas) {
    if (-not $Simular) { Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue; Start-Sleep 1 }
    Limpar-Alvo 'Cache de miniaturas' @("$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db", "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db")
    if (-not $Simular) { Start-Process explorer.exe }
}
if ($Navegadores) {
    $alvos = @()
    foreach ($p in Get-ChildItem "$env:SystemDrive\Users" -Directory -Force) {
        $l = "$($p.FullName)\AppData\Local"
        $alvos += Get-ChildItem "$l\Google\Chrome\User Data\*\Cache", "$l\Google\Chrome\User Data\*\Code Cache",
                                "$l\Microsoft\Edge\User Data\*\Cache", "$l\Microsoft\Edge\User Data\*\Code Cache",
                                "$l\BraveSoftware\Brave-Browser\User Data\*\Cache", "$l\Mozilla\Firefox\Profiles\*\cache2" -Directory -ErrorAction SilentlyContinue |
                  ForEach-Object { $_.FullName }
    }
    Limpar-Alvo 'Cache dos navegadores' $alvos
}
if ($WindowsUpdate) {
    if (-not $Simular) { Stop-Service wuauserv, bits -Force -ErrorAction SilentlyContinue }
    Limpar-Alvo 'Cache do Windows Update' @("$env:SystemRoot\SoftwareDistribution\Download")
    if (-not $Simular) { Start-Service wuauserv, bits -ErrorAction SilentlyContinue }
}
if ($Lixeira) {
    $lix = (New-Object -ComObject Shell.Application).NameSpace(0xA)
    $tam = ($lix.Items() | Measure-Object -Property Size -Sum).Sum
    if (-not $Simular) { Clear-RecycleBin -Force -ErrorAction SilentlyContinue }
    $liberadoTotal += $tam
    Write-Output ("  {0,-38} {1,12}" -f 'Lixeira', (MB $tam))
}

Write-Output ''
Write-Output ("  TOTAL {0}: {1}" -f $(if ($Simular) { 'que pode ser liberado' } else { 'liberado' }), (MB $liberadoTotal))
