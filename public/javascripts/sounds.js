/*
 *	sounds.js
 *		2009-07-30
 *		Brandon Mechtley
 *		soundwalks.org
 *
 *	Various helper functions for /soundwalks/:soundwalk_id/sounds/:id.
 *
 *	Dependencies:
 *		lib/jquery.js
 *		editable.js
 */

function cancelProp(e) {
	if (!e) var e = window.event;
	e.cancelBubble = true;
	if (e.stopPropagation) e.stopPropagation();	
}

$(document).ready(function() {
	// Edit-in-place behavior.
	$(".editable,.editable-link").each(function() {
		edit_callback = function() {}
		
		if ($(this).attr('data-edits') == 'user_tags')
			edit_callback = function(data) {
				if (!data.user_tags)
					$('[data-shows=user_tags]').html('Click here to add tags.')
				
				if (!data.all_tags)
					$('[data-shows=all_tags]').html('This sound has not been tagged yet.')
				else
					$('[data-shows=all_tags]').html(data.all_tags)
			}
		
		$(this).click(function() {
			$(this).editField(
				GetParameter($(this), 'data-url'),
				GetParameter($(this), 'data-object'),
				GetParameter($(this), 'data-edits'),
				GetParameter($(this), 'data-shows'),
				edit_callback
			);
		});
	});
	
	if (document.selection)
		document.selection.empty();
	else if (window.getSelection)
		window.getSelection().removeAllRanges();
});
