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
		'onSelect' : function(event, data) {
			disable_button($('#submit-new-sounds'));
		},
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
				$('#file-uploader').fileUploadSettings('width', '10em');
				$('#file-uploader').fileUploadSettings('height', '2.8em');
				
				// Flash embed element.
				$('#file-uploaderUploader').attr('width', '10em');
				//$('#file-uploaderUploader').attr('height', '2.8em');
				
				// Container.
				$('#file-uploader-container').css({'margin': '1em 0 0 0', 'width': '10em', 'height': '2.8em'});
				
				// Place a "save sounds" continue button at the bottom.
				$('#uploader').append("<input type='button' class='button-disabled' name='submit' id='submit-new-sounds' value='Continue' style='float: right; margin-right: 2em; margin-top: 1em; height: 2.8em' disabled='disabled' />");
			}
		},
		'onAllComplete': function(event, data) {
			$('#upload-status').text('Upload complete.');
			
			buttonify($('#submit-new-sounds'));
			
			$('#submit-new-sounds').click(function() {
				if (!$(this).attr('disabled')) {
					window.location = script;
				}
			});
		},
		'onAllCompleteWithErrors': function(event, data) {
			$('#upload-status').text('There were problems uploading some sounds.');
			
			buttonify($('#submit-new-sounds'));
			
			$('#submit-new-sounds').click(function() {
				if (!$(this).attr('disabled')) {
					window.location = script;
				}
			});
		},
		'onError': function(event, queueID, fileObj, errorObj) {},
		'onComplete': function(event, queueID, fileObj, response, data) {
			// Remove 'cancel' button, change status to "completed", and add attribute fields for time/location.
			eval('responseData = ' + response);
			
			div = $("#file-uploader" + queueID);
			div.find('.cancel .delete_button').text('');
			div.find('.cancel').text('Completed');
			div.find('.percentage').text('');
			
			div.removeClass('fileUploadQueueItem-Active');
			div.addClass('fileUploadQueueItem-Complete');
						
			//div.find('.progress').remove();
		}, 
		'onProgress': function(event, queueID, fileObj, data) {}
	});
	
	// Place the visible button and stylize it.
	$("#file-uploaderUploader").after("<input type='button' name='browse-button' id='browse-button' class='button' value='Find sounds'/>");
	buttonify($('#file-uploaderUploader'), $('#browse-button'));
});
