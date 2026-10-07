# Auditoria — scripts PowerShell

Esta pasta publica **todos os scripts PowerShell** que o CoreAxis Tech Toolbox executa no computador, muitos deles com privilégios de administrador. O objetivo é **transparência**: qualquer técnico, cliente ou auditor pode ler exatamente o que o programa faz.

## Como o programa usa estes scripts

1. Na compilação, o SHA-256 de cada script é gravado num manifesto (`integridade/vX.Y.Z.json`) que fica **dentro** do pacote protegido do executável.
2. Ao abrir, e **antes de cada execução**, o programa recalcula o hash do script e compara com o manifesto.
3. Se o arquivo tiver sido alterado (ou não constar no manifesto), a execução é **bloqueada**.

Ou seja: o que roda no seu computador é exatamente o que está publicado aqui, para a versão correspondente.

## Estrutura

| Pasta | Conteúdo |
|---|---|
| `powershell/lib/` | Funções comuns (`Executar`, `Safe`, `Saida-Json`, `Exigir-Admin`) |
| `powershell/diagnostico/` | Coleta de hardware, resumo do dashboard, temperatura |
| `powershell/rede/` | Configuração de rede |
| `powershell/windows/` | SFC, DISM, limpeza, DNS, reset de rede, Windows Update, drivers |
| `powershell/seguranca/` | Defender, firewall, serviços, processos |
| `powershell/licenca/` | Identificação do dispositivo (pendrive/PC) para licenciamento — calcula localmente, não envia nada |
| `powershell/atualizacao/` | Troca do executável após uma atualização verificada |
| `powershell/biblioteca/` | 19 scripts da biblioteca de Automação |
| `integridade/` | Manifesto SHA-256 de cada versão |

## Verificar os scripts desta pasta contra o manifesto

No PowerShell, dentro da pasta `auditoria`:

```powershell
$versao = '1.1.1'
$manifesto = (Get-Content ".\integridade\v$versao.json" -Raw | ConvertFrom-Json).files
foreach ($s in $manifesto.PSObject.Properties) {
    $atual = (Get-FileHash ".\powershell\$($s.Name)" -Algorithm SHA256).Hash.ToLower()
    $status = if ($atual -eq $s.Value) { 'OK' } else { 'DIVERGENTE' }
    '{0,-11} {1}' -f $status, $s.Name
}
```

## Verificar os scripts que estão DENTRO do executável

Com o programa aberto, os scripts são extraídos em
`%LOCALAPPDATA%\Temp\CoreAxisTechToolbox\resources\powershell`. Rode o mesmo comando acima trocando o caminho de `.\powershell\` por esse diretório para confirmar que são idênticos aos publicados.

Cada release também traz o anexo `auditoria-scripts-X.Y.Z.zip` com os scripts e o manifesto daquela versão.

## O que você NÃO vai encontrar nestes scripts

- Download ou execução de código da internet.
- Envio de dados para servidores.
- Ofuscação.
- Desativação silenciosa de proteções — ações sensíveis (reset de rede, firewall, finalizar processos, limpar lixeira, scripts perigosos) sempre pedem confirmação na interface.

Encontrou algo suspeito ou um problema? Veja o [SECURITY.md](../SECURITY.md).
