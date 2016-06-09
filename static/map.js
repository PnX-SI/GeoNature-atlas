// chargement des fonds de cartes
var osmTile = L.tileLayer(osmUrl, {attribution: osmAttribution}),
	ignTile = L.tileLayer(ignUrl, {attribution: ignAttribution});

//initilisation de la carte
	L.CRS.EPSG3857;	

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

var gejson = {"type":"Point","coordinates":[700543.748457624,5599618.49852064]};
L.geoJson(gejson).addTo(map);


function displayObs(geoJsonObs){
	L.geoJson(geoJsonObs).addTo(map);
	console.log('trace');

}
