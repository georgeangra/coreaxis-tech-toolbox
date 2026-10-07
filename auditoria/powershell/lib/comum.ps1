# CoreAxis Tech Toolbox - funções comuns (carregado via dot-source pelos demais scripts)
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$OutputEncoding = [Text.Encoding]::UTF8
try { chcp 65001 > $null } catch {}

function Safe([scriptblock]$Bloco) {
    try { & $Bloco } catch { $null }
}

function Fmt-Data($d) {
    if (-not $d) { return $null }
    try { return ([datetime]$d).ToString('dd/MM/yyyy HH:mm') } catch { return [string]$d }
}

function Limpar([string]$s) {
    if (-not $s) { return $null }
    $s = $s.Trim()
    if ($s -match '^(To be filled.*|Default string|System Serial Number|None|0+|Not Specified|O\.E\.M\.?|Unknown)$') { return $null }
    return $s
}

function Saida-Json($obj) {
    $obj | ConvertTo-Json -Depth 8 -Compress
}

function Eh-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    return (New-Object Security.Principal.WindowsPrincipal $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Titulo([string]$t) {
    Write-Output ''
    Write-Output ('=' * 70)
    Write-Output "  $t"
    Write-Output ('=' * 70)
}

<#
  Executa um programa nativo (ipconfig, netsh, dism, sfc, ping...) com a saída em tempo real
  e acentuação correta. Ferramentas do Windows escrevem na code page OEM (850 em pt-BR)
  quando a saída é redirecionada; o sfc.exe escreve em UTF-16. Cada linha é lida como bytes
  e decodificada como UTF-8 (se válida) ou OEM. Use -Codificacao Unicode para o sfc.exe.
  Exemplo: Executar ipconfig '/all'
#>
$script:__latin = [Text.Encoding]::GetEncoding(28591)
$script:__utf8 = New-Object Text.UTF8Encoding($false, $true)
$script:__oem = [Text.Encoding]::GetEncoding([Globalization.CultureInfo]::CurrentCulture.TextInfo.OEMCodePage)
function Decodificar-Linha([string]$s) {
    $b = $script:__latin.GetBytes($s)
    try { return $script:__utf8.GetString($b) } catch { return $script:__oem.GetString($b) }
}
function Executar {
    param(
        [Parameter(Mandatory, Position = 0)][string]$Programa,
        [Parameter(Position = 1)][string]$Argumentos = '',
        [ValidateSet('Auto', 'Unicode')][string]$Codificacao = 'Auto'
    )
    $enc = if ($Codificacao -eq 'Unicode') { [Text.Encoding]::Unicode } else { $script:__latin }
    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName = $Programa
    $psi.Arguments = $Argumentos
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.StandardOutputEncoding = $enc
    $psi.StandardErrorEncoding = $enc
    try { $p = [Diagnostics.Process]::Start($psi) } catch { Write-Output "[ERRO] Não foi possível executar ${Programa}: $($_.Exception.Message)"; $global:LASTEXITCODE = 1; return }
    $erros = $p.StandardError.ReadToEndAsync()
    $anterior = $null
    while ($null -ne ($linha = $p.StandardOutput.ReadLine())) {
        if ($Codificacao -ne 'Unicode') { $linha = Decodificar-Linha $linha }
        # Ignora repetições consecutivas de linhas de progresso (sfc/dism: "Verificação 96% concluída.")
        if ($linha -eq $anterior -and $linha -match '\d\s*%') { continue }
        $anterior = $linha
        Write-Output $linha
    }
    $p.WaitForExit()
    $e = $erros.Result
    if ($e) { $e -split "`r?`n" | Where-Object { $_.Trim() } | ForEach-Object { Write-Output $(if ($Codificacao -eq 'Unicode') { $_ } else { Decodificar-Linha $_ }) } }
    $global:LASTEXITCODE = $p.ExitCode
}

function Exigir-Admin {
    if (-not (Eh-Admin)) {
        Write-Output '[ERRO] Esta operação exige privilégios de Administrador.'
        Write-Output '       Feche o CoreAxis Tech Toolbox e execute-o como Administrador.'
        exit 5
    }
}
