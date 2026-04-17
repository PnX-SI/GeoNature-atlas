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
var onlyPointLoaded = false; // Indique si les points peuvent être chargés (nb_obs <= limite)
var shouldDisplayMailles = false; // Indique si les mailles doivent être affichées

// variable globale: year filters
var yearMin = null;
var yearMax = null;

/**
 * Affiche les données selon le contexte
 */
function displayDataByZoomLevel() {
    
    const isZoomedToPoints = map.getZoom() >= configuration.ZOOM_LEVEL_POINT;    
    console.log(isZoomedToPoints)
    if (onlyPointLoaded || isZoomedToPoints) {
        clearObservationsFeatureGroup();
        
        // Afficher les points
        displayMarkerLayerFicheEspece(
            observationsPoint,
            yearMin,
            yearMax,
            sliderTouch,
        );
        const legendblock = $("div.info");
        legendblock.attr("hidden", "true");
    } else if (shouldDisplayMailles) {
        map.removeLayer(currentLayer);
        // Afficher les mailles
        displayGeojsonMailles(observationsMaille, onEachFeatureMaille);
        const legendColorObs = document.querySelector("#legend-color-obs");
        legendColorObs.querySelectorAll("div").forEach((elem) => elem.remove());
        legendColorObs.appendChild(generateObservationsLegend(true));
        
        const legendblock = $("div.info");
        legendblock.removeAttr("hidden");
        
        // Mettre à jour le compteur
        $("#nbObs").html("Nombre d'observation(s): " + nb_obs);
    }
}

/**
 * Lance le rechargement des mailles selon les filtres d'année
 */
function reloadMaillesWithYearFilter() {
    map.removeLayer(currentLayer);
    
    $("#loaderSpinner").show();
    $.ajax({
        url: configuration.URL_APPLICATION + "/api/observationsMaille",
        dataType: "json",
        type: "get",
        data: {
            cd_ref: cd_ref,
            year_min: yearMin,
            year_max: yearMax,
        },
    }).done(function (observations) {
        $("#loaderSpinner").hide();
        observationsMaille = observations;
        displayDataByZoomLevel();
    });
}

/**
 * Configure les événements du slider si activé
 */
function setupSlider() {
    if (!configuration.MAP.ENABLE_SLIDER) {
        return;
    }
    
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
        
        if (shouldDisplayMailles) {
            // Si on a les mailles, les recharger avec le filtre
            reloadMaillesWithYearFilter();
        } else {
            // Sinon juste réafficher les points filtrés
            map.removeLayer(currentLayer);
            displayDataByZoomLevel();
        }
    });
}

/**
 * Lance le chargement des points après les mailles
 */
function loadPoints() {
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
        
        // Réactiver le zoom après chargement des points
        map.doubleClickZoom.enable();
        map.scrollWheelZoom.enable();
        
        // Afficher les points
        displayDataByZoomLevel();
        eventOnZoom();
        setupSlider();
    });
}

// Vérifier le nombre d'observations et décider de la stratégie de chargement
if (nb_obs <= configuration.LIMIT_POINT_MAILLE) {
    // nb_obs faible: charger UNIQUEMENT les points
    onlyPointLoaded = true;
    shouldDisplayMailles = false;
    
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
        displayDataByZoomLevel();
        eventOnZoom();
        setupSlider();
    });
} else {
    // nb_obs élevé: charger d'abord les mailles, puis les points
    shouldDisplayMailles = true;
    
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
        
        // Afficher les mailles
        displayGeojsonMailles(observationsMaille, onEachFeatureMaille);
        
        $("#loaderSpinner").hide();
        
        // Bloquer le zoom pendant le chargement des points
        map.doubleClickZoom.disable();
        map.scrollWheelZoom.disable();
        
        // Charger les points en arrière-plan
        loadPoints();
    });
}


function eventOnZoom() {
    // ZoomEvent: change maille to point (seulement si on a les deux types de données)
    var activeMode = shouldDisplayMailles ? "Maille" : "Point";
    
    map.on("zoomend", function () {
        const isZoomedToPoints = map.getZoom() >= configuration.ZOOM_LEVEL_POINT;
        
        // Si on n'a que les points, ne rien faire
        if (!shouldDisplayMailles) {
            return;
        }
        
        // Si on a les mailles et points, basculer selon le zoom
        if (activeMode === "Maille" && isZoomedToPoints) {
            displayDataByZoomLevel();
            activeMode = "Point";
        }
        if (activeMode === "Point" && !isZoomedToPoints) {
            displayDataByZoomLevel();
            activeMode = "Maille";
        }
    });
}
