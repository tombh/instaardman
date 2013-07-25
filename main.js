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

var gromits;
$.ajax({
  url: "gromits.json"
}).done(function ( result ) {
  gromits = result;
});

$.ajax({
  url: "images.json"
}).done(function ( locations ) {
  var bounds = new google.maps.LatLngBounds();
  for (i = 0; i < locations.length; i++) {
    marker = addMarker(new google.maps.LatLng(locations[i][0][0], locations[i][0][1]));
    google.maps.event.addListener(marker, 'click', (function(marker, i) {
      return function() {
        var header = '<h2>' + gromits[i]['name'] + ' by ' + gromits[i]['artist'] + '</h2>';
        var count = locations[i][1].length;
        if(count == 0){
          header = header + " (No images found yet)";
        }
        var image_markup = '';
        for (var j = count - 1; j >= 0; j--) {
          image_markup = image_markup + '<img width="150px" height="150px" src="' + locations[i][1][j] + '" />';
        }
        infowindow.setContent(header + image_markup);
        infowindow.open(map, marker);
      };
    })(marker, i));
    bounds.extend(marker.position);
  }
  if(locations.length > 1){
    map.fitBounds(bounds);
  }
});