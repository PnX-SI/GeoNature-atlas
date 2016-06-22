// load tiles
var osmTile = L.tileLayer(osmUrl, {attribution: osmAttribution}),
  ignTile = L.tileLayer(ignUrl, {attribution: ignAttribution}),
  orthoTile = L.tileLayer(orthoIGN, {attribution: ignAttribution});


//map initialization

  var map = L.map('map',{
    crs: L.CRS.EPSG3857,
    center: latLong,
    zoom: setZoom,
    layers: [osmTile, ignTile],
    fullscreenControl: true,

    });

// add a tile selector
var baseMap = {
"OSM": osmTile,
"IGN": ignTile,
"Satellite": orthoTile
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




function style(feature){
    return {
        color: "#A3C990",
        filColor : "#A3C990",
        opacity : 0.4,
        fillOpacity: 0.5
    };
}

// ******** Marker and map options *************
// Markers
function generateSingleMarkerFromGeoJson(geoJsonObs){
    var singleMarkers = L.geoJson(geoJsonObs, {
        onEachFeature : onEachFeature,
        pointToLayer: function (feature, latlng) {
            return L.circleMarker(latlng);
        }
    });
    return singleMarkers;
}

function displayMarkers(geoJsonObs){
  var markers = generateSingleMarkerFromGeoJson(geoJsonObs);
  map.addLayer(markers);
}


// Markers display on window ready

$(function(){
  displayMarkers(observations);
});