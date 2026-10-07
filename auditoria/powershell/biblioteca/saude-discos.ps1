<#
.NOME Saúde dos discos (SMART)
.CATEGORIA Hardware
.DESCRICAO Exibe saúde, temperatura, desgaste e erros dos discos físicos via contadores de confiabilidade.
.PERIGOSO Nao
#>
Get-PhysicalDisk | ForEach-Object {
    $r = $_ | Get-StorageReliabilityCounter -ErrorAction SilentlyContinue
    [pscustomobject]@{
        Disco           = $_.FriendlyName
        Tipo            = $_.MediaType
        Barramento      = $_.BusType
        'Tamanho GB'    = [math]::Round($_.Size / 1GB)
        Saude           = $_.HealthStatus
        'Temp °C'       = $r.Temperature
        'Desgaste %'    = $r.Wear
        'Horas ligado'  = $r.PowerOnHours
        'Erros leitura' = $r.ReadErrorsTotal
        'Erros escrita' = $r.WriteErrorsTotal
    }
} | Format-List
