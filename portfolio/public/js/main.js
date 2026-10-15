const $ = (s, el = document) => el.querySelector(s);
const $$ = (s, el = document) => [...el.querySelectorAll(s)];
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const safeUrl = (u) => (/^(https?:\/\/|\/(?!\/))/i.test(u || '') ? u : ''); // liens http(s) ou chemins du site (/img, /docs, /uploads)
const techs = (p) => (p.tech || '').split(',').map((t) => t.trim()).filter(Boolean);
const initialsOf = (txt) => String(txt || '').split(/\s+/).filter(Boolean).map((w) => w[0]).slice(0, 2).join('').toUpperCase();
const TONES = ['violet', 'indigo', 'teal', 'amber', 'rose', 'sky'];
const ARROW = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"/></svg>';

const ICONS = {
  github: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 19c-4.3 1.4-4.3-2.5-6-3m12 5v-3.5c0-1 .1-1.4-.5-2 2.8-.3 5.5-1.4 5.5-6a4.6 4.6 0 0 0-1.3-3.2 4.2 4.2 0 0 0-.1-3.2s-1.1-.3-3.5 1.3a12.3 12.3 0 0 0-6.2 0C6.5 2.8 5.4 3.1 5.4 3.1a4.2 4.2 0 0 0-.1 3.2A4.6 4.6 0 0 0 4 9.5c0 4.6 2.7 5.7 5.5 6-.6.6-.6 1.2-.5 2V21"/></svg>',
  linkedin: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-4 0v7h-4v-7a6 6 0 0 1 6-6zM2 9h4v12H2zM4 2a2 2 0 1 1 0 4 2 2 0 0 1 0-4z"/></svg>',
  mail: '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg>',
  phone: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1.9.4 1.8.7 2.7a2 2 0 0 1-.5 2.1L8 9.8a16 16 0 0 0 6 6l1.3-1.3a2 2 0 0 1 2.1-.4c.9.3 1.8.6 2.7.7a2 2 0 0 1 1.7 2z"/></svg>',
  pin: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0z"/><circle cx="12" cy="10" r="3"/></svg>',
  formation: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M22 10L12 5 2 10l10 5 10-5z"/><path d="M6 12v5c3 2 9 2 12 0v-5"/></svg>',
  stage: '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2"/></svg>',
  experience: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2l3 7 7 .6-5.3 4.6 1.6 7L12 17.5 5.7 21.2l1.6-7L2 9.6 9 9z"/></svg>',
  projet: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4.5 16.5c-1.5 1.3-2 5-2 5s3.7-.5 5-2c.7-.8.7-2.1-.1-2.9a2.2 2.2 0 0 0-2.9-.1z"/><path d="M12 15l-3-3a22 22 0 0 1 2-4A12.9 12.9 0 0 1 22 2c0 2.7-.8 7.5-6 11a22 22 0 0 1-4 2z"/></svg>',
};
const TYPE_LABEL = { formation: 'Formation', stage: 'Stage', experience: 'Expérience', projet: 'Projet' };
const TYPE_TONE = { formation: 'indigo', stage: 'violet', experience: 'amber', projet: 'teal' };

let projects = [];
let profile = {};

/* ---------- Thème clair / nuit ---------- */
$('#themeBtn').addEventListener('click', () => {
  const next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  try { localStorage.setItem('theme', next); } catch { /* ignoré */ }
});

/* ---------- Menu mobile ---------- */
const menu = $('#menu');
const burger = $('#burger');
burger.addEventListener('click', () => {
  const open = menu.classList.toggle('open');
  burger.setAttribute('aria-expanded', open);
});
menu.addEventListener('click', (e) => {
  if (e.target.tagName !== 'A') return;
  menu.classList.remove('open');
  burger.setAttribute('aria-expanded', 'false');
});
document.addEventListener('click', (e) => {
  if (!menu.classList.contains('open') || e.target.closest('#menu, #burger')) return;
  menu.classList.remove('open');
  burger.setAttribute('aria-expanded', 'false');
});

/* ---------- Lien actif dans le menu ---------- */
const navObserver = new IntersectionObserver((entries) => {
  entries.forEach((en) => {
    if (!en.isIntersecting) return;
    $$('#menu a').forEach((a) => a.classList.toggle('active', a.getAttribute('href') === `#${en.target.id}`));
  });
}, { rootMargin: '-45% 0px -50% 0px' });
['projets', 'apropos', 'parcours', 'methode', 'contact'].forEach((id) => { const s = document.getElementById(id); if (s) navObserver.observe(s); });

/* ---------- Apparition + compteurs ---------- */
function countUp(el, n) {
  let i = 0;
  const step = Math.max(1, Math.ceil(n / 24));
  const t = setInterval(() => {
    i = Math.min(n, i + step);
    el.textContent = i;
    if (i >= n) clearInterval(t);
  }, 40);
}
const io = new IntersectionObserver((entries) => {
  entries.forEach((en) => {
    if (!en.isIntersecting) return;
    en.target.classList.add('visible');
    $$('[data-count]', en.target).forEach((c) => countUp(c, Number(c.dataset.count)));
    io.unobserve(en.target);
  });
}, { threshold: 0.12 });
const observe = () => $$('.reveal:not(.visible)').forEach((el) => io.observe(el));

/* ---------- Notification ---------- */
function toast(msg) {
  const t = $('#toast');
  t.textContent = msg;
  t.classList.add('show');
  clearTimeout(toast.timer);
  toast.timer = setTimeout(() => t.classList.remove('show'), 2400);
}

/* ---------- Profil ---------- */
function socialLinks(p) {
  return [
    [safeUrl(p.github), 'GitHub', ICONS.github],
    [safeUrl(p.linkedin), 'LinkedIn', ICONS.linkedin],
    [p.email ? `mailto:${p.email}` : '', 'E-mail', ICONS.mail],
  ].filter((s) => s[0])
    .map(([u, l, i]) => `<a href="${esc(u)}" ${u.startsWith('mailto:') ? '' : 'target="_blank" rel="noopener"'} aria-label="${l}" title="${l}">${i}</a>`)
    .join('');
}

function renderProfile(p) {
  profile = p;
  const name = p.full_name || 'Mon Portfolio';
  document.title = `${name} — Portfolio`;
  $('#brand').textContent = name;
  $('#name').textContent = name;
  $('#bio').textContent = p.bio || '';
  $('#city').textContent = (p.location || 'Cameroun').split(',')[0];
  const city = (p.location || '').split(',')[0];
  $('#eyebrow').textContent = `${p.title || 'Développeuse full-stack'}${city ? ` · ${city}` : ''}`;
  $('#footerName').textContent = name;
  $('#year').textContent = new Date().getFullYear();

  const photo = safeUrl(p.photo);
  if (photo) {
    $('#photo').src = photo;
    $('#photo').alt = `Portrait de ${name}`;
    $('#photo').classList.remove('hidden');
    $('#initials').classList.add('hidden');
  } else {
    $('#initials').textContent = initialsOf(name);
  }

  const cv = safeUrl(p.cv);
  if (cv) {
    $('#cvBtn').href = cv;
    $('#cvBtn').classList.remove('hidden');
  }

  const socials = socialLinks(p);
  $('#socials').innerHTML = socials;
  $('#footerSocials').innerHTML = socials;

  const lines = [
    [ICONS.mail, p.email, p.email ? `mailto:${p.email}` : ''],
    [ICONS.phone, p.phone, p.phone ? `tel:${String(p.phone).replace(/\s/g, '')}` : ''],
    [ICONS.pin, p.location, ''],
  ].filter((l) => l[1]);
  $('#contactLines').innerHTML = lines
    .map(([i, v, h]) => `<li><span class="ci">${i}</span>${h ? `<a href="${esc(h)}">${esc(v)}</a>` : `<span>${esc(v)}</span>`}</li>`)
    .join('');

  if (!p.email) $('#copyLabel').textContent = 'Me contacter';
}

$('#copyBtn').addEventListener('click', async () => {
  if (!profile.email) {
    document.getElementById('contact').scrollIntoView();
    return;
  }
  try {
    await navigator.clipboard.writeText(profile.email);
    $('#copyLabel').textContent = 'E-mail copié !';
    toast(`${profile.email} copié dans le presse-papiers`);
    setTimeout(() => { $('#copyLabel').textContent = 'Copier mon e-mail'; }, 2400);
  } catch {
    location.href = `mailto:${profile.email}`;
  }
});

/* ---------- Ma stack ---------- */
function renderStack(skills) {
  const names = skills.map((s) => s.name);
  if (!names.length) {
    $('.t-stack').classList.add('hidden');
    return;
  }
  $('#stackList').innerHTML = names.map((n) => `<li>${esc(n)}</li>`).join('');
  // pastille flottante de l'accueil : 3 premières technologies, nom court
  $('#heroStack').textContent = names.slice(0, 3).map((n) => n.split('/').pop().trim()).join(' · ');
}

/* ---------- Projets ---------- */
function media(p, i) {
  const img = safeUrl(p.image);
  if (img) return `<div class="p-media"><img src="${esc(img)}" alt="${esc(p.title)}" loading="lazy"></div>`;
  return `<div class="p-media tone-${TONES[i % TONES.length]}">
    <div class="mock"><div class="mock-win">
      <div class="mock-bar"><i></i><i></i><i></i></div>
      <div class="mock-body">
        <span class="mock-title">${esc(p.title)}</span>
        <span class="mock-lines"><i></i><i></i><i></i></span>
      </div>
    </div></div>
  </div>`;
}

/* ---------- Projets phares (grands blocs) ---------- */
function shot(p, i) {
  const img = safeUrl(p.image);
  if (!img) return media(p, i);
  return `<div class="p-media"><div class="shot">
    <div class="shot-bar"><i></i><i></i><i></i></div>
    <img src="${esc(img)}" alt="Aperçu de ${esc(p.title)}" loading="lazy">
  </div></div>`;
}

function renderFeatured(list) {
  $('#featured').innerHTML = list.map((p, k) => {
    const repo = safeUrl(p.repo_url);
    const demo = safeUrl(p.demo_url);
    return `<article class="feat ${k % 2 ? 'rev' : ''} reveal">
      <div class="feat-media" data-id="${p.id}" role="button" tabindex="0" aria-label="Voir ${esc(p.title)}">${shot(p, projects.indexOf(p))}</div>
      <div class="feat-text">
        <span class="feat-num">${String(k + 1).padStart(2, '0')}</span>
        ${p.context ? `<span class="p-ctx">${esc(p.context)}</span>` : ''}
        <h3>${esc(p.title)}</h3>
        <p>${esc(p.summary || '')}</p>
        ${techs(p).length ? `<div class="m-tech">${techs(p).slice(0, 6).map((t) => `<span>${esc(t)}</span>`).join('')}</div>` : ''}
        <div class="feat-links">
          <button class="btn btn-primary" type="button" data-id="${p.id}">Découvrir ${ARROW}</button>
          ${demo ? `<a class="btn btn-ghost" href="${esc(demo)}" target="_blank" rel="noopener">Démo</a>` : ''}
          ${repo ? `<a class="btn btn-ghost" href="${esc(repo)}" target="_blank" rel="noopener">${ICONS.github} Code</a>` : ''}
        </div>
      </div>
    </article>`;
  }).join('');
}

$('#featured').addEventListener('click', (e) => {
  const t = e.target.closest('[data-id]');
  if (t) openProject(Number(t.dataset.id));
});
$('#featured').addEventListener('keydown', (e) => {
  const t = e.target.closest('.feat-media');
  if (t && (e.key === 'Enter' || e.key === ' ')) {
    e.preventDefault();
    openProject(Number(t.dataset.id));
  }
});

/* ---------- Autres réalisations ---------- */
let others = [];

function renderFilters() {
  const count = {};
  others.forEach((p) => techs(p).forEach((t) => { count[t] = (count[t] || 0) + 1; }));
  const top = Object.entries(count).sort((a, b) => b[1] - a[1]).slice(0, 7).map((e) => e[0]);
  $('#filters').innerHTML = top.length
    ? ['Tous', ...top].map((t, i) => `<button class="chip ${i ? '' : 'active'}" type="button" data-filter="${esc(t)}">${esc(t)}</button>`).join('')
    : '';
}

function renderProjects(filter) {
  const list = filter === 'Tous' ? others : others.filter((p) => techs(p).includes(filter));
  $('#projectsGrid').innerHTML = list.map((p) => {
    const i = projects.indexOf(p);
    return `<article class="project" role="button" tabindex="0" data-id="${p.id}" aria-label="${esc(p.title)}">
      ${media(p, i)}
      <div class="p-body">
        ${p.context ? `<span class="p-ctx">${esc(p.context)}</span>` : ''}
        <h3>${esc(p.title)}</h3>
        <p>${esc(p.summary)}</p>
        <div class="p-foot">
          <div class="p-tech">${techs(p).slice(0, 3).map((t) => `<span>${esc(t)}</span>`).join('')}</div>
          <span class="p-go">Voir ${ARROW}</span>
        </div>
      </div>
    </article>`;
  }).join('') || '<p class="empty">Aucun projet pour ce filtre.</p>';
}

$('#filters').addEventListener('click', (e) => {
  const b = e.target.closest('.chip');
  if (!b) return;
  $$('.chip').forEach((c) => c.classList.toggle('active', c === b));
  renderProjects(b.dataset.filter);
});
$('#projectsGrid').addEventListener('click', (e) => {
  const c = e.target.closest('.project');
  if (c) openProject(Number(c.dataset.id));
});
$('#projectsGrid').addEventListener('keydown', (e) => {
  const c = e.target.closest('.project');
  if (c && (e.key === 'Enter' || e.key === ' ')) {
    e.preventDefault();
    openProject(Number(c.dataset.id));
  }
});

/* ---------- Fenêtre projet ---------- */
let lastFocus = null;
function openProject(id) {
  const p = projects.find((x) => x.id === id);
  if (!p) return;
  const demo = safeUrl(p.demo_url);
  const repo = safeUrl(p.repo_url);
  $('#modalBody').innerHTML = `
    ${shot(p, projects.indexOf(p))}
    <div class="m-body">
      ${p.context ? `<span class="p-ctx">${esc(p.context)}</span>` : ''}
      <h3 id="modalTitle">${esc(p.title)}</h3>
      <p>${esc(p.description || p.summary || '')}</p>
      ${techs(p).length ? `<div class="m-tech">${techs(p).map((t) => `<span>${esc(t)}</span>`).join('')}</div>` : ''}
      ${demo || repo ? `<div class="m-links">
        ${demo ? `<a class="btn btn-primary" href="${esc(demo)}" target="_blank" rel="noopener">Voir la démo ${ARROW}</a>` : ''}
        ${repo ? `<a class="btn btn-ghost" href="${esc(repo)}" target="_blank" rel="noopener">${ICONS.github} Code source</a>` : ''}
      </div>` : ''}
    </div>`;
  lastFocus = document.activeElement;
  $('#modal').classList.add('open');
  document.body.style.overflow = 'hidden';
  $('.modal-box').scrollTop = 0;
  $('.modal-close').focus();
}
function closeModal() {
  if (!$('#modal').classList.contains('open')) return;
  $('#modal').classList.remove('open');
  document.body.style.overflow = '';
  if (lastFocus) lastFocus.focus();
}
$('#modal').addEventListener('click', (e) => {
  if (e.target.id === 'modal' || e.target.closest('.modal-close')) closeModal();
});
addEventListener('keydown', (e) => { if (e.key === 'Escape') closeModal(); });

/* ---------- Parcours ---------- */
function renderExperiences(items) {
  $('#timeline').innerHTML = items.map((x) => {
    const tone = TYPE_TONE[x.type] || 'violet';
    return `<article class="exp tone-${tone} reveal">
      <span class="exp-icon">${ICONS[x.type] || ICONS.experience}</span>
      <div>
        <div class="exp-meta"><b>${esc(TYPE_LABEL[x.type] || '')}</b>${x.period ? `<span>${esc(x.period)}</span>` : ''}</div>
        <h3>${esc(x.title)}</h3>
        ${x.organization ? `<div class="exp-org">${esc(x.organization)}</div>` : ''}
        ${x.description ? `<p>${esc(x.description)}</p>` : ''}
      </div>
    </article>`;
  }).join('') || '<p class="empty">Bientôt disponible.</p>';
}

/* ---------- Contact ---------- */
$('#contactForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const f = e.target;
  const msg = $('#formMsg');
  const btn = $('button[type=submit]', f);
  msg.className = 'form-msg';
  msg.textContent = '';
  btn.disabled = true;
  try {
    const res = await fetch('/api/contact', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(Object.fromEntries(new FormData(f))),
    });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || 'Envoi impossible pour le moment.');
    f.reset();
    msg.classList.add('ok');
    msg.textContent = 'Merci, votre message est bien arrivé.';
  } catch (err) {
    msg.classList.add('err');
    msg.textContent = err.message;
  } finally {
    btn.disabled = false;
  }
});

/* ---------- Chargement ---------- */
(async function load() {
  try {
    const res = await fetch('/api/portfolio');
    if (!res.ok) throw new Error();
    const d = await res.json();
    projects = d.projects || [];
    renderProfile(d.profile || {});
    renderStack(d.skills || []);
    let feat = projects.filter((p) => p.featured);
    if (!feat.length) feat = projects.slice(0, 3);
    others = projects.filter((p) => !feat.includes(p));
    renderFeatured(feat);
    if (others.length) {
      renderFilters();
      renderProjects('Tous');
    } else {
      $('#othersBlock').classList.add('hidden');
    }
    renderExperiences(d.experiences || []);
    $('#statProjects').dataset.count = projects.length;
    $('#statSkills').dataset.count = (d.skills || []).length;
    $('#statExp').dataset.count = (d.experiences || []).length;
  } catch {
    $('#bio').textContent = 'Impossible de charger le contenu pour le moment.';
  } finally {
    observe();
  }
})();
