# Changelog

Todas as mudanças relevantes do **CoreAxis Tech Toolbox** são registradas aqui.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o projeto adota [Versionamento Semântico](https://semver.org/lang/pt-BR/):
`MAJOR.MINOR.PATCH` — mudanças incompatíveis · novas funcionalidades · correções.

Os hashes SHA-256 de cada versão estão em [`SHA256.txt`](SHA256.txt) e na página de cada [release](https://github.com/georgeangra/coreaxis-tech-toolbox/releases).

## [Não lançado]

## [1.2.0] - 2026-10-07

### Adicionado
- Nova identidade visual e ícone do aplicativo baseados na marca CoreAxis Tech (constelação de nós em turquesa).
- Publicação oficial pelo GitHub: releases com SHA-256, site com verificação de integridade no navegador e scripts PowerShell abertos para auditoria.
- Atualizações automáticas servidas pelas releases do GitHub (manifesto assinado com Ed25519).
- Preparação para assinatura digital Authenticode do executável no processo de build.

### Segurança
- O teste de 15 dias passa a ser **um por dispositivo**: baixar de novo, apagar a pasta `CoreAxisData`, trocar o programa de pasta ou atrasar o relógio não reinicia mais o teste. Sem licença, a data de início fica registrada num marcador autenticado no registro do usuário, em `%ProgramData%\CoreAxis` e na raiz do pendrive. Com licença válida nada é gravado fora da pasta do programa.

## [1.1.1] - 2026-10-07

### Corrigido
- Botões **Copiar** (código do dispositivo, chave de recuperação, senha temporária, saída dos terminais, CSV da rede e resumo do diagnóstico) voltaram a funcionar. A permissão de escrita na área de transferência agora é concedida somente à interface oficial do aplicativo; a leitura continua bloqueada.

### Segurança
- Autoteste de build passa a verificar a área de transferência, evitando regressões.

## [1.1.0] - 2026-10-07

### Adicionado
- **Licenciamento comercial offline**: licença assinada (Ed25519) vinculada a um pendrive (VID/PID/número de série USB) ou a um computador (UUID SMBIOS), com teste de 15 dias e **modo consulta** ao vencer (dados sempre acessíveis).
- Aba **Configurações → Licença** com código do dispositivo e ativação por arquivo `.lic`.
- **Contrato de licença de uso (EULA)** na primeira abertura.
- **Contas por técnico** com perfis Administrador e Técnico, senhas temporárias com troca obrigatória e **chave de recuperação**.
- **Trilha de auditoria** (logins, falhas, scripts executados com hash, alterações).

### Segurança
- Cofre de dados criptografado **AES-256-GCM** com chaves derivadas por **scrypt** (N=2¹⁷); o banco só existe decifrado em memória.
- Bloqueio progressivo após tentativas de login incorretas e bloqueio automático por inatividade (`Ctrl+L` para bloquear na hora).
- Verificação **SHA-256** de todos os scripts PowerShell antes da execução; scripts alterados ou desconhecidos são bloqueados.
- **Electron Fuses**: sem `RunAsNode`, sem `NODE_OPTIONS`, sem `--inspect`, validação de integridade do pacote.
- Interface servida por protocolo privado `app://` com CSP restritiva, `contextIsolation` e `sandbox`; validação da origem de cada chamada interna.
- Atualizações exigem **assinatura Ed25519**, HTTPS e conferência de SHA-256; downgrade bloqueado.
- Chave de produto OEM do Windows mascarada em telas e relatórios.
- Caminhos de rede UNC bloqueados; permissões do navegador negadas.

### Alterado
- Código do processo principal ofuscado na compilação.

## [1.0.0] - 2026-10-07

### Adicionado
- Primeira versão: Dashboard, Diagnóstico, Rede, Windows, Segurança, Automação (19 scripts), Inventário e Atendimento.
- Relatórios PDF (inventário, Ordem de Serviço) e Excel.
- Executável portátil único para Windows 10/11, dados em `CoreAxisData` ao lado do `.exe`.

[Não lançado]: https://github.com/georgeangra/coreaxis-tech-toolbox/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/georgeangra/coreaxis-tech-toolbox/releases/tag/v1.2.0
[1.1.1]: https://github.com/georgeangra/coreaxis-tech-toolbox/releases/tag/v1.1.1
[1.1.0]: https://github.com/georgeangra/coreaxis-tech-toolbox/releases/tag/v1.1.0
[1.0.0]: https://github.com/georgeangra/coreaxis-tech-toolbox/releases/tag/v1.0.0
