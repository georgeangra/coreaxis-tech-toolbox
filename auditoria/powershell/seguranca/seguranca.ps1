<#
  CoreAxis Tech Toolbox - Módulo de Segurança (saída JSON)
  -Acao Defender | Firewall | Servicos | Processos | Assinaturas
#>
param(
    [ValidateSet('Defender', 'Firewall', 'Servicos', 'Processos', 'Assinaturas')][string]$Acao = 'Defender'
)
. "$PSScriptRoot\..\lib\comum.ps1"

switch ($Acao) {
    'Defender' {
        $mp = Safe { Get-MpComputerStatus }
        $pref = Safe { Get-MpPreference }
        $ameacas = @(Safe { Get-MpThreatDetection } | Sort-Object InitialDetectionTime -Descending | Select-Object -First 20 | ForEach-Object {
            $t = Safe { Get-MpThreat -ThreatID $_.ThreatID }
            [ordered]@{ Ameaca = $t.ThreatName; Data = Fmt-Data $_.InitialDetectionTime; Recurso = ($_.Resources -join '; '); Acao = [string]$_.CleaningActionID }
        })
        # Antivírus registrados na Central de Segurança (inclui antivírus de terceiros)
        $avs = @(Safe { Get-CimInstance -Namespace root\SecurityCenter2 -ClassName AntiVirusProduct } | ForEach-Object {
            $hex = '{0:X6}' -f $_.productState
            [ordered]@{
                Nome        = $_.displayName
                Ativo       = $hex.Substring(2, 2) -in '10', '11'
                Atualizado  = $hex.Substring(4, 2) -eq '00'
                Executavel  = $_.pathToSignedProductExe
            }
        })
        Saida-Json ([ordered]@{
            disponivel           = [bool]$mp
            servicoAtivo         = $mp.AMServiceEnabled
            antivirus            = $mp.AntivirusEnabled
            tempoReal            = $mp.RealTimeProtectionEnabled
            comportamento        = $mp.BehaviorMonitorEnabled
            protecaoRede         = $mp.NISEnabled
            antispyware          = $mp.AntispywareEnabled
            tamper               = $mp.IsTamperProtected
            modo                 = $mp.AMRunningMode
            versaoMotor          = $mp.AMEngineVersion
            versaoAssinaturas    = $mp.AntivirusSignatureVersion
            assinaturasAtualizadas = Fmt-Data $mp.AntivirusSignatureLastUpdated
            idadeAssinaturasDias = $mp.AntivirusSignatureAge
            ultimaVerificacaoRapida   = Fmt-Data $mp.QuickScanEndTime
            ultimaVerificacaoCompleta = Fmt-Data $mp.FullScanEndTime
            exclusoes            = @($pref.ExclusionPath) + @($pref.ExclusionProcess) | Where-Object { $_ }
            ameacas              = $ameacas
            produtos             = $avs
        })
    }
    'Firewall' {
        $perfis = @(Get-NetFirewallProfile | ForEach-Object {
            [ordered]@{
                Perfil   = switch ($_.Name) { 'Domain' {'Domínio'} 'Private' {'Privado'} 'Public' {'Público'} default {$_.Name} }
                Ativo    = [bool]($_.Enabled -eq 'True' -or $_.Enabled -eq 1 -or $_.Enabled -eq $true)
                Entrada  = [string]$_.DefaultInboundAction
                Saida    = [string]$_.DefaultOutboundAction
                Log      = $_.LogFileName
            }
        })
        $ativos = @(Get-NetConnectionProfile | ForEach-Object { [ordered]@{ Rede = $_.Name; Categoria = [string]$_.NetworkCategory; Interface = $_.InterfaceAlias } })
        $regras = Get-NetFirewallRule -Enabled True
        Saida-Json ([ordered]@{
            perfis         = $perfis
            redesAtivas    = $ativos
            regrasAtivas   = @($regras).Count
            regrasEntrada  = @($regras | Where-Object Direction -eq 'Inbound').Count
            regrasSaida    = @($regras | Where-Object Direction -eq 'Outbound').Count
        })
    }
    'Servicos' {
        $criticos = [ordered]@{
            'WinDefend' = 'Antivírus Microsoft Defender'; 'mpssvc' = 'Firewall do Windows'; 'SecurityHealthService' = 'Central de Segurança'
            'wscsvc' = 'Central de Segurança (WSC)'; 'BFE' = 'Mecanismo de Filtragem Base'; 'wuauserv' = 'Windows Update'
            'BITS' = 'Transferência Inteligente (BITS)'; 'CryptSvc' = 'Serviços de Criptografia'; 'TrustedInstaller' = 'Instalador de Módulos'
            'EventLog' = 'Log de Eventos'; 'Winmgmt' = 'WMI'; 'RpcSs' = 'RPC'; 'Schedule' = 'Agendador de Tarefas'
            'Dnscache' = 'Cliente DNS'; 'Dhcp' = 'Cliente DHCP'; 'NlaSvc' = 'Reconhecimento de Local de Rede'
            'LanmanWorkstation' = 'Estação de trabalho (SMB)'; 'LanmanServer' = 'Servidor (compartilhamentos)'
            'Spooler' = 'Spooler de Impressão'; 'W32Time' = 'Horário do Windows'; 'AudioSrv' = 'Áudio do Windows'
            'Themes' = 'Temas'; 'WSearch' = 'Windows Search'; 'TermService' = 'Área de Trabalho Remota'; 'VSS' = 'Cópias de Sombra (VSS)'
        }
        $lista = foreach ($nome in $criticos.Keys) {
            $s = Get-Service -Name $nome -ErrorAction SilentlyContinue
            if (-not $s) { continue }
            [ordered]@{
                Nome = $nome; Descricao = $criticos[$nome]; Exibicao = $s.DisplayName
                Status = switch ([string]$s.Status) { 'Running' {'Em execução'} 'Stopped' {'Parado'} 'Paused' {'Pausado'} default {[string]$s.Status} }
                Inicializacao = switch ([string]$s.StartType) { 'Automatic' {'Automático'} 'Manual' {'Manual'} 'Disabled' {'Desabilitado'} default {[string]$s.StartType} }
                Rodando = ($s.Status -eq 'Running')
            }
        }
        Saida-Json @($lista)
    }
    'Processos' {
        $cpuCount = [Environment]::ProcessorCount
        $perf = @{}
        Get-CimInstance Win32_PerfFormattedData_PerfProc_Process | ForEach-Object { $perf[[int]$_.IDProcess] = $_.PercentProcessorTime }
        $donos = @{}
        Get-CimInstance Win32_Process | ForEach-Object { $donos[[int]$_.ProcessId] = $_ }
        $lista = Get-Process | Where-Object { $_.Id -gt 4 } | ForEach-Object {
            $w = $donos[$_.Id]
            [ordered]@{
                PID        = $_.Id
                Nome       = $_.ProcessName
                CPU        = [math]::Round(($perf[$_.Id] / $cpuCount), 1)
                MemoriaMB  = [math]::Round($_.WorkingSet64 / 1MB, 1)
                Caminho    = $_.Path
                Empresa    = $_.Company
                Descricao  = $_.Description
                Linha      = if ($w) { $w.CommandLine } else { $null }
                PaiPID     = if ($w) { $w.ParentProcessId } else { $null }
                Inicio     = Safe { Fmt-Data $_.StartTime }
            }
        }
        Saida-Json @($lista | Sort-Object { $_.MemoriaMB } -Descending)
    }
    'Assinaturas' {
        $caminhos = Get-Process | Where-Object { $_.Path } | Select-Object -ExpandProperty Path -Unique
        $lista = foreach ($p in $caminhos) {
            $s = Get-AuthenticodeSignature -FilePath $p
            [ordered]@{
                Caminho = $p
                Status  = switch ([string]$s.Status) { 'Valid' {'Válida'} 'NotSigned' {'Não assinado'} 'HashMismatch' {'Adulterado'} default {[string]$s.Status} }
                Emissor = if ($s.SignerCertificate) { ($s.SignerCertificate.Subject -replace '^CN=([^,]+).*', '$1') } else { $null }
                Valida  = ($s.Status -eq 'Valid')
            }
        }
        Saida-Json @($lista)
    }
}
