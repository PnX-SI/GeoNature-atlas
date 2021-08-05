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
circleChart = function (element, labels, values, colors) {
    return new Chart(element, {
        type: 'pie',
        data: {
            labels: labels,
            datasets: [{
                    label: 'observations',
                    data: values,
                    backgroundColor: colors
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

var color_tab = [
    '#e7d51d',
    '#ded01f',
    '#d5ca20',
    '#cdc521',
    '#c4c022',
    '#bcba24',
    '#b4b524',
    '#acaf25',
    '#a4aa26',
    '#9da427',
    '#959f27',
    '#8e9a28',
    '#879428',
    '#808f28',
    '#7a8928',
    '#738428',
    '#6d7e28',
    '#677928',
    '#617328',
    '#5b6e27',
    '#556827',
    '#506326'
  ];

var groupChartElement = document.getElementById('groupChart');
const groupChart = circleChart(groupChartElement, getChartDatas(dataset, 'group2_inpn'), getChartDatas(dataset, 'nb_obs_group'), color_tab);
