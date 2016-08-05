
var map = generateMap();


// Layer display on window ready

$(function(){
  displayMailleLayerFicheEspece(observationsMaille, taxonYearMin, $YEARMAX);

})


// Legende

htmlLegend = "<i style='border: solid 1px blue;'> &nbsp; &nbsp; &nbsp;</i> Limite du "+ configuration.STRUCTURE;
generateLegende(htmlLegend);


 // Slider event
mySlider.on("change",function(){
    years = mySlider.getValue();
    yearMin = years[0];
    yearMax = years[1];


    map.removeLayer(currentLayer);
    if(map.getZoom() >= 11){
      displayMarkerLayerFicheEspece(observationsPoint, yearMin, yearMax);
    }else{
      displayMailleLayerFicheEspece(observationsMaille, yearMin, yearMax)
    }

    console.log(myGeojson);
    nbObs=0;
    myGeojson.features.forEach(function(l){
      nbObs += l.properties.nb_observations
    })

    $("#nbObs").html("Nombre d'observation(s): "+ nbObs);

   });



// ZoomEvent
var legendblock = $("div.info");

map.on("zoomend", function(){
zoomLev = map.getZoom();

if (zoomLev >= configuration.ZOOM_LEVEL_POINT){
  map.removeLayer(currentLayer);
  legendblock.attr("hidden", "true");

    years = mySlider.getValue();
    yearMin = years[0];
    yearMax = years[1];

  displayMarkerLayerFicheEspece(observationsPoint, yearMin, yearMax);
}
if (zoomLev <= configuration.ZOOM_LEVEL_POINT -1 ){
  // display legend
  map.removeLayer(currentLayer);
  legendblock.removeAttr( "hidden" );

    years = mySlider.getValue();
    yearMin = years[0];
    yearMax = years[1];
  displayMailleLayerFicheEspece(observationsMaille, yearMin, yearMax);
}

});