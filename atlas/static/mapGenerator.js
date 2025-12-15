// eslint-disable-next-line no-unused-vars
const areaBorderColor = String(
    getComputedStyle(document.documentElement).getPropertyValue(
        "--map-area-border-color",
    ),
);

// Feature group de chaque élément de floutage (M1, M5 etc...)
const observationsFeatureGroup = {};

const control = L.control.layers(null, null, {
    collapsed: false,
});

function clearObservationsFeatureGroup() {
    control._layers.forEach((elem) => {
        if (elem.name.includes("defaultOverlay")) {
            map.removeLayer(elem.layer);
            control.removeLayer(elem.layer);
        }
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
            <a href='${configuration.URL_APPLICATION}${language}/espece/${feature.properties.cd_ref}'> Fiche espèce </a>
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

    if (
        !configuration.AFFICHAGE_MAILLE &&
        configuration.COUCHES_SIG.length === 0
    ) {
        document.querySelector("#control-tab").style.display = "none";
        document.querySelector("#control-tab-content").style.display = "none";
    }

    const sheetName = document.querySelector("body").getAttribute("page-name");

    let isMaille = false;
    if (
        (sheetName === "home" && configuration.AFFICHAGE_TERRITOIRE_OBS) ||
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

    // Ajoute d'abord les defaultOverlay
    defaultLabels.forEach((label) => overlayDiv.appendChild(label));

    // Ajoute le séparateur si les deux groupes existent
    if (defaultLabels.length > 0 && otherLabels.length > 0) {
        const separator = document.createElement("div");
        separator.className = "leaflet-control-layers-separator";
        overlayDiv.appendChild(separator);
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

// get the different type code (COM, M1, M10) and store them in current_type_code arrray
// use to create different feature group and layer control
function getAreasTypeCode(geojson) {
    current_type_code = [];
    if (current_type_code.length === 0) {
        Object.values(geojson.features).forEach((elem) => {
            if (!current_type_code.includes(elem.properties.type_code)) {
                current_type_code.push(elem.properties.type_code);
            }
        });
    }
    return current_type_code;
}

/**
 * Create a layer control for each type of zoning (M1, M5 etc..) and associate it a feature group
 * Add the features group to map
 */
function createLayersSelector(geojson) {
    const current_type_code = getAreasTypeCode(geojson);

    current_type_code.forEach((elem) => {
        const featureGroup = L.featureGroup();
        observationsFeatureGroup[elem] = featureGroup;
        if (configuration.AFFICHAGE_COUCHES_MAP[elem].selected) {
            map.addLayer(featureGroup);
        }
        addOverlayInControl(
            featureGroup,
            configuration.AFFICHAGE_COUCHES_MAP[elem].label,
            true,
        );
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
    if (!configuration.DEFAULT_LEGEND_DISPLAY && control?.getContainer()) {
        control.collapse();
    }

    // control.addOverlay()

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
    observationsFeatureGroup[feature.properties.type_code].addLayer(layer);

    if (configuration.AFFICHAGE_MAILLE) {
        zoomMaille(layer);
    }

    var selected = false;
    layer.setStyle(
        styleMailleAtlas(
            feature.properties.nb_observations,
            feature.properties.type_code,
        ),
    );
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
            this.setStyle(
                styleMailleAtlas(
                    feature.properties.nb_observations,
                    feature.properties.type_code,
                ),
            );
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
    // on vérifie si le slider a été touché
    // sinon on met null a yearmin et yearmax pour ne pas filtrer par année a la génération du GeoJson

    // yearMin = years[0] === taxonYearMin ? null : years[0];
    // yearMax = years[1] === YEARMAX ? null : years[1];
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
    if (myGeoJson.features.length > configuration.LIMIT_CLUSTER_POINT) {
        legendColorObs.querySelectorAll("div").forEach((elem) => elem.remove());
        legendColorObs.appendChild(generateObservationsLegend(false));

        if (configuration.COUCHES_SIG.length === 0) {
            // In point only map, hide control tab if no COUCHES_SIG configured
            const controltab = document.querySelector("#control-tab");
            const controltabContent = document.querySelector(
                "#control-tab-content",
            );
            const legendtab = document.querySelector("#legend-tab");
            const legendtabContent = document.querySelector(
                "#legend-tab-content",
            );
            controltab.style.display = "none";
            document.querySelector("#control-tab-content").style.display =
                "none";

            // switch to legend tab
            legendtab.classList.add("active");
            legendtabContent.classList.add("active");
            legendtabContent.classList.add("show");
            controltab.classList.remove("active");
            controltabContent.classList.remove("active");
            controltabContent.classList.remove("show");
        }
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
        <img class="me-2 has-media-${taxon.has_media}" src="${taxon.media}" alt="">
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
    let url = `/api/taxonListJson/area/${idMaille}?page=-1`;
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
    observationsFeatureGroup[feature.properties.type_code].addLayer(layer);

    var selected = false;
    layer.setStyle(
        styleMailleAtlas(
            feature.properties.nb_observations,
            feature.properties.type_code,
        ),
    );
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
            this.setStyle(
                styleMailleAtlas(
                    feature.properties.nb_observations,
                    feature.properties.type_code,
                ),
            );
        }
    });
}

function styleMailleAtlas(nb, type_code) {
    const chartMainColor = getComputedStyle(
        document.documentElement,
    ).getPropertyValue("--main-color");

    let fillOpacity = 0.5;
    if (
        configuration.AFFICHAGE_COUCHES_MAP[type_code] &&
        configuration.AFFICHAGE_COUCHES_MAP[type_code].fillOpacity
    ) {
        fillOpacity =
            configuration.AFFICHAGE_COUCHES_MAP[type_code].fillOpacity;
    }
    let strokeOpacity = 0;
    if (
        configuration.AFFICHAGE_COUCHES_MAP[type_code] &&
        configuration.AFFICHAGE_COUCHES_MAP[type_code].strokeOpacity
    ) {
        strokeOpacity =
            configuration.AFFICHAGE_COUCHES_MAP[type_code].strokeOpacity;
    }
    let weight = 1;
    if (
        configuration.AFFICHAGE_COUCHES_MAP[type_code] &&
        configuration.AFFICHAGE_COUCHES_MAP[type_code].weight
    ) {
        weight = configuration.AFFICHAGE_COUCHES_MAP[type_code].weight;
    }

    let strokeColor = chartMainColor;
    if (
        configuration.AFFICHAGE_COUCHES_MAP[type_code] &&
        configuration.AFFICHAGE_COUCHES_MAP[type_code].strokeColor
    ) {
        strokeColor =
            configuration.AFFICHAGE_COUCHES_MAP[type_code].strokeColor;
    }

    return {
        opacity: strokeOpacity,
        weight: weight,
        fillColor: getColor(nb),
        color: strokeColor,
        fillOpacity: fillOpacity,
    };
}

function styleMailleClickedOrHover(layer) {
    var mailleCode = layer.feature.properties.type_code;
    const chartMainColor = getComputedStyle(
        document.documentElement,
    ).getPropertyValue("--main-color");

    let fillOpacityHover = 0.85;
    if (
        configuration.AFFICHAGE_COUCHES_MAP[mailleCode] &&
        configuration.AFFICHAGE_COUCHES_MAP[mailleCode].fillOpacityHover
    ) {
        fillOpacityHover =
            configuration.AFFICHAGE_COUCHES_MAP[mailleCode].fillOpacityHover;
    }
    let weightHover = 2;
    if (
        configuration.AFFICHAGE_COUCHES_MAP[mailleCode] &&
        configuration.AFFICHAGE_COUCHES_MAP[mailleCode].weightHover
    ) {
        weightHover =
            configuration.AFFICHAGE_COUCHES_MAP[mailleCode].weightHover;
    }
    let strokeColorHover = chartMainColor;
    if (
        configuration.AFFICHAGE_COUCHES_MAP[mailleCode] &&
        configuration.AFFICHAGE_COUCHES_MAP[mailleCode].strokeColorHover
    ) {
        strokeColorHover =
            configuration.AFFICHAGE_COUCHES_MAP[mailleCode].strokeColorHover;
    }

    var options = layer.options;
    return {
        ...options,
        opacity: 1,
        weight: weightHover,
        fillOpacity: fillOpacityHover,
        color: strokeColorHover,
    };
}

function resetStyleMailles() {
    // set style for all cells
    map.eachLayer(function (layer) {
        if (layer.feature && layer.feature.properties.id_type) {
            layer.setStyle(
                styleMailleAtlas(
                    layer.feature.properties.taxons.length,
                    feature.properties.type_code,
                ),
            );
        }
    });
}

// eslint-disable-next-line no-unused-vars
var mySlider;

// eslint-disable-next-line no-unused-vars
function generateSliderOnMap() {
    var SliderControl = L.Control.extend({
        options: {
            position: "bottomleft",
            //control position - allowed: 'topleft', 'topright', 'bottomleft', 'bottomright'
        },

        onAdd: function () {
            var sliderContainer = L.DomUtil.create(
                "div",
                "leaflet-bar leaflet-control leaflet-slider-control",
            );

            sliderContainer.style.backgroundColor = "white";
            sliderContainer.style.width = "300px";
            sliderContainer.style.height = "70px";
            sliderContainer.style.border = "solid white 1px";
            sliderContainer.style.cursor = "pointer";
            $(sliderContainer).css("margin-bottom", "-300px");
            $(sliderContainer).css("margin-left", "200px");
            $(sliderContainer).css("text-align", "center");
            $(sliderContainer).append(
                "<p> <span id='yearMin'> </span> <input id='sliderControl' type='text'/> <span id='yearMax'>  </span>  </p>" +
                    "<p id='nbObs'> Nombre d'observation(s): " +
                    nb_obs +
                    " </p>",
            );
            L.DomEvent.disableClickPropagation(sliderContainer);
            return sliderContainer;
        },
    });

    map.addControl(new SliderControl());

    mySlider = new Slider("#sliderControl", {
        value: [taxonYearMin, YEARMAX],
        min: taxonYearMin,
        max: YEARMAX,
        step: configuration.MAP.STEP,
    });

    $("#yearMax").html("&nbsp;&nbsp;&nbsp;&nbsp;" + YEARMAX);
    $("#yearMin").html(taxonYearMin + "&nbsp;&nbsp;&nbsp;&nbsp");
}
