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



// ******** Marker and map options *************


// Markers


function generateClusterFromGeoJson (geoJsonObs){
       var singleMarkers = L.geoJson(geoJsonObs, {
                         onEachFeature : onEachFeature,
                         pointToLayer: function (feature, latlng) {
                           return L.circleMarker(latlng);
                           }
                       });
  var clusterMarkers = L.markerClusterGroup({disableClusteringAtZoom: 11});
  clusterMarkers.addLayer(singleMarkers);
  
  return clusterMarkers;
}



var clusterMarkers ;
function displayMarkers(geoJsonObs){
  clusterMarkers = generateClusterFromGeoJson(geoJsonObs);
  map.addLayer(clusterMarkers);
  console.log(geoJsonObs);
}


var newClusterMarker;
function displayFilterMarkers(geoJsonObs, yearMin, yearMax){
    // create an empty geoJson
    filterGeoJson = {'type': 'FeatureCollection',
                    'features' : []
                  }
    
    // create a the new filter geoJson filtering the year
    filterGeoJson.features = geoJsonObs.features.filter(function(marker){
      return (marker.properties.year >= yearMin && marker.properties.year <= yearMax)
    })
    console.log(filterGeoJson)
    //generate the new cluster marker and add it to the map
    newClusterMarker= generateClusterFromGeoJson(filterGeoJson)
    map.addLayer(newClusterMarker);
}


// Slider

// slider


var mySlider = new Slider('#slider', {
  value: [$YEARMIN, $YEARMAX],
  min : $YEARMIN,
  max : $YEARMAX,
  step: $STEP,
  ticks: $LEGEND,
  ticks_labels: $STRINGLEGEND,
});

