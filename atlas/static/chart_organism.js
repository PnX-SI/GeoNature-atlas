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
    '#E1CE7A',
    '#FBFFB9',
    '#FDD692',
    '#EC7357',
    '#754F44',
    '#FB6376',
    '#B7ADCF',
    '#DEE7E7',
    '#F4FAFF',
    '#383D3B',
    '#7C7C7C',
    '#B5F44A',
    '#D6FF79',
    '#507255',
    '#381D2A',
    '#BA5624',
    '#FFA552',
    '#F7FFE0',
    '#49C6E5',
    '#54DEFD',
    '#0B5563',
    '#54DEFD'
  ];

var groupChartElement = document.getElementById('groupChart');
const groupChart = circleChart(groupChartElement, getChartDatas(dataset, 'group2_inpn'), getChartDatas(dataset, 'nb_obs_group'), color_tab);
