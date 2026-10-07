<#
.NOME Informações rápidas do sistema
.CATEGORIA Sistema
.DESCRICAO Exibe nome, modelo, número de série, Windows, CPU, RAM e IP do computador.
.PERIGOSO Nao
#>
$cs = Get-CimInstance Win32_ComputerSystem
$os = Get-CimInstance Win32_OperatingSystem
$bios = Get-CimInstance Win32_BIOS
[pscustomobject]@{
    Computador  = $env:COMPUTERNAME
    Usuario     = $cs.UserName
    Fabricante  = $cs.Manufacturer
    Modelo      = $cs.Model
    Serie       = $bios.SerialNumber
    Windows     = "$($os.Caption) ($($os.BuildNumber))"
    CPU         = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
    RAM_GB      = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
    IPs         = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254*' }).IPAddress -join ', '
    UltimoBoot  = $os.LastBootUpTime
} | Format-List
