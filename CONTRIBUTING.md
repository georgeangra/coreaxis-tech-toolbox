# Como contribuir

Obrigado por querer melhorar o **CoreAxis Tech Toolbox**! O núcleo do aplicativo é proprietário, mas a comunidade de técnicos é fundamental para a evolução do produto. Veja como ajudar.

## Formas de contribuir

| Você quer… | Como fazer |
|---|---|
| Relatar um problema | [Bug Report](https://github.com/georgeangra/coreaxis-tech-toolbox/issues/new?template=bug_report.yml) |
| Sugerir uma funcionalidade | [Feature Request](https://github.com/georgeangra/coreaxis-tech-toolbox/issues/new?template=feature_request.yml) |
| Relatar uma vulnerabilidade | **Somente** pelo [relato privado](https://github.com/georgeangra/coreaxis-tech-toolbox/security/advisories/new) — ver [SECURITY.md](SECURITY.md) |
| Sugerir um script para a biblioteca de Automação | Pull request na pasta [`contribuicoes/scripts/`](contribuicoes/scripts/) (ver abaixo) |
| Melhorar documentação ou site | Pull request nos arquivos `.md` ou em `site/` |
| Auditar os scripts | Analise [`auditoria/`](auditoria/) e relate achados |

## Antes de abrir uma issue

1. Atualize para a [versão mais recente](https://github.com/georgeangra/coreaxis-tech-toolbox/releases/latest).
2. Confirme o SHA-256 do executável (cópias não oficiais não são suportadas).
3. Procure se o problema já foi relatado.
4. **Nunca** publique dados de clientes, senhas, chaves de recuperação, códigos de licença ou números de série. Revise capturas de tela antes de anexar.

## Sugerindo scripts PowerShell

Os scripts aceitos entram na biblioteca padrão de uma próxima versão.

1. Crie o arquivo em `contribuicoes/scripts/<nome-descritivo>.ps1`, salvo em **UTF-8 com BOM**.
2. Use o cabeçalho obrigatório:

   ```powershell
   <#
   .NOME Nome exibido na biblioteca
   .CATEGORIA Sistema | Rede | Hardware | Impressão | Manutenção | Desempenho | Segurança | Diagnóstico | Licenciamento
   .DESCRICAO O que o script faz, em uma frase.
   .PERIGOSO Nao        (use Sim se alterar o sistema de forma difícil de desfazer)
   #>
   ```
3. Requisitos:
   - Compatível com **Windows PowerShell 5.1** (nativo do Windows 10/11).
   - Mensagens em português do Brasil.
   - Ferramentas nativas chamadas com a função `Executar 'programa.exe' 'argumentos'` (garante acentuação correta).
   - Nada de download/execução de código remoto, ofuscação, desativação de proteções ou coleta de dados.
   - Ações destrutivas devem ser idempotentes e explicadas na `.DESCRICAO`.
4. Descreva no pull request: objetivo, versões do Windows testadas e saída de exemplo.

## Padrões para pull requests

- Um assunto por pull request.
- Título claro no imperativo (ex.: *Adiciona script de verificação de BitLocker*).
- Mensagens de commit no formato [Conventional Commits](https://www.conventionalcommits.org/pt-br/):
  `feat:`, `fix:`, `docs:`, `chore:`, `ci:`, `security:`.
- Preencha o template de pull request.

## Direitos sobre contribuições

Ao enviar uma contribuição, você declara que é autor do conteúdo e concorda que a CoreAxis Tech poderá incorporá-lo, modificá-lo e distribuí-lo como parte do CoreAxis Tech Toolbox, inclusive em versões comerciais, mantendo o crédito ao autor no CHANGELOG.

## Código de conduta

Este projeto segue o [Código de Conduta](CODE_OF_CONDUCT.md). Seja respeitoso.
