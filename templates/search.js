/* SPDX-FileCopyrightText: 2026 e-editiones
   SPDX-License-Identifier: CC0-1.0 */

(function () {
  var form = document.querySelector('.doc-search');
  if (!form) return;
  var input = form.querySelector('input');
  var list = form.querySelector('.doc-search__hits');
  var url = form.getAttribute('data-idents');
  var items = [];
  var selected = -1;

  function hrefFor(item) {
    return item.href || ('ref-' + item.ident + '.html');
  }

  function render(hits) {
    list.innerHTML = '';
    selected = -1;
    if (!hits.length) {
      list.hidden = true;
      return;
    }
    hits.slice(0, 20).forEach(function (item, i) {
      var li = document.createElement('li');
      var a = document.createElement('a');
      a.href = hrefFor(item);
      a.innerHTML = '<code>' + item.ident + '</code><span class="doc-search__kind">' + item.kind + '</span>';
      li.appendChild(a);
      list.appendChild(li);
    });
    list.hidden = false;
  }

  function query(q) {
    q = (q || '').trim().toLowerCase();
    if (!q) return [];
    return items.filter(function (item) {
      return item.ident.toLowerCase().indexOf(q) !== -1;
    });
  }

  fetch(url)
    .then(function (r) { return r.json(); })
    .then(function (data) { items = data; })
    .catch(function () { items = []; });

  input.addEventListener('input', function () {
    render(query(input.value));
  });
  input.addEventListener('keydown', function (ev) {
    var links = list.querySelectorAll('a');
    if (ev.key === 'ArrowDown') {
      ev.preventDefault();
      selected = Math.min(selected + 1, links.length - 1);
    } else if (ev.key === 'ArrowUp') {
      ev.preventDefault();
      selected = Math.max(selected - 1, 0);
    } else if (ev.key === 'Enter' && selected >= 0 && links[selected]) {
      ev.preventDefault();
      window.location = links[selected].href;
      return;
    } else if (ev.key === 'Escape') {
      list.hidden = true;
      return;
    } else {
      return;
    }
    Array.prototype.forEach.call(list.children, function (li, i) {
      li.setAttribute('aria-selected', i === selected ? 'true' : 'false');
    });
  });
  document.addEventListener('click', function (ev) {
    if (!form.contains(ev.target)) list.hidden = true;
  });
})();

// The catalog appendices, A–Z or by module. The page holds the A–Z lists, each
// entry stamped with its module (an attribute row with the module of each
// element or class that defines it, in order); the module view is built from
// them on first use. An attribute defined in several modules is listed under
// each, with that module's owners only. Runs before the rail below, so the
// rail lists the headings of the view a reader last chose.
(function () {
  var KEY = 'opm-doc-catalog-view';
  var sections = document.querySelectorAll('section.catalog[data-catalog]');
  if (!sections.length) return;

  function stored() {
    try {
      return localStorage.getItem(KEY);
    } catch (e) {
      return null;
    }
  }

  function store(view) {
    try {
      localStorage.setItem(KEY, view);
    } catch (e) {}
  }

  function heading(module) {
    var h2 = document.createElement('h2');
    h2.id = 'module-' + module;
    h2.textContent = module;
    return h2;
  }

  // module → its entries, modules A–Z; the entries keep their A–Z order.
  function grouped(add) {
    var groups = {};
    add(function (module, node) {
      (groups[module] = groups[module] || []).push(node);
    });
    return Object.keys(groups).sort().map(function (m) { return [m, groups[m]]; });
  }

  function specView(az, view) {
    grouped(function (put) {
      az.querySelectorAll('li[data-module]').forEach(function (li) {
        put(li.getAttribute('data-module') || '-', li.cloneNode(true));
      });
    }).forEach(function (group) {
      var ul = document.createElement('ul');
      ul.className = 'catalog__list';
      group[1].forEach(function (li) { ul.appendChild(li); });
      view.appendChild(heading(group[0]));
      view.appendChild(ul);
    });
  }

  function attView(az, view) {
    var thead = az.querySelector('thead');
    grouped(function (put) {
      az.querySelectorAll('tr[data-modules]').forEach(function (tr) {
        var modules = tr.getAttribute('data-modules').split(' ');
        var owners = tr.cells[1] ? tr.cells[1].children : [];
        var seen = {};
        modules.forEach(function (module) {
          if (seen[module]) return;
          seen[module] = true;
          var row = tr.cloneNode(true);
          var cell = row.cells[1];
          cell.textContent = '';
          modules.forEach(function (m, i) {
            if (m === module && owners[i]) cell.appendChild(owners[i].cloneNode(true));
          });
          put(module, row);
        });
      });
    }).forEach(function (group) {
      var table = document.createElement('table');
      table.className = 'spec-table';
      if (thead) table.appendChild(thead.cloneNode(true));
      var tbody = document.createElement('tbody');
      group[1].forEach(function (row) { tbody.appendChild(row); });
      table.appendChild(tbody);
      view.appendChild(heading(group[0]));
      view.appendChild(table);
    });
  }

  sections.forEach(function (section) {
    var h1 = section.querySelector('h1');
    if (!h1) return;
    var az = document.createElement('div');
    az.setAttribute('data-view', 'az');
    while (h1.nextSibling) az.appendChild(h1.nextSibling);
    var byModule = document.createElement('div');
    byModule.setAttribute('data-view', 'module');
    byModule.hidden = true;
    var built = false;

    var bar = document.createElement('div');
    bar.className = 'catalog-switch';
    bar.setAttribute('role', 'group');
    bar.setAttribute('aria-label', 'Sort');
    var buttons = {};
    [['az', 'A–Z'], ['module', 'By module']].forEach(function (b) {
      var button = document.createElement('button');
      button.type = 'button';
      button.textContent = b[1];
      button.addEventListener('click', function () {
        show(b[0]);
        store(b[0]);
        document.dispatchEvent(new CustomEvent('doc:toc'));
      });
      buttons[b[0]] = button;
      bar.appendChild(button);
    });

    function show(view) {
      if (view === 'module' && !built) {
        (section.getAttribute('data-catalog') === 'atts' ? attView : specView)(az, byModule);
        built = true;
      }
      az.hidden = view === 'module';
      byModule.hidden = view !== 'module';
      buttons.az.setAttribute('aria-pressed', String(view !== 'module'));
      buttons.module.setAttribute('aria-pressed', String(view === 'module'));
    }

    section.appendChild(bar);
    section.appendChild(az);
    section.appendChild(byModule);
    // A link to a letter (#A) opens the A–Z view, whatever was chosen before;
    // one to a module (#module-core) the module view, which only now has it.
    var id = location.hash && decodeURIComponent(location.hash.slice(1));
    var target = id && document.getElementById(id);
    show(target && az.contains(target) ? 'az'
      : stored() === 'module' || /^module-/.test(id) ? 'module' : 'az');
    target = !target && id && document.getElementById(id);
    if (target && byModule.contains(target)) target.scrollIntoView();
  });
})();

(function () {
  var aside = document.querySelector('[data-page-toc]');
  var main = document.querySelector('.doc-main');
  if (!aside || !main) return;
  var ul = aside.querySelector('ul');
  if (!ul) return;
  var seen = {};
  function entry(id, label, sub) {
    if (!id || !label || seen[id]) return;
    seen[id] = true;
    var li = document.createElement('li');
    if (sub) li.className = 'is-sub';
    var a = document.createElement('a');
    a.href = '#' + id;
    a.textContent = label;
    li.appendChild(a);
    ul.appendChild(li);
  }
  // A reference section lists what it holds: the attributes the spec defines
  // itself (the inherited ones live in the tree above the list, which has no
  // anchors of its own) and the class / content relations under it.
  function subEntries(section) {
    section.querySelectorAll('dl.att-def > dt[id], dl.spec-facts > dt[id]')
      .forEach(function (dt) {
        var dd = dt.nextElementSibling;
        if (dd && dd.tagName === 'DD' && !(dd.textContent || '').trim()) return;
        var name = dt.querySelector('.att-def__name');
        entry(dt.id, ((name || dt).textContent || '').trim(), true);
      });
  }
  // What the rail links to. A chapter's headings sit in a div that carries the
  // anchor, which is what the fragment links in the prose point at; a heading
  // with neither its own id nor a section of its own — the groups on the home
  // page — gets one made from its text, or the page's own container would
  // stand in for every one of them and the rail would show only the first.
  function anchor(heading) {
    if (heading.id) return heading.id;
    var wrap = heading.closest('[id]');
    if (wrap && wrap !== main && !seen[wrap.id]) return wrap.id;
    var base = (heading.textContent || '').trim().toLowerCase()
      .replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '') || 'section';
    var id = base;
    for (var n = 2; document.getElementById(id); n++) id = base + '-' + n;
    heading.id = id;
    return id;
  }
  // Built again on `doc:toc`, when the page shows other headings (a catalog
  // switched between A–Z and by module); hidden headings are left out.
  function build() {
    ul.textContent = '';
    seen = {};
    main.querySelectorAll('h2, h3').forEach(function (heading) {
      if (heading.closest('[hidden]')) return;
      var id = anchor(heading);
      entry(id, (heading.textContent || '').trim(), heading.tagName === 'H3');
      var section = heading.tagName === 'H2' ? heading.closest('.spec-section') : null;
      if (section) subEntries(section);
    });
    var empty = !ul.children.length;
    // Keep the rail when it still carries the chapter's previous/next pair.
    var nav = aside.querySelector('.chapter-nav');
    ul.hidden = empty;
    var label = aside.querySelector('.doc-aside__label');
    if (label) label.hidden = empty;
    aside.hidden = empty && !nav;
  }
  build();
  document.addEventListener('doc:toc', build);
})();
