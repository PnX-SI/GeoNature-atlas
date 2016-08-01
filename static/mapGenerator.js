function generateMap() {


    //map initialization
firstMapTile = L.tileLayer(FIRST_MAP.url, {attribution : FIRST_MAP.attribution} );

baseMap = {};
baseMap[FIRST_MAP.tileName]=firstMapTile;

  ADDITIONAL_MAP.forEach(function(map){
     tempName = map.tileName;
    baseMap[tempName]  = L.tileLayer(map.url, {attribution: map.attribution})
  });



      var map = L.map('map',{
        crs: L.CRS.EPSG3857,
        center: latLong, 
        geosearch: true,
        zoom: setZoom,
        layers : [firstMapTile],
        fullscreenControl: true,
        });


    myStyle = {
    	fill: false
    }

    L.control.layers(baseMap).addTo(map);

     // add the limit of the territory
     $(document).ready(function()
          {
              $.getJSON(url_limit_territory, function(json) {
                  L.geoJson(json, {
                  	style: myStyle
                  }).addTo(map);
              });
          });

     if (configuration.FICHE_ESPECE == true  && configuration.AFFICHAGE_MAILLE ){

        var legend = L.control({position: 'bottomright'});

        legend.onAdd = function (map) {

            var div = L.DomUtil.create('div', 'info legend'),
                grades = [0, 1, 2, 5, 10, 20, 50, 100],
                labels = ["<strong> Nombre <br> d'observations </strong> <br>"];

            // loop through our density intervals and generate a label with a colored square for each interval
            for (var i = 0; i < grades.length; i++) {
                labels.push(
                    '<i style="background:' + getColor(grades[i] + 1) + '"></i> ' +
                    grades[i] + (grades[i + 1] ? '&ndash;' + grades[i + 1] + '<br>' : '+'));
            }
            div.innerHTML = labels.join('<br>');

            return div;
        };

    legend.addTo(map);
   }


    return map
}



//****** Fonction fiche espècce ***********


// Popup Point
function onEachFeaturePoint(feature, layer){
    popupContent = "<b>Date: </b>"+ feature.properties.dateobs+"</br><b>Altitude: </b>"+ feature.properties.altitude_retenue+
                "</br><b>Observateurs: </b>"+ feature.properties.observateurs;

     // verifie si le champs effectif est rempli
      if(feature.properties.effectif_total != undefined){
        layer.bindPopup(popupContent+"</br><b>Effectif: </b>"+ feature.properties.effectif_total);
      }else{
        layer.bindPopup(popupContent)
      }
}

// popup Maille
function onEachFeatureMaille(feature, layer){
    popupContent = "<b>Nombre d'observation(s): </b>"+ feature.properties.nb_observations+"</br> <b> Dernière observation: </b>"+ feature.properties.last_observation+ " " ;
    layer.bindPopup(popupContent)
}


// Style maille
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
        opacity: 0,
       // dashArray: '3',
        fillOpacity: 0.8
    };
}




// Geojson Maille
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


// Display Maille layer
var currentLayer;
var myGeojson;
function displayMailleLayerFicheEspece(observationsMaille, yearMin, yearMax){
  myGeojson = generateGeojsonMaille(observationsMaille, yearMin, yearMax)
  currentLayer = L.geoJson(myGeojson, {
      onEachFeature : onEachFeatureMaille,
      style: styleMaille,
  });
  currentLayer.addTo(map);

}


// GeoJson Point
function generateGeojsonPointFicheEspece(observationsPoint, yearMin, yearMax){
   var myGeoJson = {'type': 'FeatureCollection','features' : []}

      observationsPoint.forEach(function(obs){
          if(obs.year >= yearMin && obs.year <= yearMax ) {
              geometry = obs.geojson_point;
              properties = {'id_synthese' : obs.id_synthese,
                            'cd_ref': obs.cd_ref,
                            'dateobs': obs.dateobs,
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

// Display marker Layer (cluster or not)
var clusterLayer;
function displayMarkerLayerFicheEspece(observationsPoint, yearMin, yearMax){

  myGeojson = generateGeojsonPointFicheEspece(observationsPoint, yearMin, yearMax)
  currentLayer = L.geoJson(myGeojson, {
          onEachFeature : onEachFeaturePoint,
          pointToLayer: function (feature, latlng) {
                           return L.circleMarker(latlng);
                           }
  });
  if (myGeojson.features.length > configuration.LIMIT_CLUSTER_POINT) {
      newLayer = currentLayer;
      currentLayer = L.markerClusterGroup();
      currentLayer.addLayer(newLayer);
      map.addLayer(currentLayer)
  } else {
    currentLayer.addTo(map);
  }
}


// Display slider

if (configuration.FICHE_ESPECE == true){
  var mySlider = new Slider('#slider', {
    value: [taxonYearMin, $YEARMAX],
    min : taxonYearMin,
    max : $YEARMAX,
    step: $STEP,
  });

  $("#yearMax").html("&nbsp;&nbsp;"+ $YEARMAX);
  $("#yearMin").html(taxonYearMin + "&nbsp;&nbsp;");
}




// ***************Fonction lastObservations: mapHome et mapCommune*****************


  /* *** Point ****/

function onEachFeaturePointLastObs(feature, layer){
    popupContent = "<b>Espèce: </b>"+ feature.properties.taxon_name+
                "</br><b>Date: </b>"+ feature.properties.dateobs+"</br><b>Altitude: </b>"+ feature.properties.altitude_retenue;

     // verifie si le champs effectif est rempli
      if(feature.properties.effectif_total){
        layer.bindPopup(popupContent+"</br><b>Effectif: </b>"+ feature.properties.effectif_total);
      }
      layer.bindPopup(popupContent + "</br> <a href=../espece/"+feature.properties.cd_ref+"> Fiche espèce </a>")
      
}



var myGeoJson;
function generateGeojsonPointLastObs(observationsPoint){
    myGeoJson = {'type': 'FeatureCollection','features' : []}

      observationsPoint.forEach(function(obs){
              geometry = obs.geojson_point;
              properties = {'id_synthese' : obs.id_synthese,
                             'taxon_name' : obs.taxon,
                            'cd_ref': obs.cd_ref,
                            'dateobs': obs.dateobs,
                            'altitude_retenue' : obs.altitude_retenue,
                            'effectif_total' : obs.effectif_total,
                            }
              myGeoJson.features.push({
                'type' : 'Feature',
                'properties' : properties,
                'geometry' : geometry   
              })
      });
  return myGeoJson
}

var currentLayer;
function displayMarkerLayerPointLastObs(observationsPoint){
  myGeojson = generateGeojsonPointLastObs(observationsPoint)
  currentLayer = L.geoJson(myGeojson, {
          onEachFeature : onEachFeaturePointLastObs,
          pointToLayer: function (feature, latlng) {
                           return L.circleMarker(latlng);
                           }
  });
    currentLayer.addTo(map);
  }

//  ** MAILLE ***

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

function onEachFeatureMailleLastObs(feature, layer){
    popupContent = "<b>Espèces observées dans la maille: </b> <ul> "+printEspece(feature.properties.list_taxon) + "</ul>";

        layer.bindPopup(popupContent)
      }

function styleMailleLastObs(){
    return {
        opacity: 1,
        weight: 2,
        color: 'red',
        fillOpacity: 0
    }
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

function displayMailleLayerLastObs(observations){

      observations.sort(compare);
      var geojsonMaille = generateGeoJsonMailleLastObs(observations);
      currentLayer = L.geoJson(geojsonMaille,{onEachFeature: onEachFeatureMailleLastObs, style:styleMailleLastObs });
      currentLayer.addTo(map);

    }



