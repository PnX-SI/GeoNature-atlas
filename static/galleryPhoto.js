
var allPhotos = true;

$('.INPNgroup').click(function(){
	allPhotos = false;
	group = $(this).attr('alt');
	$.ajax({
		  url: configuration.URL_APPLICATION+'/api/photoGroup/'+group,
		  dataType: "json",
		  beforeSend: function(){
		    // $('#loadingGif').attr("src", configuration.URL_APPLICATION+'/static/images/loading.svg')
		  }

		  }).done(function(photos) {

		    var htmlPhoto="";
		    console.log(photos)
		    if (photos.length == 0) {

		    	htmlPhoto ="<h3> Aucune photo pour ce groupe"
		    }
		    else {
		    photos.forEach(function(photo){
				onePhoto = "<div class='col-lg-3 col-md-4 col-sm-6 col-xs-12 thumbnail-col photo-espece'> \
					<div class='hovereffect'> \
						<div class='img-responsive-logo' style='background-image:url("+photo.path+")' alt='"+photo.name+"'> </div> \
						<div class='overlay'> \
									<h2>"+photo.name+" \
									<br/>X observations </h2> \
									<a class='info' href='"+configuration.URL_APPLICATION+"/espece/"+photo.cd_ref+"'>Fiche espèce</a> \
						</div> \
					</div> \
				</div>"
				htmlPhoto += onePhoto;
		    })
		}


		    $('#insertPhotos').html(htmlPhoto);

		})
});


$(window).scroll(function() {
   if($(window).scrollTop() + $(window).height() == $(document).height() && allPhotos) {
   	console.log(allPhotos);
   	console.log("button");
   		$.ajax({
		  url: configuration.URL_APPLICATION+'/api/photoGallery',
		  dataType: "json",
		  beforeSend: function(){
		  }

		  }).done(function(photos) {
		    var htmlPhoto="";
		    console.log(photos)

		    photos.forEach(function(photo){
				onePhoto = "<div class='col-lg-3 col-md-4 col-sm-6 col-xs-12 thumbnail-col photo-espece'> \
					<div class='hovereffect'> \
						<div class='img-responsive-logo' style='background-image:url("+photo.path+")' alt='"+photo.name+"'> </div> \
						<div class='overlay'> \
									<h2>"+photo.name+" \
									<br/>X observations </h2> \
									<a class='info' href='"+configuration.URL_APPLICATION+"/espece/"+photo.cd_ref+"'>Fiche espèce</a> \
						</div> \
					</div> \
				</div>"
				htmlPhoto += onePhoto;
		    })


		    $('#insertPhotos').append(htmlPhoto);

		})

   }
});