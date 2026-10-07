<#
.NOME Listar programas instalados
.CATEGORIA Sistema
.DESCRICAO Lista todos os programas instalados (32 e 64 bits) com versão e fabricante.
.PERIGOSO Nao
#>
$chaves = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
          'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
          'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
$l = Get-ItemProperty $chaves -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -and $_.SystemComponent -ne 1 } |
     Sort-Object DisplayName -Unique |
     Select-Object @{n='Programa';e={$_.DisplayName}}, @{n='Versão';e={$_.DisplayVersion}}, @{n='Fabricante';e={$_.Publisher}}
$l | Format-Table -AutoSize | Out-String -Width 220
"Total: $(@($l).Count) programas"
