
var map = generateMap();
generateSliderOnMap();

// Layer display on window ready

/*GLOBAL VARIABLE*/

    // Current observation Layer: leaflet layer type
var currentLayer; 

// Current observation geoJson:  type object
var myGeoJson;

var compteurLegend = 0; // counter to not put the legend each time


$.ajax({
  url: configuration.URL_APPLICATION+'/api/observationsMailleAndPoint/'+cd_ref, 
  dataType: "json",
  beforeSend: function(){
    $('#loadingGif').attr("src", configuration.URL_APPLICATION+'/static/images/loading.svg')
  }

  }).done(function(observations) {
    $('#loadingGif').hide();

      //display nb observations

    var mailleBoolean = false;
    if (observations.maille.length > 500) {
       displayMailleLayerFicheEspece(observations.maille, taxonYearMin, YEARMAX);
       mailleBoolean = true;
    }
    else {
      displayMarkerLayerFicheEspece(observations.point, taxonYearMin, YEARMAX);
    }
    
    if (mailleBoolean){
      // Slider event
          mySlider.on("change",function(){
              years = mySlider.getValue();
              yearMin = years[0];
              yearMax = years[1];


              map.removeLayer(currentLayer);
              if(map.getZoom() >= configuration.ZOOM_LEVEL_POINT){
                displayMarkerLayerFicheEspece(observations.point, yearMin, yearMax);
              }else{
                displayMailleLayerFicheEspece(observations.maille, yearMin, yearMax)
              }

              nbObs=0;
              myGeoJson.features.forEach(function(l){
                nbObs += l.properties.nb_observations
              })

              $("#nbObs").html("Nombre d'observation(s): "+ nbObs);

             });


            // ZoomEvent: change maille to point
            var legendblock = $("div.info");
            var activeMode = "Maille";
            map.on("zoomend", function(){
            if (activeMode != "Point" && map.getZoom() >= configuration.ZOOM_LEVEL_POINT ){
              map.removeLayer(currentLayer);
              legendblock.attr("hidden", "true");


                years = mySlider.getValue();
                yearMin = years[0];
                yearMax = years[1];

              displayMarkerLayerFicheEspece(observations.point, yearMin, yearMax);
              activeMode = "Point";
            }
            if (activeMode != "Maille" && map.getZoom() <= configuration.ZOOM_LEVEL_POINT -1 ){
              // display legend
              map.removeLayer(currentLayer);

              legendblock.removeAttr( "hidden" );

                years = mySlider.getValue();
                yearMin = years[0];
                yearMax = years[1];
              displayMailleLayerFicheEspece(observations.maille, yearMin, yearMax);
              activeMode = "Maille"
            }

            });

    // if not display Maille
    }else {
            // Slider event
            mySlider.on("change",function(){
                years = mySlider.getValue();
                yearMin = years[0];
                yearMax = years[1];


                map.removeLayer(currentLayer);
                displayMarkerLayerFicheEspece(observations.point, yearMin, yearMax);
                nbObs=0;
                myGeoJson.features.forEach(function(l){
                  nbObs += l.properties.nb_observations
                })

                $("#nbObs").html("Nombre d'observation(s): "+ nbObs);
               });

    }

})


// Legende

htmlLegend = "<i style='border: solid 1px blue;'> &nbsp; &nbsp; &nbsp;</i> Limite du "+ configuration.STRUCTURE;

generateLegende(htmlLegend);

