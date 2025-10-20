var zoomHomeButton = true;

var map = generateMap(zoomHomeButton);

var legend = L.control({position: 'bottomright'});

map.scrollWheelZoom.disable();
$('#map').click(function(){
    map.scrollWheelZoom.enable();
})

function displayObsTaxonMaille(cd_ref) {
    $.ajax({
        url:
        configuration.URL_APPLICATION + "/api/observationsMaille",
        data: {
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


function refreshTerritoryArea(elem) {
    document.querySelector("#taxonList .current")?.classList.remove("current")
    elem.currentTarget.classList.add('current');
        displayObsTaxonMaille(elem.currentTarget.getAttribute("cdref"));
    const name = $(this)
        .find("#name")
        .html();
    $("#titleMap").fadeOut(500, function () {
        $(this)
            .html("Observations du taxon&nbsp;:&nbsp;" + name)
            .fadeIn(500);
    });
}




// Generate legends and check configuration to choose which to display (Maille ou Point)

htmlLegendMaille = "<i style='border: solid 1px red;'> &nbsp; &nbsp; &nbsp;</i> Maille comportant au moins une observation <br> <br>" +
    "<i style='border: solid "+configuration.MAP.BORDERS_WEIGHT+"px "+configuration.MAP.BORDERS_COLOR+";'> &nbsp; &nbsp; &nbsp;</i> Limite du "+configuration.STRUCTURE;

htmlLegendPoint = "<i style='border: solid "+configuration.MAP.BORDERS_WEIGHT+"px "+configuration.MAP.BORDERS_COLOR+";'> &nbsp; &nbsp; &nbsp;</i> Limite du "+configuration.STRUCTURE

htmlLegend = configuration.AFFICHAGE_MAILLE ? htmlLegendMaille : htmlLegendPoint;

generateLegende(htmlLegend);

// LOAD OBSERVATIONS if AFFICHAGE_DERNIERES_OBS
if(configuration.AFFICHAGE_DERNIERES_OBS) {
    if(configuration.AFFICHAGE_MAILLE) {
        // display maille layer
        displayGeojsonMailles(observations_mailles);
    } else {
        // Display point layer
        displayGeoJsonPoint(observations);
        generalLegendPoint();
    }
}

// Add territory obs on map
 if (configuration.AFFICHAGE_TERRITOIRE_OBS){
        $("#loaderSpinner").show();

        // display maille layer
        fetch(`/api/observationsMaille?`+ new URLSearchParams({
            "fields": "taxons"
        }))
        .then(response => response.json())
        .then(data => {
            observations = data
            displayGeojsonMailles(observations);
            $("#loaderSpinner").hide();

        })


        // interaction list - map
        $('.lastObslistItem').click(function(elem){
            $(this).siblings().removeClass('current');
            $(this).addClass('current');
            const idMaille = Number(elem.currentTarget.getAttribute("area-code"));
            p = (currentLayer._layers);
            let selectLayer;
            for (var key in p) {
                if (p[key].feature.properties.meshId === idMaille){
                    selectLayer = p[key];
                }
            }

            resetStyleMailles()
            selectLayer.setStyle(styleMailleClickedOrHover(selectLayer));
            selectLayer.openPopup(selectLayer._bounds.getCenter());
            var bounds = L.latLngBounds([]);
            var layerBounds = selectLayer.getBounds();
            bounds.extend(layerBounds);
            map.fitBounds(bounds, {
                maxZoom : 12
            });
        });
    }


// Interraction list carte en mode "territoire obs"
if (configuration.AFFICHAGE_TERRITOIRE_OBS) {
    $(document).ready(function () {
        if (configuration.INTERACTIVE_MAP_LIST) {
            $("#taxonList").on("click", "#taxonListItem", function (elem) {
                refreshTerritoryArea(elem);
            });
        }
    });
}

// Interraction list carte en mode derniere obs et point
if(configuration.AFFICHAGE_DERNIERES_OBS & !configuration.AFFICHAGE_MAILLE & configuration.INTERACTIVE_MAP_LIST ) {
    let selectedLayers = []
    $(document).ready(function () {
        $(".lastObslistItem").on("click", elem => {
            refreshStyle(selectedLayers);
            const idObs = Number(elem.currentTarget.getAttribute("idObservation"));
            const layers = (currentLayer._layers);
            let selectedLayer = null;
            for (var key in layers) {
                if (layers[key].feature.properties.id_observation === idObs){
                    selectedLayer = layers[key];
                    break;
                }
            }
            if(selectedLayer) {
                selectedLayer.openPopup();
                map.setView(
                    new L.LatLng(
                        selectedLayer.feature.geometry.coordinates[1], 
                        selectedLayer.feature.geometry.coordinates[0]
                    ), 12
                );
            }
        });
    });
}

// Interraction list carte en mode derniere obs et maille
if(configuration.AFFICHAGE_DERNIERES_OBS & 
    configuration.AFFICHAGE_MAILLE & 
    configuration.INTERACTIVE_MAP_LIST 
) {
    $(".lastObslistItem").on("click", elem => {
        const idObs = Number(elem.currentTarget.getAttribute("idObservation"));
        const layers = (currentLayer._layers);
        let selectedLayer = null;
        for (var key in layers) {
            if ((layers[key].feature.properties.ids_obs).includes(idObs)){
                selectedLayer = layers[key];
                break;
            }
        }
        if(selectedLayer) {
            var bounds = L.latLngBounds([]);
            var layerBounds = selectedLayer.getBounds();
            bounds.extend(layerBounds);
            map.fitBounds(bounds, {
                maxZoom : 12
            });
            selectedLayer.openPopup();
        }
    });

}