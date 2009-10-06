function update_value(url, span, text) {
	$.getJSON(url, function(data) {if (data.value) {$(span).html(text)} else {$(span).html('')}});
}

function update_status() {
	update_value("/admin/poll.js?setting=links_weights_acoustic", "#acoustic", "Acoustic weights are being computed.<br />");
	update_value("/admin/poll.js?setting=links_weights_semantic", "#semantic", "Semantic weights are being computed.<br />");
	update_value("/admin/poll.js?setting=links_weights_social", "#social", "Social weights are being computed.<br />");
	update_value("/admin/poll.js?setting=links_distances", "#distances", "Shortest-path distances are being computed.<br />");
}

$(document).ready(function() {setInterval('update_status()', 10000)});
