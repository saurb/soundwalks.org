function update_all() {
	update_progress("/admin/poll.js?setting=tags_frequencies", "#frequencies");
	update_progress("/admin/poll.js?setting=tags_wordnet", "#wordnet");
	update_progress("/admin/poll.js?setting=tags_populate", "#populate")
	update_progress("/admin/poll.js?setting=tags_hypernyms", "#hypernyms")
}

$(document).ready(function() {setInterval('update_all()', 5000)});
