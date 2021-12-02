// Change tooltip and glyphycon for media block

  var currentDate = new Date();
  YEARMAX = currentDate.getFullYear();

var myBoolean = true;
$('#btn-more-audio').click(function(){
    if (myBoolean){
   		 $(this).attr('data-original-title', "Masquer les enregistrements")
   		 myBoolean = false;
   	}
   	else {
   		$(this).attr('data-original-title', "Afficher plus d'enregistrements")
   		myBoolean = true;
   	}
});

var myBooleanVideo = true;
$('#btn-more-video').click(function(){
    if (myBoolean){
   		 $(this).attr('data-original-title', "Masquer les vidéos")
   		 myBooleanVideo = false;
   	}
   	else {
   		$(this).attr('data-original-title', "Afficher plus de vidéos")
   		myBooleanVideo = true;
   	}
});

$('.accordion-toggle').click(function(){
	$(this).find('span').toggleClass('fas fa-chevron-down').toggleClass('fas fa-chevron-up');
})


$("[rel=tooltip]").tooltip();



// Other information accordion


$('.collapse').on('show.bs.collapse', function () {
    $('.collapse.in').collapse('hide');
});

