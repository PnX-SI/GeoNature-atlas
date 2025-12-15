var zoomHomeButton = false;

var map = generateMap(zoomHomeButton);

// Current observation Layer: leaflet layer type
var currentLayer;

// Current observation geoJson:  type object
// eslint-disable-next-line no-unused-vars
var myGeoJson;

const id_area = areaInfos.areaID;
displayObs(id_area);

// Display limit of the territory
var areaLayer = L.geoJson(areaInfos.areaGeoJson, {
    style: function () {
        return {
            opacity: 1,
            weight: 2,
            color: areaBorderColor,
            // dashArray: "3",
            fillOpacity: 0.3,
            invert: true,
        };
    },
}).addTo(map);

var bounds = L.latLngBounds([]);
var layerBounds = areaLayer.getBounds();
bounds.extend(layerBounds);
map.fitBounds(bounds);
map.zoom = map.getZoom();

const div = L.DomUtil.create("div", "legend-item");
div.innerHTML =
    "<i style='border: dashed 2px var(--map-area-border-color); background-color:var(--map-area-border-color); opacity:0.3'> &nbsp; &nbsp; &nbsp;</i> Limite de la zone <br>";
document.getElementById("legend-other-info").appendChild(div);

// General Legend

function displayObs(id_area) {
    // si on est en mode point on rajoute une limite au nombre d'obs
    // si on est en maille on renvoie toutes les données aggregées par maille
    let url;
    if (!configuration.AFFICHAGE_MAILLE) {
        url = `${configuration.URL_APPLICATION}/api/observationsPoint?id_area=${id_area}&limit=100&fields=taxons`;
    } else {
        url = `${configuration.URL_APPLICATION}/api/observationsMaille?id_area=${id_area}&fields=taxons`;
    }
    $("#loaderSpinner").show();
    fetch(url)
        .then((data) => {
            return data.json();
        })
        .then((observations) => {
            if (configuration.AFFICHAGE_MAILLE) {
                displayGeojsonMailles(observations, onEachFeatureMailleLastObs);
            } else {
                displayGeoJsonPoint(observations);
                generalLegendPoint();
            }
            $("#loaderSpinner").hide();
        })
        .catch((err) => {
            console.error(err);
            $("#loaderSpinner").hide();
        });
}

function displayObsTaxonMaille(areaID, cd_ref) {
    $.ajax({
        url: configuration.URL_APPLICATION + "/api/observationsMaille",
        data: {
            id_area: areaID,
            cd_ref: cd_ref,
        },
        dataType: "json",
        beforeSend: function () {
            $("#loaderSpinner").show();
        },
    }).done(function (observations) {
        $("#loaderSpinner").hide();
        if (currentLayer) {
            map.removeLayer(currentLayer);
        }
        clearObservationsFeatureGroup();
        displayGeojsonMailles(observations, onEachFeatureMaille);
    });
}

function displayObsTaxon(id_area, cd_ref) {
    $.ajax({
        url: configuration.URL_APPLICATION + "/api/observationsPoint",
        data: {
            id_area: id_area,
            cd_ref: cd_ref,
        },
        dataType: "json",
        beforeSend: function () {
            $("#loaderSpinner").show();
        },
    }).done(function (observations) {
        $("#loaderSpinner").hide();
        if (currentLayer) {
            map.removeLayer(currentLayer);
        }
        displayGeoJsonPoint(observations);
    });
}

function refreshObsArea(elem) {
    document.querySelector("#taxonList .current")?.classList.remove("current");
    elem.currentTarget.classList.add("current");
    if (configuration.AFFICHAGE_MAILLE) {
        displayObsTaxonMaille(
            elem.currentTarget.getAttribute("area-code"),
            elem.currentTarget.getAttribute("cdref"),
        );
    } else {
        displayObsTaxon(
            elem.currentTarget.getAttribute("area-code"),
            elem.currentTarget.getAttribute("cdref"),
        );
    }
    var name = $(elem.currentTarget).find("#name").html();
    $("#titleMap").html("Observations du taxon&nbsp;:&nbsp;" + name);
}

$(document).ready(function () {
    $("#loaderSpinner").hide();
    if (configuration.INTERACTIVE_MAP_LIST) {
        $("#taxonList ul").on("click", "#taxonListItem", (elem) => {
            refreshObsArea(elem);
        });
    }
});
