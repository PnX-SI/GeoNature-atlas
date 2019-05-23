$(document).ready(function() {
  $(window).keydown(function(event) {
    if (event.keyCode == 13) {
      event.preventDefault();
      return false;
    }
  });
});

autocompleteSearch = function(inputID, urlDestination, nbProposal) {
  $(inputID).autocomplete({
    source: function(request, response) {
      var searchUrl;
      if (urlDestination == "espece") {
        searchUrl = "/api/searchTaxon";
      } else if (urlDestination == "enp") {
        searchUrl = "/api/searchEnp";
      } else {
        searchUrl = "/api/searchCommune";
      }
      $(inputID)
        .attr("loading", "true")
        .css(
          "background-image",
          "url('" +
            configuration.URL_APPLICATION +
            "/static/images/loading3.gif')"
        );
      $.get(
        configuration.URL_APPLICATION + searchUrl,
        { search: request.term, limit: nbProposal },
        function(results) {
          response(results.slice(0, nbProposal));
          $(inputID)
            .attr("loading", "false")
            .css("background-image", "none");
        }
      );
    },
    focus: function(event, ui) {
      return false;
    },
    select: function(event, ui) {
      $(inputID).val(ui.item.label);
      var url = ui.item.value;
      if (urlDestination == "espece") {
        location.href = configuration.URL_APPLICATION + "/espece/" + url;
      } else {
        location.href = configuration.URL_APPLICATION + "/commune/" + url;
      }

      return false;
    },
    create: function (event,ui){
       $(this).data('ui-autocomplete')._renderItem = function (ul, item) {
        return $('<li>')
            .append('<a  class="search-bar-item">' + item.label + '</a>')
            .appendTo(ul);
       }
    }
  })
};

// Generate the autocompletion with the list of item, the input id and the form id
$("#searchTaxons").focus(function() {
  autocompleteSearch("#searchTaxons", "espece", 20);
});
$("#searchTaxonsStat").focus(function() {
  autocompleteSearch("#searchTaxonsStat", "espece", 10);
});

$("#searchCommunes").focus(function() {
  autocompleteSearch("#searchCommunes", "commune", 20);
});
$("#searchCommunesStat").focus(function() {
  autocompleteSearch("#searchCommunesStat", "commune", 10);
});

// child list display
var childList = $("#childList");
$("#buttonChild").click(function() {
  $("#buttonChild")
    .find("span")
    .toggleClass("glyphicon glyphicon-chevron-right")
    .toggleClass("glyphicon glyphicon-chevron-down");
  var childList = $("#childList");
  if (childList.attr("hidden") === "hidden") {
    childList.removeAttr("hidden");
  } else {
    childList.attr("hidden", "hidden");
  }
});

// Tooltip
$(document).ready(function() {
  $('[data-toggle="tooltip"]').tooltip();
});

// Animation index.html
$(document).ready(function() {
  $("#localScroll").on("click", function() {
    var dest = $("#DernieresObservations");
    var speed = 750;
    $("html, body").animate({ scrollTop: $(dest).offset().top }, speed);
    return false;
  });
});

// Glossarizer JQUERY utilisé dans la bloc d'infos de la fiche espèce (si paramètre GLOSSAIRE activé)
if (configuration.GLOSSAIRE) {
  $(function() {
    $("#blocInfos").glossarizer({
      sourceURL:
        configuration.URL_APPLICATION + "/static/custom/glossaire.json",
      callback: function() {
        // Callback fired after glossarizer finishes its job
        new tooltip();
      }
    });
  });
}
