var zoomHomeButton = true;

var map = generateMap(zoomHomeButton);

if (configuration.MAP.ENABLE_SLIDER) {
    generateSliderOnMap();
}
// Layer display on window ready

/*GLOBAL VARIABLE*/

// Current observation Layer: leaflet layer type
var currentLayer;

// Current observation geoJson:  type object
// eslint-disable-next-line no-unused-vars
var myGeoJson;

// global variable to see if the slider has been touch
var sliderTouch = false;

// variable globale: observations récupérer en AJAX
var observationsMaille;
var observationsPoint;

// variable globale: year filters
var yearMin = null;
var yearMax = null;

// Toujours charger les mailles en premier (plus rapide)
$.ajax({
    url: configuration.URL_APPLICATION + "/api/observationsMaille",
    dataType: "json",
    type: "get",
    data: {
        cd_ref: cd_ref
    },
    beforeSend: function () {
        $("#loaderSpinner").show();
    },
}).done(function (observations) {
    observationsMaille = observations;
    displayGeojsonMailles(observationsMaille, onEachFeatureMaille);
    
    // Masquer le spinner dès que les mailles sont affichées
    $("#loaderSpinner").hide();
    
    // Bloquer le zoom jusqu'au chargement des points
    map.doubleClickZoom.disable();
    map.scrollWheelZoom.disable();


    // Charger les points dans le callback des mailles
    $.ajax({
        url: configuration.URL_APPLICATION + "/api/observationsPoint",
        dataType: "json",
        type: "get",
        data: {
            cd_ref: cd_ref
        },

    }).done(function (observations) {
        $("#loaderSpinner").hide();
        observationsPoint = observations;
        pointsLoaded = true;
        
        // Réactiver le zoom après chargement des points
        map.doubleClickZoom.enable();
        map.scrollWheelZoom.enable();

        // Afficher points si limite respectée, sinon garder les mailles
        if (nb_obs <= configuration.LIMIT_POINT_MAILLE) {
            displayMarkerLayerFicheEspece(observationsPoint, null, null, sliderTouch);
        }

        eventOnZoom();

        // Configuration du slider
        if (configuration.MAP.ENABLE_SLIDER) {
            mySlider.on("change", function () {
                sliderTouch = true;
                years = mySlider.getValue();
                yearMin = years[0];
                yearMax = years[1];

                $("#yearMin").html(yearMin + "&nbsp;&nbsp;&nbsp;&nbsp;");
                $("#yearMax").html("&nbsp;&nbsp;&nbsp;&nbsp;" + yearMax);
            });

           mySlider.on("slideStop", function () {
                sliderTouch = true;

                map.removeLayer(currentLayer);
                
                // TOUJOURS recharger les mailles avec le filtre d'année
                $.ajax({
                    url: configuration.URL_APPLICATION + "/api/observationsMaille",
                    dataType: "json",
                    type: "get",
                    data: {
                        cd_ref: cd_ref,
                        year_min: yearMin,
                        year_max: yearMax,
                    },
                    beforeSend: function () {
                        $("#loaderSpinner").show();
                    },
                }).done(function (observations) {
                    $("#loaderSpinner").hide();
                    observationsMaille = observations;
                    
                    // Puis afficher selon le zoom level
                    if (map.getZoom() >= configuration.ZOOM_LEVEL_POINT) {
                        displayMarkerLayerFicheEspece(
                            observationsPoint,
                            yearMin,
                            yearMax,
                            sliderTouch,
                        );
                    } else {
                        displayGeojsonMailles(observationsMaille, onEachFeatureMaille);
                        // Mettre à jour le compteur
                        let nbObs = 0;
                        observationsMaille.features.forEach(function (l) {
                            nbObs += l.properties.nb_observations;
                        });
                        $("#nbObs").html("Nombre d'observation(s): " + nbObs);
                    }
                });
            });
        
        }
    });
});


function eventOnZoom() {
    // ZoomEvent: change maille to point
    var legendblock = $("div.info");
    var activeMode = "Maille";
    map.on("zoomend", function () {
        if (
            activeMode === "Maille" &&
            map.getZoom() >= configuration.ZOOM_LEVEL_POINT
        ) {
            console.log("dispmay point");
            
            clearObservationsFeatureGroup();
            legendblock.attr("hidden", "true");

            displayMarkerLayerFicheEspece(
                observationsPoint,
                yearMin,
                yearMax,
                sliderTouch,
            );
            activeMode = "Point";
        }
        if (
            activeMode === "Point" &&
            map.getZoom() < configuration.ZOOM_LEVEL_POINT
        ) {
            // display legend
            console.log("passe la", currentLayer);
            
            map.removeLayer(currentLayer);
            const legendColorObs = document.querySelector("#legend-color-obs");
            legendColorObs
                .querySelectorAll("div")
                .forEach((elem) => elem.remove());
            legendColorObs.appendChild(generateObservationsLegend(true));

            toggleLayerTab(true);
            legendblock.removeAttr("hidden");
            displayGeojsonMailles(observationsMaille, onEachFeatureMaille);
            activeMode = "Maille";
        }
    });
}
