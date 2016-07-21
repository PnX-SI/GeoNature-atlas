var map = generateMap()





function generateGeojson(observations, yearMin, yearMax) {

  var i=0;
  myGeoJson = {'type': 'FeatureCollection',
             'features' : []
          }
  tabProperties =[]
  while (i<observations.length){
    if(observations[i].annee >= yearMin && observations[i].annee <= yearMax ) {
      geometry = observations[i].geojson_maille;
      idMaille = observations[i].id_maille;
      properties = {id_maille : idMaille, nb_observations : observations[i].nb_observations};
      var j = i+1;

      while (j<observations.length && observations[j].id_maille <= idMaille){
        if(observations[j].annee >= yearMin && observations[j].annee <= yearMax ){
          properties.nb_observations +=  observations[j].nb_observations
        }
        j = j+1
      }
      myGeoJson.features.push({
          'type' : 'Feature',
          'properties' : properties,
          'geometry' : geometry   
      })
      // on avance jusqu' à j 
      i = j  ;
    }
    else {
      i = i+1;
    }
  }
  return myGeoJson

}

function getColor(d) {
    return d > 100 ? '#800026' :
           d > 50  ? '#BD0026' :
           d > 20  ? '#E31A1C' :
           d > 10  ? '#FC4E2A' :
           d > 5   ? '#FD8D3C' :
           d > 2   ? '#FEB24C' :
           d > 1   ? '#FED976' :
                      '#FFEDA0';
}

function style(feature) {
    return {
        fillColor: getColor(feature.properties.nb_observations),
        weight: 2,
        opacity: 1,
        color: 'white',
        dashArray: '3',
        fillOpacity: 0.7
    };
}


function onEachFeature(feature, layer){
    popupContent = "<b>Nombre d'observation(s): </b>"+ feature.properties.nb_observations+"</br>";
    layer.bindPopup(popupContent)
      }



var currentLayer = L.geoJson(generateGeojson(observations, taxonYearMin, $YEARMAX), {
  onEachFeature : onEachFeature,
  style: style,
  })
currentLayer.addTo(map);


 // Slider event
mySlider.on("change",function(){
    years = mySlider.getValue();
    yearMin = years[0];
    yearMax = years[1];
map.removeLayer(currentLayer);

  currentLayer =  L.geoJson(generateGeojson(observations, yearMin, yearMax) , {
    onEachFeature : onEachFeature,
    style: style,
    })
    currentLayer.addTo(map);


    //$("#nbObs").html("Nombre d'observation(s): "+ filterGeoJson.features.length);

   });