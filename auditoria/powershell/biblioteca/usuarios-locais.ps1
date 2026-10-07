<#
.NOME Usuários e administradores locais
.CATEGORIA Segurança
.DESCRICAO Lista contas locais, status, último logon e membros do grupo Administradores.
.PERIGOSO Nao
#>
"=== Contas locais ==="
Get-LocalUser | Select-Object Name, Enabled, LastLogon, PasswordRequired, PasswordLastSet | Format-Table -AutoSize | Out-String -Width 200
"=== Membros do grupo Administradores ==="
Get-LocalGroupMember -SID 'S-1-5-32-544' | Select-Object Name, ObjectClass, PrincipalSource | Format-Table -AutoSize
