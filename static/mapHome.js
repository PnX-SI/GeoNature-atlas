var map = generateMap();



// Markers display on window ready

$(function(){

  if (configuration.AFFICHAGE_MAILLE){
    // display maille layer
    displayMailleLayerLastObs(observations)

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


    var legend = L.control({position: 'bottomleft'});

        legend.onAdd = function (map) {

            var div = L.DomUtil.create('div', 'info legend'),
                  labels = "<i style='border: solid 1px red;'> &nbsp; &nbsp; &nbsp;</i> Maille comportant au moin une observation &nbsp;&nbsp;&nbsp " 

            div.innerHTML = labels;

            return div;
        };
    legend.addTo(map);


});




