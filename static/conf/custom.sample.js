// ***** Map configuration ****

latLong = [44.7952, 6.2287];
setZoom = 10;
ignApiKey = 'maCleIgn';

var osmUrl = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
var osmAttribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors';

var ignUrl='http://gpp3-wxs.ign.fr/'+ignApiKey+'/wmts?LAYER=GEOGRAPHICALGRIDSYSTEMS.MAPS.SCAN-EXPRESS.STANDARD&EXCEPTIONS=text/xml&FORMAT=image/jpeg&SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetTile&STYLE=normal&TILEMATRIXSET=PM&&TILEMATRIX={z}&TILECOL={x}&TILEROW={y}'
var ignAttribution = '&copy; <a href="http://www.ign.fr/">IGN</a>'


//**********



// ************* MAP OPTIONS *********************

//       **********MARKERS************

//				***SLIDER***


$YEARMIN = 1973;
$YEARMAX = currentDate.getFullYear();
$STEP = 1;

$LEGEND = getLegend($YEARMIN, $YEARMAX);
$STRINGLEGEND = getStringLegend($LEGEND);



