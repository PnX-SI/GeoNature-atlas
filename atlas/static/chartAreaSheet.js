// ============================================
// UTILITIES
// ============================================

const hexToRgba = (hex, alpha = 1) => {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
};

// ============================================
// CHART CREATION FUNCTIONS
// ============================================

function createStackedBarChart(element, data) {
    return new Chart(element, {
        type: "bar",
        data: data,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: { intersect: false },
            elements: { bar: { borderWidth: 2 } },
            scales: {
                x: { stacked: true },
                y: { stacked: true },
            },
            borderRadius: 5,
            barThickness: 10,
            indexAxis: "y",
        },
    });
}

function createBarChart(element, data) {
    return new Chart(element, {
        type: "bar",
        data: data,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            borderRadius: 5,
            barThickness: 20,
            indexAxis: "x",
        },
    });
}

function createPieChart(element, data) {
    return new Chart(element, {
        type: "doughnut",
        data: data,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: "30%",
            layout: { padding: 25 },
            plugins: {
                legend: { position: "top" },
                title: { display: false },
            },
        },
    });
}

function createThreatenedBarChart(element, data, title) {
    return new Chart(element, {
        type: "bar",
        data: data,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: "top" },
                title: {
                    display: true,
                    text: title,
                },
            },
            scales: {
                x: { stacked: true },
                y: { stacked: true, beginAtZero: true },
            },
            borderRadius: 5,
            barThickness: 50,
        },
    });
}

// ============================================
// DATA FORMATTING
// ============================================

const dataFormatters = {
    stackedBar: (values) => {
        const labels = Object.keys(values);
        const datasets = [];

        if (configuration.DISPLAY_PATRIMONIALITE) {
            datasets.push({
                label: `${window.i18n["number.species"]} ${window.i18n["patrimonial.plural"]?.toLowerCase() || "patrimoniales"}`,
                data: labels.map((key) => values[key].nb_patrimonial),
                backgroundColor: [chartSecondColor],
                stack: "2",
            });
        }

        datasets.push({
            label: `${window.i18n["number.species"]} (${areaInfos.areaName})`,
            data: labels.map((key) => values[key].nb_species),
            backgroundColor: [chartMainColor],
            stack: "0",
        });

        if (configuration.AFFICHAGE_TOUT_TERRITOIRE_GRAPH) {
            datasets.push({
                label: window.i18n["number.species.territory"],
                data: labels.map((key) => values[key].nb_species_in_teritory),
                backgroundColor: [configuration.COLOR_STACKED_BAR_CHARTS[2]],
                stack: "1",
            });
        }

        return { labels, datasets };
    },

    bar: (values, dataName) => {
        const labels = values.map((v) => v.label);
        const data = values.map((v) => v.nb);

        return {
            labels,
            datasets: [
                {
                    label: dataName,
                    data,
                    backgroundColor: hexToRgba(chartThirdColor, 0.5),
                    borderColor: hexToRgba(chartThirdColor),
                    borderWidth: 2,
                    stack: "0",
                },
            ],
        };
    },

    pie: (data) => {
        const labels = Object.keys(data);
        const counts = Object.values(data);

        return {
            labels,
            datasets: [
                {
                    label: window.i18n["obs.number.s"],
                    data: counts,
                    backgroundColor: configuration.COLOR_PIE_CHARTS,
                    hoverOffset: 25,
                },
            ],
        };
    },

    threatened: (total, threatened) => {
        const others = total - threatened;

        return {
            labels: [window.i18n["species"]],
            datasets: [
                {
                    label: window.i18n["threatened.species"],
                    data: [threatened],
                    backgroundColor: hexToRgba(chartMainColor, 0.5),
                    borderColor: hexToRgba(chartMainColor),
                    borderWidth: 3,
                },
                {
                    label: window.i18n["other.species"],
                    data: [others],
                    backgroundColor: hexToRgba(chartThirdColor, 0.5),
                    borderColor: hexToRgba(chartThirdColor),
                    borderWidth: 1,
                },
            ],
        };
    },

    threatenedByTaxoGroup: (values) => {
        const labels = Object.keys(values);

        return {
            labels,
            datasets: [
                {
                    label: window.i18n["threatened.species"],
                    data: labels.map((key) => values[key].nb_threatened),
                    backgroundColor: hexToRgba(chartMainColor, 0.5),
                    borderColor: hexToRgba(chartMainColor),
                    borderWidth: 3,
                },
                {
                    label: window.i18n["other.species"],
                    data: labels.map(
                        (key) =>
                            values[key].nb_species - values[key].nb_threatened,
                    ),
                    backgroundColor: hexToRgba(chartThirdColor, 0.5),
                    borderColor: hexToRgba(chartThirdColor),
                    borderWidth: 1,
                },
            ],
        };
    },
};

// ============================================
// CHARTS INITIALIZATION
// ============================================

if (typeof areaInfos !== "undefined") {
    const areaID = areaInfos.areaID;

    fetch(`${configuration.URL_APPLICATION}/api/area_chart_values/${areaID}`)
        .then((response) => response.json())
        .then((data) => {
            $("#spinnerChart").hide();

            const {
                species_by_taxonomic_group,
                observations_by_taxonomic_group,
                nb_species_by_organism,
                observations_by_organism,
                nb_species,
                nb_threatened_species,
            } = data;

            // Observations and species tab
            const biodiversityElement =
                document.getElementById("biodiversityChart");
            if (biodiversityElement) {
                createStackedBarChart(
                    biodiversityElement,
                    dataFormatters.stackedBar(species_by_taxonomic_group),
                );
            }

            const observationsElement =
                document.getElementById("observationsChart");
            if (observationsElement) {
                createPieChart(
                    observationsElement,
                    dataFormatters.pie(observations_by_taxonomic_group),
                );
            }

            // Threatened species tab
            const threatenedElement = document.getElementById(
                "threatenedSpeciesChart",
            );
            if (threatenedElement) {
                createThreatenedBarChart(
                    threatenedElement,
                    dataFormatters.threatened(
                        nb_species,
                        nb_threatened_species,
                    ),
                    window.i18n["threatened.species.repartition"],
                );
            }

            const threatenedByTaxoElement = document.getElementById(
                "threatenedSpeciesByTaxoGroupChart",
            );
            if (threatenedByTaxoElement) {
                createThreatenedBarChart(
                    threatenedByTaxoElement,
                    dataFormatters.threatenedByTaxoGroup(
                        species_by_taxonomic_group,
                    ),
                    window.i18n["number.species.taxonomic.group"],
                );
            }

            // Data source tab
            const biodiversityByTerritoryElement = document.getElementById(
                "biodiversity_by_territoryChart",
            );
            if (biodiversityByTerritoryElement) {
                createBarChart(
                    biodiversityByTerritoryElement,
                    dataFormatters.bar(nb_species_by_organism, "Espèces"),
                );
            }

            const observationsByTerritoryElement = document.getElementById(
                "observations_by_territoryChart",
            );
            if (observationsByTerritoryElement) {
                createBarChart(
                    observationsByTerritoryElement,
                    dataFormatters.bar(
                        observations_by_organism,
                        "Observations",
                    ),
                );
            }
        })
        .catch((error) => {
            console.error("Error fetching data:", error);
        });
}
