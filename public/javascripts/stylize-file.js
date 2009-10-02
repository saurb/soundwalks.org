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
	
	var button = document.createElement('button');
	button.setAttribute('type', 'submit');
	button.setAttribute('onclick', 'return false;');
	$(button).text('Browse');
	$(button).css({'vertical-align': 'middle'});
	$(button).mouseover(function() {$(this).addClass('button-hover')});
	$(button).mouseout(function() {$(this).removeClass('button-hover')});
	fakeFileUpload.appendChild(button);
	
	var x = document.getElementsByTagName('input');
	
	$('.fileinput input[type=file]').each(function() {
		$(this).addClass('file');
		
		//var clone = $(fakeFileUpload).clone();
		$(this).parent().append(fakeFileUpload);
		
		$(fakeFileUpload).find('input:first').val($(this).val());
		
		$(this).mouseover(function() {$(fakeFileUpload).find('button').trigger('mouseover')});
		$(this).mouseout(function() {$(fakeFileUpload).find('button').trigger('mouseout')});
		$(this).mousedown(function() {$(fakeFileUpload).find('button').trigger('mousedown')});
		
		$(this).change(function() {$(fakeFileUpload).find('input:first').val($(this).val())});
		$(this).mouseout(function() {$(fakeFileUpload).find('input:first').val($(this).val())});
		$(this).select(function() {$(fakeFileUpload).find('input:first').select()});
	});
});
