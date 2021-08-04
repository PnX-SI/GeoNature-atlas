// ChartJS Graphs

Chart.defaults.global.defaultFontSize = 12;
const chartMainColor = getComputedStyle(document.documentElement).getPropertyValue('--main-color');
const chartHoverMainColor = getComputedStyle(document.documentElement).getPropertyValue('--second-color');

const getChartDatas = function (data, key) {
    let values = [];
    for (var i = 0; i < data.length; i++) {
        values.push(data[i][key])
    }
    return values
};

const createColor = function(data) {
    let colors = [];
    for (var i = 0; i < data.length; i++) {
        if(i%2==0){
            colors.push(chartMainColor);  
        } else {
            colors.push(chartHoverMainColor);  
        }
        
    
    }
    return colors
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
              position: 'top',
            },
            title: {
              display: true,
              text: 'Parts des observations totales'
            }
          }
        },
    })
};

var groupChartElement = document.getElementById('groupChart');
const groupChart = circleChart(groupChartElement, getChartDatas(dataset, 'group2_inpn'), getChartDatas(dataset, 'nb_obs_group'), createColor(dataset));
