console.log(dataset);


Morris.Bar({
    element:"altiChart",
    data : dataset,
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


svgContainer = d3.selectAll("svg");
    svgContainer.append("g")
        .append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", '0%')
            .attr('x', '-15%')
            .attr("dy", ".71em")
            .attr("fill", "#888888")
            .attr("font-size", "10px")
            .style("text-anchor", "end")
            .text("Observations");

        svgContainer.append("g")
        .append("text")
            .attr("y", "90%")
            .attr("x", "100%")
            .attr("dy", ".71em")
            .attr("fill", "#888888")
            .attr("font-size", "10px")
            .style("text-anchor", "end")
            .text("Altitude (m)");