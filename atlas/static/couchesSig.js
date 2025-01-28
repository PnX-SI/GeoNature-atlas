// Gestionnaire de couches SIG additionnelles

function createLeafletLayer(coucheSigInfo) {
  return L.tileLayer.wms(
    coucheSigInfo.url,
    coucheSigInfo.options
  );
}

function createEsriDynamicLayer(coucheSigInfo) {
  return L.esri.dynamicMapLayer(
    {
      url: coucheSigInfo.url,
      layers: []
    }
  );
}

function createLayer(coucheSigInfo) {
  if (coucheSigInfo.type === "wms") {
    return createLeafletLayer(coucheSigInfo);
  } else if (coucheSigInfo.type === "arcgisMapService") {
    return createEsriDynamicLayer(coucheSigInfo);
  }
}

function addLayerControlToMap(map) {
  var layer_types_map = {
    wms: "leaflet",
    arcgisMapService: "esriDynamic"
  };
  var sigLayers = [];
  couchesSigInfo.forEach(
    (coucheSigInfo) => {
      sigLayers.push(
        {
          layer: createLayer(coucheSigInfo),
          type: layer_types_map[coucheSigInfo.type],
          name: coucheSigInfo.name
        }
      );
    }
  );
  var layerTreeCtrl = new L.Control.LayerTreeControl(sigLayers, {
    position: 'topright',
    collapsed: true
  });

  map.addControl(layerTreeCtrl);
}
