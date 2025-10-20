var zoomHomeButton = false;

var map = generateMap(zoomHomeButton);

var legend = L.control({position: "bottomright"});
// Current observation Layer: leaflet layer type
var currentLayer;

// Current observation geoJson:  type object
var myGeoJson;

const id_area = areaInfos.areaID
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



function displayObs(id_area) {
    // si on est en mode point on rajoute une limite au nombre d'obs
    // si on est en maille on renvoie toutes les données aggregées par maille
    let url;
    if (!configuration.AFFICHAGE_MAILLE) {        
        url = `${configuration.URL_APPLICATION}/api/observationsPoint?id_area=${id_area}&limit=100&fields=taxons`;
    } else{
        url = `${configuration.URL_APPLICATION}/api/observationsMaille?id_area=${id_area}&fields=taxons`;
    }
    $("#loaderSpinner").show();
    fetch(url)
        .then(data => {
            return data.json()
        })
        .then(observations => {

            if (configuration.AFFICHAGE_MAILLE) {
                displayGeojsonMailles(observations);
            } else {                
                displayGeoJsonPoint(observations);
                generalLegendPoint();

            }
            $("#loaderSpinner").hide();
        })
        .catch(err => {
            console.error(err)
            $("#loaderSpinner").hide();
        })
}

function displayObsTaxonMaille(areaID, cd_ref) {
    $.ajax({
        url:
        configuration.URL_APPLICATION + "/api/observationsMaille",
        data: {
            "id_area": areaID,
            "cd_ref": cd_ref
        },
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
        displayMailleLayerFicheEspece(observations);
    });
}

function displayObsTaxon(id_area, cd_ref) {
  $.ajax({
    url:
      configuration.URL_APPLICATION +
      "/api/observationsPoint",
    data: {
        "id_area": id_area,
        "cd_ref": cd_ref
    },
    dataType: "json",
      beforeSend: function () {
          $("#loaderSpinner").show();
    }
  }).done(function (observations) {
    $("#loaderSpinner").hide();
    if (currentLayer) {
      map.removeLayer(currentLayer);
    }
    displayGeoJsonPoint(observations);
    })
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
