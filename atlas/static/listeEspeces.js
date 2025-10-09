$(".lazy").lazy({
    effect: "fadeIn",
    effectTime: 2000,
    threshold: 0,
    appendScroll: $("#taxonList")
});
$('[data-toggle="tooltip"]').tooltip();

var inputSearchTaxons = ""
let page = 0
let page_size = configuration.ITEMS_PER_PAGE
let havePossibleNextPage = true;

$(document).ready(function(){
    $("#taxonInput").on("keyup", function() {
        inputSearchTaxons = $(this).val().toLowerCase();
        page = 0;
        havePossibleNextPage = true;
        getTaxonElems(inputSearchTaxons).then(data => {
            document.getElementById('taxonList').querySelectorAll('ul')[0].innerHTML = data;
        });
    });
});


async function getTaxonElems() {
    let url = ""
    let currentList = []

    const pathNameUrl = location.pathname.split("/").filter(segment => segment);

    switch (pathNameUrl[0]) {
        case "area":
            // Territory sheet
            url = `/api/taxonList/area/${pathNameUrl[1]}?page=${page}&page_size=${page_size}&filter_taxons=${inputSearchTaxons}`;
            break;
        case "liste":
            // Family list sheet
            url = `/api/taxonList/liste/${pathNameUrl[1]}?page=${page}&page_size=${page_size}&filter_taxons=${inputSearchTaxons}`;
            break;
        case "groupe":
            // Group sheet
            url = `/api/taxonList/group/${pathNameUrl[1]}?page=${page}&page_size=${page_size}&filter_taxons=${inputSearchTaxons}`;
            break;
        default:
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
    const scrollTop = element.scrollTop; // Current scroll position
    const scrollHeight = element.scrollHeight;
    const clientHeight = element.clientHeight; // visibility size

    if (scrollTop + clientHeight >= scrollHeight && havePossibleNextPage) {
        element.parentElement.querySelector("#list-taxon-loader-spinner").style.display = 'block'
        page++;
        const data = await getTaxonElems();
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

getTaxonElems().then(data => {
    document.getElementById('taxonList').querySelectorAll('ul')[0].innerHTML = data;
});

document.getElementById('taxonList').addEventListener('scroll', debounce( onScroll , 200))
