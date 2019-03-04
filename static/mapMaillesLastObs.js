var map = generateMap();
generateSliderOnMap();
var legend = L.control({position: 'bottomright'});

// Legende

htmlLegend = "<i style='border: solid "+configuration.MAP.BORDERS_WEIGHT+"px "+configuration.MAP.BORDERS_COLOR+";'> &nbsp; &nbsp; &nbsp;</i> Limite du "+ configuration.STRUCTURE;
generateLegende(htmlLegend);


// Current observation Layer: leaflet layer type
var currentLayer; 

// Current observation geoJson:  type object
var myGeoJson;

var compteurLegend = 0; // compteur pour ne pas rajouter la légende à chaque fois

function styleMailleAtlas(feature) {
    var fillColor ;
    var currentYear = new Date().getFullYear() ;
    var obsyear = feature.properties.lastyear ;
    if(feature.properties.lastyear <= currentYear - 10){
        fillColor='red' ;
    }else if(feature.properties.lastyear <= currentYear - 5) {
        fillColor='yellow';
    }else{
        fillColor='green';
    }

    return {
        fillColor: fillColor,
        weight: 0.5,
        color: 'white',
        fillOpacity: 0.8
    };
}

L.DomUtil.remove(sliderContainer); //Remove slider created in mapGenerator.js

$.ajax({
  url: configuration.URL_APPLICATION+'/api/observationsMailleLastObs/'+cd_ref, 
  dataType: "json",
  beforeSend: function(){
    $('#loadingGif').attr('src', configuration.URL_APPLICATION+'/static/images/loading.svg')
  }
  }).done(function(observations) {
    $('#loadingGif').hide();

  currentLayer = L.geoJson(observations, {
      //onEachFeature : onEachFeatureMaille,
      style: styleMailleAtlas,
  }).addTo(map);
  currentLayer.bringToFront();
    /*    
    // affichage des mailles
    displayMailleLayerFicheEspece(observations, taxonYearMin, YEARMAX);

      //display nb observations
  $("#nbObsLateral").html("<b>"+observations.length+" </b> </br> Observations" );



    // pointer on first and last obs
    $('.pointer').css('cursor', 'pointer');
    //display nb observations
        nbObs=0;
        myGeoJson.features.forEach(function(l){
          nbObs += l.properties.nb_observations
          })
        $("#nbObs").html("Nombre d'observation(s): "+ nbObs);
   


     // Slider event
    mySlider.on("change",function(){
          years = mySlider.getValue();
          yearMin = years[0];
          yearMax = years[1];
          map.removeLayer(currentLayer);
          displayMailleLayerFicheEspece(observations, yearMin, yearMax)


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
    })*/
});

