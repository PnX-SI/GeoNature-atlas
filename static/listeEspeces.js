$(document).ready(function() {
  $("#myTable").show();
  $("#myTable").DataTable({
    responsive: true,
    order: [defaultSortedColumn, "desc"],
    aoColumnDefs: [
      {
        bSortable: false,
        aTargets: noSordedColumns
      }
    ],
    // ,"scrollY":500
    // ,"deferRender":true
    // ,"scroller": false
    lengthChange: true,
    pageLength: 50,
    oLanguage: {
      sSearch: "",
      sInfo: "",
      sInfoEmpty: "",
      sInfoFiltered: "",
      sZeroRecords: "Aucune espèce trouvée",
      oPaginate: {
        sPrevious: "Précedent",
        sNext: "Suivant"
      }
    },
    fnDrawCallback: function(oSettings) {
      //restore tooltips when page change
      $('[data-toggle="tooltip"]').tooltip();
      // Chargement "lazy" des photos
      $(".lazy").lazy();
    }
  });
  $(".dataTables_filter input")
    .attr("placeholder", "Rechercher dans la liste ")
    .attr("class", "form-control")
    .css("font-weight", "normal");
  $(".dataTables_empty").text("Aucune espèce trouvée");
});

// change de glyphicon
$("th").click(function() {
  $(this)
    .find("span")
    .toggleClass("glyphicon glyphicon-menu-down")
    .toggleClass("glyphicon glyphicon-menu-up");
});

// Load /espece/cd_ref on row click
// deactivate because is no compatible with datatables responsive plugin
// if(configuration.MYTYPE != 1){
// $(".taxonRow").click(function(){
// cd_ref = $(this).attr('cdRef');
// location.href = configuration.URL_APPLICATION+'/espece/'+cd_ref;
// });
// }
