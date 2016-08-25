// ***** Map configuration ****

// Coordonnées du centre de la carte
latLong = [mylatitude, mylongitude];
// Zoom d'affichage initial de la carte
setZoom = 'monzoom';
// Clé IGN
ignApiKey = 'myIGN-key';


// Carte qui est chargé initialement
FIRST_MAP = { 
			"url" : 'http://gpp3-wxs.ign.fr/'+ignApiKey+'/wmts?LAYER=GEOGRAPHICALGRIDSYSTEMS.MAPS.SCAN-EXPRESS.STANDARD&EXCEPTIONS=text/xml&FORMAT=image/jpeg&SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetTile&STYLE=normal&TILEMATRIXSET=PM&&TILEMATRIX={z}&TILECOL={x}&TILEROW={y}',
			"attribution" : '&copy; <a href="http://www.ign.fr/">IGN</a>',
			"tileName" : 'IGN'
		}


// Liste des cartes additionels que l'utilisateur peut "switcher"
ADDITIONAL_MAP = [
					{"url" :'https://gpp3-wxs.ign.fr/'+ignApiKey+'/geoportail/wmts?LAYER=ORTHOIMAGERY.ORTHOPHOTOS&EXCEPTIONS=text/xml&FORMAT=image/jpeg&SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetTile&STYLE=normal&TILEMATRIXSET=PM&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}',
					"attribution": "",
					"tileName" : 'Ortho IGN'
					},

					{"url" : 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
					"attribution": '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
					"tileName" : 'OpenStreetMap'
					}
				]

orthoMap =  L.tileLayer(ADDITIONAL_MAP[0].url, {attribution: ADDITIONAL_MAP[0].attribution});



// ************* MAP OPTIONS *********************

//       **********MARKERS************

//				***SLIDER***

// Année en cours 
var currentDate = new Date();
$YEARMAX = currentDate.getFullYear();

// Pas du slider sur les années d'observation: 1 = pas de 1 ans sur le slider
$STEP = 1;