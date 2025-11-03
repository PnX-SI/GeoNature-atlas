window.onresize = function () {
    var presentationText = document.getElementById("presentation-text");
    if (presentationText) {
        if (window.innerWidth <= 800) {
            presentationText.hidden = true;
        } else {
            presentationText.hidden = false;
        }
    }
};

var presentationText = document.getElementById("presentation-text");
if (window.innerWidth <= 800 && presentationText) {
    presentationText.hidden = true;
}

autocompleteSearch = function (inputID, urlDestination, nbProposal) {
    $(inputID).autocomplete({
        source: function (request, response) {
            var searchUrl;
            if (urlDestination === "espece") {
                searchUrl = "/api/searchTaxon";
            } else if (urlDestination === "area") {
                searchUrl = "/api/searchArea";
            } else {
                searchUrl = "/api/searchArea/" + urlDestination;
            }
            $(inputID)
                .attr("loading", "true")
                .css(
                    "background-image",
                    "url('" +
                        configuration.URL_APPLICATION +
                        "/static/images/loading3.gif')",
                );
            $.get(
                configuration.URL_APPLICATION + searchUrl,
                { search: request.term, limit: nbProposal },
                function (results) {
                    const unique_type_name = [
                        ...new Set(results.map((item) => item.type_name)),
                    ].filter(Boolean);
                    if (unique_type_name.length === 0) {
                        response(results.slice(0, nbProposal));
                    } else {
                        const items = [];
                        unique_type_name.forEach((u) => {
                            items.push({ type: u });
                            items.push(
                                ...results
                                    .filter((item) => {
                                        return item.type_name === u;
                                    })
                                    .slice(0, nbProposal),
                            );
                        });
                        response(items);
                    }
                    $(inputID)
                        .attr("loading", "false")
                        .css("background-image", "none");
                },
            );
        },
        focus: function () {
            return false;
        },
        select: function (event, ui) {
            if (ui.item && ui.item.type) {
                return false;
            }
            $(inputID).val(ui.item.label);
            var url = ui.item.value;
            if (urlDestination === "espece") {
                location.href =
                    configuration.URL_APPLICATION + language + "/espece/" + url;
                const splited_label = ui.item.label.split(" = ");
                const label_for_input =
                    splited_label[0] !== ""
                        ? splited_label[0]
                        : splited_label[1];
                $(inputID).val(label_for_input.replace(/<[^>]*>?/gm, ""));
            } else {
                location.href =
                    configuration.URL_APPLICATION +
                    language +
                    "/area/" +
                    "/" +
                    url;
            }

            return false;
        },
        create: function () {
            $(this).data("ui-autocomplete")._renderItem = function (ul, item) {
                if (item && item.type) {
                    return $("<div class='type_name'>")
                        .append(`<b>${item.type}</b>`)
                        .appendTo(ul);
                }
                return $("<li>")
                    .append(`<a  class="search-bar-item"> ${item.label} </a>`)
                    .appendTo(ul);
            };
        },
    });
};

// Generate the autocompletion with the list of item, the input id and the form id
$("#searchTaxons").focus(function () {
    autocompleteSearch("#searchTaxons", "espece", 20);
});
$("#searchTaxonsStat").focus(function () {
    autocompleteSearch("#searchTaxonsStat", "espece", 10);
});

$("#searchAreas").focus(function () {
    autocompleteSearch("#searchAreas", "area", 20);
});
$("#searchAreasStat").focus(function () {
    autocompleteSearch("#searchAreasStat", "area", 10);
});

$("#buttonChild").click(function () {
    $("#buttonChild")
        .find("span")
        .toggleClass("fas fa-chevron-right")
        .toggleClass("fas fa-chevron-down");
    const childList = $("#childList");
    if (childList.attr("hidden") === "hidden") {
        childList.removeAttr("hidden");
    } else {
        childList.attr("hidden", "hidden");
    }
});

// Initialisation globale des tooltips Bootstrap 5
document.addEventListener("DOMContentLoaded", function () {
    const tooltipTriggerList = [].slice.call(
        document.querySelectorAll('[data-bs-toggle="tooltip"]'),
    );
    tooltipTriggerList.forEach(function (tooltipTriggerEl) {
        new bootstrap.Tooltip(tooltipTriggerEl);
    });
});

// Animation index.html
$(document).ready(function () {
    $("#localScroll").on("click", function () {
        var dest = $("#DernieresObservations");
        var speed = 750;
        $("html, body").animate({ scrollTop: $(dest).offset().top }, speed);
        return false;
    });
});

// Glossarizer JQUERY utilisé dans la bloc d'infos de la fiche espèce (si paramètre GLOSSAIRE activé)
if (configuration.GLOSSAIRE) {
    $(function () {
        $("#blocInfos").glossarizer({
            sourceURL:
                configuration.URL_APPLICATION + "/static/custom/glossaire.json",
            callback: function () {
                // Callback fired after glossarizer finishes its job
                new tooltip();
            },
        });
    });
}

if (configuration.OREJIME_APPS.length > 0) {
    var orejimeConfig = {
        elementID: "orejime",
        appElement: "main",
        cookieName: "orejime",
        cookieExpiresAfterDays: 365,
        privacyPolicy: "/?personal_data=true",
        default: true,
        mustConsent: false,
        mustNotice: false,
        lang: configuration.DEFAULT_LANGUAGE,
        logo: false,
        apps: configuration.OREJIME_APPS,
        categories: configuration.OREJIME_CATEGORIES,
    };
    if (
        configuration.OREJIME_TRANSLATIONS &&
        Object.keys(configuration.OREJIME_TRANSLATIONS).length !== 0
    ) {
        orejimeConfig.translations = configuration.OREJIME_TRANSLATIONS;
    }
}

// eslint-disable-next-line no-unused-vars
function addGeocoderPluggin(map) {
    L.Control.geocoder({
        defaultMarkGeocode: false,
        placeholder: "Rechercher une adresse ou un lieu",
        position: "topleft",
        geocodingService: "nominatim",
        geocoder: L.Control.Geocoder.nominatim({
            geocodingQueryParams: configuration.GEOCODING_QUERY_PARAMS,
        }),
    })
        .on("markgeocode", function (e) {
            map.fitBounds(e.geocode.bbox);
        })
        .addTo(map);
}
