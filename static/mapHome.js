var map = generateMap();



// Markers display on window ready

$(function(){

  if (configuration.AFFICHAGE_MAILLE){
    // display maille layer
      observations.sort(compare);
      var geojsonMaille = generateGeoJsonMailleLastObs(observations);
      currentLayer = L.geoJson(geojsonMaille,{onEachFeature: onEachFeatureMailleLastObs});
      currentLayer.addTo(map);

    // interaction list - map 
      $('.singleTaxon').click(function(){
        var id_synthese = $(this).attr('idSynthese');

        p = (currentLayer._layers);
        var selectLayer;
        for (var key in p) {
          if (find_id_synthese_in_array(p[key].feature.properties.list_id_synthese, id_synthese) ){
              selectLayer = p[key];
          }
        }

        selectLayer.openPopup();
        var bounds = L.latLngBounds([]);
        var layerBounds = selectLayer.getBounds();
        bounds.extend(layerBounds);
        map.fitBounds(bounds, {
          maxZoom : 12
        });
      }); 
  }

  // Display point layer
  else{
    displayMarkerLayerPointLastObs(observations);

      // interaction list - map 
      $('.singleTaxon').click(function(){
        var id_synthese = $(this).attr('idSynthese');
        var p = (currentLayer._layers);
        var selectLayer;
        for (var key in p) {
          if (p[key].feature.properties.id_synthese == id_synthese){
            selectLayer = p[key];
          }
      }
      selectLayer.openPopup();
          map.setView(selectLayer._latlng, 12);
      })
  }



  // zoom on the popup on observation click

  currentLayer.on('click', function(e){
      map.setView(e.latlng, 12);
  });

});




