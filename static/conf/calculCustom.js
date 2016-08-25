var currentDate = new Date();
YEARMAX = currentDate.getFullYear();

function getLegend(yearMin, yearMax){
	var interMin = yearMin % 10;

var firstDec = yearMin - interMin; // 1970

var interMax = yearMax %10
var lastDec = yearMax - interMax; // 2010


legend = [yearMin];

var i = firstDec
while (i<lastDec){
/*	step = ((yearMax-yearMin) > 50 ) ? 20:10
*/	i+= 10;
	legend.push(i)
}
legend.push(yearMax);
return legend

}

function getStringLegend (legend){
	legend.forEach(function(x){
		x = x.toString();
	});
	return legend;
}