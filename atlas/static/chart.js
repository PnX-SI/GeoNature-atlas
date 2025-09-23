// ChartJS Graphs
const chartMainColor = getComputedStyle(document.documentElement).getPropertyValue('--main-color');
const chartHoverMainColor = getComputedStyle(document.documentElement).getPropertyValue('--second-color');
const colors = configuration.COLOR_PIE_CHARTS;
const chartMainColorThreatened = colors[5];
const chartMainColorNoThreatened = colors.at(-1);

const getChartDatas = function (data, key) {
    let values = [];
    for (var i = 0; i < data.length; i++) {
        values.push(data[i][key])
    }
    return values
};

hexToRgba = function (hex, alpha = 1) {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

//Generic vertical bar graph
genericChart = function (element, labels, values) {
    return new Chart(element, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: translations.observations,
                data: values,
                backgroundColor: chartMainColor,
                hoverBackgroundColor: chartHoverMainColor,
                borderWidth: 0
            }]
        },
        options: {
            scales: {
                y: {
                  ticks: {
                        beginAtZero: true
                    }
                },
                x: {
                    gridLines: {
                        display: false
                    }
                }
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
                label: translations.nb_observations,
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
        labels.push(key);
        if(configuration.DISPLAY_PATRIMONIALITE) {
            nb_patrimonial.push(values[key].nb_patrimonial)
        }
        nb_species.push(values[key].nb_species)
        nb_species_in_teritory.push(values[key].nb_species_in_teritory)
    })

    const datasets = []

    if(configuration.DISPLAY_PATRIMONIALITE) {
        datasets.push({
            label: `${translations.nb_species} ${configuration.PATRIMONIALITE.label_pluriel.toLowerCase()}`,
            data: nb_patrimonial,
            backgroundColor: [configuration.COLOR_STACKED_BAR_CHARTS[1]],
            stack: "2",
        });
    }

    datasets.push(
            {
                label: `${translations.nb_species} (${areaInfos.areaName})`,
                data: nb_species,
                backgroundColor: [configuration.COLOR_STACKED_BAR_CHARTS[0]],
                stack: "0",
            },

    )
    if(configuration.AFFICHAGE_TOUT_TERRITOIRE_GRAPH) {
        datasets.push({
            label: translations.nb_species_territory,
            data: nb_species_in_teritory,
            backgroundColor: [configuration.COLOR_STACKED_BAR_CHARTS[2]],
            stack: "1",
        })
    }

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

function threatenedBarChartConfig(element, total, threatened) {
    const others = total - threatened;

    const data = {
        labels: [translations.species],
        datasets: [
            {
                label: translations.threatened_species,
                data: [threatened],
                backgroundColor: hexToRgba(chartMainColorThreatened, 0.2),
                borderColor: hexToRgba(chartMainColorThreatened),
                borderWidth: 3,
                stack: "0"
            },
            {
                label: translations.other_species,
                data: [others],
                backgroundColor: hexToRgba(chartMainColorNoThreatened, 0.2),
                borderColor: hexToRgba(chartMainColorNoThreatened),
                borderWidth: 1,
                stack: "0"
            }
        ]
    };

    return new Chart(element, {
        type: 'bar',
        data: data,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'top' },
                title: {
                    display: true,
                    text: translations.threatened_species_repartition
                }
            },
            scales: {
                x: { stacked: true },
                y: { stacked: true, beginAtZero: true }
            }
        }
    });
}

function threatenedByTaxoGroupChartConfig(element, values) {
    const labels = [];
    const threatened = [];
    const notThreatened = [];

    Object.keys(values).forEach(key => {
        labels.push(key);
        threatened.push(values[key].nb_threatened);
        notThreatened.push(values[key].nb_species - values[key].nb_threatened);
    });

    const data = {
        labels: labels,
        datasets: [
            {
                label: translations.threatened_species,
                data: threatened,
                backgroundColor: hexToRgba(chartMainColorThreatened, 0.2),
                borderColor: hexToRgba(chartMainColorThreatened),
                borderWidth: 3
            },
            {
                label: translations.other_species,
                data: notThreatened,
                backgroundColor: hexToRgba(chartMainColorNoThreatened, 0.2),
                borderColor: hexToRgba(chartMainColorNoThreatened),
                borderWidth: 1
            }
        ]
    };

    return new Chart(element, {
        type: 'bar',
        data: data,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'top' },
                title: {
                    display: true,
                    text: translations.nb_species_taxonomic_group
                }
            },
            scales: {
                x: { stacked: true },
                y: { stacked: true, beginAtZero: true }
            }
        }
    });
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

if (typeof areaInfos !== 'undefined') {
    const areaCode = areaInfos.areaCode;

    fetch(`${configuration.URL_APPLICATION}/api/area_chart_values/${areaCode}`)
        .then(response => response.json())
        .then(data => {
            $("#spinnerChart").hide();
            species_by_taxonomic_group = data.species_by_taxonomic_group
            observations_by_taxonomic_group = data.observations_by_taxonomic_group
            nb_species_by_organism = data.nb_species_by_organism
            observations_by_organism = data.observations_by_organism
            nb_species = data.nb_species
            nb_threatened_species = data.nb_threatened_species

            // Onglet observations et espèces
            const biodiversityChartElement = document.getElementById('biodiversityChart');
            if (biodiversityChartElement) {
                const organismChart = stackedBarChartConfig(biodiversityChartElement, formatStackedBarChart(species_by_taxonomic_group, biodiversityChartElement));
            }

            const observationsChartElement = document.getElementById('observationsChart');
            if (observationsChartElement) {
                const organismChart = pieChartConfig(observationsChartElement, formatPieData(observations_by_taxonomic_group, observationsChartElement));
            }

            // Onglet Espèces menacées
            const threatenedSpeciesChartElement = document.getElementById('threatenedSpeciesChart');
            if (threatenedSpeciesChartElement) {
                threatenedBarChartConfig(
                    threatenedSpeciesChartElement,
                    nb_species,
                    nb_threatened_species
                );
            }
            
            const threatenedByTaxoGroupElement = document.getElementById('threatenedSpeciesByTaxoGroupChart');
            if (threatenedByTaxoGroupElement) {
                threatenedByTaxoGroupChartConfig(threatenedByTaxoGroupElement, species_by_taxonomic_group);
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
}

