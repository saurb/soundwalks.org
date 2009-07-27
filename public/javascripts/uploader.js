function localize(number, direction) {
	if ((number < 0) && (direction == 'lng')) direction = 'W';
	else if ((number < 0) && (direction == 'lat')) direction = 'N';
	else if ((number > 0) && (direction == 'lng')) direction = 'E';
	else if ((number > 0) && (direction == 'lat')) direction = 'S';
	
	number = number < 0 ? -number : number;
	degrees = Math.floor(number);
	remainder = number - degrees;
	minutes = Math.floor(remainder * 60);
	remainder = Math.floor(remainder * 60) - minutes;
	seconds = Math.floor(remainder * 60);
	
	return degrees + '&deg;' + minutes + "'" + seconds + '&quot; ' + direction;
}

function saveTime(queueID, data, textStatus) {
	eval('responseData = ' + data);
	
	if (reponseData.result == 'success') {
		div = $("#file-uploader" + queueID);
		time = $("#file-uploader" + queueID + " .recorded_at");
		location = $("#file-uploader" + queueID + " .location");

		location.show();
		time.show();
		div.find('.input').hide();
	}
}

function editTime(queueID, response) {
	eval('responseData = ' + response);
	div = $("#file-uploader" + queueID);
	time = $("#file-uploader" + queueID + " .recorded_at");
	location = $("#file-uploader" + queueID + " .location");
	
	location.hide();
	time.hide();
	div.find('.input').show();
}

function editLocation(queueID) {
	
}

function initializeUploader(script, authenticity_token, session) {
	$(document).ready(function() {
		$("#file-uploader").fileUpload({
			'script': 				script,
			'scriptData': 			{
				'format': 				'json', 
				'authenticity_token': 	encodeURIComponent(authenticity_token),
				'_soundwalks_session': 	encodeURIComponent(session)
			},
			'uploader': 			'/flash/uploader.swf',
			'fileDataName': 		$('#file-uploader input:file')[0].name,
			'creationTimeString': 	'recorded_at',
			'fileDesc': 			'Sounds (*.wav)',
			'fileExt': 				'*.wav',
			'cancelImg': 			'/images/cancel.png',
			'hideButton': 			true,
			'auto': 				true,
			'multi': 				true,
			'width': 				'200px',
			'height': 				'80px',
			'wmode': 				'transparent',
			'displayData': 			'speed',
			'onSelectOnce': function(event, data) {
				if !$('#submit-new-sounds') {
					$('#uploader').css({'text-align': 'left'});
					$('#browse-button').css({'font-size': '1em'});
					$('#browse-button').attr('value', 'Find more sounds');
					$('#upload-status').text('Uploading sounds . . .');
					$('#file-uploader').fileUploadSettings('width', '160px');
					$('#file-uploader').fileUploadSettings('height', '40px');
					$('#file-uploaderUploader').attr('width', '160px');
					$('#file-uploaderUploader').attr('height', '40px');
					$('#file-uploader-container').css({'margin': '1em 0 0 0', 'width': '160px', 'height': '40px'});
								
					$('#new_sound').append("<input type='button' class='button' name='submit' id='submit-new-sounds' value='Save sounds' disabled />");
					$('#submit-new-sounds').click(function() {
						if (!$(this).attr('disabled')) {
							window.location = script;
						}
					});
					$('#submit-new-sounds').hover(
						function() {$(this).css({'background-color' : '#efefef', 'color' : '#bf3030', 'border' : '1px dashed #888888'});},
						function() {$(this).css({'background-color' : '#efefef', 'color' : 'black', 'border' : '1px dashed #888888'});}
					);

					$('#submit-new-sounds').mousedown(function() {$(this).css({'background-color' : '#eaf8f8', 'color' : '#bf3030', 'border' : '1px solid #223241'});});
					$('#submit-new-sounds').mouseup(function() {$(this).css({'background-color' : '#efefef', 'color' : 'black', 'border' : '1px dashed #888888'});});
				}
			},
			'onAllComplete': function(event, data) {
				$('#upload-status').text('Upload complete.');
				$('#submit-new-sounds').removeAttr('disabled');
			},
			'onAllCompleteWithErrors': function(event, data) {
				$('#upload-status').text('There were problems uploading some sounds.');
			},
			'onError': function(event, queueID, fileObj, errorObj) {
				alert(queueID + "\n" + fileObj.name + "\n" + fileObj.size + "\n" + fileObj.creationDate + "\n" + fileObj.modificationDate + "\n" + fileObj.type + "\n" + errorObj.type + "\n" + errorObj.text);
			},
			'onComplete': function(event, queueID, fileObj, response, data) {
				div = $("#file-uploader" + queueID);
				percentage = $("#file-uploader" + queueID + ' .percentage');
				cancel = $("#file-uploader" + queueID + ' .cancel');
				eval('responseData = ' + response);
				
				cancel.html("<a href=\"javascript:editTime('" + queueID + "', '" + escape(response) + "');\">Fix time</a> |\
				 	<a href='javascript:editLocation(\"" + queueID + "\", \"" + escape(response) + "\");'>Fix location</span>");
				percentage.text(' - Completed');
				div.removeClass('fileUploadQueueItem-Active');
				div.addClass('fileUploadQueueItem-Complete');
				div.append("<div class='recorded_at'>Recorded: " + responseData.sound.recorded_at + "</div>");
				div.append("<div class='location'>Location: " + localize(responseData.sound.lat, 'lat') + " " + localize(responseData.sound.lng, 'lng') + "</div>");
				div.find('.fileUploadProgress').remove();
				//div.append('<input style="visibility: hidden" type="text" name="sound_recorded_at_' + queueID + '" id="sound_recorded_at_' + queueID + '" value="'+ responseData.recorded_at + '" />\
					//<input style="visibility: hidden" type="submit" class="button" name="commit" id="commit_' + queueID + '" />');
				//div.find('.input').hide();
				
				//alert(responseData.location);
				
			//	$("#commit_" + queueID).click(function(event) {
				//	$.post(responseData.location, {'sound[recorded_at]' : $('#sound_recorded_at_' + queueID).attr('value')}, function(data, textStatus) {saveTime(queueID, data, textStatus)}, "json");
					
				//})
			}, 
			'onProgress': function(event, queueID, fileObj, data) {
				if (data.percentage == 100) {
					$("#" + $(this).attr('id') + queueID + ' .cancel .delete_button').text('');
					$("#" + $(this).attr('id') + queueID + ' .cancel .delete_text').text('');
					
					$("#" + $(this).attr('id') + queueID + " .percentage").text(' - Analyzing sound .&nbsp;.&nbsp;.');
					
					return false;
				} else
					return true;
			}
		});
	
		$("#file-uploaderUploader").after("<input type='button' name='browse-button' id='browse-button' class='button' value='Find sounds'/>");
	
		$("#file-uploaderUploader").hover(
			function() {$("#browse-button").css({'background-color' : '#efefef', 'color' : '#bf3030', 'border' : '1px dashed #888888'});},
			function() {$("#browse-button").css({'background-color' : '#efefef', 'color' : 'black', 'border' : '1px dashed #888888'});}
		);

		$("#file-uploaderUploader").mousedown(function() {
			$("#browse-button").css({'background-color' : '#eaf8f8', 'color' : '#bf3030', 'border' : '1px solid #223241'});
		});
	
		$("#file-uploaderUploader").mouseup(function() {
			$("#browse-button").css({'background-color' : '#efefef', 'color' : 'black', 'border' : '1px dashed #888888'});
		});
	});
}