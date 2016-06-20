
var test = [];
dataset.forEach(function(x){
    test.push({altitude: x.altitude, value: x.value})
});
console.log(test);

Morris.Bar({
    element:"altiChart",
/*    barSizeRatio:0.2,
    barGap:0,*/
    data : test,
    xkey: "altitude",
    ykeys : ["value"],
    labels: ['Effectif'],
    xLabelAngle: 45,
    hideHover: 'auto',
    resize: true,
    axes: true,

});


rect = d3.selectAll("rect");

            rect.on("mouseover", function(d) {
             d3.select(this).classed("highlight", true);
             d3.select(this).select("text").style("visibility", "visible");



});

            rect.on("mouseout", function() {
    d3.select(this).classed("highlight", false);

});
