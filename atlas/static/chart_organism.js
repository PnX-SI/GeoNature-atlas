// ChartJS Graphs
const chartMainColor = getComputedStyle(document.documentElement).getPropertyValue('--main-color');
const chartHoverMainColor = getComputedStyle(document.documentElement).getPropertyValue('--second-color');

const getChartDatas = function (data, key) {
    let values = [];
    for (var i = 0; i < data.length; i++) {
        values.push(data[i][key])
    }
    return values
};

//Circle graph for parts graph
circleChart = function (element, labels, values) {
    return new Chart(element, {
        type: 'pie',
        data: {
            labels: labels,
            datasets: [{
                    label: 'observations',
                    data: values,
                    backgroundColor: configuration.COLOR_PIE_CHARTS
                }]
        },
        options: {
          responsive: true,
          plugins: {
            legend: {
              position: 'left',
            },
          }
        },
    })
};

var groupChartElement = document.getElementById('groupChart');
const groupChart = circleChart(groupChartElement, getChartDatas(dataset, 'group2_inpn'), getChartDatas(dataset, 'nb_obs_group'));
