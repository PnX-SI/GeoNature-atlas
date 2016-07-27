$('.tabEspece').click(function(){
	var cd_ref = ($(this).find("td[hidden='true']").html());
	focusMarkerLayer(cd_ref);

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