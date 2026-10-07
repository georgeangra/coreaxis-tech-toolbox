<#
.NOME Criar ponto de restauração
.CATEGORIA Manutenção
.DESCRICAO Habilita a Proteção do Sistema na unidade do Windows e cria um ponto de restauração antes da manutenção.
.PERIGOSO Nao
#>
Enable-ComputerRestore -Drive "$env:SystemDrive\"
# Remove o limite de 1 ponto a cada 24h
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore' -Name SystemRestorePointCreationFrequency -Value 0 -PropertyType DWord -Force | Out-Null
Checkpoint-Computer -Description "CoreAxis Tech - $(Get-Date -Format 'dd/MM/yyyy HH:mm')" -RestorePointType MODIFY_SETTINGS
"Pontos de restauração existentes:"
Get-ComputerRestorePoint | Select-Object SequenceNumber, CreationTime, Description | Format-Table -AutoSize
