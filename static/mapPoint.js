
var map = generateMap();


// Layer display on window ready

$(function(){
  displayMailleLayer(observationsMaille, taxonYearMin, $YEARMAX);  
  $("#nbObs").html("Nombre d'observation(s): "+ myGeojson.features.length);

})



 // Slider event
mySlider.on("change",function(){
    years = mySlider.getValue();
    yearMin = years[0];
    yearMax = years[1];

    map.removeLayer(currentLayer);
    if(map.getZoom() >= 11){
      displayMarkerLayer(observationsPoint, yearMin, yearMax)
    }else{
      displayMailleLayer(observationsMaille, yearMin, yearMax)
    }


  $("#nbObs").html("Nombre d'observation(s): "+ myGeojson.features.length);

   });



// ZoomEvent
var legendblock = $("div.info");

map.on("zoomend", function(){
zoomLev = map.getZoom();

if (zoomLev == configuration.ZOOM_LEVEL_POINT){
  map.removeLayer(currentLayer);
  legendblock.attr("hidden", "true");
  console.log(legendblock);

    years = mySlider.getValue();
    yearMin = years[0];
    yearMax = years[1];
  displayMarkerLayer(observationsPoint, yearMin, yearMax)
}
if (zoomLev <= configuration.ZOOM_LEVEL_POINT -1 ){
  // display legend
  map.removeLayer(currentLayer);
  legendblock.removeAttr( "hidden" );

    years = mySlider.getValue();
    yearMin = years[0];
    yearMax = years[1];
  displayMailleLayer(observationsMaille, yearMin, yearMax)
}

});