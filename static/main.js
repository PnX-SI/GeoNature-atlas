
autocompleteTaxons = function(listeTaxons){

	var tabTaxons = [];

	for(i=0; i<listeTaxons.length; i++){
		var taxonObject = {}
		if(listeTaxons[i][2] == null){
			taxonName = listeTaxons[i][0]
		}else{
			taxonName = listeTaxons[i][0] +' - '+ listeTaxons[i][2]
		}

		taxonObject = {label : taxonName, // label = latin name + vern name
					   value : listeTaxons[i][1],
					   nom_vern : listeTaxons[i][2] // value = cd_ref
	};
		tabTaxons.push(taxonObject);
	}

$("#search").autocomplete({

		source: function (request, response) {
		var results = $.ui.autocomplete.filter(tabTaxons, request.term);
		response(results.slice(0, 10))},
         focus: function(event, ui) {
         	$('#search').val(ui.item.label)
            return false;
        },
       select : function (event, ui){
        	$('#hidden-input').val(ui.item.value);
        	return false;
        }
});

}

$(function(){
	autocompleteTaxons(listeTaxons);
})
