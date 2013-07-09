function addMarker(latLng){
  return new google.maps.Marker({
      position: latLng,
      map: map
  });
}

var map = new google.maps.Map(document.getElementById('map'), {
  center: new google.maps.LatLng(51.4, -2),
  mapTypeId: google.maps.MapTypeId.ROADMAP,
  zoom: 11
});

var infowindow = new google.maps.InfoWindow();
var marker, i;

$.ajax({
  url: "hotspots.json"
}).done(function ( locations ) {
  console.log(locations.length);
  var bounds = new google.maps.LatLngBounds();
  for (i = 0; i < locations.length; i++) {
    marker = addMarker(new google.maps.LatLng(locations[i][0][0], locations[i][0][1]));
    google.maps.event.addListener(marker, 'click', (function(marker, i) {
      return function() {
        var image_markup = '';
        for (var j = locations[i][2].length - 1; j >= 0; j--) {
          image_markup = image_markup + '<img width="150px" height="150px" src="' + locations[i][2][j] + '" />';
        }
        infowindow.setContent(image_markup);
        infowindow.open(map, marker);
      };
    })(marker, i));
    bounds.extend(marker.position);
  }
  if(locations.length > 1){
    map.fitBounds(bounds);
  }
});