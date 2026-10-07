<#
  CoreAxis Tech Toolbox - Leitura de sensores de temperatura.
  Fontes: ACPI (MSAcpi_ThermalZoneTemperature), SMART dos discos e contador de desempenho
  "Thermal Zone Information". Muitas placas-mãe não expõem sensores ao Windows; nesse caso
  a lista virá vazia e a interface sugere ferramentas específicas (HWiNFO, LibreHardwareMonitor).
#>
. "$PSScriptRoot\..\lib\comum.ps1"

$lista = @()
$lista += @(Safe { Get-CimInstance -Namespace root\wmi -ClassName MSAcpi_ThermalZoneTemperature } | ForEach-Object {
    [ordered]@{ Sensor = ($_.InstanceName -replace '^ACPI\\ThermalZone\\', 'Zona térmica ' -replace '_0$', ''); Celsius = [math]::Round($_.CurrentTemperature / 10 - 273.15, 1); Origem = 'ACPI' }
})
if ($lista.Count -eq 0) {
    $lista += @(Safe { Get-CimInstance Win32_PerfFormattedData_Counters_ThermalZoneInformation } | Where-Object { $_.Temperature -gt 0 } | ForEach-Object {
        [ordered]@{ Sensor = "Zona térmica $($_.Name -replace '^\\_TZ\.', '')"; Celsius = [math]::Round($_.Temperature - 273.15, 1); Origem = 'Contador de desempenho' }
    })
}
$lista += @(Safe { Get-PhysicalDisk } | ForEach-Object {
    $rc = Safe { $_ | Get-StorageReliabilityCounter }
    if ($rc.Temperature) { [ordered]@{ Sensor = "Disco: $($_.FriendlyName)"; Celsius = [int]$rc.Temperature; Max = $rc.TemperatureMax; Origem = 'SMART' } }
})

Saida-Json ([ordered]@{ admin = (Eh-Admin); sensores = @($lista) })
