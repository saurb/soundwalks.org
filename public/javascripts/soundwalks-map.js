/*
 *	soundwalk-map.js
 *		2009-07-30
 *		Brandon Mechtley
 *		soundwalks.org
 *
 *	Displays a map containing soundwalk markers using the Google Maps API.
 *
 * 	Dependencies:
 *		(Google Maps API)
 *		lib/jquery.js
 */

var map_markers;

function makeMap() {
	if (GBrowserIsCompatible()) {
		var map = new GMap2(document.getElementById("soundwalks-map"));
		map.setUIToDefault();
		map.setMapType(G_HYBRID_MAP);
		addSoundwalks(map);
	}
}

function addSoundwalks(map) {
	function createMarker(point, index) {
		var letter = String.fromCharCode("A".charCodeAt(0) + index);
		var letteredIcon = new GIcon(baseIcon);
		letteredIcon.image = "http://www.google.com/mapfiles/marker" + letter + ".png";

		markerOptions = {icon: letteredIcon};
		var marker = new GMarker(point, markerOptions);

		GEvent.addListener(marker, "click", function() {
			marker.openInfoWindowHtml("Marker <b>" + letter + "</b>");
		})

		return marker;
	}
	
	var baseIcon = new GIcon(G_DEFAULT_ICON);
	baseIcon.shadow = "http://www.google.com/mapfiles/shadow50.png";
	baseIcon.iconSize = new GSize(20, 34);
	baseIcon.shadowSize = new GSize(37, 34);
	baseIcon.iconAnchor = new GPoint(9, 34);
	baseIcon.infoWindowAnchor = new GPoint(9, 2);
	
	map.checkResize();
	bounds = new GLatLngBounds();
	
	var i = 0;
	$('.stream-item').each(function() {
		var soundwalk = new Object();
		soundwalk.id = $(this).attr('id').split('-')[1];
		soundwalk.lat = $(this).attr('data-lat');
		soundwalk.lng = $(this).attr('data-lng');
		var point = new GLatLng(soundwalk.lat, soundwalk.lng);
		
		var marker = createMarker(point, i);
		i++;
		
		map.addOverlay(marker);
		bounds.extend(point);
	});
	
	map.setCenter(bounds.getCenter(), map.getBoundsZoomLevel(bounds));
}

$(document).ready(function() {
	alert(window.location.host)
	makeMap();
})