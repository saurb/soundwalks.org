/*
 * editable.js
 *		2009-07-30
 * 		Brandon Mechtley
 *		soundwalks.org
 *
 *	Allows for in-place editing of fields.
 * 	Based off the rest_in_place Rails plugin (http://github.com/janv/rest_in_place) 
 *	Modifications include support for tab/arrow navigation in forms and filtering text
 *  (e.g. converting latitudes/longitudes and times to readable form, textilizing),
 *	conformance to HTML 5 (data- custom attributes), and displaying formatted fields 
 *	(e.g. times, longitude/latitude coordinates, etc.)
 *
 *	Dependencies:
 *		lib/jquery.js
 */

$.fn.tagName = function() {
    return this.get(0).tagName;
}

$.fn.editField = function(url, object, edits, shows, callback) {
	// Make an alias for this element so we can access it from other elements.
	var e = $(this);
	
	// If value = "" is present in the tag, edit it, otherwise edit the text inside the element.
	var oldEditText = e.attr('data-value') || '';
	var oldShowText = e.html();
	
	if (e.tagName() == 'DIV') {
		e.html('<form action="javascript:void(0)"><textarea>' + oldEditText + '</textarea></form>');
		tagType = 'textarea';
	} else {
		e.html('<form action="javascript:void(0)"><input type="text" value="' + oldEditText + '" /></form>');
		tagType = 'input'
	}
	
	// Focus on the input element and select all its contents.
	e.find(tagType)[0].focus();
	e.find(tagType)[0].select();
	
	// Only do this once until we deselet the input element.
	e.unbind('click');
	
	// When the input element loses focus, undo our changes and restore the callback.
	e.find(tagType).blur(function() {
		e.html(oldShowText);
		e.click(function() {e.editField(url, object, edits, shows, callback)});
	});
	
	// If this item is in a table, allow for tabbing/arrowing between cells.
	if (e.tagName() == 'TD') {
		e.find("input").keypress(function(event) {			
			if (event.keyCode == 9 || event.keyCode == 38 || event.keyCode == 40) {
				if (event.keyCode == 9) {
					cells = $('td.editable');
					var index = cells.index(e);
				
					if (event.shiftKey) next_index = (index == 0) ? (cells.length - 1) : index - 1;
					else next_index = (index + 1) % cells.length;
				
					next_cell = cells.get(next_index);
				} else if (event.keyCode == 38 || event.keyCode == 40) {
					rows = $('tr:has(.editable)');
					index = rows.index(e.parent());
				
					if (event.keyCode == 38) next_index = (index == 0) ? (rows.length - 1) : index - 1;
					else next_index = (index + 1) % rows.length;
				
					next_cell = $(rows.get(next_index)).find('[data-edits=' + edits + ']');
				}
				
				$(next_cell).editField(
					GetParameter($(next_cell), 'data-url'),
					GetParameter($(next_cell), 'data-object'),
					GetParameter($(next_cell), 'data-shows'),
					GetParameter($(next_cell), 'data-edits'),
					callback
				);
				
				return false;
			}
		});
	}
	
	// If the input contents are commited, update the record in the database.
	e.find("form").change(function() {
		var value = e.find(tagType).val();
		
		e.html("saving...");
		
		jQuery.ajax({
			"url" : url,
			"type" : "PUT",
			"dataType" : "json",
			"data" : (object ? (object + '['+ edits + ']=') : (edits + '='))
			 		+ encodeURIComponent(value) + 
					'&authenticity_token=' + encodeURIComponent($('meta[name=authenticity_token]').attr('content')),
			"beforeSend": function(xhr) {
				xhr.setRequestHeader("Accept", "application/javascript");
			},
			"success" : function(json) {
				data = json;//eval('(' + json + ')');
				
				if (shows) {
					if (object && data[object]) {
						e.html(data[object][shows])
						e.attr('data-value', data[object][edits])
					} else if (data[shows]) {
						e.html(data[shows])
						e.attr('data-value', data[edits])
					}
				}
				
				callback(data);
				
				e.click(function() {e.editField(url, object, edits, shows, callback)});
			}
		});
		
		return false;
	});
}

function GetParameter(e, param) {
	var value = false;
	e.parents().each(function() {value = value || $(this).attr(param)});
	value = e.attr(param) || value;
	return value;
}

