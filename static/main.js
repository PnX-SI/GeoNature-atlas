
autocompleteTaxons = function(listeTaxons){

	var tabTaxons = [];
	for(i=0; i<listeTaxons.length; i++){
		tabTaxons.push(listeTaxons[i][0]);
	}

	$("#search").autocomplete({
        source: function(request, response){
            var results = $.ui.autocomplete.filter(tabTaxons, request.term);
            response(results.slice(0, 10));
        }
    })
}
