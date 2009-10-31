/*
 *	sound-map.js
 *		2009-07-30
 *		Brandon Mechtley
 *		soundwalks.org
 *
 *	Displays a map containing sound markers and a soundwalk GPS trace
 *	using the Google Maps API.
 *
 * 	Dependencies:
 *		(Google Maps API)
 *		lib/jquery.js
 */

var map_markers;

function makeMap() {
	if (GBrowserIsCompatible()) {
		var map = new GMap2(document.getElementById("sounds-map"));
		map.setUIToDefault();
		map.setMapType(G_HYBRID_MAP);
		
		bounds = new GLatLngBounds();
		
		addTrace(map, bounds);
		addSounds(map, bounds);
		
		map.setCenter(bounds.getCenter(), map.getBoundsZoomLevel(bounds));
	}
}

function addTrace(map, bounds) {
	soundwalk_id = $("meta[name=soundwalk_id]").attr('content');

	$.getJSON('/soundwalks/' + soundwalk_id, null, function(data, textStatus) {
		trace = data.locations;
		
		points = new Array();
		
		for (i = 0; i < trace.length; i++) {
			point = new GLatLng(trace[i][1], trace[i][2]);
			
			points.push(point);
			bounds.extend(point);
		}
		
		map.addOverlay(new GPolyline(points, '#9DBF30', 4, '50'));
	});
	
	return bounds;
}

function addSounds(map, bounds) {
	var soundIcon = new GIcon(G_DEFAULT_ICON);
	soundIcon.image = "/images/marker.png";
	soundIcon.iconAnchor = new GPoint(24, 24);
	soundIcon.infoWindowAnchor = new GPoint(24, 24);
	soundIcon.iconSize = new GSize(48, 48);
	soundIcon.shadow = null;
	soundIcon.imageMap = [[0, 0], [48, 0], [48, 24], [0, 24]];
	markerOptions = {icon: soundIcon};
	var soundwalk_id = $('meta[name=soundwalk_id]').attr('content');
	
	$('.sound-record').each(function() {
		var sound = new Object();
		sound.id = $(this).attr('id').split('_')[1];
		sound.filename = $(this).find('[data-edits=filename]').attr('data-value');
		sound.duration = $(this).find('[data-edits=duration]').attr('data-value');
		sound.lat = parseFloat($(this).find('[data-edits=lat]').attr('data-value'));
		sound.lng = parseFloat($(this).find('[data-edits=lng]').attr('data-value'));
				
		sound.recorded_at = $(this).find('[data-edits=recorded_at]').text();
		
		var point = new GLatLng(sound.lat, sound.lng);
		var marker = new GMarker(point, markerOptions);
		
		GEvent.addListener(marker, "click", function() {
			marker.openInfoWindowHtml("<div class='marker-info'>\
				<h2><span class='meta'>" + sound.recorded_at + "(" + sound.duration + ")</span>" + sound.filename + "</h2>\
				<embed\
		      		type='application/x-shockwave-flash'\
		      		src='http://www.google.com/reader/ui/3247397568-audio-player.swf?audioUrl=/soundwalks/" + soundwalk_id + "/sounds/" + sound.id + ".wav'\
		      		style='width: 100%; height: 27px'\
		      		allowscriptaccess='never'\
		      		quality='best' \
		      		bgcolor='#ffffff'\
		      		wmode='window'\
		      		flashvars='playerMode=embedded'/>\
			</div>");
		});
		
		
		map.addOverlay(marker);
		bounds.extend(point);
	});
}

$(document).ready(function() {
	makeMap();
})