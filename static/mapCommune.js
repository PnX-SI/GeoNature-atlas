var map = generateMap();


$(function(){

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
						"<i style='border: solid 1px blue;'> &nbsp; &nbsp; &nbsp;</i> Limite du "+configuration.STRUCTURE;

	htmlLegendPoint = "<i style='border-style: dotted;'> &nbsp; &nbsp; &nbsp;</i> Limite de la commune <br> <br>"+
						"<i style='border: solid 1px blue;'> &nbsp; &nbsp; &nbsp;</i> Limite du "+configuration.STRUCTURE

	htmlLegend = configuration.AFFICHAGE_MAILLE ? htmlLegendMaille : htmlLegendPoint;

	generateLegende(htmlLegend);

});


// General Legend



