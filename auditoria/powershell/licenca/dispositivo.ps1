<#
  CoreAxis Tech Toolbox - Identificação do dispositivo para licenciamento (saída JSON).
  -Unidade : letra da unidade onde está o executável (ex.: D)
  Pendrive: fabricante (VID), produto (PID) e número de série gravados no hardware USB.
  PC: UUID SMBIOS (não muda ao reinstalar o Windows) + série da placa-mãe; MachineGuid como alternativa.
#>
param([ValidatePattern('^[A-Za-z]?$')][string]$Unidade = '')
. "$PSScriptRoot\..\lib\comum.ps1"

$r = [ordered]@{ unidade = $Unidade; usb = $null; pc = $null }

if ($Unidade) {
    $part = Safe { Get-Partition -DriveLetter $Unidade -ErrorAction Stop }
    if ($part) {
        $disk = Get-Disk -Number $part.DiskNumber
        if ([string]$disk.BusType -eq 'USB') {
            $dd = Get-CimInstance Win32_DiskDrive | Where-Object { $_.Index -eq $disk.Number } | Select-Object -First 1
            $pnp = $dd.PNPDeviceID
            $pai = Safe { (Get-PnpDeviceProperty -InstanceId $pnp -KeyName 'DEVPKEY_Device_Parent' -ErrorAction Stop).Data }
            $vid = if ($pai -match 'VID_([0-9A-Fa-f]{4})') { $Matches[1].ToUpper() } else { '' }
            $prod = if ($pai -match 'PID_([0-9A-Fa-f]{4})') { $Matches[1].ToUpper() } else { '' }
            $serie = [string]$disk.SerialNumber
            if (-not $serie.Trim() -and $pai -match '\\([^\\&]+)$') { $serie = $Matches[1] }
            $r.usb = [ordered]@{
                modelo = $disk.FriendlyName
                vid    = $vid
                pid    = $prod
                serie  = $serie.Trim()
                tamanho = [int64]$disk.Size
            }
        }
    }
}

$csp = Get-CimInstance Win32_ComputerSystemProduct
$bb = Get-CimInstance Win32_BaseBoard
$r.pc = [ordered]@{
    nome        = $env:COMPUTERNAME
    uuid        = [string]$csp.UUID
    placa       = [string]$bb.SerialNumber
    machineGuid = [string](Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Cryptography').MachineGuid
}
Saida-Json $r
