// chargement des fonds de cartes
var osmTile = L.tileLayer(osmUrl, {attribution: osmAttribution}),
	ignTile = L.tileLayer(ignUrl, {attribution: ignAttribution});

//initilisation de la carte
  var map = L.map('map',{
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

var gejson = {"type":"Point","coordinates":[6.083333, 44.566667]};
L.geoJson(gejson).addTo(map);


/*function afficherObs(geoJsonObs){
	L.geoJson(geoJsonObs).addTo(map);
	console.log('trace');

}*/
