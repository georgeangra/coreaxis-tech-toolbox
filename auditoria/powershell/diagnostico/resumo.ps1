<#
  CoreAxis Tech Toolbox - Resumo rápido para o Dashboard (execução < 3 s).
#>
. "$PSScriptRoot\..\lib\comum.ps1"

$cs  = Get-CimInstance Win32_ComputerSystem
$os  = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$cv  = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
$mp  = Safe { Get-MpComputerStatus }
$fw  = @(Safe { Get-NetFirewallProfile })
$pendente = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') -or
            (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending')

Saida-Json ([ordered]@{
    computador  = $env:COMPUTERNAME
    fabricante  = Limpar $cs.Manufacturer
    modelo      = Limpar $cs.Model
    usuario     = $cs.UserName
    so          = $os.Caption
    versao      = if ($cv.DisplayVersion) { $cv.DisplayVersion } else { $cv.ReleaseId }
    build       = "$($os.BuildNumber).$($cv.UBR)"
    arquitetura = $os.OSArchitecture
    cpu         = ($cpu.Name -replace '\s+', ' ').Trim()
    ramTotal    = [int64]$cs.TotalPhysicalMemory
    ultimoBoot  = Fmt-Data $os.LastBootUpTime
    admin       = (Eh-Admin)
    reinicioPendente = $pendente
    defender    = if ($mp) { [bool]$mp.RealTimeProtectionEnabled } else { $null }
    firewall    = if ($fw.Count) { @($fw | Where-Object { -not $_.Enabled }).Count -eq 0 } else { $null }
    volumes     = @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object {
        [ordered]@{ Letra = $_.DeviceID; Rotulo = $_.VolumeName; Tamanho = [int64]$_.Size; Livre = [int64]$_.FreeSpace }
    })
})
