
autocompleteTaxons = function(listeTaxons){

	var tabTaxons = [];

	for(i=0; i<listeTaxons.length; i++){
		var taxonObject = {}
		taxonObject = {label : listeTaxons[i][0], // label = nom latin
					   value : listeTaxons[i][1], // value = cd_ref
	};
		tabTaxons.push(taxonObject);
	}


$("#search").autocomplete({

		source: function (request, response) {
		var results = $.ui.autocomplete.filter(tabTaxons, request.term);
		response(results.slice(0, 10))},
         focus: function(event, ui) {
         	console.log(ui);
         	$('#search').val(ui.item.label)
            return false;
        },
       select : function (event, ui){
        	$('#hidden-input').val(ui.item.value);
        	return false;
        }

    })
};
