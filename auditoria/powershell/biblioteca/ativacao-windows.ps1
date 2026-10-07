<#
.NOME Verificar ativação do Windows e Office
.CATEGORIA Licenciamento
.DESCRICAO Mostra o status de licenciamento do Windows e dos produtos Office instalados.
.PERIGOSO Nao
#>
$st = @{ 0 = 'Não licenciado'; 1 = 'Licenciado'; 2 = 'Carência OOB'; 3 = 'Carência OOT'; 4 = 'Carência não genuína'; 5 = 'Notificação'; 6 = 'Carência estendida' }
Get-CimInstance SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL" |
    Select-Object @{n='Produto';e={$_.Name}}, @{n='Status';e={$st[[int]$_.LicenseStatus]}}, @{n='Final da chave';e={$_.PartialProductKey}}, Description |
    Format-List
$oem = (Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey
if ($oem) { "Chave OEM gravada na BIOS: $oem" } else { "Nenhuma chave OEM na BIOS." }
