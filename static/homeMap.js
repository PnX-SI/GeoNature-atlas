var map = generateMap();





// Markers display on window ready

$(function(){
  // display markers 
  displayMarkerLayer(observations);

// zoom on observation on list-click - also open the popup
$('.singleTaxon').click(function(){
  var cd_ref = $(this).attr('cdref');
  var p = (currentLayer._layers);
  var selectLayer;
  for (var key in p) {
    if (p[key].feature.properties.cd_ref == cd_ref){
      selectLayer = p[key];
    }
}
selectLayer.openPopup();
    map.setView(selectLayer._latlng, 13);
})

 // zoom on the popup on observation click
  currentLayer.on('click', function(e){
    map.setView(e.latlng, 13);
});
});

