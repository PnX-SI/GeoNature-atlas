function generateMap() {

// load tiles
var osmTile = L.tileLayer(osmUrl, {attribution: osmAttribution}),
  ignTile = L.tileLayer(ignUrl, {attribution: ignAttribution}),
  orthoTile = L.tileLayer(orthoIGN, {attribution: ignAttribution});


//map initialization


  var map = L.map('map',{
    crs: L.CRS.EPSG3857,
    center: latLong,
    zoom: setZoom,
    layers: [osmTile, ignTile],
    fullscreenControl: true,

    });

// add a tile selector
var baseMap = {
"OSM": osmTile,
"IGN": ignTile,
"Satellite": orthoTile
}

L.control.layers(baseMap).addTo(map);

return map

}