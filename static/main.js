$(document).ready(function() {
  $(window).keydown(function(event){
    if(event.keyCode == 13) {
      event.preventDefault();
      return false;
    }
  });
});


    autocompleteSearch = function(list, inputID, formID, nbProposal){

        // get the id of the hidden input
      temp = $(formID).find("input[type='hidden']").attr('id');
      hiddenID ='#'+temp;
      // get the id of the text input
      temp = $(formID).find("input[type='text']").attr('id');
      textID = '#'+temp;


    $(inputID).autocomplete({

        source: function (request, response) {
        var results = $.ui.autocomplete.filter(list, request.term);
        response(results.slice(0, nbProposal))},
             focus: function(event, ui) {
                return false;
            },
           select : function (event, ui){
              $(textID).val(ui.item.label)
              $(hiddenID).val(ui.item.value);
              console.log($(hiddenID).val());
              $(formID).submit();
          return false;
            }
    });

    }

// generate the autocompletion with the list of item, the input id and the form id


$.ajax({
  url: configuration.URL_APPLICATION+'/api/searchTaxon/',
  dataType: "json"
  }).done(function(list) {


        $( "#searchCommunes" ).focus(function() {
      autocompleteSearch(communesSearch, "#searchCommunes", "#searchFormCommunes", 20)
    });

    $( "#searchTaxons" ).focus(function() {
       autocompleteSearch(list, "#searchTaxons", "#searchFormTaxons", 20);
    });

    // Autocomplete bloc stat

    $( "#searchTaxonsStat" ).focus(function() {
       autocompleteSearch(list, "#searchTaxonsStat", "#searchFormTaxonsStat", 10);
    });

    $( "#searchCommunesStat" ).focus(function() {
       autocompleteSearch(communesSearch, "#searchCommunesStat", "#searchFormCommunesStat", 10);
    });
});

// complete dynamically the form action on search submit with the hidden value
function completeAction(id, hiddenID){

  value = $(hiddenID).val();
  var path;
  if (id == "#searchFormTaxons" || id == "#searchFormTaxonsStat"){
    path = configuration.URL_APPLICATION+"/espece/"+parseInt(value);
  }
  if (id == "#searchFormCommunes" || id == "#searchFormCommunesStat" ){
    path = configuration.URL_APPLICATION+"/commune/"+value;
  }

    $(id).attr("action", path);

}







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


// tootip

$(function () {
  $('[data-toggle="tooltip"]').tooltip()
})


  
