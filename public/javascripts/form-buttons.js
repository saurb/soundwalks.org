/*
 *	form-buttons.js
 *		2009-07-30
 *		Brandon Mechtley
 *		soundwalks.org
 *		
 *	Stylizes a button. Allows the events of one element
 *	to stylize another button as well.
 *
 *	Dependencies:
 *		lib/jquery.js
 */

function disable_button(button, target) {
	target = target || button;
	
	button.unbind();
	
	target.removeClass('button');
	target.addClass('button-disabled');
	
	target.attr('disabled', 'disabled');
}

$(document).ready(function() {
	$('button').mouseover(function(){$(this).addClass('button-hover')});
	$('button').mouseout(function(){$(this).removeClass('button-hover')});
});