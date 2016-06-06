
//*** autocomplete recherche espece ****

$(document).ready(function(){
	$.get("http://188.165.118.87/atlas/listeTaxons", function(data){
		resultat = data.result;
		tabNom = [];
		data.result.forEach(function(nom){
			tabNom.push(nom[0]);
		})

		$("#search").autocomplete({
			source: function(request, response){
				var results = $.ui.autocomplete.filter(tabNom, request.term);
				response(results.slice(0, 10));
			}
		});
	});
})



/*
listeTaxons = function(){
	$.ajax({ 
	    type: 'GET', 
	    url: "http://188.165.118.87/atlas/listeTaxons",  
	    dataType: 'json',
	    success: function(data) {
	       	console.log(data)
	       	//test(data)
	    }
	});
}
*/
function test(listTaxons){
	console.log("je suis les données"+ listTaxons[0])
}



