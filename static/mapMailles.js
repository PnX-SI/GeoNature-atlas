var map = generateMap()


// affichage des mailles
$(function(){
displayMailleLayerFicheEspece(observationsMaille, taxonYearMin, $YEARMAX);  
});


 // Slider event
mySlider.on("change",function(){
      years = mySlider.getValue();
      yearMin = years[0];
      yearMax = years[1];
      map.removeLayer(currentLayer);
      displayMailleLayerFicheEspece(observationsMaille, yearMin, yearMax)


    nbObs=0;
    myGeojson.features.forEach(function(l){
      nbObs += l.properties.nb_observations
    })

    $("#nbObs").html("Nombre d'observation(s): "+ nbObs);

   });


