var map = generateMap()




// affichage des mailles
myGeoJson = generateGeojsonMaille(observationsMaille, taxonYearMin, $YEARMAX);
var currentLayer = L.geoJson(myGeoJson, {
  onEachFeature : onEachFeatureMaille,
  style: styleMaille,
  })
currentLayer.addTo(map);



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


