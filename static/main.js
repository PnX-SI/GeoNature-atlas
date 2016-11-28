
$(document).ready(function() {
  $(window).keydown(function(event){
    if(event.keyCode == 13) {
      event.preventDefault();
      return false;
    }
  });
});

autocompleteSearch = function(list, inputID, urlDestination, nbProposal){
    $(inputID).autocomplete({
        source: function (request, response) {
        var results = $.ui.autocomplete.filter(list, request.term);
        response(results.slice(0, nbProposal))},
             focus: function(event, ui) {
                return false;
            },
           select : function (event, ui){
             $(inputID).val(ui.item.label);
              var url = ui.item.value;
              if (urlDestination == "espece"){
                  location.href = configuration.URL_APPLICATION+"/espece/"+url;
              } else {
                  location.href = configuration.URL_APPLICATION+"/commune/"+url;
              }
              
          return false;
            }
    });
};

// Generate the autocompletion with the list of item, the input id and the form id
    $( "#searchCommunes" ).focus(function() {
      autocompleteSearch(communesSearch, "#searchCommunes", "commune", 20)
    });
    $( "#searchCommunesStat" ).focus(function() {
       autocompleteSearch(communesSearch, "#searchCommunesStat", "commune", 10);
    });


$.ajax({
  url: configuration.URL_APPLICATION+'/api/searchTaxon/',
  dataType: "json"
  }).done(function(list) {
      $('[loading="true"]').css("background-image", "none")
      $('[loading="true"]').prop("disabled", false);
      $('[loading="true"]').attr('placeholder', "Rechercher une espèce")


    $( "#searchTaxons" ).focus(function() {
       autocompleteSearch(list, "#searchTaxons", "espece", 20);
    });

    // Autocomplete bloc stat
    $( "#searchTaxonsStat" ).focus(function() {
       autocompleteSearch(list, "#searchTaxonsStat", "espece", 10);
    });

});

// child list display
var childList = $('#childList');
$('#buttonChild').click(function(){
  $('#buttonChild').find('span').toggleClass("glyphicon glyphicon-chevron-right").toggleClass('glyphicon glyphicon-chevron-down');
 var childList = $('#childList');
    if (childList.attr("hidden") === "hidden"){
      childList.removeAttr( "hidden" )
    }
    else {
      childList.attr("hidden", "hidden")
    }
})

// Tooltip
$(document).ready(function(){
  $('[data-toggle="tooltip"]').tooltip();
});

// Animation index.html
$(document).ready(function() {
   $('#localScroll').on('click', function(){
    var dest = $('#DernieresObservations');
    var speed = 750;
    $('html, body').animate({scrollTop: $(dest).offset().top}, speed);
    return false;
   })
});

// Glossarizer JQUERY utilisé dans la bloc d'infos de la fiche espèce (si paramètre GLOSSAIRE activé)
if (configuration.GLOSSAIRE) {
	$(function(){
		$('#blocInfos').glossarizer({
			sourceURL: configuration.URL_APPLICATION+'/static/custom/glossaire.json',
			callback: function(){
				// Callback fired after glossarizer finishes its job
				new tooltip();
			}
		});
	});
}
