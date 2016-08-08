
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
    myGeoJson.features.forEach(function(l){
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




// Event on click on firstObs and lastObs

/*$('#firstObs').click(function(){
  var firstObsLayer;
  var year = new Date('2400-01-01');
  console.log(currentLayer);

  zoomLev = map.getZoom();
  // if layer are points
    if(map.getZoom() >= configuration.ZOOM_LEVEL_POINT) { 

      // check if layer is single point or cluster 
    var layer = (myGeoJson.features.length > configuration.LIMIT_CLUSTER_POINT) ? currentLayer._featureGroup._layers : currentLayer._layers;

      for (key in layer){
          if(layer[key].feature != undefined){ 
            if (layer[key].feature.properties.dateobsCompare < year){
              firstObsLayer = layer[key]
              year = layer[key].feature.properties.dateobsCompare;
            }
         }
      }
        map.setView(firstObsLayer._latlng, 13); 
          firstObsLayer.openPopup();
    }

    // if layers are 'maille'
    else{

        var layer = (currentLayer._layers);
        for (var key in layer) {
          layer[key].feature.properties.tabDateobs.forEach(function(thisYear){
            if (thisYear <= year){
              year = thisYear;
              firstObsLayer = layer[key];
            }
          });
        }

        
        var bounds = L.latLngBounds([]);
        var layerBounds = firstObsLayer.getBounds();
        bounds.extend(layerBounds);
        map.fitBounds(bounds, {
          maxZoom : 12
        });

        firstObsLayer.openPopup();

    }
 
})*/