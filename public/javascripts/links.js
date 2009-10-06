function update_value(url, span, text) {
	$.getJSON(url, function(data) {if (data.value) {$(span).html(text)}});
}

function update_status() {
	update_value("/admin/poll.js?setting=links_weights_acoustic", "#acoustic", text);
	update_value("/admin/poll.js?setting=links_weights_semantic", "#semantic", text);
	update_value("/admin/poll.js?setting=links_weights_social", "#social", text);
	update_value("/admin/poll.js?setting=links_distances", "#distances", text);
}

$(document).ready(function{setInterval('update_status()', 5000)});
