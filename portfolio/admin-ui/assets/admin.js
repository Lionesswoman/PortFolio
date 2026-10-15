const $ = (s, el = document) => el.querySelector(s);
const $$ = (s, el = document) => [...el.querySelectorAll(s)];
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

async function api(url, opts = {}) {
  const isForm = opts.body instanceof FormData;
  const res = await fetch('/api/admin' + url, { ...opts, headers: isForm ? {} : { 'Content-Type': 'application/json' } });
  if (res.status === 401) {
    location.href = 'login';
    throw new Error('Session expirée');
  }
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || 'Erreur serveur');
  return data;
}
const send = (url, method, body) => api(url, { method, body: body ? JSON.stringify(body) : undefined });

function toast(msg, type = 'ok') {
  const t = $('#toast');
  t.textContent = msg;
  t.className = `toast show ${type}`;
  clearTimeout(toast.timer);
  toast.timer = setTimeout(() => { t.className = 'toast'; }, 2800);
}

const IMG = 'image/png,image/jpeg,image/webp,image/gif';

const PROFILE_FIELDS = [
  { k: 'full_name', l: 'Nom complet' },
  { k: 'title', l: 'Titre (ex : Développeuse Full-Stack)' },
  { k: 'bio', l: 'Présentation', t: 'textarea' },
  { k: 'email', l: 'E-mail', t: 'email' },
  { k: 'phone', l: 'Téléphone' },
  { k: 'location', l: 'Localisation' },
  { k: 'github', l: 'Lien GitHub', t: 'url' },
  { k: 'linkedin', l: 'Lien LinkedIn', t: 'url' },
  { k: 'photo', l: 'Photo de profil', t: 'file', accept: IMG },
  { k: 'cv', l: 'CV (PDF)', t: 'file', accept: 'application/pdf' },
];

const SCHEMAS = {
  projects: {
    add: 'Ajouter un projet',
    cols: [['title', 'Titre'], ['context', 'Contexte'], ['tech', 'Technologies']],
    fields: [
      { k: 'title', l: 'Titre *', req: true },
      { k: 'context', l: 'Contexte (ex : Stage — Albatres Ingénierie)' },
      { k: 'summary', l: 'Résumé court (affiché sur la carte)', t: 'textarea' },
      { k: 'description', l: 'Description détaillée (affichée dans la fenêtre)', t: 'textarea' },
      { k: 'tech', l: 'Technologies (séparées par des virgules)' },
      { k: 'demo_url', l: 'Lien démo', t: 'url' },
      { k: 'repo_url', l: 'Lien GitHub', t: 'url' },
      { k: 'image', l: 'Image de couverture', t: 'file', accept: IMG },
      { k: 'sort_order', l: 'Ordre d’affichage', t: 'number' },
      { k: 'featured', l: 'Mettre en vedette', t: 'check' },
    ],
  },
  skills: {
    add: 'Ajouter une compétence',
    cols: [['name', 'Nom'], ['category', 'Catégorie'], ['level', 'Niveau %']],
    fields: [
      { k: 'name', l: 'Nom *', req: true },
      { k: 'category', l: 'Catégorie (Backend, Frontend, Mobile…)' },
      { k: 'level', l: 'Niveau (0 à 100)', t: 'number', min: 0, max: 100 },
      { k: 'sort_order', l: 'Ordre d’affichage', t: 'number' },
    ],
  },
  experiences: {
    add: 'Ajouter une étape',
    cols: [['period', 'Période'], ['title', 'Intitulé'], ['organization', 'Structure']],
    fields: [
      { k: 'type', l: 'Type', t: 'select', opts: [['formation', 'Formation'], ['stage', 'Stage'], ['experience', 'Expérience'], ['projet', 'Projet']] },
      { k: 'period', l: 'Période (ex : Juil. — Sept. 2026)' },
      { k: 'title', l: 'Intitulé *', req: true },
      { k: 'organization', l: 'Établissement / entreprise' },
      { k: 'description', l: 'Description', t: 'textarea' },
      { k: 'sort_order', l: 'Ordre d’affichage', t: 'number' },
    ],
  },
};

const TITLES = { profile: 'Mon profil', projects: 'Projets', skills: 'Compétences', experiences: 'Parcours', messages: 'Messages', security: 'Sécurité' };

function fieldHtml(f, value) {
  const v = value ?? '';
  const req = f.req ? 'required' : '';
  switch (f.t) {
    case 'textarea':
      return `<label class="full">${f.l}<textarea name="${f.k}" ${req}>${esc(v)}</textarea></label>`;
    case 'number':
      return `<label>${f.l}<input type="number" name="${f.k}" value="${esc(v)}" ${f.min != null ? `min="${f.min}"` : ''} ${f.max != null ? `max="${f.max}"` : ''}></label>`;
    case 'check':
      return `<label class="check"><input type="checkbox" name="${f.k}" ${Number(v) ? 'checked' : ''}> ${f.l}</label>`;
    case 'select':
      return `<label>${f.l}<select name="${f.k}">${f.opts.map(([val, lab]) => `<option value="${val}" ${val === v ? 'selected' : ''}>${lab}</option>`).join('')}</select></label>`;
    case 'file': {
      const isImg = v && !/\.pdf$/i.test(v);
      return `<div class="file-field full">
        <span>${f.l}</span>
        <input type="hidden" name="${f.k}" value="${esc(v)}">
        <div class="file-row">
          <img class="thumb ${isImg ? '' : 'hidden'}" ${isImg ? `src="${esc(v)}"` : ''} alt="">
          <input type="file" data-upload accept="${f.accept}">
          <a class="link-btn file-current ${v ? '' : 'hidden'}" href="${esc(v || '#')}" target="_blank" rel="noopener">Ouvrir</a>
          <button type="button" class="link-btn danger ${v ? '' : 'hidden'}" data-clear>Retirer</button>
        </div>
      </div>`;
    }
    default:
      return `<label>${f.l}<input type="${f.t || 'text'}" name="${f.k}" value="${esc(v)}" ${req}></label>`;
  }
}

function collect(form, fields) {
  const out = {};
  for (const f of fields) {
    const el = form.elements[f.k];
    if (!el) continue;
    if (f.t === 'check') out[f.k] = el.checked ? 1 : 0;
    else if (f.t === 'number') out[f.k] = el.value === '' ? 0 : Number(el.value);
    else out[f.k] = el.value.trim();
  }
  return out;
}

function setFile(box, url) {
  $('input[type=hidden]', box).value = url;
  const link = $('.file-current', box);
  link.href = url || '#';
  link.classList.toggle('hidden', !url);
  $('[data-clear]', box).classList.toggle('hidden', !url);
  const img = $('.thumb', box);
  const isImg = url && !/\.pdf$/i.test(url);
  if (isImg) img.src = url;
  img.classList.toggle('hidden', !isImg);
  if (!url) $('input[type=file]', box).value = '';
}

function bindUploads(form) {
  $$('input[data-upload]', form).forEach((inp) => inp.addEventListener('change', async () => {
    const file = inp.files[0];
    if (!file) return;
    const box = inp.closest('.file-field');
    const fd = new FormData();
    fd.append('file', file);
    box.classList.add('loading');
    try {
      const { url } = await api('/upload', { method: 'POST', body: fd });
      setFile(box, url);
      toast('Fichier envoyé');
    } catch (x) {
      toast(x.message, 'err');
      inp.value = '';
    } finally {
      box.classList.remove('loading');
    }
  }));
  $$('[data-clear]', form).forEach((b) => b.addEventListener('click', () => setFile(b.closest('.file-field'), '')));
}

async function show(tab) {
  $$('[data-tab]').forEach((b) => b.classList.toggle('active', b.dataset.tab === tab));
  $('#pageTitle').textContent = TITLES[tab];
  $('#sidebar').classList.remove('open');
  const v = $('#view');
  v.innerHTML = '<p class="muted">Chargement…</p>';
  try {
    if (tab === 'profile') await renderProfile();
    else if (tab === 'messages') await renderMessages();
    else if (tab === 'security') renderSecurity();
    else await renderList(tab);
  } catch (e) {
    v.innerHTML = `<p class="err">${esc(e.message)}</p>`;
  }
}

$$('[data-tab]').forEach((b) => b.addEventListener('click', () => show(b.dataset.tab)));
$('#menuBtn').addEventListener('click', () => $('#sidebar').classList.toggle('open'));
$('#logoutBtn').addEventListener('click', async () => {
  try { await send('/logout', 'POST'); } finally { location.href = 'login'; }
});

async function renderProfile() {
  const p = await api('/profile');
  $('#view').innerHTML = `<form id="profileForm" class="panel grid-form">
    ${PROFILE_FIELDS.map((f) => fieldHtml(f, p[f.k])).join('')}
    <div class="actions full"><button class="btn" type="submit">Enregistrer</button></div>
  </form>`;
  const form = $('#profileForm');
  bindUploads(form);
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    try {
      await send('/profile', 'PUT', collect(form, PROFILE_FIELDS));
      toast('Profil enregistré');
    } catch (x) {
      toast(x.message, 'err');
    }
  });
}

async function renderList(entity) {
  const s = SCHEMAS[entity];
  const rows = await api('/' + entity);
  const v = $('#view');
  v.innerHTML = `
    <div class="toolbar">
      <span class="muted">${rows.length} élément(s)</span>
      <button class="btn" id="addBtn" type="button">+ ${s.add}</button>
    </div>
    ${rows.length ? `<div class="panel table-wrap"><table>
      <thead><tr>${s.cols.map((c) => `<th>${c[1]}</th>`).join('')}<th></th></tr></thead>
      <tbody>${rows.map((r) => `<tr>
        ${s.cols.map(([k]) => `<td>${esc(r[k])}</td>`).join('')}
        <td><div class="row-actions">
          <button class="link-btn" type="button" data-edit="${r.id}">Modifier</button>
          <button class="link-btn danger" type="button" data-del="${r.id}">Supprimer</button>
        </div></td>
      </tr>`).join('')}</tbody>
    </table></div>` : '<div class="panel empty">Aucun élément pour l’instant.</div>'}`;

  $('#addBtn').addEventListener('click', () => openForm(entity));
  $$('[data-edit]', v).forEach((b) => b.addEventListener('click', () =>
    openForm(entity, rows.find((r) => r.id === Number(b.dataset.edit)))));
  $$('[data-del]', v).forEach((b) => b.addEventListener('click', async () => {
    if (!confirm('Supprimer définitivement cet élément ?')) return;
    try {
      await send(`/${entity}/${b.dataset.del}`, 'DELETE');
      toast('Élément supprimé');
      renderList(entity);
    } catch (x) {
      toast(x.message, 'err');
    }
  }));
}

function openForm(entity, row = {}) {
  const s = SCHEMAS[entity];
  $('#modalTitle').textContent = row.id ? 'Modifier' : s.add;
  const form = $('#modalForm');
  form.innerHTML = s.fields.map((f) => fieldHtml(f, row[f.k])).join('') + `
    <div class="actions full">
      <button type="button" class="btn ghost" data-close>Annuler</button>
      <button class="btn" type="submit">${row.id ? 'Enregistrer' : 'Ajouter'}</button>
    </div>`;
  bindUploads(form);
  form.onsubmit = async (e) => {
    e.preventDefault();
    try {
      const data = collect(form, s.fields);
      if (row.id) await send(`/${entity}/${row.id}`, 'PUT', data);
      else await send(`/${entity}`, 'POST', data);
      closeModal();
      toast('Enregistré');
      renderList(entity);
    } catch (x) {
      toast(x.message, 'err');
    }
  };
  $('#modal').classList.add('open');
}

function closeModal() { $('#modal').classList.remove('open'); }
$('#modal').addEventListener('click', (e) => {
  if (e.target.id === 'modal' || e.target.closest('[data-close]')) closeModal();
});
addEventListener('keydown', (e) => { if (e.key === 'Escape') closeModal(); });

function updateBadge(list) {
  const n = list.filter((m) => !m.is_read).length;
  const b = $('#msgBadge');
  b.textContent = n;
  b.classList.toggle('hidden', !n);
}

async function renderMessages() {
  const list = await api('/messages');
  updateBadge(list);
  const v = $('#view');
  if (!list.length) {
    v.innerHTML = '<div class="panel empty">Aucun message reçu.</div>';
    return;
  }
  v.innerHTML = list.map((m) => `
    <article class="panel msg ${m.is_read ? '' : 'unread'}">
      <header>
        <div><strong>${esc(m.name)}</strong><a href="mailto:${esc(m.email)}">${esc(m.email)}</a></div>
        <time>${new Date(m.created_at).toLocaleString('fr-FR')}</time>
      </header>
      ${m.subject ? `<h4>${esc(m.subject)}</h4>` : ''}
      <p>${esc(m.message)}</p>
      <div class="row-actions start">
        <a class="link-btn" href="mailto:${esc(m.email)}?subject=${encodeURIComponent('Re : ' + (m.subject || 'Votre message'))}">Répondre</a>
        ${m.is_read ? '' : `<button class="link-btn" type="button" data-read="${m.id}">Marquer comme lu</button>`}
        <button class="link-btn danger" type="button" data-delmsg="${m.id}">Supprimer</button>
      </div>
    </article>`).join('');

  $$('[data-read]', v).forEach((b) => b.addEventListener('click', async () => {
    try { await send(`/messages/${b.dataset.read}/read`, 'PATCH'); renderMessages(); } catch (x) { toast(x.message, 'err'); }
  }));
  $$('[data-delmsg]', v).forEach((b) => b.addEventListener('click', async () => {
    if (!confirm('Supprimer ce message ?')) return;
    try { await send(`/messages/${b.dataset.delmsg}`, 'DELETE'); toast('Message supprimé'); renderMessages(); } catch (x) { toast(x.message, 'err'); }
  }));
}

function renderSecurity() {
  $('#view').innerHTML = `<form id="pwdForm" class="panel grid-form narrow">
    <label class="full">Mot de passe actuel<input type="password" name="current" required autocomplete="current-password"></label>
    <label class="full">Nouveau mot de passe (8 caractères min.)<input type="password" name="next" minlength="8" required autocomplete="new-password"></label>
    <label class="full">Confirmer le nouveau mot de passe<input type="password" name="confirm" minlength="8" required autocomplete="new-password"></label>
    <div class="actions full"><button class="btn" type="submit">Changer le mot de passe</button></div>
  </form>`;
  $('#pwdForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const f = e.target;
    if (f.next.value !== f.confirm.value) return toast('Les mots de passe ne correspondent pas', 'err');
    try {
      await send('/password', 'PUT', { current: f.current.value, next: f.next.value });
      f.reset();
      toast('Mot de passe modifié');
    } catch (x) {
      toast(x.message, 'err');
    }
  });
}

(async () => {
  try {
    const me = await api('/me');
    $('#who').textContent = `Connecté : ${me.username}`;
    updateBadge(await api('/messages'));
  } catch { /* redirection gérée par api() */ }
  show('profile');
})();
