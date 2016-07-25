var map = generateMap()







// affichage des mailles
myGeoJson = generateGeojsonMaille(observations, taxonYearMin, $YEARMAX);
var currentLayer = L.geoJson(myGeoJson, {
  onEachFeature : onEachFeatureMaille,
  style: styleMaille,
  })
currentLayer.addTo(map);



// légende
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


 // Slider event
mySlider.on("change",function(){
    years = mySlider.getValue();
    yearMin = years[0];
    yearMax = years[1];
map.removeLayer(currentLayer);
 var filterGeoJson =  generateGeojson(observations, yearMin, yearMax)
  currentLayer =  L.geoJson(filterGeoJson, {
    onEachFeature : onEachFeature,
    style: style,
    })
    currentLayer.addTo(map);


    nbObs=0;
    filterGeoJson.features.forEach(function(l){
      nbObs += l.properties.nb_observations
    })

    $("#nbObs").html("Nombre d'observation(s): "+ nbObs);

   });


