<#
.NOME Programas na inicialização
.CATEGORIA Desempenho
.DESCRICAO Lista os programas configurados para iniciar com o Windows (registro, pasta Inicializar e tarefas agendadas).
.PERIGOSO Nao
#>
"=== Itens de inicialização ==="
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User | Format-Table -AutoSize -Wrap | Out-String -Width 220
"=== Tarefas agendadas executadas no logon/boot (não Microsoft) ==="
Get-ScheduledTask | Where-Object {
    $_.State -ne 'Disabled' -and $_.TaskPath -notlike '\Microsoft\*' -and
    ($_.Triggers | Where-Object { $_.CimClass.CimClassName -match 'Logon|Boot' })
} | Select-Object TaskName, TaskPath, State | Format-Table -AutoSize | Out-String -Width 220
