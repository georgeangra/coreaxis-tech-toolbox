# Manual de Utilização — CoreAxis Tech Toolbox

## 1. Preparando o pendrive

1. Copie `CoreAxisTechToolbox-x.y.z-portable.exe` para o pendrive (ex.: `E:\CoreAxis\`).
2. Na primeira execução o app pede a **configuração inicial** (seção 2.1) e cria a pasta `E:\CoreAxis\CoreAxisData\` com:

```
CoreAxisData\
├── coreaxis.vault   ← COFRE CRIPTOGRAFADO (AES-256): clientes, equipamentos, chamados, inventários, scripts, usuários
├── Relatorios\      ← PDFs e planilhas (pasta padrão)
├── Backups\         ← cópias do banco
├── logs\            ← erros do aplicativo
├── updates\         ← atualizações baixadas
└── electron\        ← cache da interface
```

> Leve sempre a pasta `CoreAxisData` junto com o `.exe`: é nela que estão seus dados. Faça backups periódicos (*Configurações → Dados → Fazer backup agora*).

## 2. Abrindo no computador do cliente

1. Conecte o pendrive e dê dois cliques no `.exe`.
2. Confirme o **UAC** ("Deseja permitir que este aplicativo faça alterações?") → **Sim**. Sem privilégios de administrador, SFC, DISM, reset de rede, drivers, SMART, TPM e Secure Boot ficam indisponíveis — a barra superior mostra o aviso "Sem privilégios de admin".
3. Aguarde a tela de abertura (5–15 s na primeira extração).

**Requisitos:** Windows 10 (1809+) ou Windows 11, 64 bits. Nada é instalado.

### 2.1 Primeiro acesso (uma vez por pendrive)

0. Leia e aceite o **contrato de licença de uso**.
1. Informe nome, usuário e senha do **administrador** (mínimo 12 caracteres, combinando maiúsculas, minúsculas, números e símbolos).
2. O app exibe a **chave de recuperação** (`XXXX-XXXX-…`) **uma única vez**. Anote em papel ou em um gerenciador de senhas — **nunca no próprio pendrive**. Sem senha e sem essa chave, ninguém consegue recuperar os dados.
3. Se existir um banco antigo sem criptografia (versão anterior), ele é importado para o cofre e apagado.

### 2.2 Teste grátis e licença

- Após a configuração inicial você tem **15 dias de teste completo**. A barra superior mostra os dias restantes.
- Para ativar: **Configurações → Licença** → copie o **código do dispositivo** (pendrive `CX-P-…` ou computador `CX-M-…`) e envie à CoreAxis Tech. Você receberá um arquivo `.lic`: clique em **Abrir arquivo .lic** (ou cole o texto) e em **Ativar**.
- **Licença de pendrive:** funciona em qualquer computador, desde que o aplicativo seja executado a partir daquele pendrive.
- **Ao vencer** a licença ou o teste, o app entra em **modo consulta**: seus clientes, chamados e inventários continuam visíveis e exportáveis (PDF/Excel/backup), mas as ferramentas ficam bloqueadas até a renovação. **Você nunca perde acesso aos seus dados.**
- Pendrive danificado ou troca de computador: solicite a transferência (1 gratuita por ano) e copie a pasta `CoreAxisData` (ou um backup) para o novo dispositivo.

### 2.3 Uso diário

- **Login** a cada abertura. Após 5 senhas erradas, o acesso é bloqueado temporariamente (30 s, dobrando até 15 min).
- **Bloqueio automático** após 10 min sem uso (configurável) e **Ctrl+L** para bloquear na hora. Tarefas em andamento (SFC, DISM…) continuam rodando.
- Menu do usuário (canto superior direito): *Alterar senha*, *Bloquear*, *Sair*.
- **Esqueceu a senha?** Técnico: peça ao administrador para redefinir. Administrador: na tela de login, *Esqueci a senha do administrador* + chave de recuperação.

### 2.4 Perfis

| | Administrador | Técnico |
|---|:-:|:-:|
| Diagnóstico, rede, Windows, segurança, inventário e atendimento | ✓ | ✓ |
| Executar scripts da biblioteca | ✓ | ✓ |
| Criar/editar/importar scripts, configurações, usuários, auditoria, atualizações | ✓ | — |

Detalhes técnicos em [SECURITY.md](../SECURITY.md) e [PRIVACIDADE.md](../PRIVACIDADE.md).

## 3. Interface

- **Barra lateral:** módulos agrupados em *Visão geral*, *Ferramentas*, *Gestão* e *Sistema*. Em janelas estreitas, ela recolhe e mostra apenas ícones.
- **Barra superior:** nome do computador, usuário logado e nível de privilégio.
- **Atalhos:** `Ctrl+1` … `Ctrl+9` alternam módulos; `F5` atualiza o módulo atual.
- **Painéis de saída (terminal):** exibem a execução em tempo real, com botões *Copiar*, *Limpar* e *Cancelar*. Tarefas continuam rodando ao trocar de módulo.

## 4. Dashboard

Visão do equipamento atendido: fabricante/modelo, sistema, processador, uso de CPU, RAM e disco em tempo real, tempo ligado e **Saúde do sistema** (administrador, antivírus, firewall, reinicialização pendente, espaço livre). Os blocos de **Ações rápidas** levam direto às ferramentas mais usadas. Abaixo: contadores, chamados abertos e atividades recentes.

## 5. Diagnóstico

Clique em **Executar diagnóstico** (executa automaticamente ao abrir; leva 10–30 s). Abas:

| Aba | Conteúdo |
|---|---|
| Visão geral | Computador, número de série, SO, resumo de hardware |
| Processador | Modelo, núcleos/threads, clocks, caches, virtualização, uso |
| Memória | Total, slots ocupados/livres, capacidade máxima suportada, tipo (DDR4/DDR5), cada módulo com fabricante e part number |
| Armazenamento | Discos físicos (SSD/HDD/NVMe, saúde, temperatura, desgaste, horas ligado, erros) e volumes com barra de uso |
| Temperatura | Sensores ACPI e SMART, com botão de atualizar |
| BIOS / Placa-mãe | Versão/data da BIOS, modo de boot (UEFI/Legacy), Secure Boot, TPM, modelo e série da placa |
| Vídeo e rede | GPUs, memória de vídeo, drivers, resolução, monitores, adaptadores de rede, bateria |

Botões: **Copiar resumo** (texto pronto para colar em chamado/WhatsApp), **Exportar PDF**, **Salvar no inventário**.

> **Temperatura de CPU:** muitas placas-mãe (principalmente desktops) não expõem sensores ao Windows. Nesses casos o app mostra apenas temperaturas de disco e sugere ferramentas especializadas.

## 6. Rede

| Aba | Como usar |
|---|---|
| Configuração | IPs, gateway, DNS, DHCP, MAC, perfil de rede e dados do Wi-Fi (SSID, sinal, canal, banda) |
| Ping | Host, quantidade e tamanho do pacote; marque *Contínuo* para ping ininterrupto (use *Cancelar* para parar). Atalhos: gateway, 8.8.8.8, 1.1.1.1 |
| Traceroute | Rota até o destino. *PathPing* mede perda de pacotes por salto (~1 min) |
| NSLookup | Consulta A, AAAA, MX, NS, TXT, CNAME, SOA ou todos; servidor DNS opcional; IP faz consulta reversa |
| Scanner de portas | Perfis prontos (comuns, web, Windows/AD, impressoras, CFTV, bancos, 1–1024) ou lista personalizada (`22,80,8000-8100`). Portas web abertas têm botão *Abrir* |
| Scanner de rede | **Descoberta automática**: detecta a sub-rede da interface conectada ao gateway e encontra dispositivos por ping + tabela ARP (inclui quem bloqueia ping), resolve nomes, identifica fabricante pelo MAC e serviços (RDP, SMB, impressora, câmera, MikroTik…), classificando o tipo provável. *Copiar CSV* exporta a lista |
| Teste DNS | Compara o DNS atual com Google, Cloudflare, Quad9 e OpenDNS (média, mín., máx., falhas) e destaca o mais rápido |
| Teste de internet | Gateway → ping externo → DNS → HTTPS → IP público → download → upload (servidores Cloudflare, ~33 MB) |

## 7. Windows

**Reparo do sistema**
- **SFC /Scannow** — repara arquivos do sistema (5–20 min).
- **DISM** — *RestoreHealth* repara a imagem pelo Windows Update (execute antes do SFC quando o SFC não conseguir reparar). *CheckHealth/ScanHealth* apenas verificam. *Limpeza WinSxS* libera espaço.
- **Cache DNS** — `ipconfig /flushdns` (opcional: registrar no DNS).
- **Reset de rede** — Winsock, TCP/IP v4/v6, proxy WinHTTP, ARP, renovação de IP. **Requer reinício** e pode apagar IP fixo/proxy.
- **Rotina completa** — DISM → SFC → DNS em sequência.
- **Reiniciar computador** — agenda reinício em 1 min (pode ser cancelado).

**Limpeza** — selecione as categorias, clique em **Analisar espaço** (simulação, nada é apagado) e depois em **Limpar agora**. A Lixeira só é esvaziada se marcada (com confirmação). Arquivos em uso são ignorados automaticamente.

**Windows Update** — *Buscar*, *Buscar (incluir drivers)*, *Baixar e instalar*, *Histórico* e *Reparar Windows Update* (para erros de atualização: para serviços e renomeia SoftwareDistribution/catroot2).

**Drivers** — lista de drivers de terceiros com versão/data/assinatura, **dispositivos com problema** (código de erro e descrição), backup de todos os drivers para uma pasta (ótimo antes de formatar), restauração de backup, varredura de hardware e busca de drivers no Windows Update.

**Ferramentas do sistema** — 32 atalhos para ferramentas nativas (Gerenciador de Dispositivos, Serviços, Eventos, Disco, Registro, msconfig, Credenciais, Diagnóstico de Memória, Restauração…).

## 8. Segurança

- **Visão geral:** antivírus (Defender ou terceiros), firewall e serviços automáticos parados, com produtos registrados e ameaças recentes.
- **Windows Defender:** status detalhado (tempo real, comportamento, proteção contra adulteração, versão e idade das assinaturas, exclusões) e ações: verificação rápida, completa, atualizar assinaturas e verificação **offline** (reinicia o PC).
- **Firewall:** estado de cada perfil (Domínio/Privado/Público), redes conectadas, quantidade de regras; ativar todos os perfis com um clique.
- **Serviços críticos:** 25 serviços essenciais (Defender, Firewall, Windows Update, BITS, DNS, DHCP, Spooler, WMI…) com iniciar/parar/reiniciar.
- **Processos:** lista com CPU, memória, empresa e caminho; filtro; detalhes (linha de comando, processo pai); abrir local do arquivo; **Verificar assinaturas** marca executáveis sem assinatura válida (útil para identificar malware); finalizar processo.

## 9. Automação

- Escolha um script na lista (busca por nome/categoria) e clique em **Executar**. A saída aparece no painel abaixo.
- Scripts marcados **Requer cuidado** pedem confirmação.
- **Novo script:** nome, categoria, descrição e código. *Testar sem salvar* executa o rascunho. `Tab` insere 4 espaços.
- **Duplicar** cria uma cópia editável de um script da biblioteca padrão. **Exportar .ps1** e **Importar .ps1** permitem compartilhar scripts entre técnicos.
- Funções disponíveis nos seus scripts: `Executar 'programa.exe' 'argumentos'` (saída com acentuação correta), `Titulo 'texto'`, `Exigir-Admin`, `Eh-Admin`.

Biblioteca padrão (19): informações rápidas, programas instalados, inicialização, spooler, impressoras, ativação Windows/Office, usuários locais/administradores, saúde dos discos, relatório de bateria, reiniciar Explorer, sincronizar hora (NTP.br), erros críticos/BSOD, ponto de restauração, limpar cache do Windows Update, plano Alto Desempenho, CHKDSK, perfis Wi-Fi, portas em escuta, GPUpdate.

## 10. Inventário

1. Clique em **Coletar desta máquina** (até 1 min). São coletados hardware completo, SO, ativação, chave OEM da BIOS, últimas atualizações e todos os softwares instalados.
2. Escolha:
   - **Salvar** — guarda no histórico;
   - **Salvar e cadastrar equipamento** — cria o equipamento (marca, modelo, série, hostname, configuração) vinculado a um cliente no módulo Atendimento;
   - **PDF** — relatório técnico com logo, dados da empresa e campos de assinatura;
   - **Excel** — planilha com abas Equipamentos, Memória, Discos, Rede e Softwares.
3. Na lista de inventários salvos: visualizar, exportar, **vincular a equipamento** e excluir. **Exportar todos (Excel)** gera uma planilha consolidada do parque — ideal para levantamento em empresas.

## 11. Atendimento

**Fluxo recomendado:** cadastre o cliente → cadastre o equipamento (ou use o Inventário) → abra o chamado → registre o atendimento → feche o chamado → gere a Ordem de Serviço.

- **Clientes:** nome/razão social, CPF/CNPJ, contato, telefone, e-mail, endereço, observações. Ações: ver equipamentos, abrir chamado, editar, excluir.
- **Equipamentos:** tipo, marca, modelo, série, patrimônio, hostname, SO, configuração. Ações: registrar manutenção, ver histórico.
- **Histórico de manutenção:** data, tipo (preventiva, corretiva, upgrade, formatação…), serviço, peças, técnico e valor — com total por filtro.
- **Chamados:** título, cliente, equipamento, prioridade (Baixa/Média/Alta/Crítica), status (Aberto/Em andamento/Aguardando/Fechado/Cancelado), técnico, problema e solução/laudo. Ao **fechar**, o atendimento pode ser registrado automaticamente no histórico do equipamento. **Ordem de serviço (PDF)** gera o documento com laudo, histórico e assinaturas.
- **Exportar Excel:** planilha com clientes, equipamentos, chamados e manutenções.

## 12. Configurações

- **Usuários e segurança (admin):** criar técnicos/administradores (senha temporária exibida uma vez e trocada no 1º acesso), redefinir senha, desativar/excluir, tempo de bloqueio automático, exibição da chave OEM (mascarada por padrão), **gerar nova chave de recuperação** e **trilha de auditoria** (quem fez o quê e quando).
- **Empresa e marca:** nome da empresa, contato (aparece nos PDFs), técnico padrão e **logo personalizado** (PNG/JPG/SVG/WEBP até 1,5 MB) — aplicado na barra lateral, dashboard e relatórios.
- **Atualizações:** URL do manifesto `latest.json`, verificação automática ao iniciar, *Verificar agora* → *Baixar e instalar* (o app fecha, atualiza e reabre sozinho).
- **Dados e segurança:** pasta de dados, backup do banco, pasta padrão de relatórios, confirmação de scripts perigosos.
- **Sobre:** versão e ambiente.

## 13. Boas práticas de atendimento

1. Antes de qualquer reparo: **Automação → Criar ponto de restauração**.
2. Antes de formatar: **Inventário** (lista de softwares + chave OEM) e **Windows → Drivers → Backup de drivers** para o pendrive.
3. Windows corrompido: **DISM RestoreHealth → SFC → reiniciar** (ou *Rotina completa*).
4. Sem internet: **Rede → Teste de internet** identifica a etapa que falha (gateway, DNS, HTTPS); depois **Cache DNS** e, se necessário, **Reset de rede**.
5. Ao concluir: feche o chamado com o laudo e entregue a **Ordem de Serviço em PDF**.

## 14. Solução de problemas

| Sintoma | Causa / solução |
|---|---|
| "Sem privilégios de admin" | Abra o `.exe` aceitando o UAC, ou clique com o botão direito → *Executar como administrador* |
| SmartScreen bloqueia | Executável ainda sem assinatura digital: confira o SHA-256 ([como verificar](../README.md#-como-verificar-a-autenticidade-do-download)) e use *Mais informações → Executar assim mesmo* |
| Antivírus remove o `.exe` | Falso positivo de executável autoextraível; adicione exceção para a pasta do pendrive |
| "Arquivos do aplicativo foram modificados" | O executável ou seus scripts foram adulterados ou corrompidos — use uma cópia original |
| Esqueci a senha e a chave de recuperação | Não há como recuperar os dados (é o objetivo da criptografia). Restaure um backup do cofre cuja senha você saiba |
| Dados não são salvos | Pendrive protegido contra gravação — o app passa a usar `%APPDATA%\CoreAxisTechToolbox` (veja o caminho em *Configurações → Dados*) |
| Temperatura vazia | A placa não expõe sensores ACPI ao Windows |
| Teste de internet: download/upload falham | Proxy ou firewall corporativo bloqueando `speed.cloudflare.com` |
| Erros do aplicativo | Consulte `CoreAxisData\logs\erros-AAAA-MM-DD.log` |
