function update_all() {
	update_progress("/admin/poll.js?setting=links_weights_acoustic", "#acoustic");
	update_progress("/admin/poll.js?setting=links_weights_semantic", "#semantic");
	update_progress("/admin/poll.js?setting=links_weights_social", "#social");
	update_progress("/admin/poll.js?setting=links_distances", "#distances");
}

$(document).ready(function() {setInterval('update_all()', 5000)});
