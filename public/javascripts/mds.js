function update_all() {
	update_progress("/admin/poll.js?setting=mds_load", "#mds_load");
}

$(document).ready(function() {setInterval('update_all()', 5000)});
