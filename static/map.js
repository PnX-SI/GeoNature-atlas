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




/*latLongTest = L.coordsToLatLng([700543.748457624,5599618.49852064], True);
/*console.log(latLongTest);

*/


// convert coordinates in meter 3857 to coordinates in degrees : 4326
/*function convertCoord(geoJsonObs){
	var earthRadius = 6378137;
	geoJsonObs.forEach(function(obs){
		point = new L.Point(obs.coordinates[0], obs.coordinates[1]);
		latlng = L.Projection.SphericalMercator.unproject(
               point.divideBy(earthRadius));
		obs.coordinates = latLong;
	})
}

var point = new L.Point(mygeojson.coordinates[0],mygeojson.coordinates[1]);
var earthRadius = 6378137;
var latlng = L.Projection.SphericalMercator.unproject(
               point.divideBy(earthRadius));

console.log(latLong);

new L.Marker([latlng.lat, latlng.lng], {bounceOnAdd: true}).addTo(map);
*/

/*geojson = {
  		"type": "FeatureCollection",
  		"features": [ {
  		"type" : "Feature",
  		"properties" : {"john" :5},
  		"geometry": {"type":"Point","coordinates":[6.02106499971593,45.0663618221969]}
  		},
  		{"type" : "Feature",
		 "properties" : {"john" :5},
		 "geometry": {"type":"Point","coordinates":[6.01298290926569,44.753608073349]}
		}
		 ]
		};

	L.geoJson(geojson).addTo(map);
*/
 


function displayObs(geoJsonObs){

	L.geoJson(geoJsonObs, {
            onEachFeature : function(feature, layer){
            	popupOptions = {maxWidth: 200};
            	layer.bindPopup("<b>Altitude: </b>"+ feature.properties.altitude+
            		"</br><b>Observateurs: </b>"+ feature.properties.observateurs+
            		"</br><b>Effectif: </b>"+ feature.properties.effectif_total
            	,popupOptions);
            }
    	}).addTo(map);
}

/*L.geoJson(response, {
            style: function (feature) {
                return {
                    stroke: false,
                    fillColor: 'FFFFFF',
                    fillOpacity: 0
                };
            },
            onEachFeature: function (feature, layer) {
                popupOptions = {maxWidth: 200};
                layer.bindPopup("<b>Site name:</b> " + feature.properties.sitename +
                    "<br><b>Dog Exercise: </b>" + feature.properties.dog_exercise +
                    "<br><br>Please ensure that tidy up after your dog. Dogs must be kept under effective control at all times."
                    ,popupOptions);
            }
        }).addTo(map);*/