var map = generateMap()


function generateGeojson(observations, yearMin, yearMax) {

  var i=0;
  geoJson = {'type': 'FeatureCollection',
             'features' : []
          }
  tabProperties =[]
  while (i<observations.length){
    geometry = observations[i].geojson_maille;
    idMaille = observations[i].id_maille;
    properties = {id_maille : idMaille, nb_observations : observations[i].nb_observations};
    var j = i+1;
    while (j<observations.length && observations[j].id_maille <= idMaille){
      properties.nb_observations +=  observations[j].nb_observations
      j = j+1
    }
    geoJson.features.push({
        'type' : 'Feature',
        'properties' : properties,
        'geometry' : geometry   
    })
    // on avance jusqu' à j 
    i = j  ;
  }
  return geoJson
}



/*var i=0;
tabProperties =[]
while (i<observations.length){
  if(observations[i].annee > 1981 && observations[i].annee < 1984 ) {
    idMaille = observations[i].id_maille;
    properties = {id_maille : idMaille, nb_observations : observations[i].nb_observations};
    var j = i+1;
    while (j<observations.length && observations[j].id_maille <= idMaille){
      properties.nb_observations +=  observations[j].nb_observations
      j = j+1
    }
    tabProperties.push(properties)
    // on avance jusqu' à j 
    i = j  ;
  }
}*/


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


mygeoJson = generateGeojson(observations, 2016, 2016)
L.geoJson(mygeoJson, {
	onEachFeature : onEachFeature,
	style: style,
	}).addTo(map);


var legend = L.control({position: 'bottomright'});

legend.onAdd = function (map) {

    var div = L.DomUtil.create('div', 'info legend'),
        grades = [0, 1, 2, 5, 10, 20, 50, 100],
        labels = [];

    // loop through our density intervals and generate a label with a colored square for each interval
    for (var i = 0; i < grades.length; i++) {
        div.innerHTML +=
            '<i style="background:' + getColor(grades[i] + 1) + '"></i> ' +
            grades[i] + (grades[i + 1] ? '&ndash;' + grades[i + 1] + '<br>' : '+');
    }

    return div;
};



legend.addTo(map);

