<#
.NOME Verificar disco e agendar CHKDSK
.CATEGORIA Manutenção
.DESCRICAO Verifica o volume do Windows online e agenda a correção completa (chkdsk /f /r) para o próximo boot.
.PERIGOSO Sim
#>
"Estado do volume (dirty bit):"
Executar fsutil.exe "dirty query $env:SystemDrive"
"Verificação online:"
Repair-Volume -DriveLetter $env:SystemDrive[0] -Scan
"Agendando chkdsk /f /r para a próxima inicialização..."
Executar cmd.exe "/c echo S| chkdsk $env:SystemDrive /f /r"
"Reinicie o computador para executar a verificação."
