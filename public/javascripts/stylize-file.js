/*
 * 	stylize-file.js
 *		2009-07-30
 *		Brandon Mechtley
 *		soundwalks.org
 *
 *	Allows CSS-like styling of a form field by hiding the real form field
 *	and putting a replacement button and text field on top of it. Based on
 *	method presented by Peter-Paul Koch (http://www.quirksmode.org/dom/
 *	inputfile.html), originally created by Michael McGrady.
 *
 *	Dependencies:
 *		lib/jquery.js
 *		form-buttons.js
 */

$(document).ready(function() {	
	var fakeFileUpload = document.createElement('div');
	fakeFileUpload.className = 'fakefile';
	
	var input = document.createElement('input');
	input.className = 'actualfile';
	fakeFileUpload.appendChild(input);
	
	var button = document.createElement('input');
	button.type = 'submit';
	button.className = 'button';
	button.value = "Browse";
	button.setAttribute('onclick', 'return false;');

	fakeFileUpload.appendChild(button);
	
	var x = document.getElementsByTagName('input');
	
	$('.fileinput input[type=file]').each(function() {
		$(this).addClass('file');
		
		var clone = $(fakeFileUpload).clone();
		$(this).parent().append(clone);
		
		$(clone).find('input:first').val($(this).val());
		
		buttonify($(clone).find('.button'));
		
		$(this).mouseover(function() {$(clone).find('.button').trigger('mouseover');});
		$(this).mouseout(function() {$(clone).find('.button').trigger('mouseout');});
		$(this).mousedown(function() {$(clone).find('.button').trigger('mousedown');});
		$(this).mouseup(function() {$(clone).find('.button').trigger('mouseup');});
		
		$(this).change(function() {$(clone).find('input:first').val($(this).val())});
		$(this).mouseout(function() {$(clone).find('input:first').val($(this).val())});
		$(this).select(function() {$(clone).find('input:first').select()});
	});
});
