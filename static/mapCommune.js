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


    var legend = L.control({position: 'bottomleft'});

        legend.onAdd = function (map) {

            var div = L.DomUtil.create('div', 'info legend'),
                  labels = "<i style='border: solid 1px red;'></i> Maille comportant au moin une observation &nbsp;&nbsp;&nbsp " 

    
            div.innerHTML = labels;

            return div;
        };

     $('.legend').css({"line-height": "16px", "opacity": 1});
    legend.addTo(map);



})

