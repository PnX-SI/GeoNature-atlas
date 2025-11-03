if (configuration.AFFICHAGE_STAT_GLOBALES) {
    $.ajax({
        url: configuration.URL_APPLICATION + "/api/main_stat",
        dataType: "json",
    }).done(function (stat) {
        $("#nbObs").html(stat.nbTotalObs.toLocaleString());
        $("#nbTaxons").html(stat.nbTotalTaxons.toLocaleString());
        $("#nbTown").html(stat.town.toLocaleString());
        $("#nbPictures").html(stat.photo.toLocaleString());
        $("#nbPictures").html(stat.photo.toLocaleString());
        $("#mainstat-spinner").hide();
    });
}

if (configuration.AFFICHAGE_RANG_STAT) {
    $.ajax({
        url: configuration.URL_APPLICATION + "/api/rank_stat",
        dataType: "json",
    }).done(function (stat) {
        stat.forEach(function (element, index) {
            $("#rankNbObs" + index).html(element.nb_obs.toLocaleString());
            $("#rankNbTax" + index).html(element.nb_taxons.toLocaleString());
        });
        $("#rankstat-spinner").hide();
    });
}
