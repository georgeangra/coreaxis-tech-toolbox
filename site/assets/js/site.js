/* CoreAxis Tech Toolbox — scripts do site (sem rastreamento, sem bibliotecas externas) */
const CX = {
  repo: 'georgeangra/coreaxis-tech-toolbox',
  // Contato comercial (opcional): preencha para exibir na página de contato.
  contato: { email: '', whatsapp: '+55 (62) 99802-2601' },
};

// Menu móvel
document.addEventListener('click', (e) => {
  const b = e.target.closest('.menu-btn');
  if (b) {
    const m = document.querySelector('nav.menu');
    const aberto = m.classList.toggle('aberto');
    b.setAttribute('aria-expanded', aberto);
  }
});

// Ano no rodapé
document.querySelectorAll('[data-ano]').forEach((el) => { el.textContent = new Date().getFullYear(); });

/** Hashes oficiais publicados (site/hashes.json, atualizado pelo pipeline de release). */
async function cxHashes() {
  const r = await fetch('hashes.json', { cache: 'no-store' });
  if (!r.ok) throw new Error('hashes.json indisponível');
  return r.json();
}

/** Última release no GitHub (API pública, sem autenticação). */
async function cxUltimaRelease() {
  const r = await fetch(`https://api.github.com/repos/${CX.repo}/releases/latest`, { headers: { Accept: 'application/vnd.github+json' } });
  if (!r.ok) throw new Error(`GitHub respondeu ${r.status}`);
  return r.json();
}

const cxTam = (b) => (b > 1048576 ? `${(b / 1048576).toFixed(1)} MB` : `${Math.round(b / 1024)} KB`);
const cxEsc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// Página de download: preenche versão, link direto e hash
(async () => {
  const alvo = document.querySelector('[data-download]');
  if (!alvo) return;
  let dados = null;
  try { dados = await cxHashes(); } catch { /* segue com a API */ }
  try {
    const rel = await cxUltimaRelease();
    const exe = rel.assets.find((a) => /-portable\.exe$/i.test(a.name));
    const ver = rel.tag_name.replace(/^v/, '');
    const oficial = dados?.releases.find((r) => r.version === ver)?.files.find((f) => f.name === exe?.name);
    alvo.innerHTML = `
      <p><b>Versão ${cxEsc(ver)}</b> · publicada em ${new Date(rel.published_at).toLocaleDateString('pt-BR')}</p>
      ${exe ? `<a class="btn primario grande" href="${cxEsc(exe.browser_download_url)}">⬇ Baixar ${cxEsc(exe.name)} (${cxTam(exe.size)})</a>` : ''}
      <p style="margin-top:16px">SHA-256 oficial do executável:</p>
      <div class="hash">${cxEsc(oficial?.sha256?.toUpperCase() || 'consulte o SHA256.txt anexo à release')}</div>
      <p style="margin-top:10px"><a href="${cxEsc(rel.html_url)}">Ver todos os arquivos da release, notas e SHA256.txt →</a></p>`;
  } catch {
    const v = dados?.latest;
    const f = dados?.releases.find((r) => r.version === v)?.files.find((x) => /\.exe$/.test(x.name));
    alvo.innerHTML = `
      ${v ? `<p><b>Versão ${cxEsc(v)}</b></p>` : ''}
      <a class="btn primario grande" href="https://github.com/${CX.repo}/releases/latest">⬇ Ir para a página de download no GitHub</a>
      ${f ? `<p style="margin-top:16px">SHA-256 oficial de <code>${cxEsc(f.name)}</code>:</p><div class="hash">${cxEsc(f.sha256.toUpperCase())}</div>` : ''}`;
  }
})();

// Página de download: versão Linux (AppImage), a partir de site/hashes.json (campo "linux")
(async () => {
  const alvo = document.querySelector('[data-download-linux]');
  if (!alvo) return;
  try {
    const d = await cxHashes();
    const v = d.linux;
    const rel = d.releases.find((r) => r.version === `linux-${v}`);
    if (!v || !rel) throw new Error('sem versão Linux');
    const base = `https://github.com/${CX.repo}/releases/download/linux-v${encodeURIComponent(v)}/`;
    const app = rel.files.find((x) => /\.AppImage$/.test(x.name));
    const ini = rel.files.find((x) => /\.sh$/.test(x.name));
    alvo.innerHTML = `
      <p><b>Versão ${cxEsc(v)} para Linux</b> · publicada em ${cxEsc(rel.date.split('-').reverse().join('/'))}</p>
      <div style="display:flex;gap:10px;flex-wrap:wrap">
        ${app ? `<a class="btn primario grande" href="${base}${encodeURIComponent(app.name)}">⬇ Baixar ${cxEsc(app.name)} (${cxTam(app.size)})</a>` : ''}
        ${ini ? `<a class="btn grande" href="${base}${encodeURIComponent(ini.name)}">⬇ ${cxEsc(ini.name)}</a>` : ''}
      </div>
      ${app ? `<p style="margin-top:16px">SHA-256 oficial do AppImage:</p><div class="hash">${cxEsc(app.sha256.toUpperCase())}</div>` : ''}
      <p style="margin-top:10px"><a href="https://github.com/${CX.repo}/releases/tag/linux-v${cxEsc(v)}">Ver todos os arquivos, notas e SHA256.txt da versão Linux →</a></p>`;
  } catch { /* mantém o link para as releases */ }
})();

// Página de contato: exibe contatos comerciais configurados
(() => {
  const el = document.querySelector('[data-contato-comercial]');
  if (!el) return;
  const itens = [];
  if (CX.contato.email) itens.push(`<li>E-mail: <a href="mailto:${cxEsc(CX.contato.email)}">${cxEsc(CX.contato.email)}</a></li>`);
  if (CX.contato.whatsapp) itens.push(`<li>WhatsApp: <a href="https://wa.me/${cxEsc(CX.contato.whatsapp.replace(/\D/g, ''))}">${cxEsc(CX.contato.whatsapp)}</a></li>`);
  itens.push(`<li>GitHub: <a href="https://github.com/${CX.repo}/discussions">Discussões do projeto</a></li>`);
  el.innerHTML = `<ul>${itens.join('')}</ul>`;
})();

// Página de verificação: SHA-256 calculado no navegador (o arquivo não sai do seu computador)
(async () => {
  const drop = document.querySelector('[data-drop]');
  if (!drop) return;
  const input = drop.querySelector('input');
  const res = document.querySelector('[data-resultado]');
  const barra = document.querySelector('.barra');
  let oficiais = [];
  try {
    const d = await cxHashes();
    oficiais = d.releases.flatMap((r) => r.files.map((f) => ({ ...f, version: r.version })));
    const lista = document.querySelector('[data-lista-hashes]');
    if (lista) {
      lista.innerHTML = d.releases.map((r) => r.files.map((f) => `<tr><td>${cxEsc(r.version)}</td><td><code>${cxEsc(f.name)}</code></td><td class="mono" style="word-break:break-all">${cxEsc(f.sha256.toUpperCase())}</td></tr>`).join('')).join('');
    }
  } catch { /* lista indisponível */ }

  const mostrar = (cls, html) => { res.className = `resultado ${cls}`; res.innerHTML = html; };

  async function verificar(arquivo) {
    if (!window.crypto?.subtle) { mostrar('erro', 'Seu navegador não suporta o cálculo de SHA-256. Use o PowerShell (instruções abaixo).'); return; }
    mostrar('neutro', `Calculando SHA-256 de <b>${cxEsc(arquivo.name)}</b> (${cxTam(arquivo.size)})… o arquivo não é enviado a lugar nenhum.`);
    barra.style.display = 'block';
    const barraIn = barra.firstElementChild;
    barraIn.style.width = '35%';
    const buf = await arquivo.arrayBuffer();
    barraIn.style.width = '70%';
    const dig = await crypto.subtle.digest('SHA-256', buf);
    barraIn.style.width = '100%';
    const hex = [...new Uint8Array(dig)].map((b) => b.toString(16).padStart(2, '0')).join('');
    setTimeout(() => { barra.style.display = 'none'; barraIn.style.width = '0'; }, 600);
    const achado = oficiais.find((o) => o.sha256.toLowerCase() === hex);
    if (achado) {
      mostrar('ok', `<h3 style="margin:0 0 6px">✅ Arquivo autêntico</h3>
        O hash corresponde ao arquivo oficial <code>${cxEsc(achado.name)}</code> da versão <b>${cxEsc(achado.version)}</b>.
        ${achado.name !== arquivo.name ? '<br><small>(o nome do arquivo foi alterado, mas o conteúdo é idêntico ao oficial)</small>' : ''}
        <div class="hash" style="margin-top:12px">${hex.toUpperCase()}</div>`);
    } else {
      mostrar('erro', `<h3 style="margin:0 0 6px">⛔ Hash NÃO corresponde a nenhuma versão oficial</h3>
        <b>Não execute este arquivo.</b> Ele pode estar corrompido ou ter sido alterado. Baixe novamente apenas em
        <a href="https://github.com/${CX.repo}/releases/latest">github.com/${CX.repo}/releases</a>.
        <div class="hash" style="margin-top:12px">${hex.toUpperCase()}</div>`);
    }
  }

  drop.addEventListener('click', () => input.click());
  drop.addEventListener('keydown', (e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); input.click(); } });
  input.addEventListener('change', () => input.files[0] && verificar(input.files[0]));
  ['dragenter', 'dragover'].forEach((ev) => drop.addEventListener(ev, (e) => { e.preventDefault(); drop.classList.add('ativo'); }));
  ['dragleave', 'drop'].forEach((ev) => drop.addEventListener(ev, (e) => { e.preventDefault(); drop.classList.remove('ativo'); }));
  drop.addEventListener('drop', (e) => e.dataTransfer.files[0] && verificar(e.dataTransfer.files[0]));

  const form = document.querySelector('[data-comparar]');
  form?.addEventListener('submit', (e) => {
    e.preventDefault();
    const h = form.querySelector('input').value.trim().toLowerCase().replace(/[^0-9a-f]/g, '');
    if (h.length !== 64) { mostrar('erro', 'Cole um hash SHA-256 completo (64 caracteres hexadecimais).'); return; }
    const achado = oficiais.find((o) => o.sha256.toLowerCase() === h);
    mostrar(achado ? 'ok' : 'erro', achado
      ? `✅ Hash oficial de <code>${cxEsc(achado.name)}</code> (versão ${cxEsc(achado.version)}).`
      : '⛔ Este hash não corresponde a nenhuma versão oficial. Não execute o arquivo.');
  });
})();
