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

// Toujours charger les points d'abord
$.ajax({
    url: configuration.URL_APPLICATION + "/api/observationsPoint",
    dataType: "json",
    type: "get",
    data: {
        cd_ref: cd_ref
    },
    beforeSend: function () {
        $("#loaderSpinner").show();
    },
}).done(function (observations) {
    $("#loaderSpinner").hide();
    observationsPoint = observations;
    displayMarkerLayerFicheEspece(observationsPoint, null, null, sliderTouch);
    if (configuration.MAP.ENABLE_SLIDER) {
        mySlider.on("slideStop", function () {
            sliderTouch = true;
            years = mySlider.getValue();
            yearMin = years[0];
            yearMax = years[1];
            map.removeLayer(currentLayer);
            displayMarkerLayerFicheEspece(
                observationsPoint,
                yearMin,
                yearMax,
                sliderTouch,
            );
            nbObs = 0;
            observationsPoint.features.forEach(function (point) {
                if (
                    point.properties.year >= yearMin &&
                    point.properties.year <= yearMax
                ) {
                    nbObs += 1;
                }
            });
            $("#nbObs").html("Nombre d'observation(s): " + nbObs);
        });
        mySlider.on("change", function () {
            years = mySlider.getValue();
            yearMin = years[0];
            yearMax = years[1];
            $("#yearMin").html(yearMin + "&nbsp;&nbsp;&nbsp;&nbsp;");
            $("#yearMax").html("&nbsp;&nbsp;&nbsp;&nbsp;" + yearMax);
        });
    }

    // Ensuite, si besoin, charger les mailles
    if (nb_obs > configuration.LIMIT_POINT_MAILLE) {
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
            $("#loaderSpinner").hide();
            observationsMaille = observations;
            displayGeojsonMailles(observationsMaille, onEachFeatureMaille);
            eventOnZoom(observationsMaille, observationsPoint);
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
                        map.off("zoomend", function () {});
                        eventOnZoom(observationsMaille, observationsPoint);
                        displayGeojsonMailles(observationsMaille, onEachFeatureMaille);
                        nbObs = 0;
                        observationsMaille.features.forEach(function (l) {
                            nbObs += l.properties.nb_observations;
                        });
                        $("#nbObs").html("Nombre d'observation(s): " + nbObs);
                    });
                });
            }
        });
    }
});

function eventOnZoom(observationsMaille, observationsPoint) {
    // ZoomEvent: change maille to point
    var legendblock = $("div.info");
    var activeMode = "Maille";
    map.on("zoomend", function () {
        if (
            activeMode === "Maille" &&
            map.getZoom() >= configuration.ZOOM_LEVEL_POINT
        ) {
            clearObservationsFeatureGroup();
            legendblock.attr("hidden", "true");

            var yearMin = null;
            var yearMax = null;
            if (configuration.MAP.ENABLE_SLIDER) {
                years = mySlider.getValue();
                yearMin = years[0];
                yearMax = years[1];
            }

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
            map.getZoom() <= configuration.ZOOM_LEVEL_POINT - 1
        ) {
            // display legend
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
