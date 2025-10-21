function loadNewTaxons() {    
    page = 0;
    havePossibleNextPage = true;
    getTaxonElems().then(data => {
        document.getElementById('taxonList').querySelectorAll('ul')[0].innerHTML = data;
        // une fois que les données sont chargées, on est à la page 1
        page = 1;
    });
}

function initApiUrls() {
    const pathNameUrl = location.pathname.split("/").filter(segment => segment);

    switch (context.page) {
        case "area":
            url = `${configuration.URL_APPLICATION}/api/taxonList/area/${pathNameUrl[2]}`;
            jsonUrl = `${configuration.URL_APPLICATION}/api/taxonListJson/area/${pathNameUrl[2]}`;
            break;
        case "taxon_rank_sheet":
            url = `${configuration.URL_APPLICATION}/api/taxonList/liste/${pathNameUrl[2]}`;
            jsonUrl = `${configuration.URL_APPLICATION}/api/taxonListJson/liste/${pathNameUrl[2]}`;
            break;
        case "group_sheet":
            url = `${configuration.URL_APPLICATION}/api/taxonList/group/${pathNameUrl[2]}`;
            jsonUrl = `${configuration.URL_APPLICATION}/api/taxonListJson/group/${pathNameUrl[2]}`;
            break;
        case "home_territory":
            url = `${configuration.URL_APPLICATION}/api/taxonList`;
            jsonUrl = `${configuration.URL_APPLICATION}/api/taxonListJson`;
            break;
    }
}

async function getTaxonElems() {
    let currentList = [];
    const pathNameUrl = location.pathname.split("/").filter(segment => segment);

    let urlParams = new URLSearchParams([
        ["page", page],
        ["page_size", page_size],
    ]);
    apiUrlParams = urlParams;
    if(inputSearchTaxons) {
        urlParams.append(
            "filter_taxons", inputSearchTaxons
        )
    }
    if(threatenedFilter) {
        urlParams.append("threatened", true);
    }
    if(protectedFilter) {
        urlParams.append("protected", true)
    }
    if(patrimonialFilter) {
        urlParams.append("patrimonial", patrimonialFilter)
    }
    groupINPNFilters.forEach(group => {
        urlParams.append("group2_inpn", group)
    })

    currentList = await fetch(`${url}?${urlParams}`, {
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



function updateLabel() {
    let badge = "";
    const nbFilters = threatenedFilter + protectedFilter + patrimonialFilter + groupINPNFilters.size;
    if (nbFilters > 0) {
        badge = `
         <span class="badge rounded-pill bg-danger">${nbFilters}</span>
        `
    }
    document.getElementById("nbFilter").innerHTML = badge;
}



function clearFilters() {
    $('#groupFilterList input[type="checkbox"]').prop('checked', false);
    $('#g-all').prop('checked', true);
    threatenedFilter = false;
    protectedFilter = false;
    patrimonialFilter = false;
    groupINPNFilters = new Set();
    updateLabel();
    loadNewTaxons();
}

// ==================================================
// Export csv & pdf
// ==================================================

async function exportCsv(){
    if (!apiUrlParams) {
        await loadNewTaxons(); 
    }

    let exportUrl = new URLSearchParams(apiUrlParams.toString());
    exportUrl.set("page", -1); // All pages fetched

    const fullList = await fetch(`${jsonUrl}?${exportUrl}`)
        .then(r => r.json()); 

    // Colonnes du CSV
    const rows = [[
        "CdRef", translationsExport.taxonomic_group, translationsExport.common_name, 
        translationsExport.scientific_name, translationsExport.occurrences_number, 
        translationsExport.observers_number, translationsExport.last_observation, 
        translationsExport.threatened_masc, translationsExport.strict_protection, 
        translationsExport.heritage, translationsExport.inpn_group_3
    ]];

    // Filtrer les taxons visibles dans taxonsData
    fullList.forEach(taxon => {
        const taxonomicGroup = taxon.group2_inpn || "-";
        const cdRef = taxon.cd_ref || "-";
        const nomVern = (typeof taxon.nom_vern === "string" && taxon.nom_vern) 
        ? taxon.nom_vern.split(',')[0].trim() 
        : "-";
        const nomSci = taxon.lb_nom || "-";
        const nbObs = taxon.nb_obs || "0";
        const nbObservers = taxon.nb_observers || "0";
        const lastYear = taxon.last_obs || "-";
        const patrimonial = taxon.patrimonial || false;
        const strictProtection = taxon.protection_stricte || false;
        const group3Inpn = taxon.group3_inpn || "-";

        // Ajout de la colonne "Menacé" en tant que true/false
        const isThreatened = threatenedTaxons.includes(Number(taxon.cd_ref));  

        rows.push([cdRef, taxonomicGroup, nomVern, nomSci, nbObs, 
        nbObservers, lastYear, isThreatened, strictProtection, patrimonial, group3Inpn]);
    });

    const fileName = document.getElementById("exportCsvBtn").dataset.filename;
    const csvContent = rows.map(row => row.join(";")).join("\n");
    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = fileName;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

async function exportPdf() {
    if (!apiUrlParams) {
        await loadNewTaxons(); 
    }

    let exportUrl = new URLSearchParams(apiUrlParams.toString());
    exportUrl.set("page", -1); // All pages fetched

    const fullList = await fetch(`${jsonUrl}?${exportUrl}`)
        .then(r => r.json());

    const { jsPDF } = window.jspdf;
    const doc = new jsPDF({ orientation: "landscape" });

    const fileName = document.getElementById("exportPdfBtn").dataset.filename;
    const title = fileName.replace(/\.pdf$/i, "");
    const pageWidth = doc.internal.pageSize.getWidth();

    doc.setFontSize(14.5);
    doc.text(title, pageWidth / 2, 15, { align: "center" });

    const headers = [
        [
            translationsExport.taxonomic_group,
            translationsExport.common_name,
            translationsExport.scientific_name,
            translationsExport.occurrences_number,
            translationsExport.observers_number,
            translationsExport.last_observation,
            translationsExport.threatened_masc,
            translationsExport.strict_protection,
            translationsExport.heritage,
        ]
    ];

    const data = fullList
        .map(taxon => {
        const isThreatened = threatenedTaxons.includes(Number(taxon.cd_ref)) ? true : false;
        return [
            taxon.group2_inpn || "-",
            (typeof taxon.nom_vern === "string" && taxon.nom_vern) 
            ? taxon.nom_vern.split(',')[0].trim() 
            : "-",
            taxon.lb_nom || "-",
            taxon.nb_obs || "0",
            taxon.nb_observers || "0",
            taxon.last_obs || "-",
            isThreatened,
            taxon.protection_stricte || false,
            taxon.patrimonial || false,
        ]});

    doc.autoTable({
        startY: 25,
        head: headers,
        body: data,
        styles: { fontSize: 9, cellPadding: 1 },
        headStyles: { fillColor: [40, 60, 100], halign: 'center' },
        margin: { top: 20 },
        columnStyles: {
            3: { halign: 'center' }, // Occurrences number
            4: { halign: 'center' }, // Observers number
            5: { halign: 'center' }  // Last observation
        },
        didParseCell: function (data) {
            const threatenedColumnIndex = 6; // Threatened column index
            const protectedColumnIndex = 7;  // Protected column index

            if (data.section === 'body') {
                if (data.row.raw[threatenedColumnIndex] === true) {
                    data.cell.styles.fillColor = [255, 200, 200]; // light red
                }
                else if (data.row.raw[protectedColumnIndex] === true) {
                    data.cell.styles.fillColor = [200, 230, 255]; // light blue
                }
            }
        }
    });

    doc.save(fileName);
}

// ==================================================
// INITIALISATION 
// ==================================================

// on commence à la page 1 car le backend nous renvoie déjà la page 0
let page = 1;
let page_size = configuration.ITEMS_PER_PAGE
let havePossibleNextPage = true;
// var for filters
let inputSearchTaxons = "";
let groupINPNFilters = new Set();
let threatenedFilter = null;
let protectedFilter = null;
let patrimonialFilter = null;
let url = null;
let jsonUrl = null;
let apiUrlParams = null;

// event on scroll
document.getElementById('taxonList').addEventListener('scroll', debounce( onScroll , 200));

// event on taxon search
document.getElementById('taxonInput').addEventListener('keyup', debounce( (el) => {
        inputSearchTaxons = document.getElementById('taxonInput').value.toLowerCase();
    loadNewTaxons();
} , 200));

$(document).ready(function () {
    initApiUrls();
    initPlugins();

    $("#exportCsvBtn").on("click", exportCsv);
    $("#exportPdfBtn").on("click", exportPdf);
});

$('.groupINPN').on('change', 'input[type="checkbox"]', function(event) {
    if(event.target.checked) {
        groupINPNFilters.add(event.target.value);
    } else {
        groupINPNFilters.delete(event.target.value);
    }
    updateLabel();
    loadNewTaxons();
});

$('#protected').on('change', 'input[type="checkbox"]', function(event) {
    protectedFilter = event.target.checked;
    updateLabel();
    loadNewTaxons();
});

$('#threatened').on('change', 'input[type="checkbox"]', function(event) {
    threatenedFilter = event.target.checked;
    updateLabel();
    loadNewTaxons();
});

$('#patrimonial').on('change', 'input[type="checkbox"]', function(event) {
    patrimonialFilter = event.target.checked;
    updateLabel();
    loadNewTaxons();
});

$('#btn-clear').on('click', clearFilters);
