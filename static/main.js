$(document).ready(function() {
  $(window).keydown(function(event){
    if(event.keyCode == 13) {
      event.preventDefault();
      return false;
    }
  });
});

autocompleteTaxons = function(listeTaxons){

	var tabTaxons = [];

	for(i=0; i<listeTaxons.length; i++){

		taxonObject = {label : listeTaxons[i][0], // label = latin name + vern name
					   value : listeTaxons[i][1] // value = cd_ref
	};
		tabTaxons.push(taxonObject);
	}

$("#search").autocomplete({

		source: function (request, response) {
		var results = $.ui.autocomplete.filter(tabTaxons, request.term);
		response(results.slice(0, 20))},
         focus: function(event, ui) {
         	$('#search').val(ui.item.label)
            return false;
        },
       select : function (event, ui){
        	$('#hidden-input').val(ui.item.value);
        	$('#searchForm').submit();
      return false;
        }
});

}

function completeAction(){
  var cd_ref = $('#hidden-input').val()
  var path = "/atlas/espece/"+parseInt(cd_ref);
  $("form").attr("action", path)
        }


$(function(){
	autocompleteTaxons(listeTaxons);
})

