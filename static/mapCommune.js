var map = generateMap();

var legend = L.control({ position: "bottomright" });
// Current observation Layer: leaflet layer type
var currentLayer;

// Current observation geoJson:  type object
var myGeoJson;

// Diplay limit of the territory
var communeLayer = L.geoJson(communeGeoJson, {
  style: function() {
    return {
      fillColor: "blue",
      opacity: 1,
      weight: 2,
      color: "black",
      dashArray: "3",
      fillOpacity: 0
    };
  }
}).addTo(map);

var bounds = L.latLngBounds([]);
var layerBounds = communeLayer.getBounds();
bounds.extend(layerBounds);
map.fitBounds(bounds);

// Display the 'x' last observations
// MAILLE
if (configuration.AFFICHAGE_MAILLE) {
  displayMailleLayerLastObs(observations);
}
// POINT
else {
  displayMarkerLayerPointLastObs(observations);
}

// Generate legends and check configuration to choose which to display (Maille ou Point)

htmlLegendMaille =
  "<i style='border: solid 1px red;'> &nbsp; &nbsp; &nbsp;</i> Maille comportant au moins une observation <br> <br>" +
  "<i style='border-style: dotted;'> &nbsp; &nbsp; &nbsp;</i> Limite de la commune <br> <br>" +
  "<i style='border: solid " +
  configuration.MAP.BORDERS_WEIGHT +
  "px " +
  configuration.MAP.BORDERS_COLOR +
  ";'> &nbsp; &nbsp; &nbsp;</i> Limite du " +
  configuration.STRUCTURE;

htmlLegendPoint =
  "<i style='border-style: dotted;'> &nbsp; &nbsp; &nbsp;</i> Limite de la commune <br> <br>" +
  "<i style='border: solid " +
  configuration.MAP.BORDERS_WEIGHT +
  "px " +
  configuration.MAP.BORDERS_COLOR +
  ";'> &nbsp; &nbsp; &nbsp;</i> Limite du " +
  configuration.STRUCTURE;

htmlLegend = configuration.AFFICHAGE_MAILLE
  ? htmlLegendMaille
  : htmlLegendPoint;

// General Legend

generateLegende(htmlLegend);

// display observation on click
function displayObsTaxon(insee, cd_ref) {
  $.ajax({
    url:
      configuration.URL_APPLICATION +
      "/api/observations/" +
      insee +
      "/" +
      cd_ref,
    dataType: "json",
    beforeSend: function() {
      $("#loadingGif").show();
      $("#loadingGif").attr(
        "src",
        configuration.URL_APPLICATION + "/static/images/loading.svg"
      );
    }
  }).done(function(observations) {
    $("#loadingGif").hide();
    map.removeLayer(currentLayer);
    if (configuration.AFFICHAGE_MAILLE) {
    } else {
      displayMarkerLayerPointCommune(observations);
    }
  });
}

function displayObsTaxonMaille(insee, cd_ref) {
  $.ajax({
    url:
      configuration.URL_APPLICATION +
      "/api/observationsMaille/" +
      insee +
      "/" +
      cd_ref,
    dataType: "json",
    beforeSend: function() {
      $("#loadingGif").show();
      $("#loadingGif").attr(
        "src",
        configuration.URL_APPLICATION + "/static/images/loading.svg"
      );
    }
  }).done(function(observations) {
    $("#loadingGif").hide();
    map.removeLayer(currentLayer);
    displayMailleLayerCommune(observations);
  });
}

function refreshObsCommune() {
  $("#myTable tbody").on("click", ".taxonRow", function() {
    $(this)
      .siblings()
      .removeClass("current");
    $(this).addClass("current");

    if (configuration.AFFICHAGE_MAILLE) {
      displayObsTaxonMaille($(this).attr("insee"), $(this).attr("cdRef"));
    } else {
      displayObsTaxon($(this).attr("insee"), $(this).attr("cdRef"));
    }
    var name = $(this)
      .find(".name")
      .html();
    $("#titleMap").fadeOut(500, function() {
      $(this)
        .html("Observations du taxon:" + name)
        .fadeIn(500);
    });
  });
}

$("#myTable").on("page.dt", function() {
  refreshObsCommune();
});
$(document).ready(function() {
  $("#loadingGif").hide();
  refreshObsCommune();
});
