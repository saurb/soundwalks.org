var interval_a = -1;
var interval_b = -1;
var interval_c = -1;
var interval_d = -1;

function update_value(url, span, interval) {
	eval("clearInterval(interval_" + interval + ")");
	
	if ($(span + '.progress_text').html() != "100.00%") {
		$.getJSON(url, function(data) {
			if (data['settings']['value'] != undefined) {
				$(span + ' .progress').css({'width' : (data['settings']['value'] * 100).toFixed(2).toString() + '%'})
				$(span + ' .progress_text').html((data['settings']['value'] * 100).toFixed(2).toString() + '%')
			} else {
				$(span + ' .progress').css({'width' : '0'});
				$(span + ' .progress_text').html("0%")
			}
			
			eval("interval_" + interval + " = setInterval('update_value(url, span, interval));");
		});
	}
}

$(document).ready(function() {
	interval_a = setInterval('update_value("/admin/poll.js?setting=links_weights_acoustic", "#acoustic", "a")', 5000);
	interval_b = setInterval('update_value("/admin/poll.js?setting=links_weights_semantic", "#semantic", "b")', 5000);
	interval_c = setInterval('update_value("/admin/poll.js?setting=links_weights_social", "#social", "c")', 5000);
	interval_d = setInterval('update_value("/admin/poll.js?setting=links_distances", "#distances", "d")', 5000);
});
