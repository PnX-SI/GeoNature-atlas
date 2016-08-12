var map = generateMap()


// affichage des mailles
$(function(){
displayMailleLayerFicheEspece(observationsMaille, taxonYearMin, $YEARMAX);
// pointer on first and last obs
$('.pointer').css('cursor', 'pointer');
//display nb observations
$("#nbObs").html("Nombre d'observation(s): "+ observationsPoint.length);


});

// Legende

htmlLegend = "<i style='border: solid 2px blue;'> &nbsp; &nbsp; &nbsp;</i> Limite du "+ configuration.STRUCTURE;
generateLegende(htmlLegend);


 // Slider event
mySlider.on("change",function(){
      years = mySlider.getValue();
      yearMin = years[0];
      yearMax = years[1];
      map.removeLayer(currentLayer);
      displayMailleLayerFicheEspece(observationsMaille, yearMin, yearMax)


    nbObs=0;
    myGeoJson.features.forEach(function(l){
      nbObs += l.properties.nb_observations
    })

    $("#nbObs").html("Nombre d'observation(s): "+ nbObs);

   });


// Stat - map interaction
$('#firstObs').click(function(){
  var firstObsLayer;
  var year = new Date('2400-01-01');


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
})

$('#lastObs').click(function(){
  var firstObsLayer;
  var year = new Date('1800-01-01');


      var layer = (currentLayer._layers);
      for (var key in layer) {
        layer[key].feature.properties.tabDateobs.forEach(function(thisYear){
          if (thisYear >= year){
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
})

