var zoomHomeButton = false;

var map = generateMap(zoomHomeButton);

var legend = L.control({position: "bottomright"});
// Current observation Layer: leaflet layer type
var currentLayer;

// Current observation geoJson:  type object
var myGeoJson;

const id_area = document.location.pathname.split("/")[2]
displayObs(id_area)


// Display limit of the territory
var areaLayer = L.geoJson(areaInfos.areaGeoJson, {
    style: function () {
        return {
            opacity: 1,
            weight: 2,
            color: areaBorderColor,
            // dashArray: "3",
            fillOpacity: 0.3,
            invert: true
        };
    }
}).addTo(map);


var bounds = L.latLngBounds([]);
var layerBounds = areaLayer.getBounds();
bounds.extend(layerBounds);
map.fitBounds(bounds);
map.zoom = map.getZoom();

// Generate legends and check configuration to choose which to display (Maille ou Point)


htmlLegendMaille =
    "<i style='border: solid 1px var(--map-maille-lastobs-border-color);'> &nbsp; &nbsp; &nbsp;</i> Maille comportant au moins une observation <br> <br>" +
    "<i style='border: dashed 2px var(--map-area-border-color); background-color:var(--map-area-border-color); opacity:0.3'> &nbsp; &nbsp; &nbsp;</i> Limite de la zone <br> <br>" +
    "<i style='border: solid var(--map-area-border-width) var(--map-territory-border-color);'> &nbsp; &nbsp; &nbsp;</i> Limite du " +
    configuration.STRUCTURE;

htmlLegendPoint =
    "<i style='border-style: dotted;'> &nbsp; &nbsp; &nbsp;</i> Limite de la zone <br> <br>" +
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


var baseUrl =  configuration.URL_APPLICATION + "/api/observations/" + areaInfos.areaCode


function displayObsGridBaseUrl() {
    return configuration.URL_APPLICATION + "/api/observationsMaille/"
}

// display observation on click
function displayObsTaxon(id_area, cd_ref) {
  $.ajax({
    url:
      configuration.URL_APPLICATION +
      "/api/observations/" +
      id_area +
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
    if (currentLayer) {
      map.removeLayer(currentLayer);
    }
    if (configuration.AFFICHAGE_MAILLE) {
        displayMailleLayerLastObs(observations);
        clearOverlays()
    } else {
        displayMarkerLayerPointArea(observations);
    }
    })
}

function displayObs(id_area) {
    let url = `${configuration.URL_APPLICATION}/api/area/${id_area}`;
    // si on est en mode point on rajoute une limite au nombre d'obs
    // si on est en maille on renvoie toutes les données aggregées par maille
    if (!configuration.AFFICHAGE_MAILLE) {
        url +=`?limit=${configuration["NB_LAST_OBS"]}`
    }
    $("#loaderSpinner").show();
    fetch(url)
        .then(data => {
            return data.json()
        })
        .then(observations => {

            if (configuration.AFFICHAGE_MAILLE) {
            } else {
                displayMarkerLayerPointLastObs(observations)
            }
            $("#loaderSpinner").hide();
        })
        .catch(err => {
            console.error(err)
            $("#loaderSpinner").hide();
        })
}

function displayObsTaxonMaille(areaCode, cd_ref) {
    $.ajax({
        url:
            displayObsGridBaseUrl() +
            areaCode +
            "/" +
            cd_ref,
        dataType: "json",
        beforeSend: function () {
            $("#loaderSpinner").show();
        }
    }).done(function (observations) {
        $("#loaderSpinner").hide();
        if (currentLayer) {
            map.removeLayer(currentLayer);
        }
        clearOverlays();
        const geojsonMaille = generateGeoJsonMailleLastObs(observations);
        displayMailleLayerFicheEspece(geojsonMaille);
    });
}

function refreshObsArea(elem) {
        document.querySelector("#taxonList .current")?.classList.remove("current")
        elem.currentTarget.classList.add("current")
        if (configuration.AFFICHAGE_MAILLE) {
            displayObsTaxonMaille(elem.currentTarget.getAttribute("area-code"), elem.currentTarget.getAttribute("cdref"));
        } else {
            displayObsTaxon(elem.currentTarget.getAttribute("area-code"), elem.currentTarget.getAttribute("cdref"));
        }
        var name = $(elem.currentTarget)
            .find("#name")
            .html();
        $("#titleMap").html("Observations du taxon&nbsp;:&nbsp;" + name)

}

$(document).ready(function () {
    $("#loaderSpinner").hide();
    if (configuration.INTERACTIVE_MAP_LIST) {
        $("#taxonList ul").on("click", "#taxonListItem", elem => {
            refreshObsArea(elem);
        });
    }
});
