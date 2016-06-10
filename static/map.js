// chargement des fonds de cartes
var osmTile = L.tileLayer(osmUrl, {attribution: osmAttribution}),
	ignTile = L.tileLayer(ignUrl, {attribution: ignAttribution});

//initilisation de la carte

  var map = L.map('map',{
  	crs: L.CRS.EPSG3857,
  	center: latLong,
  	zoom: setZoom,
  	layers: [osmTile, ignTile]
  	});

// ajout d'un selecteur de fond de carte
var baseMap = {
	"OSM": osmTile,
	"IGN": ignTile
}

L.control.layers(baseMap).addTo(map);


// add all observations markers whith popup

function onEachFeature(feature, layer){
		popupContent = "<b>Date: </b>"+ feature.properties.dateobs+"</br><b>Altitude: </b>"+ feature.properties.altitude+
            		"</br><b>Observateurs: </b>"+ feature.properties.observateurs
        if(feature.properties.effectif_total){
        	layer.bindPopup(popupContent+"</br><b>Effectif: </b>"+ feature.properties.effectif_total);
        }else{
        	layer.bindPopup(popupContent)
        }

}


function displayObs(geoJsonObs){

	L.geoJson(geoJsonObs, {
            onEachFeature : onEachFeature
    	}).addTo(map);
}
