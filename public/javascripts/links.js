function update_value(url, span, text) {
	if ($(span + ' .progress_text').text() != "100.00%") {
		$.getJSON(url, function(data) {
			if (data['value'] != undefined) {
				$(span + ' .progress').css({'width' : (data['value'] * 100).toFixed(2).toString() + '%'})
				$(span + ' .progress_text').html((data['value'] * 100).toFixed(2).toString() + '%')
			} else {
				$(span + ' .progress').css({'width' : '0'});
				$(span + ' .progress_text').html("0.00%")
			}
		});
	}
}

function update_status() {
	update_value("/admin/poll.js?setting=links_weights_acoustic", "#acoustic");
	update_value("/admin/poll.js?setting=links_weights_semantic", "#semantic");
	update_value("/admin/poll.js?setting=links_weights_social", "#social");
	update_value("/admin/poll.js?setting=links_distances", "#distances");
}

$(document).ready(function() {setInterval('update_status()', 5000)});
