$(document).ready(function(){
  $('#myTable').show();
    $('#myTable').DataTable({
    	"order":[5, 'desc'],
    	"lengthChange": false,
    	"pageLength": 50,
        "oLanguage": {
           "sSearch": "",
            "sInfo": "",
            "sInfoEmpty": "",
            "sInfoFiltered": "",
            "sZeroRecords": "Aucune espèce trouvée",

        "oPaginate": {
           "sPrevious": "Précedent",
           "sNext" : "Suivant"
         }
      },
      "aoColumnDefs" : [
      {
       'bSortable' : false,
       'aTargets' : [7]
     }]
    });
    $('.dataTables_filter input').attr("placeholder", "Rechercher dans la liste ").attr("class", "form-control").css("font-weight", "normal");
    $('.dataTables_empty').text("Aucune espèce trouvée")

});


// change de glyphicon

$('th').click( function(){
    $(this).find('span').toggleClass('glyphicon glyphicon-menu-down').toggleClass('glyphicon glyphicon-menu-up');
});


