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

function generateGeojsonPoint(observationsPoint){
   var myGeoJson = {'type': 'FeatureCollection','features' : []}

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

function displayMarkerLayer(observationsPoint, yearMin, yearMax){
  myGeojson = generateGeojsonPoint(observationsPoint, yearMin, yearMax)
  currentLayer = L.geoJson(myGeojson, {
          onEachFeature : onEachFeatureHome,
          pointToLayer: function (feature, latlng) {
                           return L.circleMarker(latlng);
                           }
  });
    currentLayer.addTo(map);
  }



// Markers display on window ready

$(function(){
  displayMarkerLayer(observationsPoint);
});