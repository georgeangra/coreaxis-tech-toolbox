<#
.NOME Conexões e portas em escuta
.CATEGORIA Rede
.DESCRICAO Mostra portas TCP em escuta e conexões estabelecidas com o processo responsável.
.PERIGOSO Nao
#>
$procs = @{}; Get-Process | ForEach-Object { $procs[$_.Id] = $_.ProcessName }
"=== Portas em escuta ==="
Get-NetTCPConnection -State Listen | Sort-Object LocalPort |
    Select-Object LocalAddress, LocalPort, @{n='Processo';e={$procs[[int]$_.OwningProcess]}}, OwningProcess |
    Format-Table -AutoSize | Out-String -Width 200
"=== Conexões estabelecidas ==="
Get-NetTCPConnection -State Established |
    Select-Object LocalPort, RemoteAddress, RemotePort, @{n='Processo';e={$procs[[int]$_.OwningProcess]}} |
    Format-Table -AutoSize | Out-String -Width 200
