function update_value(url, span, text) {
	$.getJSON(url, function(data) {if (data['settings']['value'] != undefined) {$(span).html(text + data['settings']['value'].toString() + '<br />')} else {$(span).html('')}});
}

function update_status() {
	update_value("/admin/poll.js?setting=links_weights_acoustic", "#acoustic", "Acoustic weights: ");
	update_value("/admin/poll.js?setting=links_weights_semantic", "#semantic", "Semantic weights: ");
	update_value("/admin/poll.js?setting=links_weights_social", "#social", "Social weights: ");
	update_value("/admin/poll.js?setting=links_distances", "#distances", "Shortest-path distances: ");
}

$(document).ready(function() {setInterval('update_status()', 5000)});
