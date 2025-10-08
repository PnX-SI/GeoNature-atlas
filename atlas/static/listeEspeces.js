// const debounce = require("debounce");

$(".lazy").lazy({
    effect: "fadeIn",
    effectTime: 2000,
    threshold: 0,
    appendScroll: $("#taxonList")
});
$('[data-toggle="tooltip"]').tooltip();

// on commence à la page 1 car le backend nous renvoie déjà la page 0
let inputSearchTaxons = "";
let page = 1;
let page_size = configuration.ITEMS_PER_PAGE
let havePossibleNextPage = true;

// event on scroll
document.getElementById('taxonList').addEventListener('scroll', debounce( onScroll , 200));

// event on taxon search
document.getElementById('taxonInput').addEventListener('keyup', debounce( (el) => {
        inputSearchTaxons = document.getElementById('taxonInput').value.toLowerCase();
        page = 0;
        havePossibleNextPage = true;
        getTaxonElems().then(data => {
            document.getElementById('taxonList').querySelectorAll('ul')[0].innerHTML = data;
            // une fois que les données sont chargées, on est à la page 1
            page = 1;
        });
} , 200));


async function getTaxonElems() {
    let url = ""
    let currentList = [];

    const pathNameUrl = location.pathname.split("/").filter(segment => segment);
    
    switch (context.page) {
        case "area":
            // Territory sheet
            url = `/api/taxonList/area/${pathNameUrl[1]}?page=${page}&page_size=${page_size}&filter_taxons=${inputSearchTaxons}`;
            break;
        case "taxon_rank_sheet":
            // Family list sheet
            url = `/api/taxonList/liste/${pathNameUrl[1]}?page=${page}&page_size=${page_size}&filter_taxons=${inputSearchTaxons}`;
            break;
        case "group_sheet":
            // Group sheet
            url = `/api/taxonList/group/${pathNameUrl[1]}?page=${page}&page_size=${page_size}&filter_taxons=${inputSearchTaxons}`;
            break;
        case "home_territory":
            // Default sheet (all species) used for home page (with territory map)
            url = `/api/taxonList?page=${page}&page_size=${page_size}&filter_taxons=${inputSearchTaxons}`
            break;
    }

    currentList = await fetch(url, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/html'
        }
    })
        .then(response => response.text())
        .catch((error) => {
            console.error('Error:', error);
        });
    return currentList;
}

async function onScroll(event) {
    
    const element = event.target
    const scrollTop = element.scrollTop +100; // Current scroll position + 100 pixel to trigger event before to be at the complete end
    const scrollHeight = element.scrollHeight;
    const clientHeight = element.clientHeight; // visibility size
    
    if (scrollTop + clientHeight >= scrollHeight && havePossibleNextPage) {
        element.parentElement.querySelector("#list-taxon-loader-spinner").style.display = 'block'
        const data = await getTaxonElems();        
        page++;
        if (!data || data.length === 0) {
            havePossibleNextPage = false;
            page--;
            element.parentElement.querySelector("#list-taxon-loader-spinner").style.display = 'none'
            return;
        }
        document.getElementById('taxonList').querySelectorAll('ul')[0].innerHTML += data;
        element.parentElement.querySelector("#list-taxon-loader-spinner").style.display = 'none'
    }
}








// ==================================================
// 0. Initialisation plugins
// ==================================================

function initPlugins(){
  // Lazy loading des images
    $(".lazy").lazy({
          effect: "fadeIn",
          effectTime: 2000,
          threshold: 0,
          appendScroll: $("#taxonList")
        });
    // Bootstrap tooltips
    $('[data-toggle="tooltip"]').tooltip();
}

// ==================================================
// 1. Menu filtre drowdown
// ==================================================

const selectedGroups = new Set(["all"]); 

function buildGroupFilterMenu() {
    const groupSet = new Set(taxonsData.map(t => t.group2_inpn).filter(Boolean));
    const groupFilterList = document.getElementById("groupFilterList");
    
    // Threat & Protection filter if the configuration variable is enabled.
    let menaceItem = "";
    let protectItem = "";
    if (affichage_menace_enabled) {
        menaceItem = `
        <li class="px-1">
            <div class="form-check">
                <input class="form-check-input" type="checkbox" id="g-threat" data-group="threatened">
                <label class="form-check-label" for="g-threat">${translations.threatened}</label>
            </div>
        </li>
        <li><hr class="dropdown-divider"></li>
        `;
    }
    if (protection_enabled) {
        protectItem = `
        <li class="px-1">
            <div class="form-check">
                <input class="form-check-input" type="checkbox" id="g-protect" data-group="protected">
                <label class="form-check-label" for="g-protect">${translations.protected}</label>
            </div>
        </li>
        <li><hr class="dropdown-divider"></li>
        `;
    }
    const groupItemsHtml = [...groupSet].sort().map((group, i) => `
    <li class="px-1">
        <div class="form-check">
        <input class="form-check-input group-check" type="checkbox" id="g-${i}" data-group="${group}">
        <label class="form-check-label" for="g-${i}">${group}</label>
        </div>
    </li>
    `).join("");

    groupFilterList.innerHTML = `
    <li class="px-1 mb-1">
        <div class="form-check">
        <input class="form-check-input" type="checkbox" id="g-all" data-group="all" checked>
        <label class="form-check-label" for="g-all">${translations.all_taxa}</label>
        </div>
    </li>
    <li><hr class="dropdown-divider"></li>
    ${menaceItem}
    ${protectItem}
    ${groupItemsHtml}
    <li><hr class="dropdown-divider"></li>
    <li class="d-flex gap-2 px-1">
        <button type="button" class="btn btn-sm btn-light flex-fill" id="btn-clear">${translations.clear}</button>
        <button type="button" class="btn btn-sm btn-primary flex-fill" id="btn-apply">${translations.apply}</button>
    </li>
    `;
}

function updateLabel() {
    const span = document.getElementById("currentGroupLabel");
    if (selectedGroups.has("all") || selectedGroups.size === 0) {
        span.textContent = `${translations.all}`;
        return;
    }
    const names = [...selectedGroups].filter(g => !["threatened", "protected"].includes(g));
    const includesThreat = selectedGroups.has("threatened");
    const includesProtect = selectedGroups.has("protected");
    const shown = names.slice(0, 3).join(", ") + (names.length > 3 ? `, +${names.length - 3}` : "");
    
    const statusLabels = [];
    if (includesThreat) statusLabels.push(translations.threatened);
    if (includesProtect) statusLabels.push(translations.protected);

    let finalLabel = "";
    if (names.length && statusLabels.length) {
        finalLabel = `${shown} + ${statusLabels.join(" & ")}`;
    } else if (names.length) {
        finalLabel = shown;
    } else if (statusLabels.length) {
        finalLabel = statusLabels.join(" & ");
    } else {
        finalLabel = translations.all;
    }

    span.textContent = finalLabel;
    span.title = `${names.join(", ")}${statusLabels.length ? " + " + statusLabels.join(" & ") : ""}`;
}

function syncAllCheckbox() {
    const allCb = document.getElementById("g-all");
    const othersSelected = [...document.querySelectorAll('#groupFilterList input[type="checkbox"]')]
        .some(cb => cb.dataset.group !== "all" && cb.checked);
    allCb.checked = !othersSelected;
    if (allCb.checked) {
        selectedGroups.clear(); selectedGroups.add("all");
    } else {
        selectedGroups.delete("all");
    }
    updateLabel();
}

function handleFilterCheckboxChange() {
    const g = this.dataset.group;

    // 1. Si "Tous" est coché, on décoche tout le reste
    if (g === "all") {
        $('#groupFilterList input[type="checkbox"]').not(this).prop('checked', false);
    }

    // 2. Mettre à jour selectedGroups selon les cases cochées
    selectedGroups.clear();
    $('#groupFilterList input[type="checkbox"]:checked').each(function () {
        selectedGroups.add(this.dataset.group);
    });

    // 3. Synchroniser "Tous" et mettre à jour le label
    syncAllCheckbox();
}

function clearFilters() {
    $('#groupFilterList input[type="checkbox"]').prop('checked', false);
    $('#g-all').prop('checked', true);
    selectedGroups.clear(); selectedGroups.add("all");
    updateLabel();
    applyCombinedFilter();
}

function applyCombinedFilter() {
  const text = $("#taxonInput").val().toLowerCase();
  const hasThreat = selectedGroups.has("threatened");
  const hasProtect = selectedGroups.has("protected");
  const groupSelections = [...selectedGroups].filter(g => !["all", "threatened", "protected"].includes(g));

  $("#taxonList li").each(function () {
    const matchesText = $(this).text().toLowerCase().includes(text);

    // Groupe de l’élément 
    const group = $(this).find(".pictoImgList").attr("data-bs-original-title").trim();

    // Statut
    const cdRefAttr = this.getAttribute('cdref');
    const cdRef = cdRefAttr ? Number(cdRefAttr) : null;
    const isThreatened = cdRef != null && threatenedTaxons.includes(cdRef);
    const isProtected = cdRef != null && protectedTaxons.includes(cdRef);

    const inSelectedGroups = groupSelections.length === 0 || groupSelections.includes(group);

    let matchesStatus = true;
    if (hasThreat && hasProtect) {
      matchesStatus = isThreatened || isProtected;
    } else if (hasThreat) {
      matchesStatus = isThreatened;
    } else if (hasProtect) {
      matchesStatus = isProtected;
    }

    const shouldShow = matchesText && inSelectedGroups && matchesStatus;
    this.style.setProperty("display", shouldShow ? "flex" : "none", "important");
  });
}

// ==================================================
// 4. INITIALISATION AU CHARGEMENT
// ==================================================

$(document).ready(function () {
    initPlugins();
    buildGroupFilterMenu();
    updateLabel();

    // Écouteurs filtres
    $('#groupFilterList').on('change', 'input[type="checkbox"]', handleFilterCheckboxChange);
    $('#btn-clear').on('click', clearFilters);
    $('#btn-apply').on('click', applyCombinedFilter);
    $('#groupFilterList').on('click', e => e.stopPropagation()); // Empêche fermeture menu
    $("#taxonInput").on("keyup", applyCombinedFilter);
});
