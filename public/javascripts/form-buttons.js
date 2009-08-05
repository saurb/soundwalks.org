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

function buttonify(button, target) {
	target = target || button;
	
	target.css({'background-color' : '#efefef', 'color' : 'black', 'border' : '1px dashed #888888'});
	
	button.hover(
		function() {target.css({'background-color' : '#efefef', 'color' : '#bf3030', 'border' : '1px dashed #888888'});},
		function() {target.css({'background-color' : '#efefef', 'color' : 'black', 'border' : '1px dashed #888888'});}
	);
	
	button.mousedown(function() {target.css({'background-color' : '#eaf8f8', 'color' : '#bf3030', 'border' : '1px solid #223241'});});
	button.mouseup(function() {target.css({'background-color' : '#efefef', 'color' : 'black', 'border' : '1px dashed #888888'});});
}

$(document).ready(function() {
	$(".button").each(function() {buttonify($(this))});
	$(".free-button").each(function() {buttonify($(this))});
	$(".small-button").each(function() {buttonify($(this))});
});
