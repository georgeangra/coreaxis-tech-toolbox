<#
.NOME Erros críticos recentes (Visualizador de Eventos)
.CATEGORIA Diagnóstico
.DESCRICAO Lista erros críticos das últimas 48 horas e desligamentos inesperados/telas azuis dos últimos 30 dias.
.PERIGOSO Nao
#>
$desde = (Get-Date).AddHours(-48)
"=== Eventos críticos e erros (Sistema/Aplicativo) - últimas 48h ==="
Get-WinEvent -FilterHashtable @{ LogName = 'System', 'Application'; Level = 1, 2; StartTime = $desde } -MaxEvents 60 -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, LogName, ProviderName, Id, @{n='Mensagem';e={($_.Message -split "`n")[0]}} |
    Format-Table -AutoSize -Wrap | Out-String -Width 250
"=== Desligamentos inesperados / telas azuis (30 dias) ==="
Get-WinEvent -FilterHashtable @{ LogName = 'System'; Id = 41, 1001, 6008; StartTime = (Get-Date).AddDays(-30) } -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, ProviderName | Format-Table -AutoSize
