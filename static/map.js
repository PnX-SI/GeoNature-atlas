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



// Map and markers options

checkboxCluster = $("[name='my-checkbox']").bootstrapSwitch();



// slider

var slider =   $( "#slider" ).slider({
      value: 2000,
       min: 1973,
       max: 2016,
       step: 1
     });



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

var newClusterMarker;
function loadfilterLayer(geoJsonObs, year){
    // create an empty geoJson
    filterGeoJson = {'type': 'FeatureCollection',
                    'features' : []
                  }
    
    // create a the new filter geoJson filtering the year
    filterGeoJson.features = geoJsonObs.features.filter(function(marker){
      return marker.properties.year > year
    })
    //generate the new cluster marker and add it to the map
    newClusterMarker= generateClusterFromGeoJson(filterGeoJson)
    map.addLayer(newClusterMarker);
}


var clusterMarkers ;
function displayFilterMarkers(geoJsonObs){
  clusterMarkers = generateClusterFromGeoJson(geoJsonObs);
  map.addLayer(clusterMarkers);
}






 

// display markers with or without clusters
/*function displayObs(geoJsonObs){


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
*/
