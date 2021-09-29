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
      // map.fitBounds(territoryGeoJson.getBounds())
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
      $(container).attr("data-placement", "right");
      $(container).attr("data-toggle", "tooltip");
      $(container).attr("data-original-title", "Photos aérienne");

      container.onclick = function () {
        if (currentTileMap == "topo") {
          container.style.backgroundImage =
            "url(" +
            configuration.URL_APPLICATION +
            "/static/images/logo_topo_map.PNG)";
          $(container).attr("data-original-title", "Plan");
          map.removeLayer(firstMapTile);
          orthoMap.addTo(map);
          currentTileMap = "earth";
        } else {
          container.style.backgroundImage =
            "url(" +
            configuration.URL_APPLICATION +
            "/static/images/logo_earth_map.PNG)";
          $(container).attr("data-original-title", "Photos aérienne");
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
  fullScreenButton.attr("data-placement", "right");
  fullScreenButton.attr("data-toggle", "tooltip");
  fullScreenButton.attr("data-original-title", "Fullscreen");
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
  
  return map;
}

//****** Fonction fiche espècce ***********

// Popup Point
function onEachFeaturePoint(feature, layer) {
  popupContent =
    "<b>Date: </b>" +
    feature.properties.dateobs +
    "</br><b>Altitude: </b>" +
    feature.properties.altitude_retenue +
    "</br><b>Observateurs: </b>" +
    feature.properties.observateurs;

  // verifie si le champs effectif est rempli
  if (feature.properties.effectif_total != undefined) {
    layer.bindPopup(
      popupContent +
        "</br><b>Effectif: </b>" +
        feature.properties.effectif_total
    );
  } else {
    layer.bindPopup(popupContent);
  }
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

function generateLegendMaille() {
  legend.onAdd = function (map) {
    var div = L.DomUtil.create("div", "info legend"),
      grades = [0, 1, 2, 5, 10, 20, 50, 100],
      labels = ["<strong> Nombre <br> d'observations </strong> <br>"];

    // loop through our density intervals and generate a label with a colored square for each interval
    for (var i = 0; i < grades.length; i++) {
      labels.push(
        '<i style="background:' +
          getColor(grades[i] + 1) +
          '"></i> ' +
          grades[i] +
          (grades[i + 1] ? "&ndash;" + grades[i + 1] + "<br>" : "+")
      );
    }
    div.innerHTML = labels.join("<br>");

    return div;
  };

  legend.addTo(map);
}

// Geojson Maille
function generateGeojsonMaille(observations, yearMin, yearMax) {
  var i = 0;
  myGeoJson = { type: "FeatureCollection", features: [] };
  tabProperties = [];
  while (i < observations.length) {
    if (observations[i].annee >= yearMin && observations[i].annee <= yearMax) {
      geometry = observations[i].geojson_maille;
      idMaille = observations[i].id_maille;
      properties = {
        id_maille: idMaille,
        nb_observations: 1,
        last_observation: observations[i].annee,
        tabDateobs: [new Date(observations[i].dateobs)],
      };
      var j = i + 1;
      while (j < observations.length && observations[j].id_maille <= idMaille) {
        if (
          observations[j].annee >= yearMin &&
          observations[j].annee <= yearMax
        ) {
          properties.nb_observations += observations[j].nb_observations;
          properties.tabDateobs.push(new Date(observations[i].dateobs));
        }
        if (observations[j].annee >= properties.last_observation) {
          properties.last_observation = observations[j].annee;
        }
        j = j + 1;
      }
      myGeoJson.features.push({
        type: "Feature",
        properties: properties,
        geometry: geometry,
      });
      // on avance jusqu' à j
      i = j;
    } else {
      i = i + 1;
    }
  }

  return myGeoJson;
}

// Display Maille layer

function displayMailleLayerFicheEspece(observationsMaille) {
  myGeoJson = observationsMaille;
  currentLayer = L.geoJson(myGeoJson, {
    onEachFeature: onEachFeatureMaille,
    style: styleMaille,
  });
  currentLayer.addTo(map);
  // map.fitBounds(currentLayer.getBounds()); ZOOM FUNCTION ON SPECIES SHEET MAILLE OBSERVATIONS DISPLAY

  // ajout de la légende
  generateLegendMaille();
}

function generateGeojsonGridArea(observations) {
  var i = 0;
  myGeoJson = { type: "FeatureCollection", features: [] };
  tabProperties = [];
  while (i < observations.length) {
    geometry = observations[i].geojson_maille;
    idMaille = observations[i].id_maille;
    properties = {
      id_maille: idMaille,
      nb_observations: 1,
      last_observation: observations[i].annee,
    };
    var j = i + 1;
    while (j < observations.length && observations[j].id_maille <= idMaille) {
      properties.nb_observations += observations[j].nb_observations;

      if (observations[j].annee >= properties.last_observation) {
        properties.last_observation = observations[j].annee;
      }
      j = j + 1;
    }
    myGeoJson.features.push({
      type: "Feature",
      properties: properties,
      geometry: geometry,
    });
    // on avance jusqu' à j
    i = j;
  }

  return myGeoJson;
}

function displayGridLayerArea(observations) {
  myGeoJson = generateGeojsonGridArea(observations);
  currentLayer = L.geoJson(myGeoJson, {
    onEachFeature: onEachFeatureMaille,
    style: styleMaille,
  });
  currentLayer.addTo(map);
  map.fitBounds(currentLayer.getBounds());

  // ajout de la légende
  generateLegendMaille();
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

  if (typeof pointDisplayOptionsFicheEspece == "undefined") {
    pointDisplayOptionsFicheEspece = function (feature) {
      return {};
    };
  }
  currentLayer = L.geoJson(myGeoJson, {
    onEachFeature: onEachFeaturePoint,

    pointToLayer: function (feature, latlng) {
      return L.circleMarker(latlng, pointDisplayOptionsFicheEspece(feature));
    },
  });
  if (myGeoJson.features.length > configuration.LIMIT_CLUSTER_POINT) {
    newLayer = currentLayer;
    currentLayer = L.markerClusterGroup();
    currentLayer.addLayer(newLayer);
    map.addLayer(currentLayer);
  } else {
    currentLayer.addTo(map);
  }
  // map.fitBounds(currentLayer.getBounds()); ZOOM FUNCTION ON SPECIES SHEET MARKER LAYER OBSERVATIONS DISPLAY

  if (typeof divLegendeFicheEspece !== "undefined") {
    legend.onAdd = function (map) {
      var div = L.DomUtil.create("div", "info legend");
      div.innerHTML = divLegendeFicheEspece;
      return div;
    };
    legend.addTo(map);
  }
}

// ***************Fonction lastObservations: mapHome et mapCommune*****************

/* *** Point ****/

function onEachFeaturePointLastObs(feature, layer) {
  popupContent =
    "<b>Espèce: </b>" +
    feature.properties.taxon +
    "</br><b>Date: </b>" +
    feature.properties.dateobs +
    "</br><b>Altitude: </b>" +
    feature.properties.altitude_retenue;

  layer.bindPopup(
    popupContent +
      "</br> <a href='" +
      configuration.URL_APPLICATION +
      
      language +
      "/espece/" +
      feature.properties.cd_ref +
      "'> Fiche espèce </a>"
  );
}

function onEachFeaturePointCommune(feature, layer) {
  popupContent =
    "<b>Espèce: </b>" +
    feature.properties.taxon +
    "</br><b>Date: </b>" +
    feature.properties.dateobs +
    "</br><b>Altitude: </b>" +
    feature.properties.altitude_retenue +
    "</br><b> Observateurs(s): </b>" +
    feature.properties.observateurs;

  layer.bindPopup(
    popupContent +
      "</br> <a href='" +
      configuration.URL_APPLICATION +
      "/espece/" +
      feature.properties.cd_ref +
      "'> Fiche espèce </a>"
  );
}

function generateGeojsonPointLastObs(observationsPoint) {
  myGeoJson = { type: "FeatureCollection", features: [] };

  observationsPoint.forEach(function (obs) {
    properties = obs;
    properties["dateobsCompare"] = new Date(obs.dateobs);
    properties["dateobs"] = obs.dateobs;
    properties["nb_observations"] = 1;
    myGeoJson.features.push({
      type: "Feature",
      properties: properties,
      geometry: obs.geojson_point,
    });
  });
  return myGeoJson;
}

function displayMarkerLayerPointLastObs(observationsPoint) {
  myGeoJson = generateGeojsonPointLastObs(observationsPoint);
  if (typeof pointDisplayOptionsFicheCommuneHome == "undefined") {
    pointDisplayOptionsFicheCommuneHome = function (feature) {
      return {};
    };
  }

  currentLayer = L.geoJson(myGeoJson, {
    onEachFeature: onEachFeaturePointLastObs,
    pointToLayer: function (feature, latlng) {
      return L.circleMarker(
        latlng,
        pointDisplayOptionsFicheCommuneHome(feature)
      );
    },
  });

  map.addLayer(currentLayer);
  if (typeof divLegendeFicheCommuneHome !== "undefined") {
    legend.onAdd = function (map) {
      var div = L.DomUtil.create("div", "info legend");
      div.innerHTML = divLegendeFicheCommuneHome;
      return div;
    };
    legend.addTo(map);
  }
}

function displayMarkerLayerPointCommune(observationsPoint) {
  myGeoJson = generateGeojsonPointLastObs(observationsPoint);
  if (typeof pointDisplayOptionsFicheCommuneHome == "undefined") {
    pointDisplayOptionsFicheCommuneHome = function (feature) {
      return {};
    };
  }

  currentLayer = L.geoJson(myGeoJson, {
    onEachFeature: onEachFeaturePointCommune,
    pointToLayer: function (feature, latlng) {
      return L.circleMarker(
        latlng,
        pointDisplayOptionsFicheCommuneHome(feature)
      );
    },
  });

  map.addLayer(currentLayer);
  if (typeof divLegendeFicheCommuneHome !== "undefined") {
    legend.onAdd = function (map) {
      var div = L.DomUtil.create("div", "info legend");
      div.innerHTML = divLegendeFicheCommuneHome;
      return div;
    };
    legend.addTo(map);
  }
}

//  ** MAILLE ***

function compare(a, b) {
  if (a.id_maille < b.id_maille) return -1;
  if (a.id_maille > b.id_maille) return 1;
  return 0;
}

function printEspece(tabEspece, tabCdRef) {
  stringEspece = "";
  i = 0;
  while (i < tabEspece.length) {
    stringEspece +=
      "<li> <a href='" +
      configuration.URL_APPLICATION +
      "/espece/" +
      tabCdRef[i] +
      "'>" +
      tabEspece[i] +
      "</li>";

    i = i + 1;
  }
  return stringEspece;
}

function onEachFeatureMailleLastObs(feature, layer) {
  popupContent =
    "<b>Espèces observées dans la maille: </b> <ul> " +
    printEspece(feature.properties.list_taxon, feature.properties.list_cdref) +
    "</ul>";

  layer.bindPopup(popupContent);
}

function styleMailleLastObs() {
  return {
    opacity: 1,
    weight: 2,
    color: mailleLastObsBorderColor,
    fillOpacity: 0,
  };
}

function generateGeoJsonMailleLastObs(observations) {
  var i = 0;
  myGeoJson = { type: "FeatureCollection", features: [] };
  while (i < observations.length) {
    geometry = observations[i].geojson_maille;
    idMaille = observations[i].id_maille;
    properties = {
      id_maille: idMaille,
      list_taxon: [observations[i].taxon],
      list_cdref: [observations[i].cd_ref],
      list_id_observation: [observations[i].id_observation],
    };
    var j = i + 1;
    while (j < observations.length && observations[j].id_maille == idMaille) {
      properties.list_taxon.push(observations[j].taxon);
      properties.list_cdref.push(observations[j].cd_ref);
      properties.list_id_observation.push(observations[j].id_observation);
      j = j + 1;
    }
    myGeoJson.features.push({
      type: "Feature",
      properties: properties,
      geometry: geometry,
    });
    // on avance jusqu' à j
    i = j;
  }

  return myGeoJson;
}

function find_id_observation_in_array(tab_id, id_observation) {
  i = 0;
  while (i < tab_id.length && tab_id[i] != id_observation) {
    i = i + 1;
  }
  return i != tab_id.length;
}

function displayMailleLayerLastObs(observations) {
  var geojsonMaille = generateGeoJsonMailleLastObs(observations);
  currentLayer = L.geoJson(geojsonMaille, {
    onEachFeature: onEachFeatureMailleLastObs,
    style: styleMailleLastObs,
  });
  currentLayer.addTo(map);
  //map.fitBounds(currentLayer.getBounds()); ZOOM ON LAST OBS MAILLE
}

// Legend

var legend;
var legendActiv = false;
var div;

function generateLegende(htmlLegend) {
  // Legende

  var legendControl = L.Control.extend({
    options: {
      position: "topleft",
      //control position - allowed: 'topleft', 'topright', 'bottomleft', 'bottomright'
    },

    onAdd: function (map) {
      var container = L.DomUtil.create(
        "div",
        "leaflet-bar leaflet-control leaflet-control-custom"
      );

      container.style.backgroundColor = "white";
      container.style.width = "25px";
      container.style.height = "25px";
      container.style.border = "solid white 1px";
      container.style.cursor = "pointer";
      $(container).html(
        "<img src='" +
          configuration.URL_APPLICATION +
          "/static/images/info.png' alt='Légende'>"
      );
      $(container).attr("data-placement", "right");
      $(container).attr("data-toggle", "tooltip");
      $(container).attr("data-original-title", "Legend");

      container.onclick = function () {
        if (legendActiv == false) {
          legend = L.control({ position: "topleft" });

          legend.onAdd = function (map) {
            (div = L.DomUtil.create("div", "info legend")),
              $(div).addClass("generalLegend");

            div.innerHTML = htmlLegend;

            return div;
          };
          legend.addTo(map);
          legendActiv = true;
        } else {
          legend.remove(map);
          legendActiv = false;
        }
      };
      return container;
    },
  });

  map.addControl(new legendControl());
}

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
