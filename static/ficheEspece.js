// Change tooltip and glyphycon for media block

var myBoolean = true;
$('#btn-more-audio').click(function(){
    $(this).find('span').toggleClass('glyphicon glyphicon-plus').toggleClass('glyphicon glyphicon-minus');
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
    $(this).find('span').toggleClass('glyphicon glyphicon-plus').toggleClass('glyphicon glyphicon-minus');
    if (myBoolean){
   		 $(this).attr('data-original-title', "Masquer les vidéos")
   		 myBooleanVideo = false;
   	}
   	else {
   		$(this).attr('data-original-title', "Afficher plus de vidéos")
   		myBooleanVideo = true;
   	}
});






$("[rel=tooltip]").tooltip({ placement: 'right'});

