<#
  CoreAxis Tech Toolbox - Reset completo da pilha de rede
  -Completo : também redefine os adaptadores (equivalente a "Redefinição de rede" do Windows)
#>
param([switch]$Completo)
. "$PSScriptRoot\..\lib\comum.ps1"
Exigir-Admin

Titulo 'Reset de rede'
$passos = @(
    @{ N = 'Liberando endereço IP';        C = { Executar ipconfig.exe '/release' | Out-Null } },
    @{ N = 'Limpando cache DNS';           C = { Executar ipconfig.exe '/flushdns' } },
    @{ N = 'Limpando cache ARP';           C = { Executar netsh.exe 'interface ip delete arpcache' } },
    @{ N = 'Reset do Winsock';             C = { Executar netsh.exe 'winsock reset' } },
    @{ N = 'Reset da pilha TCP/IP (IPv4)'; C = { Executar netsh.exe 'int ipv4 reset' } },
    @{ N = 'Reset da pilha TCP/IP (IPv6)'; C = { Executar netsh.exe 'int ipv6 reset' } },
    @{ N = 'Reset do proxy WinHTTP';       C = { Executar netsh.exe 'winhttp reset proxy' } },
    @{ N = 'Renovando endereço IP';        C = { Executar ipconfig.exe '/renew' } }
)
$i = 0
foreach ($p in $passos) {
    $i++
    Write-Output ''
    Write-Output "[$i/$($passos.Count)] $($p.N)..."
    & $p.C 2>&1 | ForEach-Object { "    $_" }
}

if ($Completo) {
    Write-Output ''
    Write-Output 'Reiniciando adaptadores de rede físicos...'
    Get-NetAdapter -Physical | Where-Object Status -ne 'Disabled' | ForEach-Object {
        Write-Output "    $($_.Name)"
        Restart-NetAdapter -Name $_.Name -Confirm:$false
    }
}

Write-Output ''
Write-Output '[OK] Reset de rede concluído.'
Write-Output '[!] REINICIE o computador para concluir a aplicação do reset do Winsock/TCP-IP.'
