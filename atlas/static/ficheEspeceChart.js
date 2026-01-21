//Generic vertical bar graph
genericChart = function (element, labels, values) {
    return new Chart(element, {
        type: "bar",
        data: {
            labels: labels,
            datasets: [
                {
                    label: window.i18n.observations,
                    data: values,
                    backgroundColor: chartMainColor,
                    hoverBackgroundColor: chartHoverMainColor,
                    borderWidth: 0,
                },
            ],
        },
        options: {
            scales: {
                y: {
                    ticks: {
                        beginAtZero: true,
                    },
                },
                x: {
                    gridLines: {
                        display: false,
                    },
                },
            },
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: "top",
                    display: false,
                },
            },
        },
    });
};

// pie chart config for zoning sheet and areaSheet

pieChartConfig = function (element, data) {
    return new Chart(element, {
        type: "doughnut",
        data: data,
        options: {
            responsive: true,
            cutout: "30%",
            maintainAspectRatio: false,
            layout: {
                padding: 25,
            },
            plugins: {
                legend: {
                    position: "top",
                },
                title: {
                    display: false,
                },
            },
        },
    });
};

// use for zoning and species sheet

function formatPieData(data) {
    const labels = [];
    const data_count = [];
    Object.keys(data).forEach((key) => {
        labels.push(key);
        data_count.push(data[key]);
    });

    return {
        labels: labels,
        datasets: [
            {
                label: window.i18n["obs.number.s"],
                data: data_count,
                backgroundColor: configuration.COLOR_PIE_CHARTS,
                hoverOffset: 25,
            },
        ],
    };
}

const getChartDatas = function (data, key) {
    const values = [];
    for (var i = 0; i < data.length; i++) {
        values.push(data[i][key]);
    }
    return values;
};

var monthChartElement = document.getElementById("monthChart");
if (monthChartElement) {
    genericChart(
        monthChartElement,
        months_name,
        getChartDatas(months_value, "value"),
    );
}
var altiChartElement = document.getElementById("altiChart");
if (altiChartElement) {
    genericChart(
        altiChartElement,
        getChartDatas(dataset, "altitude"),
        getChartDatas(dataset, "value"),
    );
}

const dataSourceChartElement = document.getElementById("organismChart");
if (dataSourceChartElement) {
    pieChartConfig(
        dataSourceChartElement,
        formatPieData(organism_stats, dataSourceChartElement),
    );
}
