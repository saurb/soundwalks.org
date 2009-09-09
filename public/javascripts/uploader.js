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
		'hideButton': 			true,
		'auto': 				true,
		'multi': 				true,
		'width': 				'200px',
		'height': 				'80px',
		'simUploadLimit':		4, 
		'wmode': 				'transparent',
		'displayData': 			'speed',
		'onSelectOnce': function(event, data) {
			// Move the browse button to the top and shrink it, add upload status.
			if ($('#submit-new-sounds').length == 0) {
				$('#uploader').css({'text-align': 'left'});
				
				// Smaller browse button.
				$('#browse-button').css({'font-size': '1em'});
				$('#browse-button').attr('value', 'Find more sounds');
				
				// Upload status (complete/upload/fail)
				$('#upload-status').text('Uploading sounds . . .');
				
				// jquery.uploadify.js
				$('#file-uploader').fileUploadSettings('width', '160px');
				$('#file-uploader').fileUploadSettings('height', '40px');
				
				// Flash embed element.
				$('#file-uploaderUploader').attr('width', '160px');
				$('#file-uploaderUploader').attr('height', '40px');
				
				// Container.
				$('#file-uploader-container').css({'margin': '1em 0 0 0', 'width': '160px', 'height': '40px'});
				
				// Place a "save sounds" continue button at the bottom.
				$('#new_sound').append("<input type='button' class='button' name='submit' id='submit-new-sounds' value='Save sounds' disabled />");
				buttonify($('#submit-new-sounds'));
				$('#submit-new-sounds').click(function() {
					if (!$(this).attr('disabled')) {
						window.location = script;
					}
				});
			}
		},
		'onAllComplete': function(event, data) {
			$('#upload-status').text('Upload complete.');
			$('#submit-new-sounds').removeAttr('disabled');
		},
		'onAllCompleteWithErrors': function(event, data) {
			$('#upload-status').text('There were problems uploading some sounds.');
			$('#submit-new-sounds').removeAttr('disabled');
		},
		'onError': function(event, queueID, fileObj, errorObj) {},
		'onComplete': function(event, queueID, fileObj, response, data) {
			// Remove 'cancel' button, change status to "completed", and add attribute fields for time/location.
			eval('responseData = ' + response);
			
			div = $("#file-uploader" + queueID);
			div.find('.cancel .delete_button').text('');
			div.find('.cancel .delete_text').text('');
			div.find('.percentage').text(' - Completed');
			
			div.removeClass('fileUploadQueueItem-Active');
			div.addClass('fileUploadQueueItem-Complete');
			
			div.append("<div class='recorded_at'>Recorded: " + responseData.sound.recorded_at + "</div>");
			div.append("<div class='location'>Location: " + coordinates_text(responseData.sound.lat, 'lat') + " " + coordinates_text(responseData.sound.lng, 'lng') + "</div>");
			
			div.find('.fileUploadProgress').remove();
		}, 
		'onProgress': function(event, queueID, fileObj, data) {}
	});
	
	// Place the visible button and stylize it.
	$("#file-uploaderUploader").after("<input type='button' name='browse-button' id='browse-button' class='button' value='Find sounds'/>");
	buttonify($('#file-uploaderUploader'), $('#browse-button'));
});
