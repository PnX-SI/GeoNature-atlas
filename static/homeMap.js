var map = generateMap();



// add all observations markers whith popup

function onEachFeatureHome(feature, layer){
    popupContent = "<b>Espèce: </b>"+ feature.properties.taxon_name+
                "</br><b>Date: </b>"+ feature.properties.dateobs+"</br><b>Altitude: </b>"+ feature.properties.altitude_retenue;

     // verifie si le champs effectif est rempli
      if(feature.properties.effectif_total){
        layer.bindPopup(popupContent+"</br><b>Effectif: </b>"+ feature.properties.effectif_total);
      }
      layer.bindPopup(popupContent + "</br> <a href=espece/"+feature.properties.cd_ref+"> Fiche espèce </a>")
      
}

var myGeoJson;
function generateGeojsonPoint(observationsPoint){
    myGeoJson = {'type': 'FeatureCollection','features' : []}

      observationsPoint.forEach(function(obs){
              geometry = obs.geojson_point;
              properties = {'id_synthese' : obs.id_synthese,
                             'taxon_name' : obs.taxon,
                            'cd_ref': obs.cd_ref,
                            'dateobs': obs.dateobs,
                            'altitude_retenue' : obs.altitude_retenue,
                            'effectif_total' : obs.effectif_total,
                            }
              myGeoJson.features.push({
                'type' : 'Feature',
                'properties' : properties,
                'geometry' : geometry   
              })
      });
  return myGeoJson
}

var currentLayer;
function displayMarkerLayer(observationsPoint){
  myGeojson = generateGeojsonPoint(observationsPoint)
  currentLayer = L.geoJson(myGeojson, {
          onEachFeature : onEachFeatureHome,
          pointToLayer: function (feature, latlng) {
                           return L.circleMarker(latlng);
                           }
  });
    currentLayer.addTo(map);
  }

/*function styleFocus(feature){
  if (feature.properties.cd_ref == 61098 ){
    return {
        color: '#F50000'
    }
  }
}
*/
function focusMarkerLayer(cd_ref){
  map.removeLayer(currentLayer);
  currentLayer = L.geoJson(myGeojson, {
          onEachFeature : onEachFeatureHome,
          style : function(feature){
             if (feature.properties.cd_ref == cd_ref ){
                  return {
                    color: '#F50000'
                }
             }
          },
          pointToLayer: function (feature, latlng) {
                           return L.circleMarker(latlng);
                           }
  });
    currentLayer.addTo(map);

}






// Markers display on window ready

$(function(){
  displayMarkerLayer(observations);
  var p = (currentLayer._layers);
  var selectLayer;
  for (var key in p) {
    if (p[key].feature.properties.cd_ref == 2954){
      selectLayer = p[key];
    }
}
/*console.log(selectLayer._latlng);
  currentLayer.on('click', function(e){
    map.setView(e.latlng, 13);
});*/
});