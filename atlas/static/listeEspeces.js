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
    url = `${configuration.URL_APPLICATION}/api/taxonList`
    jsonUrl = `${configuration.URL_APPLICATION}/api/taxonListJson`;
    if(context.page != 'home_territory') {
        url = `${url}/${context.page}/${context.page_param}`;
        jsonUrl = `${jsonUrl}/${context.page}/${context.page_param}`;
    }
}

/**
 * 
 * @param {*} urlParams type : URLSearchParams
 * Build the query string from UI parameters
 */
function buildQueryString(urlParams) {
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

    return urlParams;
}

async function getTaxonElems() {
    let currentList = [];

    let baseQueryString = new URLSearchParams([
        ["page", page],
        ["page_size", page_size],
    ]);
    let queryString = buildQueryString(baseQueryString);
    currentList = await fetch(`${url}?${queryString}`, {
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
    // init the query string with page = -1 -> not pagination for export
    let baseQueryString = new URLSearchParams({"page": "-1"})
    let queryString = buildQueryString(baseQueryString);

    const fullList = await fetch(`${jsonUrl}?${queryString}`)
        .then(r => r.json()); 

    // Colonnes du CSV
    const columns = [
        "cd_ref", translationsExport.taxonomic_group, translationsExport.common_name, 
        translationsExport.scientific_name, translationsExport.occurrences_number, 
        translationsExport.observers_number, translationsExport.last_observation, 
        translationsExport.threatened_masc, translationsExport.strict_protection, 
         translationsExport.inpn_group_3
    ]
    const rows = [];
    if(configuration.DISPLAY_PATRIMONIALITE) {
        columns.push(translationsExport.patrimonial);
    }
    rows.push(columns)


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
        const patrimonial = taxon.patrimonial ? translationsExport.yes: translationsExport.no;
        const strictProtection = taxon.protection_stricte ? translationsExport.yes: translationsExport.no;
        const group3Inpn = taxon.group3_inpn || "-";
        const isThreatened = taxon.menace ? translationsExport.yes: translationsExport.no;;
        // TODO : is threatened
        // Ajout de la colonne "Menacé" en tant que true/false
        row = [cdRef, taxonomicGroup, nomVern, nomSci, nbObs, 
            nbObservers, lastYear, isThreatened, strictProtection, group3Inpn];
        if(configuration.DISPLAY_PATRIMONIALITE) {
            row.push(patrimonial)
        }

        rows.push(row);
    });

    const fileName = context.file_export_name ? context.file_export_name + ".csv" : "export.csv"
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

    let baseQueryString = new URLSearchParams({"page": "-1"})
    let queryString = buildQueryString(baseQueryString);


    const fullList = await fetch(`${jsonUrl}?${queryString}`)
        .then(r => r.json());

    const { jsPDF } = window.jspdf;
    const doc = new jsPDF({ orientation: "landscape" });

    const fileName = context.file_export_name ? context.file_export_name + ".pdf" : "export.pdf"
    const title = fileName.replace(/\.pdf$/i, "");
    const pageWidth = doc.internal.pageSize.getWidth();

    doc.setFontSize(14.5);
    doc.text(title, pageWidth / 2, 15, { align: "center" });

    const columns = [
            translationsExport.taxonomic_group,
            translationsExport.common_name,
            translationsExport.scientific_name,
            translationsExport.occurrences_number,
            translationsExport.observers_number,
            translationsExport.last_observation,
            translationsExport.threatened_masc,
            translationsExport.strict_protection,
            translationsExport.inpn_group_3,
        ]
    if(configuration.DISPLAY_PATRIMONIALITE) {
        columns.push(translationsExport.patrimonial);
    }
    const headers = [columns];

    const data = fullList.map(taxon => {
        const row = [
            taxon.group2_inpn || "-",
            (typeof taxon.nom_vern === "string" && taxon.nom_vern) ? taxon.nom_vern.split(',')[0].trim(): "-" ,
            taxon.lb_nom || "-",
            taxon.nb_obs || "0",
            taxon.nb_observers || "0",
            taxon.last_obs || "-",
            taxon.menace ? translationsExport.yes: translationsExport.no,
            taxon.protection_stricte ? translationsExport.yes: translationsExport.no,
            taxon.group3_inpn || "-",
        ];
        if(configuration.DISPLAY_PATRIMONIALITE) {
            
            row.push(
                taxon.patrimonial == "oui" ? translationsExport.yes: translationsExport.no
            )
        }
        return row;
    });

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
                if (data.row.raw[threatenedColumnIndex] === translationsExport.yes) {
                    data.cell.styles.fillColor = [255, 200, 200]; // light red
                }
                else if (data.row.raw[protectedColumnIndex] === translationsExport.yes) {
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
