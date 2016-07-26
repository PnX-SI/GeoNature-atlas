
var map = generateMap();



var currentLayer ;
function displayMailleLayer(observationsMaille, yearMin, yearMax){
  mailleGeoJson = generateGeojsonMaille(observationsMaille, yearMin, yearMax)
  currentLayer = L.geoJson(mailleGeoJson, {
      onEachFeature : onEachFeatureMaille,
      style: styleMaille,
  });
currentLayer.addTo(map);
}

var clusterLayer;
function displayMarkerLayer(observationsPoint, yearMin, yearMax){
  geoJsonPoint = generateGeojsonPoint(observationsPoint, yearMin, yearMax)
  currentLayer = L.geoJson(geoJsonPoint, {
          onEachFeature : onEachFeaturePoint,
          pointToLayer: function (feature, latlng) {
                           return L.circleMarker(latlng);
                           }
  });
  if (geoJsonPoint.features.length > 1000) {
      newLayer = currentLayer;
      currentLayer = L.markerClusterGroup();
      currentLayer.addLayer(newLayer);
      map.addLayer(currentLayer)
  } else {
    currentLayer.addTo(map);
  }
}


// Layer display on window ready

$(function(){
  displayMailleLayer(observationsMaille, taxonYearMin, $YEARMAX);  
})


var legend = L.control({position: 'bottomright'});




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


/*    $("#nbObs").html("Nombre d'observation(s): "+ filterGeoJson.features.length);
*/
   });



// ZoomEvent
var legendblock = $("div.info");

map.on("zoomend", function(){
zoomLev = map.getZoom();

if (zoomLev == 11){
  map.removeLayer(currentLayer);
  legendblock.attr("hidden", "true");
  console.log(legendblock);

    years = mySlider.getValue();
    yearMin = years[0];
    yearMax = years[1];
  displayMarkerLayer(observationsPoint, yearMin, yearMax)
}
if (zoomLev <= 10){
  // display legend
  map.removeLayer(currentLayer);
  legendblock.removeAttr( "hidden" );

    years = mySlider.getValue();
    yearMin = years[0];
    yearMax = years[1];
  displayMailleLayer(observationsMaille, yearMin, yearMax)
}

});