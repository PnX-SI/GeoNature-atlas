var map = generateMap();
if (configuration.ENABLE_SLIDER) {
  generateSliderOnMap();
}
var legend = L.control({ position: "bottomright" });

// Layer display on window ready

/*GLOBAL VARIABLE*/

// Current observation Layer: leaflet layer type
var currentLayer;

// Current observation geoJson:  type object
var myGeoJson;

var compteurLegend = 0; // counter to not put the legend each time

// variable globale: observations récupérer en AJAX
var observationsMaille;
var observationsPoint;
$.ajax({
  url:
    configuration.URL_APPLICATION + "/api/observationsMailleAndPoint/" + cd_ref,
  dataType: "json",
  beforeSend: function() {
    $("#loadingGif").attr(
      "src",
      configuration.URL_APPLICATION + "/static/images/loading.svg"
    );
  }
}).done(function(observations) {
  $("#loadingGif").hide();

  if (mailleBoolean) {
    // zoom event
    eventOnZoom(observationsMaille, observationsPoint);

    if (configuration.ENABLE_SLIDER) {
      // Slider event
      mySlider.on("slideStop", function() {
        years = mySlider.getValue();
        yearMin = years[0];
        yearMax = years[1];

        map.removeLayer(currentLayer);
        if (map.getZoom() >= configuration.ZOOM_LEVEL_POINT) {
          // on filtre en local
          displayMarkerLayerFicheEspece(observations.point, yearMin, yearMax);
        } else {
          // on recharge que les mailles en AJAX - filtrée par années
          $.ajax({
            url:
              configuration.URL_APPLICATION +
              "/api/observationsMaille/" +
              cd_ref,
            dataType: "json",
            type: "get",
            data: {
              year_min: yearMin,
              year_max: yearMax
            },
            beforeSend: function() {
              $("#loadingGif").show();
            }
          }).done(function(observations) {
            $("#loadingGif").hide();
            observationsMaille = observations;

            // desactivation de l'event precedent
            map.off("zoomend", function() {});
            // reactivation de l'event du zoom avec les nouvelle valeurs
            eventOnZoom(observationsMaille, observationsPoint);

            displayMailleLayerFicheEspece(observationsMaille);
            nbObs = 0;
            observationsMaille.features.forEach(function(l) {
              nbObs += l.properties.nb_observations;
            });

            $("#nbObs").html("Nombre d'observation(s): " + nbObs);
          });
        }
      });
    }

    // if not display Maille
  } else {
    if (configuration.ENABLE_SLIDER) {
      // Slider event
      mySlider.on("change", function() {
        years = mySlider.getValue();
        yearMin = years[0];
        yearMax = years[1];

        map.removeLayer(currentLayer);
        displayMarkerLayerFicheEspece(observations.point, yearMin, yearMax);
        nbObs = 0;
        myGeoJson.features.forEach(function(l) {
          nbObs += l.properties.nb_observations;
        });

        $("#nbObs").html("Nombre d'observation(s): " + nbObs);
      });
    }
  }
});

function eventOnZoom(observationsMaille, observationsPoint) {
  // ZoomEvent: change maille to point
  var legendblock = $("div.info");
  var activeMode = "Maille";
  map.on("zoomend", function() {
    if (
      activeMode != "Point" &&
      map.getZoom() >= configuration.ZOOM_LEVEL_POINT
    ) {
      map.removeLayer(currentLayer);
      legendblock.attr("hidden", "true");

      years = mySlider.getValue();
      yearMin = years[0];
      yearMax = years[1];

      displayMarkerLayerFicheEspece(observationsPoint, yearMin, yearMax);
      activeMode = "Point";
    }
    if (
      activeMode != "Maille" &&
      map.getZoom() <= configuration.ZOOM_LEVEL_POINT - 1
    ) {
      // display legend
      map.removeLayer(currentLayer);

      legendblock.removeAttr("hidden");

      years = mySlider.getValue();
      yearMin = years[0];
      yearMax = years[1];
      displayMailleLayerFicheEspece(observationsMaille);
      activeMode = "Maille";
    }
  });
}

// Legende

htmlLegend =
  "<i style='border: solid " +
  configuration.MAP.BORDERS_WEIGHT +
  "px " +
  configuration.MAP.BORDERS_COLOR +
  ";'> &nbsp; &nbsp; &nbsp;</i> Limite du " +
  configuration.STRUCTURE;

generateLegende(htmlLegend);
