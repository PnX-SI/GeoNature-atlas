var map = generateMap();

    // Current observation Layer: leaflet layer type
var currentLayer; 

// Current observation geoJson:  type object
var myGeoJson;

	// Diplay limit of the territory
	var communeLayer = L.geoJson(communeGeoJson, {
		style : function(){
			return {
				fillColor: 'blue',
				opacity: 1,
				weight: 2,
				color: 'black',
				dashArray: '3',
				fillOpacity: 0
			}
		}
	}).addTo(map);

	var bounds = L.latLngBounds([]);
	var layerBounds = communeLayer.getBounds();
	bounds.extend(layerBounds);
	map.fitBounds(bounds);

	// Display the 'x' last observations
		// MAILLE
	if (configuration.AFFICHAGE_MAILLE){
		displayMailleLayerLastObs(observations)
	  }
		// POINT
	else{
	displayMarkerLayerPointLastObs(observations);

	}

	// Diplay legend

	htmlLegendMaille = "<i style='border: solid 1px red;'> &nbsp; &nbsp; &nbsp;</i> Maille comportant au moin une observation <br> <br>" +
						"<i style='border-style: dotted;'> &nbsp; &nbsp; &nbsp;</i> Limite de la commune <br> <br>"+
						"<i style='border: solid 2px blue;'> &nbsp; &nbsp; &nbsp;</i> Limite du "+configuration.STRUCTURE;

	htmlLegendPoint = "<i style='border-style: dotted;'> &nbsp; &nbsp; &nbsp;</i> Limite de la commune <br> <br>"+
						"<i style='border: solid 2px blue;'> &nbsp; &nbsp; &nbsp;</i> Limite du "+configuration.STRUCTURE

	htmlLegend = configuration.AFFICHAGE_MAILLE ? htmlLegendMaille : htmlLegendPoint;
// General Legend
	generateLegende(htmlLegend);





// display observation on click

function displayObsTaxonPoint(insee, cd_ref){
	console.log(insee);
	$.ajax({
  url: configuration.URL_APPLICATION+'/api/observations/'+insee+'/'+cd_ref, 
  dataType: "json"
	}).done(function(observations){
		map.removeLayer(currentLayer);
		displayMarkerLayerPointLastObs(observations);

	});
}


$(".displayObs").click(function(){
	
	displayObsTaxonPoint($(this).attr('insee'), $(this).attr('cdRef'));
	console.log($(this).attr('insee'));
})

