var map = generateMap();



function compare(a,b) {
  if (a.id_maille < b.id_maille)
    return -1;
  if (a.id_maille > b.id_maille)
    return 1;
  return 0;
}

function printEspece(tabEspece){
  stringEspece = "";
  tabEspece.forEach(function(espece){
      stringEspece += "<li> "+espece+"</li>"
  })
  return stringEspece;
}

function onEachFeature(feature, layer){
    popupContent = "<b>Espèces observées dans la maille: </b> <ul> "+printEspece(feature.properties.list_taxon) + "</ul>" + "</br> id: " +feature.properties.list_id_synthese
    + "idmaille: "+ feature.properties.id_maille + "nb id_synthese: " +feature.properties.list_id_synthese.length;

        layer.bindPopup(popupContent)
      }


function generateGeoJsonMailleLastObs(observations) {

  var i=0;
  var myGeoJson = {'type': 'FeatureCollection',
             'features' : []
          }
  while (i<observations.length){
      geometry = observations[i].geojson_maille;
      idMaille = observations[i].id_maille;
      properties = {id_maille : idMaille, list_taxon : [observations[i].taxon], list_cdref:[observations[i].cd_ref], list_id_synthese: [observations[i].id_synthese] };
      var j = i+1;
      while (j<observations.length && observations[j].id_maille == idMaille){
           properties.list_taxon.push(observations[j].taxon);
           properties.list_cdref.push(observations[j].cd_ref);
           properties.list_id_synthese.push(observations[j].id_synthese);
        j = j+1
      }
      myGeoJson.features.push({
          'type' : 'Feature',
          'properties' : properties,
          'geometry' : geometry
      })
      // on avance jusqu' à j 
      i = j ;
  }

  return myGeoJson
}


function find_id_synthese_in_array(tab_id, id_synthese){
  i = 0 ;
  while (i < tab_id.length && tab_id[i] != id_synthese){
    i = i+1
  }
  return i != tab_id.length
}

// Markers display on window ready

$(function(){
    // display markers 
    // displayMarkerLayer(observations);


 observations.sort(compare);


var geojsonMaille = generateGeoJsonMailleLastObs(observations);


  var currentLayer = L.geoJson(geojsonMaille,{onEachFeature: onEachFeature});
  currentLayer.addTo(map);



  // zoom on observation on list-click - also open the popup
  // $('.singleTaxon').click(function(){
  //   var cd_ref = $(this).attr('cdref');
  //   var p = (currentLayer._layers);
  //   var selectLayer;
  //   for (var key in p) {
  //     if (p[key].feature.properties.cd_ref == cd_ref){
  //       selectLayer = p[key];
  //     }
  // }
  // selectLayer.openPopup();
  //     map.setView(selectLayer._latlng, 13);
  // })

  //  // zoom on the popup on observation click
  //   currentLayer.on('click', function(e){
  //     map.setView(e.latlng, 13);
  // });



 p = (currentLayer._layers);
    var selectLayer;
    for (var key in p) {
      var myP;
     var inter = p[key].feature.properties.list_id_synthese;
     console.log(find_id_synthese_in_array(inter, 10051094));

  }


 var list_id_layer = [];

  $('.singleTaxon').click(function(){
    var id_synthese = $(this).attr('idSynthese');
    console.log("id id_synthese de la liste"+ id_synthese);
     p = (currentLayer._layers);
    var selectLayer;
    for (var key in p) {
      if (find_id_synthese_in_array(p[key].feature.properties.list_id_synthese, id_synthese) ){
        selectLayer = p[key];
        }

  }

  selectLayer.openPopup();
      // map.setView(selectLayer._latlng, 13); fonctionne pas avec des polygone: faire un feetbounds pour zoomer dessus
  })

   // zoom on the popup on observation click
    currentLayer.on('click', function(e){
      map.setView(e.latlng, 13);
  });

});



