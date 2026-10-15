// Applique le thème mémorisé avant l'affichage (évite le flash)
(function () {
  try {
    var t = localStorage.getItem('theme');
    if (t === 'dark' || t === 'light') document.documentElement.setAttribute('data-theme', t);
  } catch (e) { /* stockage indisponible : thème clair par défaut */ }
})();