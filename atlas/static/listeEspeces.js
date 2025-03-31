$(".lazy").lazy({
    effect: "fadeIn",
    effectTime: 2000,
    threshold: 0,
    appendScroll: $("#taxonList")
});
$('[data-toggle="tooltip"]').tooltip();

var taxonDomElem = Array.from(document.querySelectorAll("#taxonList li"))

$(document).ready(function(){
    function filterListeEspèces() {
        let name = document.querySelector("#taxonInput").value.toLowerCase();
        let onlyProtégées = document.querySelector("#filtreProtégées").checked;
        let onlyPatrimoniales = document.querySelector("#filtrePatrimoniales").checked;

        const filteredTaxonDomElem = taxonDomElem.filter(elem => {
            let matched = elem.innerText.toLowerCase().indexOf(name) > -1
                && (!onlyProtégées || "data-protégée" in elem.attributes)
                && (!onlyPatrimoniales || "data-patrimoniale" in elem.attributes);
            if (matched) {
                return true;
            }
        })
        document.querySelectorAll("#taxonList li").forEach(e => e.remove());
        document.querySelector("#taxonList ul").append(...filteredTaxonDomElem)
    }
    document.querySelectorAll("#filtresListeEspèces input").forEach(
        (element) => element.addEventListener("input", filterListeEspèces)
    )
});