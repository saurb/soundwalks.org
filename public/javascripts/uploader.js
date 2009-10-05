/*
 *	uploader.js
 *		2009-07-30
 *		Brandon Mechtley
 *		soundwalks.org
 *		
 *	Multiple-file uploader for sounds.
 *	Dependencies:
 *		lib/jquery.js
 *		lib/jquery.uploadify.js
 *		text-filters.js
 *		form-buttons.js
 */

$(document).ready(function() {
	// POST data.
	scriptData = new Object();
	scriptData['format'] = 'json';
	scriptData['authenticity_token'] = encodeURIComponent($('meta[name=authenticity_token]').attr('content'));
	scriptData[$('meta[name=session_key]').attr('content')] = encodeURIComponent($('meta[name=session]').attr('content'));
	
	// URL to upload sounds.
	script = $('meta[name=upload_path]').attr('content');
	
	// Main file uploader.
	$("#file-uploader").fileUpload({
		'script': 				script,
		'scriptData': 			scriptData,
		'uploader': 			'/flash/uploader.swf',
		'fileDataName': 		$('#file-uploader input:file')[0].name,
		'creationTimeString': 	'recorded_at',
		'fileDesc': 			'Sounds (*.wav)',
		'fileExt': 				'*.wav',
//		'hideButton': 			false,
		'auto': 				true,
		'multi': 				true,
		'simUploadLimit':		4, 
		'wmode': 				'transparent',
		'displayData': 			'speed',
		'onSelect' : function(event, data) {
			disable_button($('#submit-new-sounds'));
		},
		'onSelectOnce': function(event, data) {
			// Move the browse button to the top and shrink it, add upload status.
			$('#uploader').css({'text-align': 'left'});
			
			// Smaller browse button.
			$('#file-upload-button').html("Find more sounds");
			
			// Upload status (complete/upload/fail)
			$('#upload-status').text('Uploading sounds . . .');
			
			// Flash embed element.
			$('#file-uploader-container').css({'width': '11em'});
		},
		'onAllComplete': function(event, data) {
			$('#upload-status').html("\
				<p>Sounds added successfully.</p>\
				<p class='buttons' style='text-align: right'>\
					<a href='/soundwalks/" + $('meta[name=soundwalk_id]').attr('content') + "'>Continue</a>\
				</p>");
		},
		'onAllCompleteWithErrors': function(event, data) {
			$('#upload-status').html("\
				<p>Some sounds could not be added. Please try again.</p>\
				<p class='buttons' style='text-align: right'><a href='/soundwalks/" + $('meta[name=soundwalk_id]').attr('content') + "'>Continue</a></p>");
		},
		'onError': function(event, queueID, fileObj, errorObj) {
		},
		'onComplete': function(event, queueID, fileObj, response, data) {
			// Remove 'cancel' button, change status to "completed", and add attribute fields for time/location.
			eval('responseData = ' + response);
			
			div = $("#file-uploader" + queueID);
			div.find('.cancel').text('Completed');
			div.find('.percentage').text('');
			
			div.removeClass('fileUploadQueueItem-Active');
			div.addClass('fileUploadQueueItem-Complete');						
		}, 
		'onProgress': function(event, queueID, fileObj, data) {},
		'onMouseOut': function() {$("#file-upload-button").removeClass('button-hover')},
		'onMouseOver': function() {$("#file-upload-button").addClass('button-hover')}
	});
		
	// Place the visible button and stylize it.
	$("#file-uploader-container").append("<p class='buttons'><a id='file-upload-button' href='#'>Find sounds</a></p>");
});
