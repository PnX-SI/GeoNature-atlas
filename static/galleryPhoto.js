
var compteurJson = 0;
var compteurGroup = 0;
var booleanGroup = false;

function generateHtmlPhoto(photos){
	var htmlPhoto = $('#insertPhotos').html()


	if (booleanGroup && compteurGroup <1){ 
		if(photos.length == 0){
			htmlPhoto = "<h3> Aucune photo pour ce groupe </h3>";
		}else{

		//$('#insertPhotos').fadeOut();
		htmlPhoto = "";
		}
	}
		if (compteurJson <= photos.length){
	  	 slicePhoto = photos.slice(compteurJson, compteurJson+22);
	  	 compteurJson = compteurJson + 22;
	  	 slicePhoto.forEach(function(photo){
			onePhoto = "<div class='col-lg-3 col-md-4 col-sm-6 col-xs-12 thumbnail-col photo-espece'> \
						  <div class='zoom-wrapper'> \
					 		<a href='"+photo.path+"' data-lightbox='imageSet' data-title='"+photo.title+"  &copy; "+photo.author+"'>\
								<div class='img-custom-medias' style='background-image:url("+photo.path+")' alt='"+photo.name+"'> </div> \
								<div class='stat-medias-hovereffet'> \
						    		 <h2 class='overlay-obs'>"+photo.name+" </br> </br>"+photo.nb_obs+" observations </h2>  <img src='"+configuration.URL_APPLICATION+"/static/images/eye.png'></div> </a> </div> </div> </div>"



			htmlPhoto += onePhoto;
			
		})
	 }
	$('#insertPhotos').html(htmlPhoto);
}

function scrollEvent(photos){
	  	 
}



$(document).ready(function(){
	$.ajax({
		  url: configuration.URL_APPLICATION+'/api/photosGallery',
		  dataType: "json",
		  beforeSend: function(){
		    // $('#loadingGif').attr("src", configuration.URL_APPLICATION+'/static/images/loading.svg')
		  }

		  }).done(function(photos) {
		  	console.log(photos);
		  	 generateHtmlPhoto(photos)

			console.log("hauteur"+ $(document).height())
		  	 $(window).scroll(function(){
		  	 	console.log($(window).scrollTop() + $(window).height());	
	  	  		if($(window).scrollTop() + $(window).height() >= $(document).height()*0.80){
	  	  			console.log("bottom")
	  	  			generateHtmlPhoto(photos)
	  	 		 }
	 			});
		  	
		});
})


$('.INPNgroup').click(function(){
	compteurJson = 0;
	booleanGroup = true;
	compteurGroup =0;
	group = $(this).attr('alt');
	$(window).off("scroll");
	$.ajax({
		  url: configuration.URL_APPLICATION+'/api/photoGroup/'+group,
		  dataType: "json",
		  beforeSend: function(){
		  	console.log("loasd"+group);
		    // $('#loadingGif').attr("src", configuration.URL_APPLICATION+'/static/images/loading.svg')
		  }

		  }).done(function(photos) {
		  	console.log(photos.length);
			generateHtmlPhoto(photos)
			compteurGroup +=1;

			$(window).scroll(function(){
	  	  		if($(window).scrollTop() + $(window).height() >= $(document).height()*0.80){
	  	  			generateHtmlPhoto(photos);
	  	 		 }
	 			});

		})
});

