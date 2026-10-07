# Sugestões de scripts para a biblioteca

Envie aqui, por pull request, scripts PowerShell que você usa no dia a dia e que podem entrar na biblioteca de Automação do CoreAxis Tech Toolbox.

Regras e cabeçalho obrigatório: veja [CONTRIBUTING.md](../../CONTRIBUTING.md#sugerindo-scripts-powershell).

Modelo:

```powershell
<#
.NOME Verificar status do BitLocker
.CATEGORIA Segurança
.DESCRICAO Mostra o estado de criptografia BitLocker de cada unidade.
.PERIGOSO Nao
#>
Executar manage-bde.exe '-status'
```

Scripts aprovados são revisados, testados e incluídos numa próxima versão, com crédito ao autor no CHANGELOG.
