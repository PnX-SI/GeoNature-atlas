// ***** Map configuration ****

latLong = [44.7952, 6.2287];
zoom = 10;
ignApiKey = '9lecnwu27bjiw08s384hvzhi'

tileLayer = {
             openstreetmap: {
                url: "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                options: {
                    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                },
            ignScan25: {
	 			url: "http://gpp3-wxs.ign.fr/"+ignApiKey + "/wmts?LAYER=GEOGRAPHICALGRIDSYSTEMS.MAPS.SCAN-EXPRESS.STANDARD&EXCEPTIONS=text/xml&FORMAT=image/jpeg&SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetTile&STYLE=normal&TILEMATRIXSET=PM&&TILEMATRIX={z}&TILECOL={x}&TILEROW={y}" ;
	 			option: {
	 				attribution: '&copy; <a href="http://www.ign.fr/">IGN</a>'
	 		}


//**********



