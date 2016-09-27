
var compteurJson = 0;
var clearHtml = false;


function generateHtmlPhoto(photos){
	
	if (clearHtml){ 
		if(photos.length == 0){
			htmlPhoto = "<h3> Aucun résultat pour cette recherche </h3>";
		}else{
		htmlPhoto = "";
		}
	} else{
		htmlPhoto = $('#insertPhotos').html()
	}

		if (compteurJson <= photos.length){
	  	 slicePhoto = photos.slice(compteurJson, compteurJson+22);
	  	 compteurJson = compteurJson + 22;
	  		slicePhoto.forEach(function(photo){

	  		if (photo.title.indexOf("'") != -1){
	  			photo.title = photo.title.split("'").join("&#39;");
			}

			onePhoto = "<div class='col-lg-3 col-md-4 col-sm-6 col-xs-12 thumbnail-col photo-espece'> \
						  <div class='zoom-wrapper'> \
					 		<a href='"+photo.path+"' data-lightbox='imageSet' data-title='"+photo.title +" &copy; "+photo.author+"'>\
								<div class='img-custom-medias' style='background-image:url("+photo.path+")' alt='"+photo.name+"'> </div> \
								<div class='stat-medias-hovereffet'> \
						    		 <h2 class='overlay-obs'>"+photo.name+" </br> </br>"+photo.nb_obs+" observations </h2>  <img src='"+configuration.URL_APPLICATION+"/static/images/eye.png'></div> </a> </div> </div> </div>"



			htmlPhoto += onePhoto;
			
		})
	 }
	$('#insertPhotos').html(htmlPhoto);
}




function orderBynbObs(json){

	json.sort(function(a, b){
		if(a.nb_obs >= b.nb_obs)
			return -1
		if(a.nb_obs < b.nb_obs)
			return 1
		return 1
	})
}


function scrollEvent(photos){
	 $(window).scroll(function(){
	 	clearHtml = false;
	 	console.log(clearHtml);
	  	if($(window).scrollTop() + $(window).height() >= $(document).height()*0.80){
	  		generateHtmlPhoto(photos)
	 	}
	});
}



$(document).ready(function(){
	$.ajax({
		  url: configuration.URL_APPLICATION+'/api/photosGallery',
		  dataType: "json",
		  beforeSend: function(){
		    // $('#loadingGif').attr("src", configuration.URL_APPLICATION+'/static/images/loading.svg')
		  }

          // Count and display number of photos
		  }).done(function(photos) {
		  	 generateHtmlPhoto(photos);
		  	 $('#nbPhotos').html(photos.length + " photos");
		  	 scrollEvent(photos);

		  	$('#allGroups').click(function(){
				clearHtml = true;
				compteurJson = 0;
				$(window).off("scroll");
				generateHtmlPhoto(photos);
				$('#group').html("");
				$('#nbPhotos').html(photos.length + " photos");
				scrollEvent(photos);
			})

		  	$('#sort').click(function(){
		  		orderBynbObs(photos);
	  			clearHtml = true;
				compteurJson=0;
				generateHtmlPhoto(photos);

		  	})

		  	// search a photo by the name of the species
			$('#searchPhotos').on('keyup', function() {
				$(window).off("scroll");
				keyString = this.value;
				filterJsonPhoto = photos.filter(function(obj){
					name = obj.name.toLowerCase();
					title = obj.title.toLowerCase();
					author = obj.author.toLowerCase();
					return (name.includes(keyString.toLowerCase()) || title.includes(keyString.toLowerCase()) || author.includes(keyString.toLowerCase()))
				})

				clearHtml = true; compteurJson=0;
				generateHtmlPhoto(filterJsonPhoto);
				$('#nbPhotos').html(filterJsonPhoto.length + " photos");
				scrollEvent(filterJsonPhoto)
			});

		});

})


$('.INPNgroup').click(function(){
	compteurJson = 0;
	clearHtml = true;
	group = $(this).attr('alt');
	$(window).off("scroll");
	$.ajax({
		  url: configuration.URL_APPLICATION+'/api/photoGroup/'+group,
		  dataType: "json",
		  beforeSend: function(){
		    // $('#loadingGif').attr("src", configuration.URL_APPLICATION+'/static/images/loading.svg')
		    }
            
		  // Count and display number of photos in 1 group
		  }).done(function(photos) {
				generateHtmlPhoto(photos);
				$('#group').html("("+group+")");
				$('#nbPhotos').html(photos.length + " photos");
				clearHtml = false;
				
				scrollEvent(photos)
	 		});

});

