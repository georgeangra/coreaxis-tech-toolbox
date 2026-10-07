<#
.NOME Listar impressoras e portas
.CATEGORIA Impressão
.DESCRICAO Lista impressoras instaladas, drivers, portas TCP/IP e a impressora padrão.
.PERIGOSO Nao
#>
$padrao = (Get-CimInstance Win32_Printer | Where-Object Default).Name
"Impressora padrão: $padrao"
""
Get-Printer | Select-Object Name, DriverName, PortName, PrinterStatus, Shared | Format-Table -AutoSize | Out-String -Width 220
"=== Portas TCP/IP ==="
Get-PrinterPort | Where-Object PrinterHostAddress | Select-Object Name, PrinterHostAddress, PortNumber | Format-Table -AutoSize
