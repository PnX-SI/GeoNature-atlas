// Affiche ou masque l'onglet "choix des couches" (tab control)
function toggleLayerTab(show) {
    const controltab = document.querySelector("#control-tab");
    const controltabContent = document.querySelector("#control-tab-content");
    if (controltab && controltabContent) {
        controltab.style.display = show ? "" : "none";
        controltabContent.style.display = show ? "" : "none";
    }
}
// global :
let current_sensitivity_codes = []; // list of distinct cd_sensibility in geojson

// eslint-disable-next-line no-unused-vars
const areaBorderColor = String(
    getComputedStyle(document.documentElement).getPropertyValue(
        "--map-area-border-color",
    ),
);

// Feature group de chaque élément de floutage (M1, M5 etc...)
const observationsFeatureGroup = {};

function isMobile() {
    return window.innerWidth <= 768; // Détecte si l'utilisateur est en mode mobile
}

const control = L.control.layers(null, null, {
    collapsed: isMobile(),
});

function clearObservationsFeatureGroup() {
    // Supprime toutes les couches d'observations (FeatureGroup créés dans createLayersSelector)
    Object.values(observationsFeatureGroup).forEach((featureGroup) => {
        if (map.hasLayer(featureGroup)) {
            map.removeLayer(featureGroup);
        }
        control.removeLayer(featureGroup);
    });
}

function generateObservationPopup(feature) {
    /*
      Génération popup des observations
    */

    popupContent = `
            <b>Date: </b> ${feature.properties.dateobs}
            </br><b>Altitude: </b> ${feature.properties.altitude_retenue}
            ${observersTxt(feature)} </br>
            <a href='${window.LANGUAGE_PREFIXED_URL_APPLICATION}/espece/${feature.properties.cd_ref}'> Fiche espèce </a>
            `;

    // verifie si le champs effectif est rempli
    if (feature.properties.effectif_total !== undefined) {
        popupContent = `${popupContent} </br><b>Effectif: </b>${feature.properties.effectif_total}`;
    }

    // S'il faut lier à une fiche espèce
    if (feature.properties.taxon) {
        popupContent = `<b>Espèce: </b> ${feature.properties.taxon} </br>
              ${popupContent}
              </br>
              `;
    }
    return popupContent;
}

function addExternalOverlays(map) {
    const sheetName = document.querySelector("body").getAttribute("page-name");

    for (const elem of configuration.COUCHES_SIG) {
        if (
            elem?.type === "wms" &&
            (elem?.pages?.includes(sheetName) || !elem?.pages)
        ) {
            elem["options"][""];
            const layer = L.tileLayer.wms(elem.url, elem.options);

            layer.addEventListener("add", function (event) {
                // Add legend item into good place
                legendUrl = `${event.sourceTarget._url}?request=GetLegendGraphic&version=${elem.wms_version}&format=image/png&layer=${event.sourceTarget.wmsParams.layers}`;
                const div = L.DomUtil.create("div", "legend-item");
                div.setAttribute("data-name", elem.name);
                div.innerHTML = `
                        <span style="
                                padding-top: 0.5rem;
                                padding-bottom: 0.5rem;
                                display: flex;
                                flex-direction: column;
                                justify-content: space-between;
                            ">
                            <div>${elem.name}</div>
                            <div>
                                <img src="${legendUrl}" alt="legend image for ${event.sourceTarget.wmsParams.layers}">
                            </div>
                        </span>
                        `;
                document.getElementById("legend-other-info").appendChild(div);
            });

            if (elem.selected) {
                map.addLayer(layer);
            }

            layer.addEventListener("remove", () => {
                // Remove legend item
                const item = document.querySelector(
                    `.legend-item[data-name='${elem.name}']`,
                );
                if (item) {
                    document
                        .getElementById("legend-other-info")
                        .removeChild(item);
                }
            });
            addOverlayInControl(layer, elem.name);
        } else if (
            elem?.type === "geojson" &&
            (elem?.pages?.includes(sheetName) || !elem?.pages)
        ) {
            fetch(elem.url)
                .then((response) => response.json())
                .then((data) => {
                    const layer = L.geoJSON(data, {
                        pane: "backgroundLayers",
                        style: function () {
                            return elem.style || {};
                        },
                    });

                    layer.addEventListener("add", function () {
                        let color = "#3388ff";
                        const style = elem.style;
                        if (style && style.color) {
                            color = style.color;
                        }
                        const div = L.DomUtil.create("div", "legend-item");
                        div.setAttribute("data-name", elem.name);
                        div.innerHTML = `
                            <i style='border: solid 1px ${color};'> &nbsp; &nbsp; &nbsp;</i>
                             ${elem.name}
                        `;
                        document
                            .getElementById("legend-other-info")
                            .appendChild(div);
                    });

                    layer.addEventListener("remove", () => {
                        // Remove legend item
                        const item = document.querySelector(
                            `.legend-item[data-name='${elem.name}']`,
                        );
                        if (item) {
                            document
                                .getElementById("legend-other-info")
                                .removeChild(item);
                        }
                    });

                    addOverlayInControl(layer, elem.name);
                    if (elem.selected) {
                        map.addLayer(layer);
                    }
                });
        }
    }
    return observationsFeatureGroup;
}

function createTabControl() {
    const content = control
        .getContainer()
        .querySelector(".leaflet-control-layers-overlays");
    var div = L.DomUtil.create("div", "leaflet-control-tabs");
    div.innerHTML = `
<button
        style="position: relative; display: flex; float: right;"
        type="button" class="btn-close"
        data-dismiss="modal"
        onclick="control.collapse();"
        aria-label="Close">
    <span aria-hidden="true" class="text-white">×</span>
</button>
        
<div class="leaflet-control-layers leaflet-control" aria-haspopup="true">
    <a class="leaflet-control-layers-toggle" href="#" title="Layers" role="button"></a>
    <ul class="nav nav-tabs" id="overlay-tab" role="tablist">
      <li class="nav-item mr-1">
        <a class="nav-link active" id="legend-tab" data-bs-toggle="tab" href="#legend-tab-content" role="tab" aria-controls="legend" aria-selected="true">Légende</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" id="control-tab" data-bs-toggle="tab" href="#control-tab-content" role="tab" aria-controls="control" aria-selected="false">Choix des couches</a>
      </li>
    </ul>
    <div class="tab-content">
        <div class="tab-pane fade show active" id="legend-tab-content" role="tabpanel" aria-labelledby="legend-tab">
            <div id="legend-wrapper" class="d-grid gap-3">
                <div id="legend-color-obs" class="p-2 bg-light border"></div>
                <div id="legend-other-info" class="p-2 bg-light border"></div>
            </div>
        </div>
        <div class="tab-pane fade" id="control-tab-content" role="tabpanel" aria-labelledby="control-tab">      
        </div>
    </div>
</div>
`;
    content.parentNode.insertBefore(div, content);
    div.querySelector("#control-tab-content").appendChild(content);

    const sheetName = document.querySelector("body").getAttribute("page-name");

    let isMaille = false;
    if (
        (sheetName === "index" && configuration.AFFICHAGE_TERRITOIRE_OBS) ||
        (sheetName === "ficheEspece" &&
            nb_obs > configuration.LIMIT_POINT_MAILLE) ||
        configuration.AFFICHAGE_MAILLE
    ) {
        isMaille = true;
    }
    // Initialization of legend
    document
        .querySelector("#legend-color-obs")
        .appendChild(generateObservationsLegend(isMaille));
}

/**
 *Réordonne les control en mettant en premier les layer d'obseration et en second les couches additionnelles (COUCHES_SIG)
 **/
function reorderLayerControl() {
    const container = control.getContainer();
    const overlayDiv = container.querySelector(
        ".leaflet-control-layers-overlays",
    );

    if (!overlayDiv) return;

    // Récupère tous les labels
    const allLabels = Array.from(overlayDiv.querySelectorAll("label"));

    // Sépare en deux groupes
    const defaultLabels = allLabels.filter(
        (label) => label.querySelector(".defaultOverlay") !== null,
    );
    const otherLabels = allLabels.filter(
        (label) => label.querySelector(".defaultOverlay") === null,
    );

    // Vide le conteneur
    overlayDiv.innerHTML = "";

    if (defaultLabels.length > 0) {
        const defaultLabelTitle = document.createElement("p");
        defaultLabelTitle.style.fontWeight = "bold";
        defaultLabelTitle.style.margin = "5px 0";
        defaultLabelTitle.textContent =
            "Niveau de diffusion des données en fonction leur sensibilité";
        overlayDiv.appendChild(defaultLabelTitle);
    }
    defaultLabels.forEach((label) => overlayDiv.appendChild(label));

    // Ajoute le séparateur si les deux groupes existent
    if (defaultLabels.length > 0 && otherLabels.length > 0) {
        const separator = document.createElement("div");
        separator.className = "leaflet-control-layers-separator";
        overlayDiv.appendChild(separator);
    }
    if (otherLabels.length > 0) {
        const aditionnalLbelTitle = document.createElement("p");
        aditionnalLbelTitle.style.fontWeight = "bold";
        aditionnalLbelTitle.style.margin = "5px 0";
        aditionnalLbelTitle.textContent = "Couche(s) additionnelle(s)";
        overlayDiv.appendChild(aditionnalLbelTitle);
    }

    // Ajoute les autres couches
    otherLabels.forEach((label) => overlayDiv.appendChild(label));
}

function addOverlayInControl(layer, label, isDefaultOverlay = false) {
    let className = "";
    const separator = "";
    if (isDefaultOverlay) {
        className = "defaultOverlay";
    }
    control.addOverlay(
        layer,
        `
    <div>
        <div class="${className}">${label}</div>
        ${separator}
    </div>
    `,
    );
}

// get the different cd_sensitivity and store them in current_type_code arrray
// use to create different feature group and layer control
function getSensitivityLevelInGeojson(geojson) {
    current_sensitivity_codes = [];
    Object.values(geojson.features).forEach((elem) => {
        if (
            !current_sensitivity_codes.includes(elem.properties.cd_sensitivity)
        ) {
            current_sensitivity_codes.push(elem.properties.cd_sensitivity);
        }
    });
    current_sensitivity_codes.sort();
}

/**
 * Create a layer control for each type of zoning (M1, M5 etc..) and associate it a feature group
 * Add the features group to map
 */
function createLayersSelector(geojson) {
    getSensitivityLevelInGeojson(geojson);

    current_sensitivity_codes.forEach((cd_sensitivity, index) => {
        const featureGroup = L.featureGroup();
        observationsFeatureGroup[cd_sensitivity] = featureGroup;
        // les cd_sensitivity présent dans le geojson sont triés par ordre de sensibilité croissant
        // par défaut on affiche que la couche du niveau le moins sensible !
        if (index === 0) {
            map.addLayer(featureGroup);
        }
        let layerName = "";
        if (cd_sensitivity === "0") {
            layerName = "Observations non sensibles";
        } else {
            layerName = `Observations sensibles - niveau ${cd_sensitivity}`;
        }
        addOverlayInControl(featureGroup, layerName, true);
    });
}

// eslint-disable-next-line no-unused-vars
function generateMap(zoomHomeButton) {
    // Map initialization
    firstMapTile = L.tileLayer(configuration.MAP.FIRST_MAP.url, {
        attribution: configuration.MAP.FIRST_MAP.attribution,
    });
    orthoMap = L.tileLayer(configuration.MAP.SECOND_MAP.url, {
        attribution: configuration.MAP.SECOND_MAP.attribution,
    });

    baseMap = {};
    baseMap[configuration.MAP.FIRST_MAP.tileName] = firstMapTile;

    var map = L.map("map", {
        crs: L.CRS.EPSG3857,
        center: configuration.MAP.LAT_LONG,
        maxBounds: configuration.MAP.MAX_BOUNDS,
        minZoom: configuration.MAP.MIN_ZOOM,
        geosearch: true,
        zoom: configuration.MAP.ZOOM,
        layers: [firstMapTile],
        fullscreenControl: true,
        zoomControl: !zoomHomeButton,
    });

    // use for geojson external layers. Avoid them to overlap observations layer when they are added/removed
    map.createPane("backgroundLayers");
    map.getPane("backgroundLayers").style.zIndex = 250;

    control.addTo(map);

    // create the html control panel
    createTabControl();
    // add `COUCHE_SIG`
    addExternalOverlays(map);

    // Keep Layers in the same order as specified by the
    // observationsFeatureGroup variable so Departement under Commune
    // under 10km2 under 1km2
    map.on("overlayadd", function () {
        Object.values(observationsFeatureGroup).forEach((e) =>
            e.bringToFront(),
        );
    });

    if (zoomHomeButton) {
        var zoomHome = L.Control.zoomHome();
        zoomHome.addTo(map);
    }

    // 'Google-like' baseLayer controler

    var LayerControl = L.Control.extend({
        options: {
            position: "bottomleft",
        },

        onAdd: function (map) {
            currentTileMap = "topo";
            var container = L.DomUtil.create(
                "div",
                "leaflet-bar leaflet-control leaflet-control-custom",
            );

            container.style.backgroundColor = "white";
            container.style.backgroundImage =
                "url(" +
                configuration.URL_APPLICATION +
                "/static/images/logo_earth_map.PNG)";
            container.style.width = "50px";
            container.style.height = "50px";
            container.style.border = "solid white 1px";
            container.style.cursor = "pointer";
            $(container).attr("data-bs-placement", "right");
            $(container).attr("data-bs-toggle", "tooltip");
            $(container).attr("title", "Photos aérienne");

            container.onclick = function () {
                if (currentTileMap === "topo") {
                    container.style.backgroundImage =
                        "url(" +
                        configuration.URL_APPLICATION +
                        "/static/images/logo_topo_map.PNG)";
                    $(container).attr("title", "Plan");
                    map.removeLayer(firstMapTile);
                    orthoMap.addTo(map);
                    currentTileMap = "earth";
                } else {
                    container.style.backgroundImage =
                        "url(" +
                        configuration.URL_APPLICATION +
                        "/static/images/logo_earth_map.PNG)";
                    $(container).attr("title", "Photos aérienne");
                    map.removeLayer(orthoMap);
                    firstMapTile.addTo(map);
                    currentTileMap = "topo";
                }
            };
            return container;
        },
    });

    map.addControl(new LayerControl());

    // add tooltip on fullScreen button

    fullScreenButton = $(".leaflet-control-fullscreen");
    fullScreenButton.attr("data-bs-placement", "right");
    fullScreenButton.attr("data-bs-toggle", "tooltip");
    fullScreenButton.attr("title", "Fullscreen");
    $(".leaflet-control-fullscreen-button").removeAttr("title");

    // Add scale depending on the configuration
    if (configuration.MAP.ENABLE_SCALE) {
        L.control
            .scale({
                imperial: false,
                position: "bottomright",
            })
            .addTo(map);
    }

    if (configuration.SEARCH_NOMINATIM) {
        addGeocoderPluggin(map);
    }

    return map;
}

function observersTxt(feature) {
    return configuration.DISPLAY_OBSERVERS
        ? `</br><b> Observateurs(s): </b> ${feature.properties.observateurs}`
        : "";
}

//****** Fonction fiche espècce ***********

// Popup Point
function onEachFeaturePointSpecies(feature, layer) {
    popupContent = generateObservationPopup(feature, false);
    layer.bindPopup(popupContent);
}

// popup Maille
// eslint-disable-next-line no-unused-vars
function onEachFeatureMaille(feature, layer) {
    popupContent =
        "<b>Nombre d'observation(s): </b>" +
        feature.properties.nb_observations +
        "</br> <b> Dernière observation: </b>" +
        feature.properties.last_observation +
        " ";
    layer.bindPopup(popupContent);

    // associate a feature to the correct feature group
    observationsFeatureGroup[feature.properties.cd_sensitivity].addLayer(layer);

    if (configuration.AFFICHAGE_MAILLE) {
        zoomMaille(layer);
    }

    var selected = false;
    layer.setStyle(styleMailleAtlas(feature.properties.nb_observations));
    layer.on("click", function (layer) {
        resetStyleMailles();
        this.setStyle(styleMailleClickedOrHover(layer.target));
        selected = true;
    });
    layer.on("mouseover", function (layer) {
        this.setStyle(styleMailleClickedOrHover(layer.target));
        selected = false;
    });

    layer.on("mouseout", function () {
        if (!selected) {
            this.setStyle(styleMailleAtlas(feature.properties.nb_observations));
        }
    });
}

function zoomMaille(layer) {
    layer.on("click", function () {
        map.fitBounds(layer.getBounds());
    });
}

// Style maille
function getColor(d) {
    return d > 100
        ? "#800026"
        : d > 50
          ? "#BD0026"
          : d > 20
            ? "#E31A1C"
            : d > 10
              ? "#FC4E2A"
              : d > 5
                ? "#FD8D3C"
                : d > 2
                  ? "#FEB24C"
                  : d > 1
                    ? "#FED976"
                    : "#FFEDA0";
}

function generateObservationsLegend(isMaille = false) {
    if (!configuration.AFFICHAGE_MAILLE && !isMaille) {
        return generalLegendPoint();
    }
    // check if contour already exists
    if (L.DomUtil.get("contour-legend")) {
        return;
    }
    var div = L.DomUtil.create("div", "info legend"),
        grades = [0, 1, 2, 5, 10, 20, 50, 100],
        labels = [
            "<div  style='padding-bottom: 1rem'><strong> Nombre d'observations </strong></div>",
        ];

    // loop through our density intervals and generate a label with a colored square for each interval
    grades.forEach((grade, i) => {
        const next = grades[i + 1];
        // Ajout d'un plus si c'est la dernière valeur
        const grade_n1 = next ? ` &ndash; ${next} <br>` : "+";
        // Si les 2 valeurs sont identiques, alors on en affiche qu'une
        const label =
            next === grade + 1 ? `${next}  <br>` : `${grade + 1}${grade_n1}`;
        labels.push(
            `<div class="d-flex pb-1 align-items-center">
                <div class="me-2" style="background: ${getColor(grade + 1)}; width: 15px; height: 15px;"></div>
                <div class="" >${label}</div>
            </div>
                `,
        );
    });

    // Add id to get it above
    div.id = "contour-legend";
    div.innerHTML = labels.join("");

    return div;
}

function generalLegendPoint() {
    if (typeof divLegendeFicheEspece !== "undefined") {
        var div = L.DomUtil.create("div", "info legend");
        div.innerHTML = divLegendeFicheEspece;
        return div;
    }
}

// Display Maille layer

// eslint-disable-next-line no-unused-vars
function displayGeojsonMailles(observationsMaille, onEachFeature) {
    myGeoJson = observationsMaille;

    clearObservationsFeatureGroup();

    // create features group and layer control for each area type in geojson
    createLayersSelector(observationsMaille, true);
    // NB : the geosjon is not directly added to the map, it's done with the FeatureGroup
    // which are added by default is the config tell so or can be added with le control layer later
    currentLayer = L.geoJson(myGeoJson, {
        onEachFeature: onEachFeature,
    });

    reorderLayerControl();
}

// GeoJson Point
function generateGeojsonPointFicheEspece(
    geojsonPoint,
    yearMin,
    yearMax,
    sliderTouch,
) {
    var filteredGeoJsonPoint = Object.assign({}, geojsonPoint);
    // si on a touché le slider on filtre sinon on retourne directement le geojson
    if (yearMin && yearMax && sliderTouch) {
        filteredGeoJsonPoint.features = geojsonPoint.features.filter(
            function (obs) {
                return (
                    obs.properties.year >= yearMin &&
                    obs.properties.year <= yearMax
                );
            },
        );
        return filteredGeoJsonPoint;
    } else {
        return filteredGeoJsonPoint;
    }
}

// Display marker Layer (cluster or not)
// eslint-disable-next-line no-unused-vars
function displayMarkerLayerFicheEspece(
    observationsPoint,
    yearMin,
    yearMax,
    sliderTouch,
) {
    myGeoJson = generateGeojsonPointFicheEspece(
        observationsPoint,
        yearMin,
        yearMax,
        sliderTouch,
    );

    if (typeof customizeMarkerStyle === "undefined") {
        customizeMarkerStyle = function () {
            return {};
        };
    }
    currentLayer = L.geoJson(myGeoJson, {
        onEachFeature: onEachFeaturePointSpecies,

        pointToLayer: function (feature, latlng) {
            return L.circleMarker(latlng, customizeMarkerStyle(feature));
        },
    });
    const legendColorObs = document.querySelector("#legend-color-obs");
    if (configuration.COUCHES_SIG.length === 0) {
        // In point only map, hide control tab if no COUCHES_SIG configured
        toggleLayerTab(false);
        const legendtab = document.querySelector("#legend-tab");
        const legendtabContent = document.querySelector("#legend-tab-content");
        const controltab = document.querySelector("#control-tab");
        const controltabContent = document.querySelector(
            "#control-tab-content",
        );
        // switch to legend tab
        legendtab.classList.add("active");
        legendtabContent.classList.add("active");
        legendtabContent.classList.add("show");
        controltab.classList.remove("active");
        controltabContent.classList.remove("active");
        controltabContent.classList.remove("show");
    }
    if (myGeoJson.features.length > configuration.LIMIT_CLUSTER_POINT) {
        legendColorObs.querySelectorAll("div").forEach((elem) => elem.remove());        
        legendColorObs.appendChild(generateObservationsLegend(false));

        // Not display labels of maille observationsFeatureGroup
        document.querySelectorAll(".defaultOverlay").forEach((elem) => {
            elem.closest("label").style.display = "none";
        });

        newLayer = currentLayer;
        currentLayer = L.markerClusterGroup();
        currentLayer.addLayer(newLayer);
        map.addLayer(currentLayer);
    } else {
        currentLayer.addTo(map);
    }
    // map.fitBounds(currentLayer.getBounds()); ZOOM FUNCTION ON SPECIES SHEET MARKER LAYER OBSERVATIONS DISPLAY
}

// ***************Fonction lastObservations: mapHome et mapArea*****************

/* *** Point ****/

function onEachFeaturePoint(feature, layer) {
    popupContent = generateObservationPopup(feature, true);
    layer.bindPopup(popupContent);
}

function getCustomizeMarkerStyle() {
    if (typeof customizeMarkerStyle === "undefined") {
        customizeMarkerStyle = function () {
            return {};
        };
    } else {
        return customizeMarkerStyle;
    }
}

// eslint-disable-next-line no-unused-vars
function displayGeoJsonPoint(geojson) {
    currentLayer = L.geoJson(geojson, {
        onEachFeature: onEachFeaturePoint,
        pointToLayer: function (feature, latlng) {
            return L.circleMarker(latlng, getCustomizeMarkerStyle(feature));
        },
    });
    map.addLayer(currentLayer);

    clearObservationsFeatureGroup(true);

    control.addTo(map);
}

// eslint-disable-next-line no-unused-vars
function refreshStyle(layers) {
    // fonction to refresh style of a list of layers from the customizeMarkerStyle (set green for sensibility and blue for non sensible obs)
    layers.forEach((layer) => {
        layer.setStyle(getCustomizeMarkerStyle(layer.feature));
    });
}

//  ** MAILLE ***

function buildSpeciesEntries(taxons) {
    rows = [];
    taxons.forEach((taxon) => {
        rows.push(`
    <a title="Cliquez pour aller à la fiche de '${taxon.nom_vern}'" class="tooltip-item btn" href="/espece/${taxon.cd_ref}" target="_blank">
        <img loading="lazy" class="me-2 has-media-${taxon.has_media}" src="${taxon.media}" alt="" >
        <div class="tooltip-item-text">
            <p class="name_vern">${taxon.nom_vern ? taxon.nom_vern : ""}</p>
            <p class="lb_nom">${taxon.lb_nom}</p>
            <p>${taxon.nb_obs} observations (dernière  ${taxon.last_obs})
        </div>
    </a>
    `);
    });
    return rows.join("\n");
}

function createPopUp(event) {
    const sheetName = document.querySelector("body").getAttribute("page-name");
    const idMaille = event.target.feature.id;
    page_tooltip = 1;
    havePossibleNextPage_tooltip = true;
    let url = `/api/taxonListJson/area/${idMaille}?page=-1&only_related_sensitivity_level=true`;
    if (sheetName === "index" && configuration.AFFICHAGE_DERNIERES_OBS) {
        url = url + "&last_obs=true";
    }
    fetch(url)
        .then((response) => response.json())
        .then((data) => {
            const title = `${data.length} espèces observées dans la maille &nbsp;: `;
            const rows = buildSpeciesEntries(data);
            const popupContent = `
                <div class="tooltip-item-wrapper">
                    <b>${title}</b>
                    <div class="d-flex flex-column tooltip-content">${rows}</div>
                </div>`;

            L.popup({ maxHeight: 300 })
                .setLatLng(event.latlng)
                .setContent(popupContent)
                .openOn(map);
        });
}

// eslint-disable-next-line no-unused-vars
function onEachFeatureMailleLastObs(feature, layer) {
    observationsFeatureGroup[feature.properties.cd_sensitivity].addLayer(layer);

    var selected = false;
    layer.setStyle(styleMailleAtlas(feature.properties.nb_observations));
    layer.on("click", function (event) {
        createPopUp(event);
        resetStyleMailles();
        selected = true;
    });
    layer.on("mouseover", function (layer) {
        this.setStyle(styleMailleClickedOrHover(layer.target));
        selected = false;
    });

    layer.on("mouseout", function () {
        if (!selected) {
            this.setStyle(styleMailleAtlas(feature.properties.nb_observations));
        }
    });
}

function styleMailleAtlas(nb) {
    return {
        opacity: 0, // opacité de la bordure
        fillColor: getColor(nb),
        fillOpacity: 0.7,
    };
}

function styleMailleClickedOrHover(layer) {
    var options = layer.options;
    return {
        ...options,
        opacity: 1,
        weight: 2,
        fillOpacity: 0.85,
        color: configuration.TEMPLATE_MAIN_COLOR,
    };
}

function resetStyleMailles() {
    // set style for all cells
    map.eachLayer(function (layer) {
        if (layer.feature && layer.feature.properties.id_type) {
            layer.setStyle(
                styleMailleAtlas(layer.feature.properties.taxons.length),
            );
        }
    });
}

// eslint-disable-next-line no-unused-vars
var mySlider;

// eslint-disable-next-line no-unused-vars
function generateSliderOnMap() {
    // Vérifie si le slider existe déjà
    if (document.getElementById("sliderContainer")) return;

    // Crée le conteneur du slider
    var sliderContainer = document.createElement("div");
    sliderContainer.id = "sliderContainer";
    sliderContainer.className = "slider-bottom-center";
    sliderContainer.style.backgroundColor = "white";
    sliderContainer.style.width = "350px";
    sliderContainer.style.height = "70px";
    sliderContainer.style.border = "solid white 1px";
    sliderContainer.style.cursor = "pointer";
    sliderContainer.style.textAlign = "center";
    sliderContainer.innerHTML =
        "<p> <span id='yearMin'> </span> <input id='sliderControl' type='text'/> <span id='yearMax'>  </span>  </p>" +
        "<p id='nbObs'> Nombre d'observation(s): " + nb_obs + " </p>";

    // Ajoute le slider dans le conteneur principal de la carte
    var mapContainer = document.getElementById("mapContainer") || document.getElementById("map").parentNode;
    mapContainer.appendChild(sliderContainer);

    mySlider = new Slider("#sliderControl", {
        value: [taxonYearMin, YEARMAX],
        min: taxonYearMin,
        max: YEARMAX,
        step: configuration.MAP.STEP,
    });

    document.getElementById("yearMax").innerHTML = "&nbsp;&nbsp;&nbsp;&nbsp;" + YEARMAX;
    document.getElementById("yearMin").innerHTML = taxonYearMin + "&nbsp;&nbsp;&nbsp;&nbsp";
}
