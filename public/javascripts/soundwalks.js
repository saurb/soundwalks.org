/*
 *	soundwalks.js
 *		2009-07-30
 *		Brandon Mechtley
 *		soundwalks.org
 *
 *	Various helper functions for /soundwalks/:id.
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
	// Allow users to check multiple sounds and delete them all at once.
	$('#delete-multiple-sounds').click(function() {
		form = $(this).parent().parent();
		
		$.post(
			form.attr('action'),
			form.serialize(),
			function(data, textStatus) {
				for (i = 0; i < data.sound_ids.length; i++) {
					$('#sound_' + data.sound_ids[i]).fadeOut('slow', function() {$(this).remove()});
					$('#sound_' + data.sound_ids[i]).removeAttr('checked');
				}
			},
			"json"
		);
	});
	
	// Edit-in-place behavior.
	edit_callback = function() {}
	
	$(".editable,.editable-link").click(function() {
		$(this).editField(
			GetParameter($(this), 'data-url'),
			GetParameter($(this), 'data-object'),
			GetParameter($(this), 'data-edits'),
			GetParameter($(this), 'data-shows'),
			edit_callback
		);
	});
	
	if (document.selection)
		document.selection.empty();
	else if (window.getSelection)
		window.getSelection().removeAllRanges();
});
