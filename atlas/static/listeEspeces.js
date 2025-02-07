$(".lazy").lazy({
          effect: "fadeIn",
          effectTime: 2000,
          threshold: 0,
          appendScroll: $("#taxonList")
        });
$('[data-toggle="tooltip"]').tooltip();
$(document).ready(function(){
  function filterListeEspèces() {
    let name = document.querySelector("#taxonInput").value.toLowerCase();
    let onlyProtégées = document.querySelector("#filtreProtégées").checked;
    let onlyPatrimoniales = document.querySelector("#filtrePatrimoniales").checked;
    $("#taxonList li").each(function() {
      let matched = $(this).text().toLowerCase().indexOf(name) > -1
        && (!onlyProtégées || "data-protégée" in this.attributes)
        && (!onlyPatrimoniales || "data-patrimoniale" in this.attributes);
      $(this).toggle(matched);
    });
  }

  document.querySelectorAll("#filtresListeEspèces input").forEach(
    (element) => element.addEventListener("input", filterListeEspèces)
  )
});