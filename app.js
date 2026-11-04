/* LSV shared app script — settings, routing, demos. Safe no-ops on pages missing the relevant elements. */
(function(){
'use strict';
var root = document.documentElement;

/* ---------- helpers ---------- */
function escapeHtml(s){
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}
function savePref(key, value){ try{ localStorage.setItem(key, value); }catch(e){} }

/* ---------- toast ---------- */
var toastEl = document.getElementById('toast');
var toastTimer = null;
function showToast(msg){
  if(!toastEl) return;
  toastEl.textContent = msg;
  toastEl.classList.add('is-visible');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(function(){ toastEl.classList.remove('is-visible'); }, 2600);
}

/* ---------- clipboard ---------- */
function fallbackCopy(text, cb){
  var ta = document.createElement('textarea');
  ta.value = text;
  ta.style.position = 'fixed';
  ta.style.opacity = '0';
  document.body.appendChild(ta);
  ta.select();
  try{ document.execCommand('copy'); }catch(e){}
  document.body.removeChild(ta);
  if(cb) cb();
}
function copyText(text, btn){
  function done(){
    if(!btn) return;
    btn.classList.add('is-copied');
    setTimeout(function(){ btn.classList.remove('is-copied'); }, 1400);
  }
  if(navigator.clipboard && window.isSecureContext){
    navigator.clipboard.writeText(text).then(done).catch(function(){ fallbackCopy(text, done); });
  } else {
    fallbackCopy(text, done);
  }
}

/* ---------- docs sub-page router (no-ops on pages without .doc-article) ---------- */
var DOC_IDS = ['introduction','quickstart','presets','macros','cli','changelog'];

function parseDocsHash(){
  var sub = location.hash.replace('#','');
  if(DOC_IDS.indexOf(sub) === -1) sub = 'introduction';
  return sub;
}

function activateDoc(sub){
  var any = false;
  DOC_IDS.forEach(function(id){
    var art = document.getElementById('doc-' + id);
    var link = document.querySelector('.docs-link[data-doc-target="' + id + '"]');
    var isActive = id === sub;
    if(art){ art.classList.toggle('is-active', isActive); any = true; }
    if(link) link.classList.toggle('is-active', isActive);
  });
  if(any){
    var docsContent = document.querySelector('.docs-content');
    if(docsContent) docsContent.scrollTop = 0;
    window.scrollTo(0, 0);
  }
}

window.addEventListener('hashchange', function(){ activateDoc(parseDocsHash()); });

/* ---------- mobile nav ---------- */
var navBurger = document.getElementById('navBurger');
var navTabs = document.getElementById('navTabs');
if(navBurger && navTabs){
  navBurger.addEventListener('click', function(){
    var open = navTabs.classList.toggle('is-open');
    navBurger.setAttribute('aria-expanded', String(open));
  });
}

/* ---------- noop-guard + contextual toasts for placeholder "#" links ---------- */
document.addEventListener('click', function(e){
  var a = e.target.closest('a[href="#"]');
  if(!a) return;
  e.preventDefault();
  if(a.closest('.plan-card')){
    showToast("Checkout preview — connect billing to go live.");
  } else if(a.closest('.cta-band')){
    showToast('Demo site — wire this up to your sales contact flow.');
  }
});

/* ---------- settings panel ---------- */
var settingsPanel = document.getElementById('settingsPanel');
var settingsOverlay = document.getElementById('settingsOverlay');
function openSettings(){
  if(!settingsPanel) return;
  settingsPanel.classList.add('is-open');
  settingsOverlay.classList.add('is-open');
  settingsPanel.setAttribute('aria-hidden','false');
}
function closeSettings(){
  if(!settingsPanel) return;
  settingsPanel.classList.remove('is-open');
  settingsOverlay.classList.remove('is-open');
  settingsPanel.setAttribute('aria-hidden','true');
}
var settingsToggle = document.getElementById('settingsToggle');
var settingsClose = document.getElementById('settingsClose');
if(settingsToggle) settingsToggle.addEventListener('click', openSettings);
if(settingsClose) settingsClose.addEventListener('click', closeSettings);
if(settingsOverlay) settingsOverlay.addEventListener('click', closeSettings);
document.addEventListener('keydown', function(e){ if(e.key === 'Escape') closeSettings(); });

function syncSettingsUI(){
  var theme = root.getAttribute('data-theme');
  var accent = root.getAttribute('data-accent');
  document.querySelectorAll('.theme-opt').forEach(function(b){ b.classList.toggle('is-active', b.dataset.themeOpt === theme); });
  document.querySelectorAll('.accent-opt').forEach(function(b){ b.classList.toggle('is-active', b.dataset.accentOpt === accent); });
  var motionToggle = document.getElementById('motionToggle');
  if(motionToggle) motionToggle.checked = root.classList.contains('reduce-motion');
}
document.querySelectorAll('.theme-opt').forEach(function(btn){
  btn.addEventListener('click', function(){
    root.setAttribute('data-theme', btn.dataset.themeOpt);
    savePref('lsv-theme', btn.dataset.themeOpt);
    syncSettingsUI();
  });
});
document.querySelectorAll('.accent-opt').forEach(function(btn){
  btn.addEventListener('click', function(){
    root.setAttribute('data-accent', btn.dataset.accentOpt);
    savePref('lsv-accent', btn.dataset.accentOpt);
    syncSettingsUI();
  });
});
var motionToggleEl = document.getElementById('motionToggle');
if(motionToggleEl){
  motionToggleEl.addEventListener('change', function(e){
    root.classList.toggle('reduce-motion', e.target.checked);
    savePref('lsv-reduce-motion', e.target.checked ? '1' : '0');
  });
}
var settingsReset = document.getElementById('settingsReset');
if(settingsReset){
  settingsReset.addEventListener('click', function(){
    root.setAttribute('data-theme','dark');
    root.setAttribute('data-accent','blue');
    root.classList.remove('reduce-motion');
    try{
      localStorage.removeItem('lsv-theme');
      localStorage.removeItem('lsv-accent');
      localStorage.removeItem('lsv-reduce-motion');
    }catch(e){}
    syncSettingsUI();
  });
}

/* ---------- Lua syntax highlighter ---------- */
var LUA_KEYWORDS = {and:1,"break":1,"do":1,"else":1,elseif:1,end:1,"false":1,"for":1,"function":1,goto:1,"if":1,"in":1,local:1,"nil":1,not:1,or:1,repeat:1,"return":1,then:1,"true":1,until:1,"while":1};
var LUA_BUILTINS = {game:1,workspace:1,script:1,print:1,pairs:1,ipairs:1,require:1,pcall:1,xpcall:1,type:1,tostring:1,tonumber:1,setmetatable:1,getmetatable:1,select:1,unpack:1,table:1,string:1,math:1,os:1,coroutine:1,debug:1,getfenv:1,setfenv:1,loadstring:1,Instance:1,Vector3:1,CFrame:1,Players:1,HttpService:1,error:1,logger:1};
var LUA_TOKEN_RE = /(--\[\[[\s\S]*?\]\])|(--[^\n]*)|("(?:[^"\\]|\\.)*")|('(?:[^'\\]|\\.)*')|(\b0x[0-9a-fA-F]+\b|\b\d+\.?\d*\b)|([A-Za-z_][A-Za-z0-9_]*)|(\s+)|([^\sA-Za-z0-9_])/g;
function highlightLua(src){
  var out = '';
  var m;
  LUA_TOKEN_RE.lastIndex = 0;
  while((m = LUA_TOKEN_RE.exec(src))){
    var all = m[0];
    if(m[1] || m[2]){ out += '<span class="tok-com">' + escapeHtml(all) + '</span>'; }
    else if(m[3] || m[4]){ out += '<span class="tok-str">' + escapeHtml(all) + '</span>'; }
    else if(m[5]){ out += '<span class="tok-num">' + escapeHtml(all) + '</span>'; }
    else if(m[6]){
      var w = all;
      if(w.indexOf('LSV_') === 0) out += '<span class="tok-macro">' + w + '</span>';
      else if(LUA_KEYWORDS.hasOwnProperty(w)) out += '<span class="tok-kw">' + w + '</span>';
      else if(LUA_BUILTINS.hasOwnProperty(w)) out += '<span class="tok-fn">' + w + '</span>';
      else out += escapeHtml(w);
    }
    else if(m[7]){ out += all; }
    else { out += escapeHtml(all); }
  }
  return out;
}
document.querySelectorAll('.code-block code').forEach(function(code){
  var raw = code.textContent;
  code.dataset.raw = raw;
  code.innerHTML = code.classList.contains('language-lua') ? highlightLua(raw) : escapeHtml(raw);
});
document.querySelectorAll('.code-copy-btn').forEach(function(btn){
  btn.addEventListener('click', function(){
    var card = btn.closest('.code-card');
    var codeEl = card && card.querySelector('pre code');
    if(codeEl) copyText(codeEl.dataset.raw || codeEl.textContent, btn);
  });
});

/* ---------- hero before/after preview ---------- */
document.querySelectorAll('.preview-tab').forEach(function(tab){
  tab.addEventListener('click', function(){
    var cardEl = tab.closest('.preview-card');
    cardEl.querySelectorAll('.preview-tab').forEach(function(t){ t.classList.toggle('is-active', t === tab); });
    cardEl.querySelectorAll('.preview-pane').forEach(function(p){ p.classList.toggle('is-active', p.dataset.pane === tab.dataset.preview); });
  });
});

/* ---------- pricing billing toggle ---------- */
var billingSwitch = document.getElementById('billingSwitch');
var pricingGrid = document.querySelector('.pricing-grid');
if(billingSwitch && pricingGrid){
  billingSwitch.addEventListener('click', function(){
    var isYearly = !billingSwitch.classList.contains('is-active');
    billingSwitch.classList.toggle('is-active', isYearly);
    billingSwitch.setAttribute('aria-checked', String(isYearly));
    pricingGrid.classList.toggle('is-yearly', isYearly);
    document.querySelectorAll('.billing-label').forEach(function(l){
      l.classList.toggle('is-active', l.dataset.billingLabel === (isYearly ? 'yearly' : 'monthly'));
    });
  });
}

/* ---------- docs search filter ---------- */
var docsSearch = document.getElementById('docsSearch');
if(docsSearch){
  docsSearch.addEventListener('input', function(e){
    var q = e.target.value.trim().toLowerCase();
    document.querySelectorAll('.docs-link').forEach(function(link){
      var text = link.textContent.toLowerCase();
      var keywords = (link.dataset.keywords || '').toLowerCase();
      var match = !q || text.indexOf(q) !== -1 || keywords.indexOf(q) !== -1;
      link.closest('li').style.display = match ? '' : 'none';
    });
    document.querySelectorAll('.docs-group').forEach(function(group){
      var anyVisible = Array.prototype.some.call(group.querySelectorAll('li'), function(li){ return li.style.display !== 'none'; });
      group.style.display = anyVisible ? '' : 'none';
    });
  });
}

/* ---------- dashboard: API key reveal/copy ---------- */
var apiKeyText = document.getElementById('apiKeyText');
var apiKeyRevealed = false;
var apiKeyToggle = document.getElementById('apiKeyToggle');
if(apiKeyToggle && apiKeyText){
  apiKeyToggle.addEventListener('click', function(){
    apiKeyRevealed = !apiKeyRevealed;
    apiKeyText.textContent = apiKeyRevealed ? apiKeyText.dataset.full : apiKeyText.dataset.masked;
  });
}
var apiKeyCopy = document.getElementById('apiKeyCopy');
if(apiKeyCopy && apiKeyText){
  apiKeyCopy.addEventListener('click', function(){ copyText(apiKeyText.dataset.full, apiKeyCopy); });
}
var regenerateKeyBtn = document.getElementById('regenerateKeyBtn');
if(regenerateKeyBtn){
  regenerateKeyBtn.addEventListener('click', function(){ showToast('Demo mode — connect a real account to rotate keys.'); });
}
document.querySelectorAll('.revoke-key-btn').forEach(function(btn){
  btn.addEventListener('click', function(){ showToast('Demo mode — connect a real account to manage keys.'); });
});

/* ---------- dashboard: usage chart ---------- */
(function renderChart(){
  var svg = document.getElementById('usageChart');
  if(!svg) return;
  var data = [12,18,9,22,30,26,19,24,35,28,31,40,33,45];
  var w = 560, h = 160, pad = 8, gap = 6;
  var max = Math.max.apply(null, data);
  var barW = (w - pad * 2 - gap * (data.length - 1)) / data.length;
  var html = '';
  data.forEach(function(v, i){
    var barH = (v / max) * (h - pad * 2 - 18);
    var x = pad + i * (barW + gap);
    var y = h - pad - barH;
    var cls = 'chart-bar' + (i === data.length - 1 ? ' chart-bar-current' : '');
    html += '<rect x="' + x.toFixed(1) + '" y="' + y.toFixed(1) + '" width="' + barW.toFixed(1) + '" height="' + barH.toFixed(1) + '" rx="3" class="' + cls + '"><title>' + v + ' scripts</title></rect>';
  });
  svg.innerHTML = html;
})();

/* ---------- dashboard: dropzone demo ---------- */
var dropzone = document.getElementById('dropzone');
var fileInput = document.getElementById('fileInput');
var selectedFile = document.getElementById('selectedFile');
var obfuscateDemoBtn = document.getElementById('obfuscateDemoBtn');
var chosenFile = null;

function humanSize(bytes){
  if(bytes < 1024) return bytes + ' B';
  if(bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
  return (bytes / (1024 * 1024)).toFixed(2) + ' MB';
}
function handleFile(file){
  if(!file) return;
  chosenFile = file;
  var nameEl = document.getElementById('selectedFileName');
  var sizeEl = document.getElementById('selectedFileSize');
  if(nameEl) nameEl.textContent = file.name;
  if(sizeEl) sizeEl.textContent = humanSize(file.size);
  if(selectedFile) selectedFile.hidden = false;
  var resultEl = document.getElementById('demoResult');
  if(resultEl) resultEl.hidden = true;
}
if(dropzone && fileInput){
  dropzone.addEventListener('click', function(){ fileInput.click(); });
  dropzone.addEventListener('keydown', function(e){
    if(e.key === 'Enter' || e.key === ' '){ e.preventDefault(); fileInput.click(); }
  });
  fileInput.addEventListener('change', function(e){ handleFile(e.target.files[0]); });
  ['dragenter','dragover'].forEach(function(evt){
    dropzone.addEventListener(evt, function(e){ e.preventDefault(); dropzone.classList.add('is-dragover'); });
  });
  ['dragleave','drop'].forEach(function(evt){
    dropzone.addEventListener(evt, function(e){ e.preventDefault(); dropzone.classList.remove('is-dragover'); });
  });
  dropzone.addEventListener('drop', function(e){
    var f = e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files[0];
    if(f) handleFile(f);
  });
}
if(obfuscateDemoBtn){
  obfuscateDemoBtn.addEventListener('click', function(){
    if(!chosenFile) return;
    obfuscateDemoBtn.disabled = true;
    var wrap = document.getElementById('demoProgress');
    var bar = document.getElementById('demoProgressBar');
    if(wrap) wrap.hidden = false;
    if(bar){
      bar.style.width = '0%';
      requestAnimationFrame(function(){ bar.style.width = '100%'; });
    }
    setTimeout(function(){
      if(wrap) wrap.hidden = true;
      obfuscateDemoBtn.disabled = false;
      var outSize = Math.round(chosenFile.size * (1.15 + Math.random() * 0.2));
      var origEl = document.getElementById('resultOrigSize');
      var outEl = document.getElementById('resultOutSize');
      if(origEl) origEl.textContent = humanSize(chosenFile.size);
      if(outEl) outEl.textContent = humanSize(outSize);
      var resultEl = document.getElementById('demoResult');
      if(resultEl) resultEl.hidden = false;
    }, 1300);
  });
}

/* ---------- reveal on scroll (safe: hidden state only applied here) ---------- */
(function(){
  var els = document.querySelectorAll('.reveal');
  if(!('IntersectionObserver' in window) || root.classList.contains('reduce-motion') || !els.length) return;
  els.forEach(function(el){ el.classList.add('reveal-init'); });
  var io = new IntersectionObserver(function(entries){
    entries.forEach(function(entry){
      if(entry.isIntersecting){
        entry.target.classList.add('is-visible');
        io.unobserve(entry.target);
      }
    });
  }, {threshold:0.12, rootMargin:'0px 0px -40px 0px'});
  els.forEach(function(el){ io.observe(el); });
})();

/* ---------- init ---------- */
syncSettingsUI();
activateDoc(parseDocsHash());
})();
