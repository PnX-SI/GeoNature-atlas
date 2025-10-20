function loadNewTaxons() {    
    page = 0;
    havePossibleNextPage = true;
    getTaxonElems().then(data => {
        document.getElementById('taxonList').querySelectorAll('ul')[0].innerHTML = data;
        // une fois que les données sont chargées, on est à la page 1
        page = 1;
    });
}

async function getTaxonElems() {
    let url = ""
    let currentList = [];

    const pathNameUrl = location.pathname.split("/").filter(segment => segment);
    
    switch (context.page) {
        case "area":
            // Territory sheet
            url = `/api/taxonList/area/${pathNameUrl[1]}`;
            break;
        case "taxon_rank_sheet":
            // Family list sheet
            url = `/api/taxonList/liste/${pathNameUrl[1]}`;
            break;
        case "group_sheet":
            // Group sheet
            url = `/api/taxonList/group/${pathNameUrl[1]}`;
            break;
        case "home_territory":
            // Default sheet (all species) used for home page (with territory map)
            url = `/api/taxonList`
            break;
    }

    let urlParams = new URLSearchParams([
        ["page", page],
        ["page_size", page_size],
    ]);
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

// event on scroll
document.getElementById('taxonList').addEventListener('scroll', debounce( onScroll , 200));

// event on taxon search
document.getElementById('taxonInput').addEventListener('keyup', debounce( (el) => {
        inputSearchTaxons = document.getElementById('taxonInput').value.toLowerCase();
    loadNewTaxons();
} , 200));

$(document).ready(function () {
    initPlugins();

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
