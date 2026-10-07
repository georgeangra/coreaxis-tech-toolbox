<#
  CoreAxis Tech Toolbox - Gerenciamento de drivers
  -Acao Listar     : JSON com drivers de terceiros e status dos dispositivos
        Problemas  : texto com dispositivos com erro / sem driver
        Backup     : exporta drivers de terceiros para -Destino
        Escanear   : procura alterações de hardware (pnputil /scan-devices)
        Restaurar  : instala drivers a partir de -Destino (pnputil /add-driver /subdirs /install)
#>
param(
    [ValidateSet('Listar', 'Problemas', 'Backup', 'Escanear', 'Restaurar')][string]$Acao = 'Listar',
    [string]$Destino
)
. "$PSScriptRoot\..\lib\comum.ps1"

$codigos = @{
    1 = 'Dispositivo não configurado corretamente'; 3 = 'Driver corrompido'; 10 = 'Dispositivo não pode ser iniciado'
    12 = 'Recursos insuficientes'; 18 = 'Reinstale os drivers'; 22 = 'Dispositivo desabilitado'; 24 = 'Dispositivo ausente'
    28 = 'Driver não instalado'; 31 = 'Driver não carregado'; 39 = 'Driver corrompido ou ausente'; 43 = 'Dispositivo relatou problema'
    45 = 'Dispositivo desconectado'; 52 = 'Assinatura digital inválida'
}

switch ($Acao) {
    'Listar' {
        $problemas = @(Get-CimInstance Win32_PnPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 } | ForEach-Object {
            [ordered]@{ Nome = if ($_.Name) { $_.Name } else { $_.DeviceID }; Classe = $_.PNPClass; Codigo = $_.ConfigManagerErrorCode
                        Descricao = $codigos[[int]$_.ConfigManagerErrorCode]; Id = $_.DeviceID }
        })
        $drivers = @(Get-CimInstance Win32_PnPSignedDriver | Where-Object { $_.DeviceName -and $_.DriverProviderName -and $_.DriverProviderName -ne 'Microsoft' } |
            Sort-Object DeviceClass, DeviceName | ForEach-Object {
                [ordered]@{ Dispositivo = $_.DeviceName; Classe = $_.DeviceClass; Fabricante = $_.DriverProviderName
                            Versao = $_.DriverVersion; Data = if ($_.DriverDate) { ([datetime]$_.DriverDate).ToString('dd/MM/yyyy') } else { '' }
                            Inf = $_.InfName; Assinado = [bool]$_.IsSigned }
            })
        Saida-Json ([ordered]@{ problemas = $problemas; drivers = $drivers })
    }
    'Problemas' {
        Titulo 'Dispositivos com problema'
        $l = @(Get-CimInstance Win32_PnPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 })
        if ($l.Count -eq 0) { Write-Output '[OK] Nenhum dispositivo com problema.' }
        $l | ForEach-Object { Write-Output ("  [Código {0}] {1} - {2}" -f $_.ConfigManagerErrorCode, $_.Name, $codigos[[int]$_.ConfigManagerErrorCode]) }
    }
    'Backup' {
        Exigir-Admin
        if (-not $Destino) { Write-Output '[ERRO] Informe a pasta de destino.'; exit 1 }
        $pasta = Join-Path $Destino ("Drivers_{0}_{1}" -f $env:COMPUTERNAME, (Get-Date -Format 'yyyyMMdd_HHmm'))
        New-Item -ItemType Directory -Path $pasta -Force | Out-Null
        Titulo "Backup de drivers para $pasta"
        $r = Export-WindowsDriver -Online -Destination $pasta
        $r | ForEach-Object { Write-Output ("  {0,-28} {1} ({2})" -f $_.ClassName, $_.ProviderName, $_.Version) }
        Write-Output ''
        Write-Output "[OK] $(@($r).Count) driver(s) exportado(s)."
    }
    'Restaurar' {
        Exigir-Admin
        if (-not $Destino -or -not (Test-Path $Destino)) { Write-Output '[ERRO] Pasta de drivers inválida.'; exit 1 }
        Titulo "Instalando drivers de $Destino"
        Executar pnputil.exe "/add-driver `"$Destino\*.inf`" /subdirs /install"
    }
    'Escanear' {
        Exigir-Admin
        Titulo 'Procurando alterações de hardware'
        Executar pnputil.exe '/scan-devices'
        Write-Output '[OK] Varredura concluída.'
    }
}
