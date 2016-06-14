// load tiles
var osmTile = L.tileLayer(osmUrl, {attribution: osmAttribution}),
	ignTile = L.tileLayer(ignUrl, {attribution: ignAttribution});

//map initialization

  var map = L.map('map',{
  	crs: L.CRS.EPSG3857,
  	center: latLong,
  	zoom: setZoom,
  	layers: [osmTile, ignTile]
  	});

// add a tile selector
var baseMap = {
	"OSM": osmTile,
	"IGN": ignTile
}

L.control.layers(baseMap).addTo(map);


// add all observations markers whith popup

function onEachFeature(feature, layer){
		popupContent = "<b>Date: </b>"+ feature.properties.dateobs+"</br><b>Altitude: </b>"+ feature.properties.altitude_retenue+
            		"</br><b>Observateurs: </b>"+ feature.properties.observateurs;

     // verifie si le champs effectif est rempli
      if(feature.properties.effectif_total){
      	layer.bindPopup(popupContent+"</br><b>Effectif: </b>"+ feature.properties.effectif_total);
      }else{
      	layer.bindPopup(popupContent)
      }
}


checkboxCluster = $("[name='my-checkbox']").bootstrapSwitch();



// display markers with or without clusters
function displayObs(geoJsonObs){

   var singleMarkers = L.geoJson(geoJsonObs, {
                       onEachFeature : onEachFeature,
                       pointToLayer: function (feature, latlng) {
                          return L.circleMarker(latlng);
                          },
                       style: function(feature){
                          switch (feature.properties.ageobs){
                            case 0 : return {color: "#ff0000"};
                            case 1 : return {color: "#0000ff"};
                        }
                       }
                       });

  var clusterMarkers = L.markerClusterGroup({disableClusteringAtZoom: 11});
  clusterMarkers.addLayer(singleMarkers);
  map.addLayer(clusterMarkers);

  $('#checkbox').on('switchChange.bootstrapSwitch', function(state) {
    if (!this.checked){
        map.removeLayer(clusterMarkers);
        singleMarkers.addTo(map);
    }else{
        map.removeLayer(singleMarkers);
        map.addLayer(clusterMarkers);
    }
  });
}
