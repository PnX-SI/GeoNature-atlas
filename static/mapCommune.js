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

	if(configuration.AFFICHAGE_MAILLE){ 
	    var legend = L.control({position: 'bottomleft'});

	var styleLegend = ['border: solid 1px red' , 'border-style: dotted ' , 'border: solid 1px blue;']

	       legend.onAdd = function (map) {

        var div = L.DomUtil.create('div', 'info legend'),
            grades = ["Maille comportant au moin  \ une observation &nbsp;&nbsp;&nbsp", "Limite de la commune", "Limite du "+ configuration.STRUCTURE],
            labels = [""];

        for (var i = 0; i < 3; i++) {
            labels.push(
                "<i style='"+ styleLegend[i]+"'></i> "
                 + grades[i] + "<br>" );
        }
        div.innerHTML = labels.join('<br>');

        return div;
    };

	    legend.addTo(map);
	}
});



