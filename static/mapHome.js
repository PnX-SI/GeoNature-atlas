var map = generateMap();

map.scrollWheelZoom.disable();
$('#map').click(function(){
  map.scrollWheelZoom.enable();
})



// Markers display on window ready

$(function(){

  if (configuration.AFFICHAGE_MAILLE){
    // display maille layer
    displayMailleLayerLastObs(observations)

    // interaction list - map 
      $('.tabEspece').click(function(){
         $(this).siblings().removeClass('current');
         $(this).addClass('current');
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
      $('.tabEspece').click(function(){
         $(this).siblings().removeClass('current');
         $(this).addClass('current');
        var id_synthese = $(this).attr('idSynthese');

        var p = (currentLayer._layers);
        var selectLayer;
        for (var key in p) {
          if (p[key].feature.properties.id_synthese == id_synthese){
            selectLayer = p[key];
          }
      }
      selectLayer.openPopup();
          map.setView(selectLayer._latlng, 14);
      })
  }



  // zoom on the popup on observation click

  currentLayer.on('click', function(e){
    console.log(map.getZoom());
    if (map.getZoom()<14) {
      map.setView(e.latlng, 14);
    }
  });


});




htmlLegend = "<i style='border: solid 1px red;'> &nbsp; &nbsp; &nbsp;</i> <span> Maille comportant au moins une observation </span> "
              + "<br> <br> <i style='border: solid 2px blue;'> &nbsp; &nbsp; &nbsp;</i> Limite du "+ configuration.STRUCTURE;



generateLegende(htmlLegend);