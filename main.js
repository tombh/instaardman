function addMarker(latLng){
  return new google.maps.Marker({
      position: latLng,
      map: map
  });
}

var map = new google.maps.Map(document.getElementById('map'), {
  center: new google.maps.LatLng(51.463393,-2.608702),
  mapTypeId: google.maps.MapTypeId.ROADMAP,
  zoom: 13
});

var infowindow = new google.maps.InfoWindow();
var markers = [];
var marker, i;
var showcase;
var sculptures;
var total = 0;

// Pass the click event to Google maps in order to display the popup of pics
function popup(e){
  var id = $(this).attr('data-gromit');
  google.maps.event.trigger(markers[id], 'click');
}

// Creates a marker on the map
function gMarker(marker, i) {
  return function() {
    var header = '<h2>' + sculptures[i].title + ' by ' + sculptures[i].artist + '</h2>';
    var count = locations[i][1] === null ? 0 : locations[i][1].length;
    if(count === 0){
      header = header + " (No images found yet)";
    }
    var image_markup = '';
    for (var j = count - 1; j >= 0; j--) {
      image_markup = image_markup +
        '<a target="_blank" href="' + locations[i][1][j][0] + '">' +
        '<img width="150px" height="150px" src="' +
        locations[i][1][j][1] + '" />' +
        '</a>';
    }
    infowindow.setContent(header + image_markup);
    infowindow.open(map, marker);
  };
}

function parseSculptures(result) {
  locations = result.images;
  for (i = 0; i < locations.length; i++) {
    marker = addMarker(new google.maps.LatLng(locations[i][0][0], locations[i][0][1]));
    markers.push(marker);
    total = total + locations[i][1].length;
    if(locations[i][1].length === 0){
      $('.unsnapped ul')
        .append(
          '<li><a href="#" data-gromit="' + i + '">' + sculptures[i].title + '</a></li>'
        );
      $('.unsnapped ul li a').bind('click', popup);
    }
    google.maps.event.addListener(marker, 'click', gMarker(marker, i));
  }
  $('.image_count').text(total);
  google.maps.event.trigger(markers[49], 'click');
}

$.ajax({
  url: "sculptures.json",
  dataType: "json"
}).done(function(result) {
  sculptures = result.sculptures;
  $.ajax({
    url: "images.json",
    dataType: "json"
  }).done(parseSculptures);
});
