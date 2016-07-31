var map = generateMap();


function displayMailleLayer(observations){
	
}


$(function(){
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
	bounds.extend(layerBounds)
	map.fitBounds(bounds);

	displayMarkerLayer(observations)
})