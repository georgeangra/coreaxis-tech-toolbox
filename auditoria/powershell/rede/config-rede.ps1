<#
  CoreAxis Tech Toolbox - Configuração de rede atual (JSON)
#>
. "$PSScriptRoot\..\lib\comum.ps1"

$adaptadores = @(Get-NetIPConfiguration -Detailed | Where-Object { $_.NetAdapter.Status -eq 'Up' } | ForEach-Object {
    $a = $_.NetAdapter
    [ordered]@{
        Nome      = $_.InterfaceAlias
        Descricao = $_.InterfaceDescription
        MAC       = ($a.MacAddress -replace '-', ':')
        Velocidade = $a.LinkSpeed
        IPv4      = @($_.IPv4Address | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" })
        IPv6      = @($_.IPv6Address | ForEach-Object { $_.IPAddress })
        Gateway   = @($_.IPv4DefaultGateway | ForEach-Object { $_.NextHop })
        DNS       = @(($_.DNSServer | Where-Object AddressFamily -eq 2).ServerAddresses)
        DHCP      = ($_.NetIPv4Interface.Dhcp -eq 'Enabled')
        Perfil    = [string]$_.NetProfile.NetworkCategory
        Rede      = $_.NetProfile.Name
    }
})
$wifi = $null
$w = (Executar netsh.exe 'wlan show interfaces') -join "`n"
if ($w -match '(?m)^\s*SSID\s*:\s*(.+)$') {
    $wifi = [ordered]@{
        SSID   = $Matches[1].Trim()
        Sinal  = if ($w -match '(?m)^\s*(Sinal|Signal)\s*:\s*(.+)$') { $Matches[2].Trim() } else { $null }
        Canal  = if ($w -match '(?m)^\s*(Canal|Channel)\s*:\s*(.+)$') { $Matches[2].Trim() } else { $null }
        Banda  = if ($w -match '(?m)^\s*(Banda|Band)\s*:\s*(.+)$') { $Matches[2].Trim() } else { $null }
        Taxa   = if ($w -match '(?m)^\s*(Taxa de recep\S+|Receive rate) \(Mbps\)\s*:\s*(.+)$') { "$($Matches[2].Trim()) Mbps" } else { $null }
    }
}
Saida-Json ([ordered]@{ hostname = $env:COMPUTERNAME; adaptadores = $adaptadores; wifi = $wifi })
