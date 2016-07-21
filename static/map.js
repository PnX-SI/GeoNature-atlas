
var map = generateMap()

// add all observations markers whith popup

function onEachFeature(feature, layer){
    popupContent = "<b>Date: </b>"+ feature.properties.dateobs+"</br><b>Altitude: </b>"+ feature.properties.altitude_retenue+
                "</br><b>Observateurs: </b>"+ feature.properties.observateurs;

     // verifie si le champs effectif est rempli
      if(feature.properties.effectif_total){
        layer.bindPopup(popupContent+"</br><b>Effectif: </b>"+ feature.properties.effectif_total);
      }else{
        layer.bindPopup(popupContent)
      }
}




function style(feature){
  if (feature.properties.dateobs.year > 2000) {
    return {color: "#A3C990",
            filColor : "#A3C990",
            opacity : 0.4,
            fillOpacity: 0.5
          };
  }else {
        return {color: "#FFFFFF",
            filColor : "#FFFFFF",
            opacity : 0,
            fillOpacity: 0};
    }

  }

  var invisibleStyle = {
            color: "#FFFFFF",
            filColor : "#FFFFFF",
            opacity : 0,
            fillOpacity: 0

  }

  var normalStyle = {

  }


// ******** Marker and map options *************


// Markers



function generateClusterFromGeoJson (geoJsonObs){
       var singleMarkers = L.geoJson(geoJsonObs, {
                         onEachFeature : onEachFeature,
                         pointToLayer: function (feature, latlng) {
                           return L.circleMarker(latlng);
                           }
                       });
  var clusterMarkers = L.markerClusterGroup();
  clusterMarkers.addLayer(singleMarkers);
  
  return clusterMarkers;
}

function generateSingleMarkerFromGeoJson(geoJsonObs){
  var singleMarkers = L.geoJson(geoJsonObs, {
                         onEachFeature : onEachFeature,
                         pointToLayer: function (feature, latlng) {
                           return L.circleMarker(latlng);
                           }
                       });
  return singleMarkers;
}


var clusterMarkers ;
function displayMarkers(geoJsonObs){
  clusterMarkers = generateClusterFromGeoJson(geoJsonObs);
  map.addLayer(clusterMarkers);
}


var newMarkers;
var filterGeoJson;
function displayFilterMarkers(geoJsonObs, yearMin, yearMax, cluster){
    // create an empty geoJson
    filterGeoJson = {'type': 'FeatureCollection',
                    'features' : []
                  }
    
    // create a the new filter geoJson with min and max years 
    filterGeoJson.features = geoJsonObs.features.filter(function(marker){
      return (marker.properties.year >= yearMin && marker.properties.year <= yearMax)
    })
   
    //generate single or cluster markers from GeoJson
    newMarkers = (cluster==true)?generateClusterFromGeoJson(filterGeoJson):generateSingleMarkerFromGeoJson(filterGeoJson);
    map.addLayer(newMarkers);
}


// Markers display on window ready

$(function(){
  displayMarkers(observations);
})




//slider 

$("#yearMax").html("&nbsp;&nbsp;"+ $YEARMAX);
$("#yearMin").html(taxonYearMin + "&nbsp;&nbsp;");





// slider event: display filter observations

var yearMin = taxonYearMin;
var yearMax = $YEARMAX;


 // Slider event
mySlider.on("change",function(){
    years = mySlider.getValue();
    yearMin = years[0];
    yearMax = years[1];

    var currentMarker = (newMarkers == undefined) ? clusterMarkers: newMarkers;
    map.removeLayer(currentMarker);
    displayFilterMarkers(observations, yearMin, yearMax, $("#checkbox").is(":checked"));


    $("#nbObs").html("Nombre d'observation(s): "+ filterGeoJson.features.length);

   });


// switcher

mySwitcher = $("[name='my-checkbox']").bootstrapSwitch();

mySwitcher.on('switchChange.bootstrapSwitch', function(state) {
  
    currentMarker = (newMarkers == undefined) ? clusterMarkers:newMarkers;
    map.removeLayer(currentMarker);

    displayFilterMarkers(observations, yearMin, yearMax, this.checked)

});


currentMarker = (newMarkers == undefined) ? clusterMarkers:newMarkers;

$('#test').click(function(){
  console.log("test");
})
