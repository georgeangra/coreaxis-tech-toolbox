const fs = require('fs');
const path = require('path');
// Gera as páginas de site/ (cabeçalho e rodapé compartilhados).  Uso: node scripts/gerar-site.js
const SITE = path.join(__dirname, '..', 'site');
const REPO = 'https://github.com/georgeangra/coreaxis-tech-toolbox';
const PAGES = [
  ['index.html', 'Início'], ['recursos.html', 'Recursos'], ['download.html', 'Download'],
  ['verificar.html', 'Verificar download'], ['changelog.html', 'Changelog'], ['privacidade.html', 'Privacidade'], ['contato.html', 'Contato'],
];

function page(file, title, desc, body) {
  const nav = PAGES.map(([f, t]) => `<a href="${f}"${f === file ? ' aria-current="page"' : ''}>${t}</a>`).join('');
  return `<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self' https://api.github.com; object-src 'none'; base-uri 'self'; form-action 'none'">
<meta name="referrer" content="strict-origin-when-cross-origin">
<title>${title}</title>
<meta name="description" content="${desc}">
<meta name="theme-color" content="#060B16">
<meta property="og:title" content="${title}">
<meta property="og:description" content="${desc}">
<meta property="og:image" content="assets/img/icon-192.png">
<link rel="icon" href="assets/img/icon.svg" type="image/svg+xml">
<link rel="icon" href="assets/img/icon-32.png" sizes="32x32">
<link rel="stylesheet" href="assets/css/site.css">
</head>
<body>
<a class="skip" href="#conteudo">Pular para o conteúdo</a>
<header class="top"><div class="wrap">
  <a class="brand" href="index.html"><img src="assets/img/icon.svg" alt=""><span>CoreAxis <b>Tech Toolbox</b></span></a>
  <button class="menu-btn" aria-label="Abrir menu" aria-expanded="false">☰</button>
  <nav class="menu" aria-label="Principal">${nav}</nav>
</div></header>
<main id="conteudo">
${body}
</main>
<footer><div class="wrap">
  <div>© <span data-ano>2026</span> <b>CoreAxis Tech</b> · Desenvolvedor: <b>George</b><br>
  Distribuição oficial exclusiva: <a href="${REPO}/releases">GitHub Releases</a></div>
  <div><a href="privacidade.html">Privacidade</a> · <a href="${REPO}/blob/main/SECURITY.md">Segurança</a> · <a href="${REPO}/blob/main/LICENSE">Licença</a> · <a href="${REPO}">GitHub</a></div>
</div></footer>
<script src="assets/js/site.js"></script>
</body>
</html>
`;
}

const verificacaoManual = `
<h3>PowerShell (Windows)</h3>
<pre>Get-FileHash .\\CoreAxisTechToolbox-1.1.1-portable.exe -Algorithm SHA256</pre>
<p>Compare o valor do campo <code>Hash</code> com o hash oficial. Maiúsculas e minúsculas não importam; <b>todos</b> os 64 caracteres devem ser iguais.</p>
<h3>Prompt de Comando</h3>
<pre>certutil -hashfile CoreAxisTechToolbox-1.1.1-portable.exe SHA256</pre>
<h3>Linux, macOS ou Git Bash</h3>
<p>Com o <code>SHA256.txt</code> da release na mesma pasta do arquivo:</p>
<pre>sha256sum -c SHA256.txt</pre>`;

const modulos = [
  ['📊', 'Dashboard', 'Visão do equipamento em segundos.', ['CPU, RAM e disco em tempo real', 'Antivírus, firewall e reinicialização pendente', 'Ações rápidas e chamados abertos']],
  ['🧩', 'Diagnóstico', 'Hardware completo via WMI/CIM.', ['Memória por módulo e slots livres', 'Discos com SMART, desgaste e temperatura', 'BIOS/UEFI, Secure Boot, TPM, bateria', 'Relatório em PDF']],
  ['🌐', 'Rede', 'Do ping à descoberta de dispositivos.', ['Ping, Traceroute, PathPing, NSLookup', 'Scanner de portas com perfis (CFTV, impressoras, AD…)', 'Descoberta automática com fabricante pelo MAC', 'Teste de DNS e de velocidade']],
  ['🛠️', 'Windows', 'Reparo e manutenção com saída em tempo real.', ['SFC, DISM e rotina completa', 'Limpeza com análise prévia', 'Windows Update e reparo de componentes', 'Drivers: problemas, backup e restauração', '32 atalhos para ferramentas nativas']],
  ['🛡️', 'Segurança', 'Postura de proteção do computador.', ['Windows Defender e antivírus de terceiros', 'Firewall por perfil', '25 serviços críticos', 'Processos com verificação de assinatura digital']],
  ['⚙️', 'Automação', 'PowerShell com um clique.', ['19 scripts prontos (spooler, ativação, SMART, eventos, NTP…)', 'Editor de scripts próprios', 'Confirmação para scripts sensíveis', 'Scripts publicados para auditoria']],
  ['📋', 'Inventário', 'Levantamento completo do parque.', ['Hardware, softwares e atualizações', 'Vínculo com cliente e equipamento', 'Relatórios PDF e planilhas Excel']],
  ['🎧', 'Atendimento', 'Gestão do suporte de ponta a ponta.', ['Clientes, equipamentos e manutenções', 'Chamados com prioridade e status', 'Ordem de Serviço em PDF com sua marca']],
];
const cartoesModulos = (detalhe) => modulos.map(([ic, t, d, itens]) => `
    <article class="cartao"><div class="ic" aria-hidden="true">${ic}</div><h3>${t}</h3><p>${d}</p>${detalhe ? `<ul>${itens.map((i) => `<li>${i}</li>`).join('')}</ul>` : ''}</article>`).join('');

const out = {
'index.html': page('index.html', 'CoreAxis Tech Toolbox — a caixa de ferramentas portátil do técnico de TI',
'Suíte portátil para Windows 10/11: diagnóstico, rede, reparo, segurança, automação, inventário e atendimento. Sem instalação, sem coleta de dados, verificável por SHA-256.', `
<section class="hero"><div class="wrap">
  <div>
    <h1>A caixa de ferramentas <em>portátil</em> do técnico de TI</h1>
    <p class="lead">Diagnóstico, rede, reparo do Windows, segurança, automação, inventário e atendimento — em um único executável que roda direto do pendrive.</p>
    <div class="acoes">
      <a class="btn primario grande" href="download.html">⬇ Baixar grátis por 15 dias</a>
      <a class="btn grande" href="recursos.html">Ver recursos</a>
    </div>
    <p class="meta">Windows 10 e 11 · 64 bits · Sem instalação · Distribuído pelo GitHub</p>
    <div class="selos">
      <span class="selo">🔐 <b>SHA-256</b> publicado em cada versão</span>
      <span class="selo">🛡️ Dados criptografados <b>AES-256</b></span>
      <span class="selo">🚫 <b>Zero</b> coleta de dados</span>
      <span class="selo">📜 Scripts <b>auditáveis</b></span>
    </div>
  </div>
  <img class="icone" src="assets/img/icon.svg" alt="Ícone do CoreAxis Tech Toolbox">
</div></section>

<section><div class="wrap">
  <h2>Tudo o que o atendimento precisa</h2>
  <p class="sub">Oito módulos integrados substituem a coleção de utilitários soltos, planilhas e o sistema de chamados.</p>
  <div class="grade">${cartoesModulos(false)}</div>
  <p style="margin-top:24px"><a href="recursos.html">Conheça cada recurso em detalhe →</a></p>
</div></section>

<section class="alt"><div class="wrap">
  <h2>Por que técnicos confiam</h2>
  <p class="sub">Uma ferramenta que roda como administrador no computador do seu cliente precisa ser transparente.</p>
  <div class="grade">
    <article class="cartao"><div class="ic">🔐</div><h3>Integridade verificável</h3><p>Cada versão publica o SHA-256 oficial. Confira em segundos, no PowerShell ou <a href="verificar.html">no navegador</a>.</p></article>
    <article class="cartao"><div class="ic">🚫</div><h3>Sem coleta de dados</h3><p>Sem telemetria, sem cadastro online. Clientes, chamados e inventários ficam só no seu dispositivo.</p></article>
    <article class="cartao"><div class="ic">🛡️</div><h3>Cofre criptografado</h3><p>AES-256-GCM, login por técnico, bloqueio automático e trilha de auditoria. Apoia a conformidade com a LGPD.</p></article>
    <article class="cartao"><div class="ic">📜</div><h3>Código auditável</h3><p>Os scripts PowerShell executados estão <a href="${REPO}/tree/main/auditoria">publicados</a> e são conferidos por hash antes de rodar.</p></article>
    <article class="cartao"><div class="ic">💾</div><h3>Portátil de verdade</h3><p>Um único .exe. Não instala nada e não altera o sistema do cliente. Com licença, não deixa rastros no PC atendido.</p></article>
    <article class="cartao"><div class="ic">🇧🇷</div><h3>Feito para o Brasil</h3><p>Interface em português, CPF/CNPJ, R$, laudo técnico, NTP.br e suporte em português.</p></article>
  </div>
</div></section>

<section><div class="wrap">
  <h2>Comece em 3 passos</h2>
  <ol class="passos">
    <li><b>Baixe</b> o executável na <a href="download.html">página de download</a> (GitHub Releases).</li>
    <li><b>Verifique</b> o SHA-256 — <code>Get-FileHash .\\arquivo.exe -Algorithm SHA256</code>.</li>
    <li><b>Abra</b> no pendrive, crie seu usuário e use 15 dias grátis com todas as funções.</li>
  </ol>
  <a class="btn primario" href="download.html">⬇ Ir para o download</a>
</div></section>`),

'recursos.html': page('recursos.html', 'Recursos — CoreAxis Tech Toolbox', 'Todos os módulos e funcionalidades do CoreAxis Tech Toolbox.', `
<section><div class="wrap">
  <h1>Recursos</h1>
  <p class="sub">Oito módulos integrados, pensados para o fluxo real do atendimento técnico: diagnosticar, reparar, documentar e entregar.</p>
  <div class="grade">${cartoesModulos(true)}</div>
</div></section>
<section class="alt"><div class="wrap">
  <h2>Segurança e privacidade embutidas</h2>
  <table>
    <tr><th>Recurso</th><th>Como funciona</th></tr>
    <tr><td>Cofre de dados</td><td>Banco SQLite inteiro criptografado com AES-256-GCM; chaves derivadas por scrypt; decifrado somente em memória.</td></tr>
    <tr><td>Contas e perfis</td><td>Administrador e Técnico, senha temporária com troca obrigatória, chave de recuperação.</td></tr>
    <tr><td>Bloqueios</td><td>Bloqueio progressivo contra tentativas de senha e bloqueio automático por inatividade.</td></tr>
    <tr><td>Auditoria</td><td>Registro de logins, alterações e scripts executados (com hash), por usuário.</td></tr>
    <tr><td>Integridade</td><td>Pacote do executável protegido; scripts conferidos por SHA-256 antes de executar.</td></tr>
    <tr><td>Atualizações</td><td>Somente pacotes com assinatura digital Ed25519 oficial, por HTTPS, sem permitir voltar a versões antigas.</td></tr>
    <tr><td>Relatórios</td><td>Chave de produto do Windows mascarada por padrão.</td></tr>
  </table>
</div></section>
<section><div class="wrap">
  <h2>Licença e uso</h2>
  <ul>
    <li><b>15 dias de teste</b> com todas as funções — um teste por dispositivo (baixar de novo não reinicia).</li>
    <li>Licença paga por dispositivo: <b>um pendrive</b> (use em qualquer PC) <b>ou um computador</b>. Ativação offline.</li>
    <li>Ao vencer: <b>modo consulta</b> — seus dados continuam acessíveis e exportáveis.</li>
  </ul>
  <a class="btn primario" href="download.html">⬇ Baixar</a> <a class="btn" href="contato.html">Licenças comerciais</a>
</div></section>`),

'download.html': page('download.html', 'Download — CoreAxis Tech Toolbox', 'Baixe a versão oficial do CoreAxis Tech Toolbox e verifique o SHA-256.', `
<section><div class="wrap">
  <h1>Download</h1>
  <p class="sub">Distribuição oficial exclusiva pelo GitHub. Desconfie de cópias em outros sites.</p>
  <div class="cartao" data-download><p>Carregando a versão mais recente…</p>
    <a class="btn primario grande" href="${REPO}/releases/latest">⬇ Ir para a página de download no GitHub</a></div>

  <h2 id="licenca" style="margin-top:44px">Download gratuito, uso licenciado</h2>
  <div class="aviso"><b>Baixar é grátis, mas o CoreAxis Tech Toolbox não é um programa gratuito.</b> O download inclui <b>15 dias de teste</b> com todas as funções. Depois disso, é preciso comprar uma licença para continuar usando as ferramentas.</div>
  <table style="margin-top:16px">
    <tr><th>Como funciona</th><th>Detalhes</th></tr>
    <tr><td>Teste de 15 dias</td><td>Começa no primeiro uso, com todas as funções liberadas.</td></tr>
    <tr><td><b>Um teste por dispositivo</b></td><td>Baixar de novo, apagar a pasta <code>CoreAxisData</code>, trocar o programa de pasta ou atrasar o relógio do Windows <b>não reinicia</b> o teste. A data de início fica registrada no computador e no pendrive onde o programa foi usado.</td></tr>
    <tr><td><b>Uma licença = um dispositivo</b></td><td>Cada licença é emitida para <b>um único pendrive</b> (use em qualquer computador) <b>ou um único computador</b>. Copiar o programa para outro pendrive ou PC não leva a licença junto.</td></tr>
    <tr><td>Ativação offline</td><td>No programa, em <i>Configurações → Licença</i>, copie o <b>código do dispositivo</b> (<code>CX-P-…</code> pendrive, <code>CX-M-…</code> computador) e envie para a CoreAxis Tech. Você recebe a chave de licença e cola no mesmo lugar. Não precisa de internet.</td></tr>
    <tr><td>Fim do teste ou da licença</td><td><b>Modo consulta:</b> as ferramentas são bloqueadas, mas seus clientes, chamados e inventários continuam acessíveis e exportáveis. Você nunca perde seus dados.</td></tr>
  </table>
  <p style="margin-top:14px"><a class="btn" href="contato.html">Comprar ou renovar licença</a></p>

  <h2 style="margin-top:44px">Requisitos</h2>
  <ul>
    <li>Windows 10 (1809 ou superior) ou Windows 11, 64 bits</li>
    <li>Permissão de administrador (o programa solicita ao abrir)</li>
    <li>~110 MB livres · nenhuma dependência adicional</li>
  </ul>

  <h2 style="margin-top:36px">Instalação</h2>
  <ol class="passos">
    <li>Crie uma pasta exclusiva, por exemplo <code>E:\\CoreAxis</code> no pendrive ou <code>C:\\CoreAxis</code>.</li>
    <li>Coloque o arquivo baixado dentro dela e <a href="#autenticidade">verifique o SHA-256</a>.</li>
    <li>Dê dois cliques e aceite o pedido de administrador.</li>
    <li>Aceite o contrato de uso, crie o usuário administrador e <b>anote a chave de recuperação</b> fora do pendrive.</li>
  </ol>
  <div class="aviso"><b>"O Windows protegeu o computador"?</b> O executável ainda não tem assinatura digital Authenticode (planejada). Confirme o SHA-256 e clique em <i>Mais informações → Executar assim mesmo</i>.</div>

  <h2 id="autenticidade" style="margin-top:44px">Como verificar a autenticidade do download</h2>
  <p>O hash SHA-256 é a "impressão digital" do arquivo: qualquer alteração, por menor que seja, muda o hash completamente. Se o hash do seu arquivo for igual ao oficial, o arquivo é exatamente o publicado pela CoreAxis Tech.</p>
  <div class="info">Mais fácil: use o <a href="verificar.html">verificador no navegador</a> — arraste o arquivo e pronto. O cálculo é feito no seu computador; o arquivo não é enviado.</div>
  ${verificacaoManual}
  <p>Hashes oficiais: <a href="${REPO}/blob/main/SHA256.txt">SHA256.txt</a> · anexos de cada <a href="${REPO}/releases">release</a> · <a href="verificar.html">lista no site</a>.</p>
  <div class="aviso"><b>O hash não confere?</b> Não execute. Apague o arquivo, baixe novamente pelo GitHub oficial e, se persistir, <a href="${REPO}/security/advisories/new">relate em privado</a>.</div>
</div></section>`),

'verificar.html': page('verificar.html', 'Verificar download — CoreAxis Tech Toolbox', 'Confira o SHA-256 do arquivo baixado diretamente no navegador, sem enviar o arquivo.', `
<section><div class="wrap">
  <h1>Verificação de integridade</h1>
  <p class="sub">Arraste o arquivo baixado abaixo. O SHA-256 é calculado <b>no seu navegador</b> — o arquivo não é enviado para nenhum servidor.</p>
  <div class="drop" data-drop tabindex="0" role="button" aria-label="Selecionar arquivo para verificar">
    <input type="file" aria-hidden="true">
    <div style="font-size:42px" aria-hidden="true">🔐</div>
    <p style="margin:6px 0 0"><b>Arraste o arquivo aqui</b> ou clique para selecionar</p>
    <p style="margin:4px 0 0;color:var(--muted);font-size:14px">.exe ou .zip baixado da release</p>
  </div>
  <div class="barra"><div></div></div>
  <div class="resultado" data-resultado role="status" aria-live="polite"></div>

  <h2 style="margin-top:44px">Já tem o hash? Compare aqui</h2>
  <form data-comparar style="display:flex;gap:10px;flex-wrap:wrap">
    <label for="hash-in" class="skip">Hash SHA-256</label>
    <input id="hash-in" class="mono" placeholder="Cole o valor do Get-FileHash" style="flex:1;min-width:260px;padding:12px;border-radius:10px;border:1px solid var(--borda);background:#050a14;color:var(--texto)">
    <button class="btn primario" type="submit">Comparar</button>
  </form>

  <h2 style="margin-top:44px">Hashes oficiais publicados</h2>
  <div class="cartao" style="overflow-x:auto"><table><thead><tr><th>Versão</th><th>Arquivo</th><th>SHA-256</th></tr></thead>
    <tbody data-lista-hashes><tr><td colspan="3">Carregando…</td></tr></tbody></table></div>

  <h2 id="manual" style="margin-top:44px">Como verificar a autenticidade do download (manual)</h2>
  ${verificacaoManual}
</div></section>`),

'changelog.html': page('changelog.html', 'Changelog — CoreAxis Tech Toolbox', 'Histórico de versões do CoreAxis Tech Toolbox.', `
<section><div class="wrap">
  <h1>Changelog</h1>
  <p class="sub">Histórico de versões. Versão completa e atualizada em <a href="${REPO}/blob/main/CHANGELOG.md">CHANGELOG.md</a>.</p>
  <div class="versao"><h3>Próxima versão</h3><span class="data">em desenvolvimento</span>
    <h4>Adicionado</h4><ul><li>Nova identidade visual e ícone baseados na marca CoreAxis Tech.</li><li>Publicação oficial pelo GitHub com SHA-256, verificação no navegador e scripts para auditoria.</li><li>Atualizações automáticas servidas pelas releases do GitHub, com assinatura Ed25519.</li><li>Preparação para assinatura digital Authenticode.</li></ul>
    <h4>Segurança</h4><ul><li>Teste de 15 dias passa a ser um por dispositivo: baixar de novo, trocar de pasta ou atrasar o relógio não reinicia o teste.</li></ul></div>
  <div class="versao"><h3>1.1.1</h3><span class="data">07/10/2026</span>
    <h4>Corrigido</h4><ul><li>Botões "Copiar" voltaram a funcionar em todo o programa.</li></ul>
    <h4>Segurança</h4><ul><li>Permissão de área de transferência restrita à escrita e à interface oficial; teste automatizado contra regressão.</li></ul></div>
  <div class="versao"><h3>1.1.0</h3><span class="data">07/10/2026</span>
    <h4>Adicionado</h4><ul><li>Licenciamento offline por pendrive ou computador, teste de 15 dias e modo consulta.</li><li>Contrato de uso, contas por técnico, chave de recuperação e trilha de auditoria.</li></ul>
    <h4>Segurança</h4><ul><li>Cofre AES-256-GCM com scrypt, bloqueios de acesso, integridade SHA-256 dos scripts, Electron Fuses, protocolo privado com CSP, atualizações assinadas, chave OEM mascarada.</li></ul></div>
  <div class="versao"><h3>1.0.0</h3><span class="data">07/10/2026</span>
    <h4>Adicionado</h4><ul><li>Primeira versão com os 8 módulos, relatórios PDF/Excel e executável portátil.</li></ul></div>
</div></section>`),

'privacidade.html': page('privacidade.html', 'Privacidade e transparência — CoreAxis Tech Toolbox', 'O CoreAxis Tech Toolbox não coleta informações pessoais e não envia dados a terceiros.', `
<section><div class="wrap">
  <h1>Privacidade e transparência</h1>
  <p class="sub">Declaração institucional da CoreAxis Tech sobre o CoreAxis Tech Toolbox.</p>
  <div class="grade">
    <article class="cartao"><div class="ic">🚫</div><h3>Não coleta informações pessoais</h3><p>Sem telemetria, analytics, rastreamento ou cadastro online. A CoreAxis Tech não recebe nenhuma informação sobre quem usa o programa.</p></article>
    <article class="cartao"><div class="ic">🔒</div><h3>Não envia dados a terceiros</h3><p>Clientes, chamados e inventários ficam só no seu dispositivo, num cofre AES-256. Nem a CoreAxis Tech tem acesso.</p></article>
    <article class="cartao"><div class="ic">🔐</div><h3>Validável por SHA-256</h3><p>Cada versão publica o hash oficial. <a href="verificar.html">Verifique aqui</a>.</p></article>
    <article class="cartao"><div class="ic">🐙</div><h3>Distribuído pelo GitHub</h3><p>Único canal oficial: <a href="${REPO}/releases">GitHub Releases</a>.</p></article>
    <article class="cartao"><div class="ic">📜</div><h3>Código auditável</h3><p>Os scripts PowerShell executados com privilégios de administrador são <a href="${REPO}/tree/main/auditoria">publicados</a> e conferidos por hash pelo próprio programa.</p></article>
  </div>
  <h2 style="margin-top:44px">Quando o programa usa a internet</h2>
  <table>
    <tr><th>Função</th><th>Destino</th><th>Quando</th></tr>
    <tr><td>Teste de internet</td><td>speed.cloudflare.com, google.com, api.ipify.org</td><td>Quando você clica em "Iniciar teste"</td></tr>
    <tr><td>Ping, traceroute, DNS, scanner</td><td>Endereços que você informar / sua rede local</td><td>Quando você executa</td></tr>
    <tr><td>Teste de DNS</td><td>Google, Cloudflare, Quad9, OpenDNS</td><td>Quando você executa</td></tr>
    <tr><td>Verificar atualizações</td><td>github.com</td><td>Ao iniciar (administradores; desativável) ou ao clicar em "Verificar agora". Nenhum dado seu é enviado</td></tr>
  </table>
  <p><b>Marcador do período de teste:</b> enquanto o programa está <b>sem licença</b>, ele grava um pequeno marcador com apenas duas datas (início do teste e último uso) — no registro do usuário do Windows (<code>HKCU\\Software\\CoreAxis</code>), em <code>%ProgramData%\\CoreAxis</code> e, se rodar de um pendrive, num arquivo oculto na raiz dele. Serve só para impedir que o teste seja reiniciado; não contém dados pessoais e nunca sai do computador. Com licença válida, nada é gravado fora da pasta do programa.</p>
  <p>A ativação de licença é offline. O código do dispositivo é um resumo criptográfico calculado localmente e só é enviado à CoreAxis Tech se você decidir enviá-lo para comprar ou renovar uma licença.</p>
  <p>Como os dados ficam apenas no seu dispositivo, você é o controlador dos dados pessoais de seus clientes (LGPD). Texto completo: <a href="${REPO}/blob/main/PRIVACIDADE.md">PRIVACIDADE.md</a>.</p>
</div></section>`),

'contato.html': page('contato.html', 'Contato — CoreAxis Tech Toolbox', 'Suporte, licenças comerciais e relato de segurança do CoreAxis Tech Toolbox.', `
<section><div class="wrap">
  <h1>Contato</h1>
  <p class="sub">Escolha o canal certo para cada assunto.</p>
  <div class="grade">
    <article class="cartao"><div class="ic">🐞</div><h3>Problemas</h3><p>Algo não funcionou? Abra um relato com versão, Windows e passos.</p><p style="margin-top:12px"><a class="btn" href="${REPO}/issues/new?template=bug_report.yml">Relatar problema</a></p></article>
    <article class="cartao"><div class="ic">💡</div><h3>Sugestões</h3><p>Ideias de ferramentas e scripts que facilitariam seu atendimento.</p><p style="margin-top:12px"><a class="btn" href="${REPO}/issues/new?template=feature_request.yml">Sugerir</a></p></article>
    <article class="cartao"><div class="ic">🔒</div><h3>Segurança</h3><p>Vulnerabilidades: <b>somente</b> pelo canal privado. Nunca em issue pública.</p><p style="margin-top:12px"><a class="btn" href="${REPO}/security/advisories/new">Relato privado</a></p></article>
    <article class="cartao"><div class="ic">💼</div><h3>Licenças comerciais</h3><p>Compra, renovação e transferência. Tenha em mãos o <b>código do dispositivo</b> (Configurações → Licença).</p><div data-contato-comercial style="margin-top:10px"></div></article>
  </div>
  <div class="info" style="margin-top:30px"><b>Nunca envie</b> senhas, chave de recuperação ou dados de clientes por nenhum canal. A CoreAxis Tech nunca pede essas informações.</div>
  <h2 style="margin-top:44px">Desenvolvedor</h2>
  <div class="cartao" style="display:flex;gap:18px;align-items:center;flex-wrap:wrap">
    <img src="assets/img/icon.svg" alt="" width="64" height="64">
    <div><b>CoreAxis Tech</b> — soluções em suporte técnico e automação de TI<br>Desenvolvedor: <b>George</b> · <a href="https://github.com/georgeangra">github.com/georgeangra</a></div>
  </div>
</div></section>`),

'404.html': page('404.html', 'Página não encontrada — CoreAxis Tech Toolbox', 'Página não encontrada.', `
<section><div class="wrap" style="text-align:center;padding:60px 0">
  <h1>Página não encontrada</h1><p class="sub" style="margin:0 auto 24px">O endereço pode ter mudado.</p>
  <a class="btn primario" href="index.html">Ir para o início</a>
</div></section>`),
};

for (const [f, html] of Object.entries(out)) fs.writeFileSync(path.join(SITE, f), html, 'utf8');
fs.writeFileSync(path.join(SITE, '.nojekyll'), '');
console.log('páginas:', Object.keys(out).join(', '));
