/*
 *	sound-map.js
 *		2009-07-30
 *		Brandon Mechtley
 *		soundwalks.org
 *
 *	Displays a map containing a single sound marker using the Google Maps API.
 *
 * 	Dependencies:
 *		(Google Maps API)
 *		lib/jquery.js
 */

function makeMap() {
	if (GBrowserIsCompatible()) {
		var map = new GMap2(document.getElementById("sound-map"));
		map.setUIToDefault();
		map.setMapType(G_HYBRID_MAP);
		addSound(map);		
	}
}

function addSound(map) {
	map.checkResize();
	bounds = new GLatLngBounds();
	
	var soundIcon = new GIcon(G_DEFAULT_ICON);
	soundIcon.image = "/images/marker.png";
	soundIcon.iconAnchor = new GPoint(24, 24);
	soundIcon.infoWindowAnchor = new GPoint(24, 24);
	soundIcon.iconSize = new GSize(48, 48);
	soundIcon.shadow = null;
	soundIcon.imageMap = [[0, 0], [24, 0], [24, 12], [0, 24]];
	
	markerOptions = {icon: soundIcon};

	var soundwalk_id = $('meta[name=soundwalk_id]').attr('content');
	
	var sound = new Object();
	sound.id = $('meta[name=sound_id]').attr('content');
	sound.lat = $('meta[name=sound_lat]').attr('content');
	sound.lng = $('meta[name=sound_lng]').attr('content');
	
	var point = new GLatLng(sound.lat, sound.lng);
	var marker = new GMarker(point, markerOptions);
		
	map.addOverlay(marker);
	bounds.extend(point);
	
	map.setCenter(bounds.getCenter(), map.getBoundsZoomLevel(bounds));
}

$(document).ready(function() {
	makeMap();
})