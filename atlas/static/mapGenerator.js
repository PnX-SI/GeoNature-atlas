const mailleBorderColor = String(
    getComputedStyle(document.documentElement).getPropertyValue(
        "--map-maille-border-color"
    )
);
const mailleLastObsBorderColor = String(
    getComputedStyle(document.documentElement).getPropertyValue(
        "--map-maille-lastobs-border-color"
    )
);
const territoryBorderColor = String(
    getComputedStyle(document.documentElement).getPropertyValue(
        "--map-territory-border-color"
    )
);
const areaBorderColor = String(
    getComputedStyle(document.documentElement).getPropertyValue(
        "--map-area-border-color"
    )
);

// Feature group de chaque élément de floutage (M1, M5 etc...)
let overlays = {}
let mailleSelectorrGenerated = false;
let current_type_code = []
const control = L.control.layers(null, null, {
    collapsed: false
})

function clearOverlays(removeAllOverlays = false){
    // remove all Layer from leaflet overlays (featureGroup)
    control._layers.forEach(elem => {
        if (elem.name.includes('defaultOverlay') || removeAllOverlays) {
            map.removeLayer(elem.layer);
            control.removeLayer(elem.layer);
            clearOverlays(removeAllOverlays)
        }
    })
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
            `

    // verifie si le champs effectif est rempli
    if (feature.properties.effectif_total != undefined) {
        popupContent = `${popupContent} </br><b>Effectif: </b>${feature.properties.effectif_total}`
    }

    // S'il faut lier à une fiche espèce
    if (feature.properties.taxon) {
        popupContent = `<b>Espèce: </b> ${feature.properties.taxon} </br>
              ${popupContent}
              </br>
              `
    }
    return popupContent
}

function addExternalOverlays() {
    const sheetName = document.querySelector("body").getAttribute("page-name")

    for (const elem of configuration.COUCHES_SIG) {
        if (elem?.type === "wms" && (elem?.pages?.includes(sheetName) || !elem?.pages)) {
            overlays[elem.name] = L.tileLayer.wms(elem.url, elem.options);
            overlays[elem.name].addEventListener('add', function(event) {
                // Add legend item into good place
                legendUrl = `${event.sourceTarget._url}?request=GetLegendGraphic&version=${elem.wms_version}&format=image/png&layer=${event.sourceTarget.wmsParams.layers}`;
                let div = L.DomUtil.create('div', 'legend-item');
                div.setAttribute('data-name', elem.name);
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
                document.getElementById("legend-other-info").appendChild(div)
            })

            overlays[elem.name].addEventListener('remove', event => {
                // Remove legend item
                const item = document.querySelector(`.legend-item[data-name='${elem.name}']`);
                if (item) {
                    document.getElementById("legend-other-info").removeChild(item)
                }
            })
            createOverlayNameHtml(elem.name)
        } else if (elem?.type === "geojson" && (elem?.pages?.includes(sheetName) || !elem?.pages)) {
            fetch(elem.url).then(response => response.json()).then(data =>
            {
                overlays[elem.name] = L.geoJSON(data, {
                    style: function (feature) {
                        return elem.style || {};
                    }
                })
                createOverlayNameHtml(elem.name)
            })
        }
    }
    return overlays;
}

function createTabControl() {
    let content = control.getContainer().querySelector(".leaflet-control-layers-overlays");
    var div = L.DomUtil.create('div', 'leaflet-control-tabs');
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
                <div id="legend-area" class="p-2 bg-light border">
                    ${htmlLegend}
                </div>
            </div>
        </div>
        <div class="tab-pane fade" id="control-tab-content" role="tabpanel" aria-labelledby="control-tab">      
        </div>
    </div>
</div>
`;
    content.parentNode.insertBefore(div, content);
    div.querySelector("#control-tab-content").appendChild(content);

    if (!configuration.AFFICHAGE_MAILLE && configuration.COUCHES_SIG.length === 0) {
        document.querySelector("#control-tab").style.display = "none";
        document.querySelector("#control-tab-content").style.display = "none";
    }

    const sheetName = document.querySelector("body").getAttribute("page-name")

    let isMaille = false
    if ((sheetName === "home" && configuration.AFFICHAGE_TERRITOIRE_OBS) || configuration.AFFICHAGE_MAILLE) {
        isMaille = true;
    }
    // Initialization of legend
    document.querySelector("#legend-color-obs").appendChild(generateLegend(isMaille));
}

function createOverlayNameHtml(label, isDefaultOverlay = false, lastElement = false) {
    let className = '';
    let separator = '';
    if (isDefaultOverlay) {
        className = 'defaultOverlay';
        if (lastElement) {
            separator = `<div class="leaflet-control-layers-separator"></div>`;
        }
    }
    control.addOverlay(overlays[label], `
    <div>
        <div class="${className}">${label}</div>
        ${separator}
    </div>
    `);
    if (!configuration.DEFAULT_LEGEND_DISPLAY && control?.getContainer()) {
        control.collapse();
    }
}

/**
 * Create a layer control for each type of zoning (M1, M5 etc..) and associate it a feature group
 */
function createLayersSelector(selectedAllLayer = false) {
    const defaultActiveLayer = []
    current_type_code.forEach((elem, index) => {
        const isLastElement = index === current_type_code.length - 1;
        if (configuration.AFFICHAGE_COUCHES_MAP[elem]) {
            if (configuration.AFFICHAGE_COUCHES_MAP[elem].selected || selectedAllLayer) {
                defaultActiveLayer.push(configuration.AFFICHAGE_COUCHES_MAP[elem].label)
            }
            overlays[configuration.AFFICHAGE_COUCHES_MAP[elem].label] = L.featureGroup()
            createOverlayNameHtml(configuration.AFFICHAGE_COUCHES_MAP[elem].label,
                true,
                isLastElement
            )
        } else {
            defaultActiveLayer.push(elem)
            overlays[elem] = L.featureGroup()
            createOverlayNameHtml(elem.name, true, isLastElement)
        }
    });
    addExternalOverlays()

    control.addTo(map);
    if (!configuration.DEFAULT_LEGEND_DISPLAY && control?.getContainer()) {
        control.collapse();
    }
    createTabControl()
    // Activate layers
    Object.entries(overlays).forEach(elem => {
        if (defaultActiveLayer.includes(elem[0])) {
            map.addLayer(elem[1])
        }
    });
}

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
        zoomControl: !(zoomHomeButton),
    });


    // Keep Layers in the same order as specified by the
    // overlays variable so Departement under Commune
    // under 10km2 under 1km2
    map.on("overlayadd", function (e) {
        Object.values(overlays).forEach((e) => e.bringToFront());
    });

    if (zoomHomeButton) {
        var zoomHome = L.Control.zoomHome();
        zoomHome.addTo(map);
    }



    // Style of territory on map
    // Uses snogylop to generate a mask
    territoryStyle = {
        fill: false,
        color: territoryBorderColor,
        weight: configuration.MAP.BORDERS_WEIGHT,
    };

    // Add limits of the territory to the map
    $(document).ready(function () {
        $.getJSON(url_limit_territory, function (json) {
            const territoryGeoJson = L.geoJson(json, {
                style: territoryStyle,
            });
            territoryGeoJson.addTo(map);
        });
    });

    // 'Google-like' baseLayer controler

    var LayerControl = L.Control.extend({
        options: {
            position: "bottomleft",
        },

        onAdd: function (map) {
            currentTileMap = "topo";
            var container = L.DomUtil.create(
                "div",
                "leaflet-bar leaflet-control leaflet-control-custom"
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
                if (currentTileMap == "topo") {
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
        L.control.scale(
            {
                imperial: false,
                position: 'bottomright'
            }
        ).addTo(map);
    }

    if (configuration.SEARCH_NOMINATIM) {
        addGeocoderPluggin(map);
    }

    return map;
}

function observersTxt(feature) {
    return configuration.DISPLAY_OBSERVERS
        ? `</br><b> Observateurs(s): </b> ${feature.properties.observateurs}`
        : ""
}

//****** Fonction fiche espècce ***********

// Popup Point
function onEachFeaturePointSpecies(feature, layer) {
    popupContent = generateObservationPopup(feature, false);
    layer.bindPopup(popupContent);
}

// popup Maille
function onEachFeatureMaille(feature, layer) {
    popupContent =
        "<b>Nombre d'observation(s): </b>" +
        feature.properties.nb_observations +
        "</br> <b> Dernière observation: </b>" +
        feature.properties.last_observation +
        " ";
    layer.bindPopup(popupContent);

    // associate a feature to the correct feature group
    addInFeatureGroup(feature, layer);

    if (configuration.AFFICHAGE_MAILLE) {
        zoomMaille(layer);
    }

    var selected = false;
    layer.setStyle(styleMailleAtlas(feature.properties.nb_observations, feature.properties.type_code))
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
            this.setStyle(styleMailleAtlas(feature.properties.nb_observations, feature.properties.type_code));
        }
    });



}

function zoomMaille(layer) {
    layer.on("click", function (e) {
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

function styleMaille(feature) {
    return {
        fillColor: getColor(feature.properties.nb_observations),
        weight: 1,
        color: mailleBorderColor,
        fillOpacity: 0.8,
    };
}


function generateLegend(isMaille = false) {
    if (!configuration.AFFICHAGE_MAILLE && !isMaille) {
        return generalLegendPoint()
    }
    // check if contour already exists
    if (L.DomUtil.get("contour-legend")) {
        return
    }
    var div = L.DomUtil.create("div", "info legend"),
        grades = [0, 1, 2, 5, 10, 20, 50, 100],
        labels = ["<div  style='padding-bottom: 1rem'><strong> Nombre d'observations </strong></div>"];

    // loop through our density intervals and generate a label with a colored square for each interval
    grades.forEach((grade, i) => {
        const  next = grades[i + 1]
        // Ajout d'un plus si c'est la dernière valeur
        const grade_n1 = next ? ` &ndash; ${next} <br>` : "+"
        // Si les 2 valeurs sont identiques, alors on en affiche qu'une
        const label = next === (grade+1) ? `${next}  <br>` :  `${grade+1}${grade_n1}`
        labels.push(
            `<div class="d-flex pb-1 align-items-center">
                <div class="me-2" style="background: ${getColor(grade + 1)}; width: 15px; height: 15px;"></div>
                <div class="" >${label}</div>
            </div>
                `
        );
    })

    // Add id to get it above
    div.id = "contour-legend"
    div.innerHTML = labels.join("");

    return div;
}

function generalLegendPoint() {
    if (typeof divLegendeFicheEspece !== "undefined") {
        var div = L.DomUtil.create("div", "info legend");
        div.innerHTML = divLegendeFicheEspece;
        return div;
    } else {

    }
}

// Display Maille layer

function displayMailleLayerFicheEspece(observationsMaille) {
    myGeoJson = observationsMaille;
    // Get all different type code

    current_type_code = []
    if (current_type_code.length === 0) {
        Object.values(myGeoJson.features).forEach(elem => {
            if (!current_type_code.includes(elem.properties.type_code)) {
                current_type_code.push(elem.properties.type_code)
            }
        })
    }

    clearOverlays(true)
    createLayersSelector(true)

    currentLayer = L.geoJson(myGeoJson, {
        onEachFeature: onEachFeatureMaille,
    });
    currentLayer.addTo(map);
    // map.fitBounds(currentLayer.getBounds()); ZOOM FUNCTION ON SPECIES SHEET MAILLE OBSERVATIONS DISPLAY

    // legend update
    const legendColorObs = document.querySelector("#legend-color-obs");
    legendColorObs.querySelectorAll("div").forEach(elem => elem.remove())
    legendColorObs.appendChild(generateLegend(true));

    // Display labels of maille overlays
    document.querySelectorAll(".defaultOverlay").forEach(elem => {
        elem.closest("label").style.display = 'block';
    })

}

// GeoJson Point
function generateGeojsonPointFicheEspece(
    geojsonPoint,
    yearMin,
    yearMax,
    sliderTouch
) {
    var filteredGeoJsonPoint = Object.assign({}, geojsonPoint);
    // si on a touché le slider on filtre sinon on retourne directement le geojson
    if (yearMin && yearMax && sliderTouch) {
        filteredGeoJsonPoint.features = geojsonPoint.features.filter(function (
            obs
        ) {
            return obs.properties.year >= yearMin && obs.properties.year <= yearMax;
        });
        return filteredGeoJsonPoint;
    } else {
        return filteredGeoJsonPoint;
    }
}

// Display marker Layer (cluster or not)
function displayMarkerLayerFicheEspece(
    observationsPoint,
    yearMin,
    yearMax,
    sliderTouch
) {
    // on vérifie si le slider a été touché
    // sinon on met null a yearmin et yearmax pour ne pas filtrer par année a la génération du GeoJson

    // yearMin = years[0] == taxonYearMin ? null : years[0];
    // yearMax = years[1] == YEARMAX ? null : years[1];
    myGeoJson = generateGeojsonPointFicheEspece(
        observationsPoint,
        yearMin,
        yearMax,
        sliderTouch
    );


    if (typeof customizeMarkerStyle == "undefined") {
        customizeMarkerStyle = function (feature) {
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
        legendColorObs.querySelectorAll("div").forEach(elem => elem.remove())
        legendColorObs.appendChild(generateLegend(false));

        if (configuration.COUCHES_SIG.length === 0) {
            // In point only map, hide control tab if no COUCHES_SIG configured
            const controltab = document.querySelector("#control-tab")
            const controltabContent = document.querySelector("#control-tab-content")
            const legendtab = document.querySelector("#legend-tab")
            const legendtabContent = document.querySelector("#legend-tab-content")
            controltab.style.display = "none";
            document.querySelector("#control-tab-content").style.display = "none";

            // switch to legend tab
            legendtab.classList.add("active");
            legendtabContent.classList.add("active");
            legendtabContent.classList.add("show");
            controltab.classList.remove("active");
            controltabContent.classList.remove("active");
            controltabContent.classList.remove("show");
        }
        // Not display labels of maille overlays
        document.querySelectorAll(".defaultOverlay").forEach(elem => {
            elem.closest("label").style.display = 'none';
        })


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

function onEachFeaturePointArea(feature, layer) {
    popupContent = generateObservationPopup(feature, true);
    layer.bindPopup(popupContent);
}


function getCustomizeMarkerStyle() {
    if (typeof customizeMarkerStyle == "undefined") {
        customizeMarkerStyle = function (feature) {
            return {};
        };
    }
    else {
        return customizeMarkerStyle
    }
}

function displayGeoJsonPoint(geojson) {
    currentLayer = L.geoJson(geojson, {
        onEachFeature: onEachFeaturePoint,
        pointToLayer: function (feature, latlng) {
            return L.circleMarker(
                latlng,
                getCustomizeMarkerStyle(feature)
            );
        },
    });
    map.addLayer(currentLayer);

    clearOverlays(true)
    addExternalOverlays()

    control.addTo(map);
    createTabControl(control)
}

function refreshStyle(layers) {
    // fonction to refresh style of a list of layers from the customizeMarkerStyle (set green for sensibility and blue for non sensible obs)
    layers.forEach(layer => {
        layer.setStyle(getCustomizeMarkerStyle(layer.feature))
    });
}



//  ** MAILLE ***

function compare(a, b) {
    if (a.id_maille < b.id_maille) return -1;
    if (a.id_maille > b.id_maille) return 1;
    return 0;
}

function buildSpeciesEntries(taxons) {
    rows = [];
    taxons.forEach(taxon => {
        href = `${configuration.URL_APPLICATION}/espece/${taxon.cdRef}`
        rows.push(`<li><a href="${href}">${taxon.name}</li>`);
    });
    return rows.join('\n');
}

function createPopUp(feature, layer) {
    const title = `${feature.properties.taxons.length} espèces observées dans la maille &nbsp;: `;
    const rows = buildSpeciesEntries(feature.properties.taxons);
    const popupContent = `<b>${title}</b><ul>${rows}</ul>`;

    layer.bindPopup(popupContent, { maxHeight: 300 });
}

function onEachFeatureMailleLastObs(feature, layer) {
    createPopUp(feature, layer);
    addInFeatureGroup(feature, layer);

    zoomMaille(layer);

    var selected = false;
    layer.setStyle(styleMailleAtlas(feature.properties.nb_observations, feature.properties.type_code))
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
            this.setStyle(styleMailleAtlas(feature.properties.nb_observations, feature.properties.type_code));
        }
    });
}

function styleMailleAtlas(nb, type_code) {
    const chartMainColor = getComputedStyle(document.documentElement).getPropertyValue('--main-color');

    let fillOpacity = 0.5;
    if (configuration.AFFICHAGE_COUCHES_MAP[type_code] && configuration.AFFICHAGE_COUCHES_MAP[type_code].fillOpacity) {
        fillOpacity = configuration.AFFICHAGE_COUCHES_MAP[type_code].fillOpacity;
    }
    let strokeOpacity = 0;
    if (configuration.AFFICHAGE_COUCHES_MAP[type_code] && configuration.AFFICHAGE_COUCHES_MAP[type_code].strokeOpacity) {
        strokeOpacity = configuration.AFFICHAGE_COUCHES_MAP[type_code].strokeOpacity;
    }
    let weight = 1;
    if (configuration.AFFICHAGE_COUCHES_MAP[type_code] && configuration.AFFICHAGE_COUCHES_MAP[type_code].weight) {
        weight = configuration.AFFICHAGE_COUCHES_MAP[type_code].weight;
    }

    let strokeColor = chartMainColor;
    if (configuration.AFFICHAGE_COUCHES_MAP[type_code] && configuration.AFFICHAGE_COUCHES_MAP[type_code].strokeColor) {
        strokeColor = configuration.AFFICHAGE_COUCHES_MAP[type_code].strokeColor;
    }

    return {
        opacity: strokeOpacity,
        weight: weight,
        fillColor: getColor(nb),
        color: strokeColor,
        fillOpacity: fillOpacity
    };
}

function styleMailleClickedOrHover(layer) {
    var mailleCode = layer.feature.properties.type_code;
    const chartMainColor = getComputedStyle(document.documentElement).getPropertyValue('--main-color');

    let fillOpacityHover = 0.85;
    if (configuration.AFFICHAGE_COUCHES_MAP[mailleCode] && configuration.AFFICHAGE_COUCHES_MAP[mailleCode].fillOpacityHover) {
        fillOpacityHover = configuration.AFFICHAGE_COUCHES_MAP[mailleCode].fillOpacityHover
    }
    let weightHover = 2
    if (configuration.AFFICHAGE_COUCHES_MAP[mailleCode] && configuration.AFFICHAGE_COUCHES_MAP[mailleCode].weightHover) {
        weightHover = configuration.AFFICHAGE_COUCHES_MAP[mailleCode].weightHover
    }
    let strokeColorHover = chartMainColor;
    if (configuration.AFFICHAGE_COUCHES_MAP[mailleCode] && configuration.AFFICHAGE_COUCHES_MAP[mailleCode].strokeColorHover) {
        strokeColorHover = configuration.AFFICHAGE_COUCHES_MAP[mailleCode].strokeColorHover;
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
            layer.setStyle(styleMailleAtlas(layer.feature.properties.taxons.length, feature.properties.type_code));
        }
    });
}

/**
 * Associate a feature to the correct feature group (M1, M5 ...)
 */
function addInFeatureGroup(feature, layer) {
    mailleTypeCode = feature.properties.type_code;

    if (Object.keys(overlays).length !== 0) {
        if (configuration.AFFICHAGE_COUCHES_MAP[mailleTypeCode] && configuration.AFFICHAGE_COUCHES_MAP[mailleTypeCode].label) {
            overlays[configuration.AFFICHAGE_COUCHES_MAP[mailleTypeCode].label].addLayer(layer);
        } else {
            overlays[mailleTypeCode].addLayer(layer);
        }
    }
}


function displayGeojsonMailles(observationsMaille) {

    // Get all different type code
    observationsMaille.features.forEach(elem => {
        if (!current_type_code.includes(elem.properties.type_code)) {
            current_type_code.push(elem.properties.type_code)
        }
    })
    createLayersSelector()
    currentLayer = L.geoJson(observationsMaille, {
        onEachFeature: onEachFeatureMailleLastObs,
    });
}

// Legend

var div;
var mySlider;

function generateSliderOnMap() {
    var SliderControl = L.Control.extend({
        options: {
            position: "bottomleft",
            //control position - allowed: 'topleft', 'topright', 'bottomleft', 'bottomright'
        },

        onAdd: function (map) {
            var sliderContainer = L.DomUtil.create(
                "div",
                "leaflet-bar leaflet-control leaflet-slider-control"
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
                " </p>"
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


function find_id_observation_in_array(tab_id, id_observation) {
    i = 0;
    while (i < tab_id.length && tab_id[i] != id_observation) {
        i = i + 1;
    }
    return i != tab_id.length;
}
