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
		console.log(observations);
	if (configuration.AFFICHAGE_MAILLE){
		observations.sort(compare);
		console.log(observations);
		var geojsonMaille = generateGeoJsonMailleLastObs(observations);
      	currentLayer = L.geoJson(geojsonMaille,{onEachFeature: onEachFeatureMailleLastObs});
      	currentLayer.addTo(map);
	  }
		// POINT
	else{
	displayMarkerLayerPointLastObs(observations);

	}
})