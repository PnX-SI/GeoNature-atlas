function generateMap() {

// load tiles
var osmTile = L.tileLayer(osmUrl, {attribution: osmAttribution}),
  ignTile = L.tileLayer(ignUrl, {attribution: ignAttribution}),
  orthoTile = L.tileLayer(orthoIGN, {attribution: ignAttribution});


//map initialization


  var map = L.map('map',{
    crs: L.CRS.EPSG3857,
    center: latLong,
    zoom: setZoom,
    layers: [osmTile, ignTile],
    fullscreenControl: true,

    });

// add a tile selector
var baseMap = {
"OSM": osmTile,
"IGN": ignTile,
"Satellite": orthoTile
}

myStyle = {
	fill: false
}

L.control.layers(baseMap).addTo(map);

 $(document).ready(function()
      {
          $.getJSON('../static/territoire.json', function(json) {
              L.geoJson(json, {
              	style: myStyle
              }).addTo(map);
          });
      });


return map

}



function onEachFeaturePoint(feature, layer){
    popupContent = "<b>Date: </b>"+ feature.properties.dateobs+"</br><b>Altitude: </b>"+ feature.properties.altitude_retenue+
                "</br><b>Observateurs: </b>"+ feature.properties.observateurs;

     // verifie si le champs effectif est rempli
      if(feature.properties.effectif_total){
        layer.bindPopup(popupContent+"</br><b>Effectif: </b>"+ feature.properties.effectif_total);
      }else{
        layer.bindPopup(popupContent)
      }
}


function getColor(d) {
    return d > 100 ? '#800026' :
           d > 50  ? '#BD0026' :
           d > 20  ? '#E31A1C' :
           d > 10  ? '#FC4E2A' :
           d > 5   ? '#FD8D3C' :
           d > 2   ? '#FEB24C' :
           d > 1   ? '#FED976' :
                      '#FFEDA0';
}

function styleMaille(feature) {
    return {
        fillColor: getColor(feature.properties.nb_observations),
        weight: 2,
        opacity: 1,
        color: 'white',
        dashArray: '3',
        fillOpacity: 0.7
    };
}


function onEachFeatureMaille(feature, layer){
    popupContent = "<b>Nombre d'observation(s): </b>"+ feature.properties.nb_observations+"</br> <b> Dernière observation: </b>"+ feature.properties.last_observation+ " " ;
    layer.bindPopup(popupContent)
      }




function generateGeojsonMaille(observations, yearMin, yearMax) {

  var i=0;
  var myGeoJson = {'type': 'FeatureCollection',
             'features' : []
          }
  tabProperties =[]
  while (i<observations.length){
    if(observations[i].annee >= yearMin && observations[i].annee <= yearMax ) {
      geometry = observations[i].geojson_maille;
      idMaille = observations[i].id_maille;
      properties = {id_maille : idMaille, nb_observations : observations[i].nb_observations, last_observation: observations[i].annee};
      var j = i+1;
      while (j<observations.length && observations[j].id_maille <= idMaille){
        if(observations[j].annee >= yearMin && observations[j].annee <= yearMax ){
          properties.nb_observations +=  observations[j].nb_observations;
        }
        if (observations[j].annee >=  observations[j-1].annee){
          properties.last_observation = observations[j].annee
        }
        j = j+1
      }
      myGeoJson.features.push({
          'type' : 'Feature',
          'properties' : properties,
          'geometry' : geometry   
      })
      // on avance jusqu' à j 
      i = j  ;
    }
    else {
      i = i+1;
    }
  }
  return myGeoJson
}



function generateGeojsonPoint(observationsPoint, yearMin, yearMax){
   var myGeoJson = {'type': 'FeatureCollection','features' : []}

      observationsPoint.forEach(function(obs){
          if(obs.year >= yearMin && obs.year <= yearMax ) {
            
              geometry = obs.geojson_point;
              properties = {'id_synthese' : obs.id_synthese,
                            'cd_ref': obs.cd_ref,
                            'dateobs': toString(obs.dateobs),
                            'observateurs' : obs.observateurs,
                            'altitude_retenue' : obs.altitude_retenue,
                            'effectif_total' : obs.effectif_total,
                            'year': obs.dateobs.year
                            }
              myGeoJson.features.push({
                'type' : 'Feature',
                'properties' : properties,
                'geometry' : geometry   
              })
         } 
      });
  return myGeoJson
}


// slider
var mySlider = new Slider('#slider', {
  value: [taxonYearMin, $YEARMAX],
  min : taxonYearMin,
  max : $YEARMAX,
  step: $STEP,
/*  ticks: getLegend(taxonYearMin, $YEARMAX),
  ticks_labels: getStringLegend(getLegend(taxonYearMin, $YEARMAX)),*/
});

$("#yearMax").html("&nbsp;&nbsp;"+ $YEARMAX);
$("#yearMin").html(taxonYearMin + "&nbsp;&nbsp;");
