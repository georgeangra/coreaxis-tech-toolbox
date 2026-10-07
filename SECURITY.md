# Política de Segurança

A segurança dos técnicos que usam o **CoreAxis Tech Toolbox** — e dos dados dos clientes deles — é prioridade. Este documento explica como relatar vulnerabilidades e como o software é protegido.

## Versões suportadas

| Versão | Suporte de segurança |
|---|---|
| 1.1.x | ✅ Suportada |
| 1.0.x | ❌ Não suportada — atualize para a versão mais recente |

## Como relatar uma vulnerabilidade

**Não abra uma issue pública** para vulnerabilidades. Isso expõe todos os usuários antes de existir uma correção.

1. Use o **relato privado de vulnerabilidades** do GitHub:
   **[Reportar vulnerabilidade](https://github.com/georgeangra/coreaxis-tech-toolbox/security/advisories/new)**
2. Inclua, se possível:
   - versão do programa e do Windows;
   - descrição do problema e impacto esperado;
   - passos para reproduzir ou prova de conceito;
   - SHA-256 do executável testado.

### O que você pode esperar

| Etapa | Prazo |
|---|---|
| Confirmação de recebimento | até 3 dias úteis |
| Avaliação inicial e classificação | até 10 dias úteis |
| Correção de falhas críticas/altas | prioridade máxima, com release dedicada |
| Divulgação | coordenada com quem relatou, após a correção |

Pesquisadores que relatarem de forma responsável serão creditados no CHANGELOG (se desejarem).

### Escopo

Dentro do escopo: o executável oficial publicado em [Releases](https://github.com/georgeangra/coreaxis-tech-toolbox/releases), os scripts em [`auditoria/`](auditoria/), o mecanismo de licenciamento, o cofre de dados, o mecanismo de atualização e o site oficial.

Fora do escopo: cópias obtidas fora do GitHub oficial, versões não suportadas, ataques que exigem acesso físico prévio com privilégios de administrador ao computador, engenharia social.

## Como o software é protegido

| Camada | Proteção |
|---|---|
| Dados | Cofre **AES-256-GCM**; chaves derivadas por **scrypt** (N=2¹⁷, r=8, p=1); senha nunca armazenada; banco decifrado somente em memória |
| Acesso | Login obrigatório, perfis Administrador/Técnico, bloqueio progressivo, bloqueio por inatividade, chave de recuperação, trilha de auditoria |
| Executável | Electron Fuses (sem RunAsNode, NODE_OPTIONS e `--inspect`; integridade do pacote validada a cada abertura) |
| Scripts | Cada script PowerShell é conferido por SHA-256 antes de executar; scripts alterados/desconhecidos são bloqueados |
| Interface | Protocolo privado `app://`, CSP restritiva, `contextIsolation`, `sandbox`, permissões do navegador negadas, origem de cada chamada validada |
| Atualizações | Manifesto assinado com **Ed25519**, HTTPS obrigatório, SHA-256 conferido antes e depois do download, downgrade bloqueado |
| Licenças | Assinadas com Ed25519 e vinculadas ao dispositivo; não podem ser falsificadas ou alteradas |
| Distribuição | Somente via GitHub Releases, com SHA-256 publicado e verificado automaticamente por workflow |

## Verificação de integridade

Antes de executar, confira o SHA-256 do arquivo baixado:

```powershell
Get-FileHash .\CoreAxisTechToolbox-<versão>-portable.exe -Algorithm SHA256
```

O valor deve ser idêntico ao publicado em [`SHA256.txt`](SHA256.txt) e na página da release. Um workflow público ([verify-release](.github/workflows/verify-release.yml)) baixa periodicamente os arquivos de cada release e confere os hashes publicados.

## Assinatura digital

O executável ainda **não** possui assinatura Authenticode; por isso o Windows SmartScreen pode exibir um aviso. O processo de build já está preparado para assinar automaticamente assim que o certificado de assinatura de código for adquirido (OV/EV ou Azure Trusted Signing). Até lá, a autenticidade deve ser confirmada pelo SHA-256.

## Privilégios de administrador

O programa solicita elevação porque funções como SFC, DISM, reset de rede, drivers, SMART, TPM e Secure Boot exigem privilégios elevados no Windows. Ações destrutivas (reset de rede, desativar firewall, finalizar processos, limpeza da lixeira, scripts marcados como perigosos) sempre pedem confirmação. Todos os scripts executados estão publicados em [`auditoria/`](auditoria/).

## Riscos residuais conhecidos

- Malware com privilégio de administrador no computador atendido pode ler a memória do programa enquanto o cofre está aberto. Bloqueie a sessão (`Ctrl+L`) ao se afastar.
- Apagamento seguro não é garantido em memórias flash. Recomenda-se BitLocker To Go no pendrive.
- Nenhuma proteção de software é absoluta; relatos de falhas são bem-vindos.
