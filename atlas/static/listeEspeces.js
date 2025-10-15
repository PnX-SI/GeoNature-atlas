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








