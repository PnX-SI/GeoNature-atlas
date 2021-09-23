$(".lazy").lazy({
          effect: "fadeIn",
          effectTime: 2000,
          threshold: 0
        });
$('[data-toggle="tooltip"]').tooltip();
$(document).ready(function(){
  $("#taxonInput").on("keyup", function() {
    var value = $(this).val().toLowerCase();
    $("#taxonList li").filter(function() {
      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
    });
  });
});