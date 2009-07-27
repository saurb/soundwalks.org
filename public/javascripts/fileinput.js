var W3CDOM = (document.createElement && document.getElementsByTagName);

function initFileUploads() {
	if (!W3CDOM) return;
	
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
	
	for (var i = 0; i < x.length; i++) {
		if (x[i].type != 'file' || x[i].parentNode.className != 'fileinput') 
			continue;
		else {
			x[i].className = 'file';						// Make it invisible.
			
			var clone = fakeFileUpload.cloneNode(true);
			x[i].parentNode.appendChild(clone);
			
			x[i].relatedElement = clone.getElementsByTagName('input')[0];
			
			$(x[i]).mouseover(function() {$(clone).find('.button').trigger('mouseover');});
			$(x[i]).mouseout(function() {$(clone).find('.button').trigger('mouseout');});
			$(x[i]).mousedown(function() {$(clone).find('.button').trigger('mousedown');});
			$(x[i]).mouseup(function() {$(clone).find('.button').trigger('mouseup');});
			
			
			x[i].onchange = x[i].onmouseout = function () {
				this.relatedElement.value = this.value;
			}
			
			x[i].onselect = function () {
				this.relatedElement.select();
			}
		}
	}
}
