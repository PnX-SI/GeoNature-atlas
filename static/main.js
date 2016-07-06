$(document).ready(function() {
  $(window).keydown(function(event){
    if(event.keyCode == 13) {
      event.preventDefault();
      return false;
    }
  });
});


autocompleteTaxons = function(listeTaxonsSearch){

	var tabTaxons = [];

	for(i=0; i<listeTaxonsSearch.length; i++){

		taxonObject = {label : listeTaxonsSearch[i][0], // label = latin name + vern name
					   value : listeTaxonsSearch[i][1] // value = cd_ref
	};
		tabTaxons.push(taxonObject);
	}

$("#searchFormTaxon").autocomplete({

		source: function (request, response) {
		var results = $.ui.autocomplete.filter(tabTaxons, request.term);
		response(results.slice(0, 20))},
         focus: function(event, ui) {
         	$('#search').val(ui.item.label)
            return false;
        },
       select : function (event, ui){
        	$('#hidden-input').val(ui.item.value);
        	$('#searchFormTaxon').submit();
      return false;
        }
});

}


// complete dynamically the form action on search submit
function completeAction(id){
  var inputInter = $(id).find('input');
  hiddenInput = inputInter[1];
  value = hiddenInput.value;
  var path;

  if (id == "#searchFormTaxon"){
    path = "/atlas/espece/"+parseInt(value);
  }
  if (id == "#searchFormCommunes"){
    path = "/atlas/commune/"+value;
  }

    $(id).attr("action", path);

}


autocompleteCommunes = function(communesSearch){

$("#searchCommunes").autocomplete({

    source: function (request, response) {
    var results = $.ui.autocomplete.filter(communesSearch, request.term);
    response(results.slice(0, 20))},
         focus: function(event, ui) {
          $('#searchCommunes').val(ui.item.label)
            return false;
        },
       select : function (event, ui){
          $('#hiddenInputCommunes').val(ui.item.value);
          $('#searchFormCommunes').submit();
      return false;
        }
});

}



$(function(){
  autocompleteTaxons(listeTaxonsSearch);
  autocompleteCommunes(communesSearch);
});

