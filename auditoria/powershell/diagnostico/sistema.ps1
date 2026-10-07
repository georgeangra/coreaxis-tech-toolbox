<#
  CoreAxis Tech Toolbox - Coleta completa de hardware e sistema.
  Saída: JSON (consumido pelos módulos Diagnóstico e Inventário).
  -Inventario : inclui softwares instalados, ativação e chave OEM (mais lento).
#>
param([switch]$Inventario)
. "$PSScriptRoot\..\lib\comum.ps1"

$cs   = Get-CimInstance Win32_ComputerSystem
$os   = Get-CimInstance Win32_OperatingSystem
$bios = Get-CimInstance Win32_BIOS
$bb   = Get-CimInstance Win32_BaseBoard
$cv   = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

# ---------------------------------------------------------------- computador
$tipo = switch ($cs.PCSystemType) { 1 {'Desktop'} 2 {'Notebook'} 3 {'Workstation'} 4 {'Servidor'} 5 {'Servidor'} 8 {'Tablet'} default {'Outro'} }
$computador = [ordered]@{
    Nome       = $env:COMPUTERNAME
    Fabricante = Limpar $cs.Manufacturer
    Modelo     = Limpar $cs.Model
    Familia    = Limpar $cs.SystemFamily
    Dominio    = if ($cs.PartOfDomain) { $cs.Domain } else { "Grupo de trabalho: $($cs.Workgroup)" }
    Usuario    = $cs.UserName
    Tipo       = $tipo
}

# ---------------------------------------------------------------- sistema operacional
$uptime = (Get-Date) - $os.LastBootUpTime
$sistema = [ordered]@{
    Nome            = $os.Caption
    VersaoExibicao  = if ($cv.DisplayVersion) { $cv.DisplayVersion } else { $cv.ReleaseId }
    Build           = "$($os.BuildNumber).$($cv.UBR)"
    Arquitetura     = $os.OSArchitecture
    Idioma          = (Get-Culture).Name
    DataInstalacao  = Fmt-Data $os.InstallDate
    UltimoBoot      = Fmt-Data $os.LastBootUpTime
    Uptime          = '{0}d {1}h {2}min' -f $uptime.Days, $uptime.Hours, $uptime.Minutes
    UsuarioRegistrado = $os.RegisteredUser
    PastaSistema    = $os.WindowsDirectory
}

# ---------------------------------------------------------------- CPU
$cpu = @(Get-CimInstance Win32_Processor | ForEach-Object {
    [ordered]@{
        Nome       = ($_.Name -replace '\s+', ' ').Trim()
        Fabricante = $_.Manufacturer
        Nucleos    = $_.NumberOfCores
        Threads    = $_.NumberOfLogicalProcessors
        ClockMHz   = $_.MaxClockSpeed
        ClockAtual = $_.CurrentClockSpeed
        Soquete    = $_.SocketDesignation
        L2KB       = $_.L2CacheSize
        L3KB       = $_.L3CacheSize
        Uso        = $_.LoadPercentage
        Virtualizacao = if ($_.VirtualizationFirmwareEnabled) { 'Habilitada' } else { 'Desabilitada/Indisponível' }
    }
})

# ---------------------------------------------------------------- BIOS / placa-mãe
$secureBoot = Safe { if (Confirm-SecureBootUEFI) { 'Ativado' } else { 'Desativado' } }
if (-not $secureBoot) { $secureBoot = 'Não suportado / modo Legacy' }
$tpm = Safe { $t = Get-Tpm; if ($t.TpmPresent) { "Presente ($(if ($t.TpmReady) {'pronto'} else {'não inicializado'}))" } else { 'Ausente' } }
$tpmVer = Safe { (Get-CimInstance -Namespace root\cimv2\security\microsofttpm -ClassName Win32_Tpm).SpecVersion }
if ($tpmVer) { $tpm = "$tpm - versão $(($tpmVer -split ',')[0])" }

$biosInfo = [ordered]@{
    Fabricante  = $bios.Manufacturer
    Versao      = $bios.SMBIOSBIOSVersion
    Data        = if ($bios.ReleaseDate) { ([datetime]$bios.ReleaseDate).ToUniversalTime().ToString('dd/MM/yyyy') } else { $null }
    NumeroSerie = Limpar $bios.SerialNumber
    SMBIOS      = "$($bios.SMBIOSMajorVersion).$($bios.SMBIOSMinorVersion)"
    ModoBoot    = if ($env:firmware_type) { $env:firmware_type } else { 'Desconhecido' }
    SecureBoot  = $secureBoot
    TPM         = $tpm
}
$placaMae = [ordered]@{
    Fabricante  = $bb.Manufacturer
    Modelo      = $bb.Product
    Versao      = Limpar $bb.Version
    NumeroSerie = Limpar $bb.SerialNumber
}

# ---------------------------------------------------------------- memória
$tiposMem = @{ 20='DDR'; 21='DDR2'; 24='DDR3'; 26='DDR4'; 27='LPDDR'; 28='LPDDR2'; 29='LPDDR3'; 30='LPDDR4'; 34='DDR5'; 35='LPDDR5' }
$arrMem = Get-CimInstance Win32_PhysicalMemoryArray | Where-Object { $_.Use -eq 3 }
$modulos = @(Get-CimInstance Win32_PhysicalMemory | ForEach-Object {
    [ordered]@{
        Slot       = if ($_.DeviceLocator) { $_.DeviceLocator } else { $_.BankLabel }
        Capacidade = [int64]$_.Capacity
        Velocidade = if ($_.ConfiguredClockSpeed) { $_.ConfiguredClockSpeed } else { $_.Speed }
        Tipo       = $tiposMem[[int]$_.SMBIOSMemoryType]
        Fabricante = Limpar $_.Manufacturer
        PartNumber = Limpar $_.PartNumber
        NumeroSerie = Limpar $_.SerialNumber
    }
})
$memoria = [ordered]@{
    Total         = [int64]$cs.TotalPhysicalMemory
    Livre         = [int64]$os.FreePhysicalMemory * 1024
    Slots         = ($arrMem | Measure-Object MemoryDevices -Sum).Sum
    MaxCapacidade = [int64](($arrMem | Measure-Object MaxCapacityEx -Sum).Sum) * 1024
    Modulos       = $modulos
}

# ---------------------------------------------------------------- discos
$discos = @(Safe { Get-PhysicalDisk } | ForEach-Object {
    $pd = $_
    $rc = Safe { $pd | Get-StorageReliabilityCounter }
    $tipo = switch ([string]$pd.MediaType) { 'SSD' {'SSD'} 'HDD' {'HDD'} '3' {'HDD'} '4' {'SSD'} default { if ($pd.BusType -eq 'NVMe') {'SSD'} else {'Não especificado'} } }
    [ordered]@{
        Modelo       = $pd.FriendlyName
        Tipo         = $tipo
        Barramento   = [string]$pd.BusType
        Tamanho      = [int64]$pd.Size
        Saude        = switch ([string]$pd.HealthStatus) { 'Healthy' {'Saudável'} 'Warning' {'Atenção'} 'Unhealthy' {'Crítico'} '0' {'Saudável'} '1' {'Atenção'} '2' {'Crítico'} default {[string]$pd.HealthStatus} }
        Status       = [string]$pd.OperationalStatus
        NumeroSerie  = Limpar $pd.SerialNumber
        Firmware     = $pd.FirmwareVersion
        Temperatura  = if ($rc.Temperature) { [int]$rc.Temperature } else { $null }
        Desgaste     = if ($null -ne $rc.Wear) { [int]$rc.Wear } else { $null }
        HorasLigado  = $rc.PowerOnHours
        ErrosLeitura = $rc.ReadErrorsTotal
    }
})

$volumes = @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object {
    [ordered]@{
        Letra   = $_.DeviceID
        Rotulo  = $_.VolumeName
        Sistema = $_.FileSystem
        Tamanho = [int64]$_.Size
        Livre   = [int64]$_.FreeSpace
        UsoPct  = if ($_.Size) { [math]::Round((1 - $_.FreeSpace / $_.Size) * 100, 1) } else { 0 }
    }
})

# ---------------------------------------------------------------- vídeo
$regVideo = @(Get-ChildItem 'HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}' |
    Where-Object { $_.PSChildName -match '^\d{4}$' } | ForEach-Object { Get-ItemProperty $_.PSPath })
$video = @(Get-CimInstance Win32_VideoController | ForEach-Object {
    $v = $_
    $reg = $regVideo | Where-Object { $_.DriverDesc -eq $v.Name } | Select-Object -First 1
    $mem = if ($reg.'HardwareInformation.qwMemorySize') { [int64]$reg.'HardwareInformation.qwMemorySize' } else { [int64]$v.AdapterRAM }
    [ordered]@{
        Nome      = $v.Name
        Memoria   = $mem
        Driver    = $v.DriverVersion
        DataDriver = Fmt-Data $v.DriverDate
        Resolucao = if ($v.CurrentHorizontalResolution) { "$($v.CurrentHorizontalResolution)x$($v.CurrentVerticalResolution) @ $($v.CurrentRefreshRate)Hz" } else { '' }
    }
})

$monitores = @(Safe { Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID } | ForEach-Object {
    $dec = { param($a) if ($a) { ([Text.Encoding]::ASCII.GetString(($a | Where-Object { $_ -ne 0 }))).Trim() } }
    [ordered]@{ Fabricante = (& $dec $_.ManufacturerName); Modelo = (& $dec $_.UserFriendlyName); NumeroSerie = (& $dec $_.SerialNumberID) }
})

# ---------------------------------------------------------------- rede
$rede = @(Safe { Get-NetAdapter -Physical } | ForEach-Object {
    $a = $_
    $cfg = Safe { Get-NetIPConfiguration -InterfaceIndex $a.ifIndex }
    [ordered]@{
        Nome       = $a.Name
        Descricao  = $a.InterfaceDescription
        MAC        = ($a.MacAddress -replace '-', ':')
        Velocidade = $a.LinkSpeed
        Status     = switch ($a.Status) { 'Up' {'Conectado'} 'Disconnected' {'Desconectado'} 'Disabled' {'Desabilitado'} default {[string]$a.Status} }
        IPs        = @($cfg.IPv4Address | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength)" })
        Gateway    = ($cfg.IPv4DefaultGateway | Select-Object -First 1).NextHop
        DNS        = @(($cfg.DNSServer | Where-Object { $_.AddressFamily -eq 2 }).ServerAddresses)
        DHCP       = Safe { (Get-NetIPInterface -InterfaceIndex $a.ifIndex -AddressFamily IPv4).Dhcp -eq 'Enabled' }
        Driver     = $a.DriverVersion
    }
})

# ---------------------------------------------------------------- bateria
$bateria = $null
$bat = Get-CimInstance Win32_Battery | Select-Object -First 1
if ($bat) {
    $design = Safe { (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData | Select-Object -First 1).DesignedCapacity }
    $full   = Safe { (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity | Select-Object -First 1).FullChargedCapacity }
    $bateria = [ordered]@{
        Nome              = $bat.Name
        Carga             = $bat.EstimatedChargeRemaining
        Status            = switch ($bat.BatteryStatus) { 1 {'Descarregando'} 2 {'Na tomada'} 3 {'Carregada'} 6 {'Carregando'} default {"Código $($bat.BatteryStatus)"} }
        CapacidadeProjeto = if ($design) { "$design mWh" } else { $null }
        CapacidadeAtual   = if ($full) { "$full mWh" } else { $null }
        Saude             = if ($design -and $full) { '{0}%' -f [math]::Round($full / $design * 100) } else { $null }
    }
}

# ---------------------------------------------------------------- temperaturas
$temperaturas = @()
$temperaturas += @(Safe { Get-CimInstance -Namespace root\wmi -ClassName MSAcpi_ThermalZoneTemperature } | ForEach-Object {
    [ordered]@{ Sensor = ($_.InstanceName -replace '^ACPI\\ThermalZone\\', 'Zona térmica ' -replace '_0$', ''); Celsius = [math]::Round($_.CurrentTemperature / 10 - 273.15, 1); Origem = 'ACPI' }
})
$temperaturas += @($discos | Where-Object { $_.Temperatura } | ForEach-Object {
    [ordered]@{ Sensor = "Disco: $($_.Modelo)"; Celsius = $_.Temperatura; Origem = 'SMART' }
})

$resultado = [ordered]@{
    coletadoEm   = (Get-Date).ToString('dd/MM/yyyy HH:mm:ss')
    admin        = (Eh-Admin)
    computador   = $computador
    sistema      = $sistema
    cpu          = $cpu
    bios         = $biosInfo
    placaMae     = $placaMae
    memoria      = $memoria
    discos       = $discos
    volumes      = $volumes
    video        = $video
    monitores    = $monitores
    rede         = $rede
    bateria      = $bateria
    temperaturas = $temperaturas
}

# ---------------------------------------------------------------- inventário (extras)
if ($Inventario) {
    $lic = Safe { Get-CimInstance SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL AND ApplicationID='55c92734-d682-4d71-983e-d6ec3f16059f'" | Select-Object -First 1 }
    $resultado.sistema.Ativacao = switch ($lic.LicenseStatus) { 1 {'Ativado'} 0 {'Não licenciado'} 2 {'Período de carência'} 5 {'Notificação (não ativado)'} default {'Desconhecido'} }
    if ($lic.Description) { $resultado.sistema.Ativacao += " - $($lic.Description)" }
    $resultado.sistema.ChaveOEM = Safe { (Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey }
    $resultado.sistema.Hotfixes = @(Safe { Get-HotFix } | Sort-Object InstalledOn -Descending | Select-Object -First 15 | ForEach-Object { "$($_.HotFixID) ($(Fmt-Data $_.InstalledOn))" })

    $chaves = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
              'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
              'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $resultado.software = @(Get-ItemProperty $chaves |
        Where-Object { $_.DisplayName -and $_.SystemComponent -ne 1 -and -not $_.ParentKeyName } |
        Sort-Object DisplayName -Unique | ForEach-Object {
            $d = $null
            if ($_.InstallDate -match '^\d{8}$') { $d = '{0}/{1}/{2}' -f $_.InstallDate.Substring(6, 2), $_.InstallDate.Substring(4, 2), $_.InstallDate.Substring(0, 4) }
            [ordered]@{ Nome = $_.DisplayName; Versao = $_.DisplayVersion; Fabricante = $_.Publisher; Data = $d }
        })
}

Saida-Json $resultado
