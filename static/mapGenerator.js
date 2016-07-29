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




// Popup Point
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
function displayMailleLayer(observationsMaille, yearMin, yearMax){
  myGeojson = generateGeojsonMaille(observationsMaille, yearMin, yearMax)
  currentLayer = L.geoJson(myGeojson, {
      onEachFeature : onEachFeatureMaille,
      style: styleMaille,
  });
  currentLayer.addTo(map);

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


// GeoJson Point
function generateGeojsonPoint(observationsPoint, yearMin, yearMax){
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

// Display marker Layer (cluster on not)
var clusterLayer;
function displayMarkerLayer(observationsPoint, yearMin, yearMax){
  myGeojson = generateGeojsonPoint(observationsPoint, yearMin, yearMax)
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





// Geojson last observations: 


// add all observations markers whith popup

function onEachFeatureHome(feature, layer){
    popupContent = "<b>Espèce: </b>"+ feature.properties.taxon_name+
                "</br><b>Date: </b>"+ feature.properties.dateobs+"</br><b>Altitude: </b>"+ feature.properties.altitude_retenue;

     // verifie si le champs effectif est rempli
      if(feature.properties.effectif_total){
        layer.bindPopup(popupContent+"</br><b>Effectif: </b>"+ feature.properties.effectif_total);
      }
      layer.bindPopup(popupContent + "</br> <a href=espece/"+feature.properties.cd_ref+"> Fiche espèce </a>")
      
}

var myGeoJson;
function generateGeojsonPoint(observationsPoint){
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
function displayMarkerLayer(observationsPoint){
  myGeojson = generateGeojsonPoint(observationsPoint)
  currentLayer = L.geoJson(myGeojson, {
          onEachFeature : onEachFeatureHome,
          pointToLayer: function (feature, latlng) {
                           return L.circleMarker(latlng);
                           }
  });
    currentLayer.addTo(map);
  }






// slider

if (configuration.MAP_ESPECE == true){
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
}

