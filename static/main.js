$(document).ready(function() {
  $(window).keydown(function(event){
    if(event.keyCode == 13) {
      event.preventDefault();
      return false;
    }
  });
});




// generate the autocompletion with the list of item, the input id and the form id
autocompleteSearch = function(list, inputID, formID){

    // get the id of the hidden input
  temp = $(formID).find("input[type='hidden']").attr('id')
  hiddenID ='#'+temp
  // get the id of the text input
  temp = $(formID).find("input[type='text']").attr('id')
  textID = '#'+temp


$(inputID).autocomplete({


    source: function (request, response) {
    var results = $.ui.autocomplete.filter(list, request.term);
    response(results.slice(0, 20))},
         focus: function(event, ui) {
          $(textID).val(ui.item.label)
            return false;
        },
       select : function (event, ui){
          $(hiddenID).val(ui.item.value);
          $(formID).submit();
      return false;
        }
});

}

// complete dynamically the form action on search submit with the hidden value
function completeAction(id){

  var inputInter = $(id).find('input');
  hiddenInput = inputInter[1];
  value = hiddenInput.value;
    console.log(value);

  var path;

  if (id == "#searchFormTaxons"){
    path = "/atlas/espece/"+parseInt(value);
  }
  if (id == "#searchFormCommunes"){
    path = "/atlas/commune/"+value;
  }

    $(id).attr("action", path);

}



$( "#searchCommunes" ).focus(function() {
  autocompleteSearch(communesSearch, "#searchCommunes", "#searchFormCommunes")
});

$( "#searchTaxons" ).focus(function() {
   autocompleteSearch(listeTaxonsSearch, "#searchTaxons", "#searchFormTaxons");
});

