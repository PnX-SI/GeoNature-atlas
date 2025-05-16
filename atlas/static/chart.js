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

//Generic vertical bar graph
genericChart = function (element, labels, values) {
    return new Chart(element, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'observations',
                data: values,
                backgroundColor: chartMainColor,
                hoverBackgroundColor: chartHoverMainColor,
                borderWidth: 0
            }]
        },
        options: {
            scales: {
                yAxes: [{
                    ticks: {
                        beginAtZero: true
                    }
                }],
                xAxes: [{
                    gridLines: {
                        display: false
                    }
                }]
            },
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'top',
                    display: false
                },
            }
        }
    });
};

pieChartConfig = function (element, data) {
    return new Chart(element, {
        type: 'doughnut',
        data: data,
        options: {
            responsive: true,
            cutout: "30%",
            maintainAspectRatio: false,
            layout: {
                padding: 25
            },
            plugins: {
                legend: {
                    position: 'top',
                },
                title: {
                    display: false
                }
            }
        }
    })
}

function formatPieData(data) {
    let labels = []
    let data_count = []
    Object.keys(data).forEach(key => {
        labels.push(key)
        data_count.push(data[key])
    })

    return {
        labels: labels,
        datasets: [
            {
                label: `${translations.nb_observations}`,
                data: data_count,
                backgroundColor: configuration.COLOR_PIE_CHARTS,
                hoverOffset: 25
            }
        ]
    }
}

function stackedBarChartConfig(element, data) {
    return new Chart(element, {
        type: 'bar',
        data: data,
        options: {
            plugins: {
                title: {
                    display: false
                },
            },
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                intersect: false,
            },
            elements: {
                bar: {
                    borderWidth: 2,
                }
            },
            scales: {
                x: {
                    stacked: true,
                },
                y: {
                    stacked: true
                }
            },
            borderRadius: '5',
            barThickness: '10',
            indexAxis: 'y',
        }
    });
}

function formatStackedBarChart(values, element) {
    const labels = []
    const nb_species = []
    const nb_patrimonial = []
    const nb_species_in_teritory = []
    Object.keys(values).forEach(key => {
        labels.push(key)
        nb_species.push(values[key].nb_species)
        if(configuration.DISPLAY_PATRIMONIALITE) {
            nb_patrimonial.push(values[key].nb_patrimonial)
        }
        nb_species_in_teritory.push(values[key].nb_species_in_teritory)
    })

    const datasets = []

    if(configuration.DISPLAY_PATRIMONIALITE) {
        datasets.push({
            label: "Nombre d'espèces remarquables",
            data: nb_patrimonial,
            backgroundColor: [configuration.COLOR_STACKED_BAR_CHARTS[1]],
            stack: "2",
        });
    }

    datasets.push(
            {
                label: "Nombre d'espèces sur ce territoire",
                data: nb_species,
                backgroundColor: [configuration.COLOR_STACKED_BAR_CHARTS[0]],
                stack: "0",
            },
            {
                label: "Nombre d'espèces sur tout le territoire",
                data: nb_species_in_teritory,
                backgroundColor: [configuration.COLOR_STACKED_BAR_CHARTS[2]],
                stack: "1",
            }
    )

    const data = {
        labels: labels,
        datasets: datasets
    };

    return data
}

function barChartConfig(element, data) {
    return new Chart(element, {
        type: 'bar',
        data: data,
        options: {
            plugins: {
                title: {
                    display: false
                },
            },
            responsive: true,
            maintainAspectRatio: false,
            borderRadius: '5',
            barThickness: '20',
            indexAxis: 'x',
        }
    });
}

function formatBarChart(values, element, dataName) {
    const labels = []
    const nb_elem = []
    values.forEach(value => {
        labels.push(value.label)
        nb_elem.push(value.nb)
    })

    const data = {
        labels: labels,
        datasets: [
            {
                label: dataName,
                data: nb_elem,
                backgroundColor: chartMainColor,
                stack: "0",
            }
        ]
    };

    return data
}

var monthChartElement = document.getElementById('monthChart');
if (monthChartElement) {
    const monthChart = genericChart(monthChartElement, months_name, getChartDatas(months_value, 'value'));
}
var altiChartElement = document.getElementById('altiChart');
if (altiChartElement) {
    const altiChart = genericChart(altiChartElement, getChartDatas(dataset, 'altitude'), getChartDatas(dataset, 'value'));
}

const dataSourceChartElement = document.getElementById('organismChart');
if (dataSourceChartElement) {
    const organismChart = pieChartConfig(dataSourceChartElement, formatPieData(organism_stats, dataSourceChartElement));
}

const areaCode = areaInfos.areaCode;

fetch(`/api/area_chart_values/${areaCode}`)
    .then(response => response.json())
    .then(data => {
        $("#spinnerChart").hide();
        species_by_taxonomic_group = data.species_by_taxonomic_group
        observations_by_taxonomic_group = data.observations_by_taxonomic_group
        nb_species_by_organism = data.nb_species_by_organism
        observations_by_organism = data.observations_by_organism
// Onglet observations et espèces

        const biodiversityChartElement = document.getElementById('biodiversityChart');
        if (biodiversityChartElement) {
            const organismChart = stackedBarChartConfig(biodiversityChartElement, formatStackedBarChart(species_by_taxonomic_group, biodiversityChartElement));
        }

        const observationsChartElement = document.getElementById('observationsChart');
        if (observationsChartElement) {
            const organismChart = pieChartConfig(observationsChartElement, formatPieData(observations_by_taxonomic_group, observationsChartElement));
        }

// Onglet provenance des données

        const biodiversityByTerritoryChartElement = document.getElementById('biodiversity_by_territoryChart');
        if (biodiversityByTerritoryChartElement) {
            const organismChart = barChartConfig(biodiversityByTerritoryChartElement, formatBarChart(nb_species_by_organism, biodiversityByTerritoryChartElement, "Espèces"));
        }

        const observationsByTerritoryChartElement = document.getElementById('observations_by_territoryChart');
        if (observationsByTerritoryChartElement) {
            const organismChart = barChartConfig(observationsByTerritoryChartElement, formatBarChart(observations_by_organism, observationsByTerritoryChartElement, "Observations"));
        }
    })
    .catch(error => {
        console.log('Error fetching data: ', error);
    });

